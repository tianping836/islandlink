import fs from "node:fs";
import path from "node:path";

const root = path.resolve("youmind-import");
const out = path.join(root, "synced-board");
const rawOut = path.join(out, "raw");
const notesOut = path.join(out, "notes");

fs.mkdirSync(rawOut, { recursive: true });
fs.mkdirSync(notesOut, { recursive: true });

const rawFiles = [
  "youmind-file-page-full.txt",
  "youmind-document-raw.txt",
  "appintents-snapshot.txt",
  "batch-3-page.txt",
  "batch-3-snapshot.txt",
];

for (const file of rawFiles) {
  const src = path.join(root, file);
  if (fs.existsSync(src)) {
    fs.copyFileSync(src, path.join(rawOut, file));
  }
}

const read = (file) => {
  const p = path.join(root, file);
  return fs.existsSync(p) ? fs.readFileSync(p, "utf8") : "";
};

const sanitize = (text) =>
  text
    .replace(/ghp[A-Za-z0-9_]{20,}/g, "REDACTED_GITHUB_TOKEN")
    .replace(/github_pat_[A-Za-z0-9_]+/g, "REDACTED_GITHUB_TOKEN");

const shareLinkTextPath = path.join(rawOut, "share-link-full-text.txt");
const shareLinkText = fs.existsSync(shareLinkTextPath) ? sanitize(fs.readFileSync(shareLinkTextPath, "utf8")) : "";
if (shareLinkText && fs.readFileSync(shareLinkTextPath, "utf8") !== shareLinkText) {
  fs.writeFileSync(shareLinkTextPath, shareLinkText);
}
const boardText = [read("youmind-file-page-full.txt"), read("youmind-document-raw.txt"), shareLinkText]
  .filter(Boolean)
  .join("\n\n");
const sanitizedBoardText = sanitize(boardText);

const lines = sanitizedBoardText.split(/\r?\n/);
const titleLines = lines
  .map((line) => line.trim())
  .filter(Boolean)
  .filter((line) =>
    /屿连|IslandLink|Pitch Deck|产品叙事|设计信念|连接|人脉|源码|分析|方案|原型|指南|Batch|project\.yml|swift/i.test(line),
  );

const unique = [];
const seen = new Set();
for (const line of titleLines) {
  const normalized = line.replace(/\s+/g, " ");
  if (!seen.has(normalized)) {
    seen.add(normalized);
    unique.push(normalized);
  }
}

const namingPatterns = [
  "屿连不是通讯录",
  "看见你人脉网络中的真实路径",
  "不是通讯录里的名字",
  "真实连接",
  "不做美化",
  "不做滤镜",
  "专业人脉的真实面貌",
  "地图和指南针",
  "AllTrails",
  "BeReal",
  "Tiimo",
];

const extractAround = (text, pattern, radius = 180) => {
  const idx = text.indexOf(pattern);
  if (idx === -1) return null;
  const start = Math.max(0, idx - radius);
  const end = Math.min(text.length, idx + pattern.length + radius);
  return text.slice(start, end).replace(/\n{3,}/g, "\n\n").trim();
};

const namingEvidence = namingPatterns
  .map((pattern) => ({ pattern, excerpt: extractAround(sanitizedBoardText, pattern) }))
  .filter((item) => item.excerpt);

const sourceFiles = [];
const sourceRoot = path.join(root, "IslandLink-v4");
const walk = (dir) => {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(p);
    else sourceFiles.push(path.relative(sourceRoot, p));
  }
};
if (fs.existsSync(sourceRoot)) walk(sourceRoot);
sourceFiles.sort();

const documentSections = [
  {
    name: "PRODUCT_NARRATIVE.md",
    title: "Product Narrative",
    anchors: ["屿连 IslandLink · 产品叙事文案", "一句话", "Apple 年度最佳应用对屿连的启发"],
  },
  {
    name: "PROJECT_CONTEXT.md",
    title: "Project Context From YouMind",
    anchors: ["屿连 IslandLink — 项目上下文（供 AI 编程助手使用）", "一、项目概述", "二、数据模型现状"],
  },
  {
    name: "PITCH_DECK_NOTES.md",
    title: "Pitch Deck Notes",
    anchors: ["屿连 IslandLink · Pitch Deck", "屿连不是通讯录", "法律人的通讯录困境"],
  },
  {
    name: "IMPROVEMENT_NOTES.md",
    title: "Improvement Notes",
    anchors: ["屿连 IslandLink · 第四梯队：连接落地计划", "屿连 IslandLink · 第三轮深度改进分析", "屿连 IslandLink · 第二轮深度改进分析"],
  },
  {
    name: "DESIGN_SYSTEM_NOTES.md",
    title: "Design System Notes",
    anchors: ["屿连 IslandLink — 设计系统 v2", "按「屿连 IslandLink 设计系统 v2」重新设计的全部页面"],
  },
  {
    name: "INTEGRATION_NOTES.md",
    title: "Integration Notes",
    anchors: ["屿连 IslandLink — 日历/通讯录集成 · 缺失分析与设计方案", "飞书多维表格 → 岛连 IslandLink：契合功能与借鉴方案", "飞书多维表格字段系统研究"],
  },
];

const excerptFromAnchors = (text, anchors, radius = 1800) => {
  const excerpts = [];
  for (const anchor of anchors) {
    const idx = text.indexOf(anchor);
    if (idx === -1) continue;
    const start = Math.max(0, idx - 200);
    const end = Math.min(text.length, idx + radius);
    excerpts.push(text.slice(start, end).trim());
  }
  return excerpts;
};

for (const section of documentSections) {
  const excerpts = excerptFromAnchors(sanitizedBoardText, section.anchors);
  fs.writeFileSync(
    path.join(notesOut, section.name),
    [
      `# ${section.title}`,
      "",
      "Recovered from local YouMind board text. These excerpts are intentionally local-first so future development does not depend on reopening YouMind.",
      "",
      ...excerpts.flatMap((excerpt, index) => [
        `## Excerpt ${index + 1}`,
        "",
        "```text",
        excerpt,
        "```",
        "",
      ]),
      excerpts.length === 0 ? "_No matching excerpt was found in the recovered text._" : "",
    ].join("\n"),
  );
}

fs.writeFileSync(
  path.join(out, "BOARD_INDEX.md"),
  [
    "# YouMind Board Sync Index",
    "",
    "Source board: `屿连app开发`.",
    "",
    "This index is generated from the locally recovered YouMind board text and snapshots. It is intended to make Codex the working development home for the app.",
    "",
    "## Recovered Board Items",
    "",
    ...unique.slice(0, 260).map((line) => `- ${line}`),
    "",
    "## Reconstructed Source Files",
    "",
    ...sourceFiles.map((file) => `- IslandLink-v4/${file}`),
    "",
  ].join("\n"),
);

fs.writeFileSync(
  path.join(notesOut, "NAMING_CONTEXT.md"),
  [
    "# Naming Context",
    "",
    "## First-Principles Target",
    "",
    "The app name should support this idea: a professional user can see relationship paths proven by real shared experience.",
    "",
    "## Recovered YouMind Evidence",
    "",
    ...namingEvidence.flatMap((item) => [
      `### ${item.pattern}`,
      "",
      "```text",
      item.excerpt,
      "```",
      "",
    ]),
    "## Current Recommendation",
    "",
    "- Keep working name: `屿连`.",
    "- Positioning line: `看见人脉中的真实路径`.",
    "- Core in-app terms: `你们之间`, `连接证据`, `共同经历`.",
    "",
    "## Adversarial Rejection Rules",
    "",
    "- Reject names that sound like a contacts app.",
    "- Reject names that sound like a case-management system.",
    "- Reject names that make the app feel like social media.",
    "- Reject names that imply AI prediction before the evidence loop works.",
    "",
  ].join("\n"),
);

fs.writeFileSync(
  path.join(notesOut, "PRODUCT_CONTEXT.md"),
  [
    "# Product Context",
    "",
    "## Core Sentence",
    "",
    "> 看见你人脉网络中的真实路径。",
    "",
    "## Product Identity",
    "",
    "屿连 is not a contacts app and not a case-management app. It is a professional relationship-navigation app.",
    "",
    "## Highest-Level Rules",
    "",
    "1. First-principles reasoning: every feature must make relationship paths clearer with less user burden.",
    "2. Adversarial review: reject anything that turns the product into CRM, case management, feature showcase, or empty graph decoration.",
    "",
    "## MVP Loop",
    "",
    "1. Add or import people.",
    "2. Create an event.",
    "3. Attach people to the event.",
    "4. Optionally attach a case.",
    "5. Open a person and see connection evidence.",
    "6. Open `你们之间` and understand why two people are connected.",
    "",
  ].join("\n"),
);

fs.writeFileSync(
  path.join(out, "SYNC_STATUS.md"),
  [
    "# Sync Status",
    "",
    "## Current State",
    "",
    "- Recovered source files are in `../IslandLink-v4`.",
    "- Raw recovered board text and snapshots are copied into `raw/`.",
    "- Public share-link text is saved into `raw/share-link-full-text.txt` when available.",
    "- Product and naming notes are in `notes/`.",
    "- Current core Swift files pass syntax parsing in the local sandbox.",
    "",
    "## Known Limitations",
    "",
    "- Browser automation could not yet reliably open and read the live YouMind chat view because the page was timing out.",
    "- The current sync is therefore based on previously recovered board file text and snapshots.",
    "- If the live chat contains newer naming discussion, open the specific board chat page and rerun sync.",
    "- Treat `synced-board/` and `IslandLink-product-review.md` as the local authority unless a newer YouMind export is explicitly imported.",
    "",
  ].join("\n"),
);

fs.writeFileSync(
  path.join(out, "FULL_RECOVERED_TEXT.txt"),
  sanitizedBoardText,
);

console.log(`Synced ${rawFiles.length} raw artifacts and ${sourceFiles.length} source files into ${out}`);
