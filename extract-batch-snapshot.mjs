import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';

const root = '/Users/zhouyijun/.myagents/projects/mino';
const snapshotPath = path.join(root, 'youmind-import', process.argv[2]);
const outRoot = path.join(root, 'youmind-import', 'IslandLink-v4');

const raw = await readFile(snapshotPath, 'utf8');
const genericLines = raw
  .split('\n')
  .filter((line) => line.includes('- generic: "'))
  .map((line) => line.slice(line.indexOf('"')));

const decoded = [];
for (const line of genericLines) {
  try {
    decoded.push(JSON.parse(line));
  } catch {
    // Ignore non-JSON snapshot fragments.
  }
}

const longest = decoded
  .filter((text) => text.includes('FILES['))
  .sort((a, b) => b.length - a.length)[0];

if (!longest) {
  throw new Error(`No FILES block found in ${snapshotPath}`);
}

const fileRe = /FILES\["([^"]+)"\]\s*=\s*r"""([\s\S]*?)"""/g;
const files = [];
let match;
while ((match = fileRe.exec(longest)) !== null) {
  files.push({ filePath: match[1], content: match[2].trimEnd() + '\n' });
}

for (const file of files) {
  const safeParts = file.filePath.split(/[\\/]+/).filter(Boolean);
  const target = path.join(outRoot, ...safeParts);
  if (!target.startsWith(outRoot)) throw new Error(`Unsafe path: ${file.filePath}`);
  await mkdir(path.dirname(target), { recursive: true });
  await writeFile(target, file.content, 'utf8');
}

console.log(`Extracted ${files.length} files from ${snapshotPath}`);
for (const file of files) console.log(file.filePath);
