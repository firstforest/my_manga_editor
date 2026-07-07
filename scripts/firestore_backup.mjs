// Firestore 全ドキュメントのバックアップツール。
//
// 使い方:
//   node scripts/firestore_backup.mjs <dev|prod> [出力先ディレクトリ]
//   (mise タスク: `mise run backup` / `mise run backup-prod`)
//
// 仕組み: Firestore REST API でルートコレクションから再帰的に全ドキュメントを
//   ダンプする。gcloud のマネージドエクスポート (GCS バケット必須・Blaze プラン前提)
//   を使わずローカルに保存できるのが利点。認証は ADC (scripts/config.mjs と同じ)。
//
// 出力:
//   <出力先>/firestore.jsonl  … 1行 = 1ドキュメント。Firestore REST の typed value
//                               (integerValue 等) をそのまま保存するため無劣化。
//   <出力先>/meta.json        … プロジェクト ID・取得日時・件数
//
// 出力先を省略すると backups/<env>-<YYYYMMDD-HHMMSS>/ に保存する。
// 復元は scripts/firestore_restore.mjs を使う。
//
// 注意: 「存在しないが子コレクションを持つドキュメント」(missing doc) も辿るので、
//   サブコレクション内のドキュメントも漏れなくダンプされる。

import { mkdirSync, writeFileSync, appendFileSync } from 'node:fs';
import { join } from 'node:path';
import {
  resolveProject,
  getAuthHeaders,
  restBase,
  documentsRoot,
  fail,
  adcHint,
} from './firestore_common.mjs';

function timestampSlug(date) {
  const pad = (n) => String(n).padStart(2, '0');
  return (
    `${date.getFullYear()}${pad(date.getMonth() + 1)}${pad(date.getDate())}` +
    `-${pad(date.getHours())}${pad(date.getMinutes())}${pad(date.getSeconds())}`
  );
}

async function main() {
  const [env, outDirArg] = process.argv.slice(2);
  const project = resolveProject(env);

  const startedAt = new Date();
  const outDir = outDirArg ?? join('backups', `${env}-${timestampSlug(startedAt)}`);
  const jsonlPath = join(outDir, 'firestore.jsonl');

  const headers = await getAuthHeaders();
  const base = restBase(project);

  async function api(url, init) {
    const res = await fetch(url, { ...init, headers: { ...headers, ...init?.headers } });
    if (!res.ok) fail(`${init?.method ?? 'GET'} ${url} failed: ${res.status} ${await res.text()}`);
    return res.json();
  }

  // parentPath: '' (ルート) または 'coll/doc' 形式の相対パス
  async function listCollectionIds(parentPath) {
    const url = `${base}${parentPath ? `/${parentPath}` : ''}:listCollectionIds`;
    const ids = [];
    let pageToken;
    do {
      const body = { pageSize: 300, ...(pageToken ? { pageToken } : {}) };
      const json = await api(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      ids.push(...(json.collectionIds ?? []));
      pageToken = json.nextPageToken;
    } while (pageToken);
    return ids;
  }

  // showMissing=true で「存在しないが子を持つドキュメント」も列挙する
  // (missing doc は name のみで fields を持たない)。
  async function listDocuments(collectionPath) {
    const docs = [];
    let pageToken;
    do {
      const params = new URLSearchParams({ pageSize: '300', showMissing: 'true' });
      if (pageToken) params.set('pageToken', pageToken);
      const json = await api(`${base}/${collectionPath}?${params}`);
      docs.push(...(json.documents ?? []));
      pageToken = json.nextPageToken;
    } while (pageToken);
    return docs;
  }

  mkdirSync(outDir, { recursive: true });
  writeFileSync(jsonlPath, '');

  const rootPrefix = `${documentsRoot(project)}/`;
  let dumped = 0;

  async function dumpUnder(parentPath) {
    for (const collectionId of await listCollectionIds(parentPath)) {
      const collectionPath = parentPath ? `${parentPath}/${collectionId}` : collectionId;
      for (const doc of await listDocuments(collectionPath)) {
        const relPath = doc.name.slice(rootPrefix.length);
        if (doc.fields != null || doc.createTime != null) {
          appendFileSync(jsonlPath, `${JSON.stringify(doc)}\n`);
          dumped += 1;
          if (dumped % 100 === 0) console.log(`  ... ${dumped} documents`);
        }
        await dumpUnder(relPath);
      }
    }
  }

  console.log(`[${env}] ${project} → ${outDir}`);
  await dumpUnder('');

  writeFileSync(
    join(outDir, 'meta.json'),
    `${JSON.stringify(
      {
        env,
        project,
        exportedAt: startedAt.toISOString(),
        documentCount: dumped,
        format: 'firestore-rest-jsonl-v1',
      },
      null,
      2,
    )}\n`,
  );

  console.log(`Done. ${dumped} documents dumped to ${jsonlPath}`);
}

main().catch(adcHint);
