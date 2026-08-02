// Firestore `config/app` ドキュメントの読み書きツール。
//
// 使い方:
//   node scripts/config.mjs <dev|prod> get
//   node scripts/config.mjs <dev|prod> set <key> <value>
//   node scripts/config.mjs <dev|prod> notice "<message>"   アプリ内お知らせを出す
//   node scripts/config.mjs <dev|prod> notice-clear         お知らせを取り下げる
//
// notice は noticeMessage と noticeId をまとめて書く。noticeId には実行時刻が入り、
// 本文を変えるたびに変わるので、前のお知らせを閉じた利用者にも新しい本文が表示される。
//
// 仕組み: アクセストークンを取り Firestore REST API を直接叩く (組み込み fetch)。
//   config は security rules で write:false だが、IAM 権限を持つ OAuth トークンで
//   REST を呼ぶと rules はバイパスされる (rules は Firebase クライアント SDK にのみ適用)。
//   そのため firebase-admin SDK は不要で、トークン取得に google-auth-library だけ使う。
//
// 認証: Application Default Credentials (ADC) を使う。
//   事前に `gcloud auth application-default login` を一度実行しておくこと。
//   (firebase CLI の `firebase login` とは別物なので注意)
//   サービスアカウントキーで動かしたい場合は、環境変数
//   GOOGLE_APPLICATION_CREDENTIALS にキーの json パスを指定する
//   (google-auth-library が ADC 探索の一環として参照する)。
//
// set 時は常に変更前→後を表示し updatedAt (serverTimestamp) を記録する。
// 確認 (y/N) を挟むのは、prod への書き込み or 未知フィールド (typo 疑い) のとき。

import { createInterface } from 'node:readline/promises';
import { stdin, stdout } from 'node:process';
import { GoogleAuth } from 'google-auth-library';

const PROJECTS = {
  dev: 'my-manga-editor-dev',
  prod: 'my-manga-editor',
};

const DOC_PATH = 'config/app';
const SCOPES = ['https://www.googleapis.com/auth/datastore'];

// 既知フィールドの検証。typo によるサイレント失敗や、型崩れによるクライアント側
// CastError (例: minSupportedBuildNumber が string 化して `as num?` で例外) を防ぐ。
const NOTICE_MAX_LENGTH = 300;

const FIELD_VALIDATORS = {
  // バージョンゲートの最小サポートビルド番号。非負整数のみ。
  minSupportedBuildNumber: (raw) => {
    if (!/^\d+$/.test(raw)) {
      fail(
        `minSupportedBuildNumber must be a non-negative integer, got: ${JSON.stringify(raw)}`,
      );
    }
    return Number(raw);
  },
  // アプリ内お知らせの本文。空文字は「お知らせなし」。
  // バナーは 4 行までしか表示しないので長文は入れない。
  noticeMessage: (raw) => {
    if (raw.length > NOTICE_MAX_LENGTH) {
      fail(`noticeMessage must be <= ${NOTICE_MAX_LENGTH} characters, got: ${raw.length}`);
    }
    return raw;
  },
  // お知らせの識別子。利用者の「閉じた」状態はこの値で記録される。
  noticeId: (raw) => raw,
};

function fail(message) {
  console.error(`Error: ${message}`);
  process.exit(1);
}

function usage() {
  console.error(
    [
      'Usage:',
      '  node scripts/config.mjs <dev|prod> get',
      '  node scripts/config.mjs <dev|prod> set <key> <value>',
      '  node scripts/config.mjs <dev|prod> notice "<message>"   # アプリ内お知らせを出す',
      '  node scripts/config.mjs <dev|prod> notice-clear         # お知らせを取り下げる',
    ].join('\n'),
  );
  process.exit(1);
}

async function confirm(question) {
  // 非対話シェル (パイプ / リダイレクト) では確認を取れないので安全側に倒す。
  if (!stdin.isTTY) {
    console.error('Refusing to proceed without confirmation in a non-interactive shell.');
    return false;
  }
  const rl = createInterface({ input: stdin, output: stdout });
  try {
    const answer = (await rl.question(`${question} [y/N] `)).trim().toLowerCase();
    return answer === 'y' || answer === 'yes';
  } finally {
    rl.close();
  }
}

async function getToken() {
  // ADC で認証する。google-auth-library が gcloud の ADC や
  // GOOGLE_APPLICATION_CREDENTIALS を探索してくれる。
  const auth = new GoogleAuth({ scopes: SCOPES });
  const { token } = await (await auth.getClient()).getAccessToken();
  if (!token) fail('Failed to obtain access token.');
  return token;
}

// Firestore REST の typed value <-> プレーン値。必要な型だけ扱う。
function decodeValue(v) {
  if (v == null) return null;
  if ('integerValue' in v) return Number(v.integerValue);
  if ('doubleValue' in v) return v.doubleValue;
  if ('booleanValue' in v) return v.booleanValue;
  if ('stringValue' in v) return v.stringValue;
  if ('timestampValue' in v) return v.timestampValue;
  if ('nullValue' in v) return null;
  if ('mapValue' in v) return decodeFields(v.mapValue.fields);
  if ('arrayValue' in v) return (v.arrayValue.values ?? []).map(decodeValue);
  return v;
}

function decodeFields(fields) {
  return Object.fromEntries(
    Object.entries(fields ?? {}).map(([k, v]) => [k, decodeValue(v)]),
  );
}

function encodeValue(v) {
  if (typeof v === 'boolean') return { booleanValue: v };
  if (typeof v === 'number') {
    return Number.isInteger(v) ? { integerValue: String(v) } : { doubleValue: v };
  }
  return { stringValue: String(v) };
}

async function main() {
  const [env, action, ...rest] = process.argv.slice(2);

  const project = PROJECTS[env];
  if (!project) fail(`Unknown env: ${env ?? '(none)'} (use dev or prod)`);
  if (!['get', 'set', 'notice', 'notice-clear'].includes(action)) usage();

  const token = await getToken();
  const headers = { Authorization: `Bearer ${token}` };
  const docsBase = `https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents`;
  const docUrl = `${docsBase}/${DOC_PATH}`;
  const docName = `projects/${project}/databases/(default)/documents/${DOC_PATH}`;

  // 現在値を取得 (未作成なら 404 → null)。
  async function getDoc() {
    const res = await fetch(docUrl, { headers });
    if (res.status === 404) return null;
    if (!res.ok) fail(`GET ${DOC_PATH} failed: ${res.status} ${await res.text()}`);
    return (await res.json()).fields ?? {};
  }

  if (action === 'get') {
    const fields = await getDoc();
    console.log(`[${env}] ${project} / ${DOC_PATH}`);
    console.log(fields ? JSON.stringify(decodeFields(fields), null, 2) : '(document does not exist)');
    return;
  }

  // 書き込む内容を action ごとに組み立てる。
  const updates = {}; // { フィールド名: 新しい値 }
  const unknownKeys = []; // 検証できなかった (= 既知でない) フィールド名
  if (action === 'set') {
    const [key, value] = rest;
    if (key == null || value == null) usage();
    const validator = FIELD_VALIDATORS[key];
    if (!validator) unknownKeys.push(key);
    updates[key] = validator ? validator(value) : value; // 未知 key は文字列のまま
  } else if (action === 'notice') {
    const [message] = rest;
    if (message == null || message.trim() === '') usage();
    updates.noticeMessage = FIELD_VALIDATORS.noticeMessage(message);
    // 本文を変えたら ID も変わるようにして、前のお知らせを閉じた人にも見せ直す。
    updates.noticeId = new Date().toISOString();
  } else {
    // notice-clear: 本文と ID を空にして取り下げる
    updates.noticeMessage = '';
    updates.noticeId = '';
  }

  const fields = await getDoc();
  console.log(`[${env}] ${project} / ${DOC_PATH}`);
  for (const [k, v] of Object.entries(updates)) {
    const before = fields && k in fields ? decodeValue(fields[k]) : undefined;
    console.log(`  ${k}: ${JSON.stringify(before)} -> ${JSON.stringify(v)}`);
  }

  // prod への書き込み、または未知フィールド (typo の可能性) は確認を挟む。
  if (env === 'prod' || unknownKeys.length > 0) {
    for (const k of unknownKeys) {
      console.warn(`Warning: '${k}' is not a known field of ${DOC_PATH} (possible typo).`);
    }
    const ok = await confirm(env === 'prod' ? 'Write this change to PROD?' : 'Write this change?');
    if (!ok) {
      console.log('Aborted.');
      return;
    }
  }

  // updateMask で対象フィールドだけ merge し、updatedAt は serverTimestamp で記録。
  const body = {
    writes: [
      {
        update: {
          name: docName,
          fields: Object.fromEntries(
            Object.entries(updates).map(([k, v]) => [k, encodeValue(v)]),
          ),
        },
        updateMask: { fieldPaths: Object.keys(updates) },
        updateTransforms: [{ fieldPath: 'updatedAt', setToServerValue: 'REQUEST_TIME' }],
      },
    ],
  };
  const res = await fetch(`${docsBase}:commit`, {
    method: 'POST',
    headers: { ...headers, 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
  if (!res.ok) fail(`commit failed: ${res.status} ${await res.text()}`);
  console.log('Done.');
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    const msg = err?.message ?? String(err);
    if (/credential|default credentials|UNAUTHENTICATED|invalid_grant|could not load/i.test(msg)) {
      fail(
        `${msg}\nHint: run \`gcloud auth application-default login\` (ADC), ` +
          'or place a service account key in the key dir.',
      );
    }
    fail(msg);
  });
