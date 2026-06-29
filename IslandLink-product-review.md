# IslandLink Product Review

## Read Sources

- Primary: YouMind extracted materials in `youmind-file-page-full.txt`, `youmind-document-raw.txt`, imported source comments, and second/third/fourth/fifth-tier improvement notes.
- Excluded as product direction: the old local `连接App开发/*` materials. They represent an earlier case-management direction that should not drive the current roadmap.

## YouMind Direction

The strongest YouMind direction is:

> 看见你人脉网络中的真实路径。

This is not a case-management app. It is a professional relationship-navigation app. Cases and events are evidence that a relationship exists; they are not the product's main subject.

The product principles are:

- 一切以连接为中心。
- 人 > 案件。
- 网络 > 节点。
- 不做案件管理，不做时间线，做人与人之间的桥梁。
- 事件是一级公民，独立于案件；案件是可选的 lawyer-grade context.

## Highest-Level Development Rules

These two rules override feature requests, UI habits, and inherited code direction:

1. First-principles product reasoning.
   Every feature must answer: what real relationship problem does this solve, what evidence proves the relationship, and what is the shortest path from empty data to visible value?

2. Adversarial review.
   Every feature must be attacked before it is accepted. Reject or defer anything that turns the app into a generic contacts app, a case-management system, a feature showcase, or a data-entry burden without immediate relationship insight.

Default answer when uncertain: cut scope, strengthen the connection loop, and make the evidence clearer.

## Main Gaps

- The code and documents have absorbed too many "Apple ecosystem" features before the connection loop is compile-clean and usable.
- The connection evidence model is implicit in UI comments, but it should become a first-class data and UX concept.
- The event-first architecture is right, but the app still risks falling back into case-management UI language.
- The first-run data path is not strong enough. A network app is useless when empty, so import, dedupe, and sample-data flows are core.
- Potential connections are promising, but should wait until direct connections and "you two" explanations are excellent.
- Privacy is part of the promise, but it needs visible product affordances, not just technical notes.
- Current extracted source is not build-ready; cleanup and project generation are prerequisite work.

## Recommended Direction

Use this product sentence:

> 屿连帮助法律人看见专业人脉中的真实路径，每一条路径都由案件、事件或共同经历证明。

## Naming Review

First-principles test: the name should point to "relationship paths proven by real shared experience," not to generic contact storage, case management, or decorative networking metaphors.

YouMind naming evidence already recovered from the board:

- "屿连不是通讯录"
- "看见你人脉网络中的真实路径。"
- "他们不是通讯录里的名字，而是无数个案号和庭次织成的真实连接。"
- "屿连不做美化，不做滤镜。它让你看见的，是你专业人脉的真实面貌。"
- "把屿连想成人脉世界的 AllTrails——它不是通讯录，是你专业网络的地图和指南针。"

These lines strongly support a name that feels like navigation, pathfinding, truth, and relationship evidence. They do not support names that sound like a legal case database, a generic address book, or a social graph toy.

Adversarial test:

- Reject names that sound like CRM, address book, case system, social media, or productivity suite.
- Reject names that overpromise AI prediction before the evidence loop works.
- Reject names that are clever but do not help a serious legal/professional user understand the product.
- Prefer names that can support the core UI phrase "你们之间".

Current working name:

- 屿连: strong, short, memorable, and emotionally aligned with "separate people connected by paths." Weakness: the "island" metaphor is poetic and may not instantly say professional relationship evidence. Keep as the working name unless a clearer alternative proves better.

Stronger literal candidates:

1. 人脉路径
   Clear and exact. It says what the app does. Weakness: less distinctive as a brand.
2. 脉络
   Elegant and close to "context/path/thread." Strong brand feel. Weakness: may sound broad unless paired with a subtitle.
3. 关系径
   Very aligned with paths between people. Weakness: slightly coined and may feel less natural.
4. 见脉
   Short and strategic: see the network. Weakness: "脉" may feel abstract.
5. 证连
   Emphasizes evidence-backed connections. Weakness: colder, more legalistic.

Recommendation for now:

- Keep app name: 屿连.
- Use positioning subtitle: 看见人脉中的真实路径.
- Use core screen language: 你们之间 / 连接证据 / 共同经历.

This gives the brand warmth while the product language carries precision.

Recommended app structure:

- 人脉: home surface, search, import, dedupe, person detail.
- 连接: "你们之间", closest people, relationship paths, network graph.
- 事件: meetings, hearings, deadlines, filings, social/professional touchpoints.
- 案件: optional matter template attached to events and people, not the main navigation metaphor.
- 设置: privacy, local-only status, import/export, app lock, sync status.

## MVP Cut

Build only the first complete connection loop:

- Add/import people.
- Create an event.
- Attach people to the event with roles.
- Optionally attach a case/matter to the event.
- Open a person and see connection evidence.
- Open "你们之间" for two people and see shared events/cases, timeline, and common contacts.
- Search people and events.
- Export data and protect with app lock.

Defer until the loop is delightful:

- Watch app.
- Widget variants.
- Siri/AppIntents.
- Spotlight.
- Pro subscription flows.
- CloudKit sync.
- Potential connection graph.
- Full case-management workflows.

## Product Improvements

1. Make "connection evidence" first-class: show shared event, shared case, role, date, and strength for every connection.
2. Rename UI around human language: "你们之间", "共同经历", "最近变远的人", "通过谁认识".
3. Treat events as the atomic unit. A case is one possible container, but a relationship can also come from a meeting, meal, referral, hearing, research, or collaboration.
4. Turn first-run into a guided story: import contacts, select 3 important people, add one event, see the first connection.
5. Add dedupe and identity resolution early: same person, multiple roles, changing court/law firm, old phone number, alias.
6. Keep graph progressive: closest circle first, then shared nodes, then potential paths. Never show a hairball.
7. Make privacy visible: local-only mode, app lock, export, delete-all confirmation, sync status.
8. Clean and compile the current Swift code before adding features. A beautiful product direction still needs a stable baseline.
