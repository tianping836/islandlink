import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';

const root = '/Users/zhouyijun/.myagents/projects/mino';
const rawPath = path.join(root, 'youmind-import', 'youmind-document-raw.txt');
const outRoot = path.join(root, 'youmind-import', 'IslandLink-v4');

const tokenPattern = /ghp_[A-Za-z0-9_]+/g;
let raw = await readFile(rawPath, 'utf8');
raw = raw.replace(tokenPattern, '[REDACTED_GITHUB_TOKEN]');
await writeFile(rawPath, raw, 'utf8');

const marker = /=FILE:\s*([^=\n]+?)=/g;
const files = [];
let match;

while ((match = marker.exec(raw)) !== null) {
  const filePath = match[1].trim();
  const contentStart = marker.lastIndex;
  const endMatch = /=END=/g;
  endMatch.lastIndex = contentStart;
  const end = endMatch.exec(raw);
  if (!end) break;

  let content = raw.slice(contentStart, end.index);
  content = content.replace(/^\s*\n+/, '').replace(/\n+\s*$/, '\n');

  files.push({ filePath, content });
  marker.lastIndex = end.index + end[0].length;
}

for (const file of files) {
  const safeParts = file.filePath.split(/[\\/]+/).filter(Boolean);
  const target = path.join(outRoot, ...safeParts);
  if (!target.startsWith(outRoot)) {
    throw new Error(`Unsafe path: ${file.filePath}`);
  }
  await mkdir(path.dirname(target), { recursive: true });
  await writeFile(target, file.content, 'utf8');
}

const manifest = files.map((file) => ({
  path: file.filePath,
  bytes: Buffer.byteLength(file.content, 'utf8'),
  lines: file.content.split('\n').length,
}));

await writeFile(
  path.join(root, 'youmind-import', 'manifest.json'),
  JSON.stringify({ extractedAt: new Date().toISOString(), fileCount: files.length, files: manifest }, null, 2),
  'utf8',
);

console.log(`Extracted ${files.length} files to ${outRoot}`);
