import { readdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';

const root = '/Users/zhouyijun/.myagents/projects/mino/youmind-import/IslandLink-v4/屿连';

async function walk(dir) {
  const entries = await readdir(dir, { withFileTypes: true });
  const files = [];
  for (const entry of entries) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) files.push(...await walk(full));
    else if (entry.isFile() && entry.name.endsWith('.swift')) files.push(full);
  }
  return files;
}

function cleanText(source) {
  let text = source;

  text = text
    .replace(/\r\n/g, '\n')
    .replace(/^\s*Swift\s*\n/gm, '')
    .replace(/<\/[a-zA-Z0-9,]+>/g, '')
    .replace(/[“”]/g, '"')
    .replace(/[‘’]/g, "'")
    .replace(/……/g, '...')
    .replace(/import SwiftUIimport/g, 'import SwiftUI\nimport')
    .replace(/import SwiftDataimport/g, 'import SwiftData\nimport')
    .replace(/import Foundationimport/g, 'import Foundation\nimport')
    .replace(/import AppIntentsimport/g, 'import AppIntents\nimport')
    .replace(/import WidgetKit import/g, 'import WidgetKit\nimport')
    .replace(/import SwiftUI import/g, 'import SwiftUI\nimport')
    .replace(/import SwiftData import/g, 'import SwiftData\nimport')
    .replace(/import CoreSpotlight import/g, 'import CoreSpotlight\nimport')
    .replace(/import MobileCoreServices import/g, 'import MobileCoreServices\nimport')
    .replace(/import LocalAuthenticationimport/g, 'import LocalAuthentication\nimport')
    .replace(/import StoreKitimport/g, 'import StoreKit\nimport')
    .replace(/import MessageUIimport/g, 'import MessageUI\nimport')
    .replace(/ContactsImportManager\.\s+ImportEntry/g, 'ContactsImportManager.ImportEntry')
    .replace(/\?\?\s+0if/g, '?? 0\nif')
    .replace(/\}else/g, '} else')
    .replace(/\}if/g, '}\nif')
    .replace(/\)return/g, ')\nreturn')
    .replace(/activityFilterBarroleFilterBar/g, 'activityFilterBar\nroleFilterBar')
    .replace(/expansionTogglepotentialToggle/g, 'expansionToggle\npotentialToggle');

  // Remove duplicated AppIntents block caused by DOM extraction. Keep the larger latest block.
  if (text.includes('// MARK: - ─── 岛连 App Intents ───')) {
    const markers = [...text.matchAll(/\/\/ MARK: - ─── 岛连 App Intents ───/g)].map((m) => m.index);
    if (markers.length > 1) {
      text = text.slice(0, markers[0]).replace(/import AppIntents\s+import SwiftData\s+import Foundation\s*$/s, '') +
        text.slice(markers[1]).replace(/^\/\/ MARK: - ─── 岛连 App Intents ───/, 'import AppIntents\nimport SwiftData\nimport Foundation\n\n// MARK: - ─── 岛连 App Intents ───');
    }
  }

  text = text
    .replace(/\n{3,}/g, '\n\n')
    .trimEnd() + '\n';

  return text;
}

for (const file of await walk(root)) {
  const original = await readFile(file, 'utf8');
  const cleaned = cleanText(original);
  if (cleaned !== original) await writeFile(file, cleaned, 'utf8');
}

console.log('Cleaned Swift sources');
