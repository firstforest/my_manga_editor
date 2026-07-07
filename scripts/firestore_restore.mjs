// Firestore バックアップの復元ツール (scripts/firestore_backup.mjs の対)。
//
// 使い方:
//   node scripts/firestore_restore.mjs <dev|prod> <バックアップディレクトリ or .jsonl> [--only <パス接頭辞>] [--yes]
//   例: node scripts/firestore_restore.mjs prod backups/prod-20260706-120000
//   例: node scripts/firestore_restore.mjs dev backups/prod-20260706-120000 --only mangas/abc123
//       (prod のバックアップを dev に流し込んで中身を検証する、なども可能)
//
// 仕組み: jsonl の各ドキュメントを Firestore REST の :commit で書き戻す
//   (500 write/コミットずつ)。ドキュメント名のプロジェクト部分は復元先に
//   合わせて書き換えるので、別プロジェクトへの復元もできる。
//
// 動作の性質 (重要):
//   - バックアップに含まれるドキュメントを「丸ごと上書き or 再作成」する
//   - バックアップ後に**新規作成**されたドキュメントは削除しない (残る)
//   - つまり「完全なポイントインタイム復元」ではなく「上書き復元」。
//     消えたデータを戻す用途には十分で、余計な削除をしない分安全側に倒している
//   - --only で相対パス接頭辞 (例: mangas/abc123) を指定すると部分復元できる
//
// 認証: ADC (scripts/config.mjs と同じ)。書き込みは常に確認プロンプトを挟む。
//   --yes は確認を省略する (非対話の自動リカバリ用。対話できるときは使わないこと)。

import { readFileSync, existsSync, statSync } from 'node:fs';
import { join } from 'node:path';
import {
  resolveProject,
  getAuthHeaders,
  restBase,
  documentsRoot,
  confirm,
  fail,
  adcHint,
} from './firestore_common.mjs';

const BATCH_SIZE = 500; // Firestore :commit の上限

function usage() {
  console.error(
    'Usage: node scripts/firestore_restore.mjs <dev|prod> <backup-dir-or-jsonl> [--only <path-prefix>]',
  );
  process.exit(1);
}

async function main() {
  const args = process.argv.slice(2);
  const yesIndex = args.indexOf('--yes');
  const skipConfirm = yesIndex >= 0;
  if (skipConfirm) args.splice(yesIndex, 1);
  const onlyIndex = args.indexOf('--only');
  const only = onlyIndex >= 0 ? args[onlyIndex + 1] : null;
  if (onlyIndex >= 0) {
    if (!only) usage();
    args.splice(onlyIndex, 2);
  }
  const [env, sourceArg] = args;
  if (!sourceArg) usage();
  const project = resolveProject(env);

  const jsonlPath =
    existsSync(sourceArg) && statSync(sourceArg).isDirectory()
      ? join(sourceArg, 'firestore.jsonl')
      : sourceArg;
  if (!existsSync(jsonlPath)) fail(`Backup file not found: ${jsonlPath}`);

  const lines = readFileSync(jsonlPath, 'utf8').split('\n').filter((l) => l.trim() !== '');
  const docs = lines.map((line, i) => {
    try {
      return JSON.parse(line);
    } catch {
      return fail(`Invalid JSON at ${jsonlPath}:${i + 1}`);
    }
  });

  // ドキュメント名を復元先プロジェクトに合わせて書き換える。
  // name: projects/<p>/databases/(default)/documents/<relPath>
  const targetRoot = documentsRoot(project);
  const restorable = [];
  for (const doc of docs) {
    const match = doc.name?.match(/^projects\/[^/]+\/databases\/[^/]+\/documents\/(.+)$/);
    if (!match) fail(`Unexpected document name in backup: ${doc.name}`);
    const relPath = match[1];
    if (only && relPath !== only && !relPath.startsWith(`${only}/`)) continue;
    restorable.push({ name: `${targetRoot}/${relPath}`, relPath, fields: doc.fields ?? {} });
  }

  if (restorable.length === 0) {
    fail(only ? `No documents match --only ${only}` : 'Backup contains no documents.');
  }

  console.log(`[${env}] restore target: ${project}`);
  console.log(`  source:    ${jsonlPath}`);
  console.log(`  documents: ${restorable.length}${only ? ` (filtered by --only ${only})` : ''}`);
  console.log('  mode:      overwrite (バックアップ後に作られたドキュメントは削除されません)');
  const sample = restorable.slice(0, 5).map((d) => `    - ${d.relPath}`);
  console.log(sample.join('\n') + (restorable.length > 5 ? '\n    ...' : ''));

  if (skipConfirm) {
    console.log('  (--yes: skipping confirmation)');
  } else {
    const question =
      env === 'prod'
        ? `Overwrite ${restorable.length} documents in PROD (${project})?`
        : `Overwrite ${restorable.length} documents in ${project}?`;
    if (!(await confirm(question))) {
      console.log('Aborted.');
      return;
    }
  }

  const headers = await getAuthHeaders();
  const commitUrl = `${restBase(project)}:commit`;

  let written = 0;
  for (let i = 0; i < restorable.length; i += BATCH_SIZE) {
    const batch = restorable.slice(i, i + BATCH_SIZE);
    const body = {
      writes: batch.map((doc) => ({ update: { name: doc.name, fields: doc.fields } })),
    };
    const res = await fetch(commitUrl, {
      method: 'POST',
      headers: { ...headers, 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });
    if (!res.ok) {
      fail(
        `commit failed after ${written} documents: ${res.status} ${await res.text()}\n` +
          'Firestore is now partially restored — re-run the same restore to make it consistent.',
      );
    }
    written += batch.length;
    console.log(`  ... ${written}/${restorable.length} documents restored`);
  }

  console.log(`Done. ${written} documents restored to ${project}.`);
}

main().catch(adcHint);
