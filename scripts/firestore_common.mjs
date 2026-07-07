// firestore_backup.mjs / firestore_restore.mjs の共通部品。
//
// 認証は config.mjs と同じ ADC (Application Default Credentials) 方式。
// 事前に `gcloud auth application-default login` を一度実行しておくこと。
// スクリプト単体で使うものではない。

import { createInterface } from 'node:readline/promises';
import { stdin, stdout } from 'node:process';
import { GoogleAuth } from 'google-auth-library';

export const PROJECTS = {
  dev: 'my-manga-editor-dev',
  prod: 'my-manga-editor',
};

const SCOPES = ['https://www.googleapis.com/auth/datastore'];

export function fail(message) {
  console.error(`Error: ${message}`);
  process.exit(1);
}

export function resolveProject(env) {
  const project = PROJECTS[env];
  if (!project) fail(`Unknown env: ${env ?? '(none)'} (use dev or prod)`);
  return project;
}

export async function confirm(question) {
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

export async function getAuthHeaders() {
  const auth = new GoogleAuth({ scopes: SCOPES });
  const { token } = await (await auth.getClient()).getAccessToken();
  if (!token) fail('Failed to obtain access token.');
  return { Authorization: `Bearer ${token}` };
}

// `projects/<p>/databases/(default)/documents` (REST のベースパス)
export function documentsRoot(project) {
  return `projects/${project}/databases/(default)/documents`;
}

export function restBase(project) {
  return `https://firestore.googleapis.com/v1/${documentsRoot(project)}`;
}

export function adcHint(err) {
  const msg = err?.message ?? String(err);
  if (/credential|default credentials|UNAUTHENTICATED|invalid_grant|could not load/i.test(msg)) {
    fail(`${msg}\nHint: run \`gcloud auth application-default login\` (ADC).`);
  }
  fail(msg);
}
