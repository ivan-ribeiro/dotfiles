# Bridge

Run a full contract analysis between a backend and frontend, then auto-generate a seeded spec from the findings.

## Usage
`/bridge <feature-name>`

Then follow the intake prompt to register your repos.

---

## RULE: SILENT OPERATION
- Do not ask clarifying questions before running
- Do not ask for permission to read files
- Do not confirm steps before taking them
- If something is ambiguous, make the best assumption and note it at the end under "Assumptions"
- Only stop and ask if it is completely impossible to proceed

---

## Step 1 — Intake

Greet with exactly this and wait for the user's response:

```
🔗 Bridge ready.

  [name]  [role]  [source]

  roles:
    b  = backend
    f  = frontend
    bf = single repo with both backend and frontend

  source options:
    repo name only              → auto-searches ~/dev ~/projects ~/workspace ~/code ~/src
    github.com/org/repo@branch  → reads directly from GitHub
    paste                       → drop files inline

  examples:
    api        b   my-api
    web        f   github.com/org/web@feature/checkout
    fullstack  bf  my-monorepo
    api        b   paste
```

---

## Step 2 — Load Repos

**Repo type rules — apply silently:**
- `b` → backend only. Read backend priority files.
- `f` → frontend only. Read frontend priority files.
- `bf` → single repo containing both. Read both sets of priority files. Treat BE and FE as two separate layers — a monorepo does not mean the integration is automatically correct.

**What to read (priority order, auto-detected):**

Backend:
1. `package.json` / `pyproject.toml` / `go.mod` / `Gemfile`
2. `routes/` `controllers/` `api/` `routers/`
3. `middleware/auth.*` `guards/` `decorators/auth*`
4. `models/` `schemas/` `entities/` `prisma/schema.prisma`
5. `.env.example`

Frontend:
1. `package.json`
2. `src/api/` `src/services/` `src/lib/http.*` `src/lib/axios.*`
3. `src/types/` `src/interfaces/` `*.d.ts`
4. `src/auth/` `context/AuthContext.*` `middleware.ts`
5. `.env.example`

---

## Step 3 — Run Contract Analysis & Print Matrix

Print the full contract matrix immediately after loading. Wide layout, never truncate.

```
╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
║  CONTRACT MATRIX                                                                          [DD MMM YYYY HH:MM]  ║
║  BE  [name]  ·  [framework]  ·  [branch]                                                                       ║
║  FE  [name]  ·  [framework]  ·  [branch]                                                                       ║
║  TYPE  [monorepo | separate repos]                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝

  ENDPOINTS
  ┌────────┬──────────────────────────────────────┬──────────────────┬──────────────────┬──────────────────────┐
  │ METHOD │ PATH                                 │ BACKEND          │ FRONTEND         │ STATUS               │
  ├────────┼──────────────────────────────────────┼──────────────────┼──────────────────┼──────────────────────┤
  │ GET    │ /api/v1/users                        │ ✅  exists       │ ✅  calls        │ ✅  Aligned          │
  │ POST   │ /api/v1/orders                       │ ✅  exists       │ ✅  calls        │ 🟠  Risk             │
  │ GET    │ /api/v1/payments                     │ ✅  exists       │ ─                │ 🔇  Orphan           │
  │ PATCH  │ /api/v1/profile                      │ ─                │ ✅  calls        │ ❌  Missing          │
  └────────┴──────────────────────────────────────┴──────────────────┴──────────────────┴──────────────────────┘

  FIELDS
  ┌──────────────────────────────────────┬──────────────────────────┬──────────────────────────┬──────────────────────┐
  │ ROUTE                                │ BACKEND RETURNS          │ FRONTEND EXPECTS         │ STATUS               │
  ├──────────────────────────────────────┼──────────────────────────┼──────────────────────────┼──────────────────────┤
  │ GET /api/v1/users                    │ user_id                  │ userId                   │ ⚠️   Mismatch        │
  └──────────────────────────────────────┴──────────────────────────┴──────────────────────────┴──────────────────────┘

  AUTH
  ┌──────────────────────────────────────┬──────────────────────────┬──────────────────────────┬──────────────────────┐
  │ ROUTE                                │ BACKEND REQUIRES         │ FRONTEND SENDS           │ STATUS               │
  ├──────────────────────────────────────┼──────────────────────────┼──────────────────────────┼──────────────────────┤
  │ PATCH /api/v1/profile                │ Bearer token             │ ─                        │ 🔐  Gap              │
  └──────────────────────────────────────┴──────────────────────────┴──────────────────────────┴──────────────────────┘

  ENV
  ┌──────────────────────────────────────┬──────────────┬──────────────┬──────────────────────────────────────────────┐
  │ VARIABLE                             │ BACKEND      │ FRONTEND     │ STATUS                                       │
  ├──────────────────────────────────────┼──────────────┼──────────────┼──────────────────────────────────────────────┤
  │ STRIPE_KEY                           │ ✅           │ ─            │ 🌍  Missing from FE config                   │
  └──────────────────────────────────────┴──────────────┴──────────────┴──────────────────────────────────────────────┘

  ──────────────────────────────────────────────────────────────────────────────────────────────────
  🔴 Breaking  0    🟠 Risk  1    🟡 Feature  0    ⚠️  Mismatch  1    ❌ Missing  1
  🔇 Orphan    1    👻 Phantom  0    🔐 Auth Gap  1    🌍 ENV Gap  1    ✅ Aligned  1
  ──────────────────────────────────────────────────────────────────────────────────────────────────
```

Column sizing rules:
- METHOD column    → fixed, 8 chars
- PATH / ROUTE     → expand to longest entry, minimum 38 chars
- BE / FE columns  → expand to longest content, minimum 18 chars
- STATUS column    → expand to longest status label, minimum 22 chars
- VARIABLE column  → expand to longest name, minimum 38 chars
- Never truncate any path, field name, or variable name

---

## Step 4 — Save bridge-report.md

Save the full matrix output to `.claude/specs/$FEATURE_NAME/bridge-report.md` with this structure:

```markdown
# Bridge: [BE name] ↔ [FE name]

| Field | Value |
| :---- | :---- |
| **Status** | draft |
| **Branch** | `feat/[feature-name]` |
| **Created** | YYYY-MM-DD |
| **Updated** | YYYY-MM-DD |

## Summary / Description

Contract analysis between [BE name] ([framework]) and [FE name] ([framework]).
[1–2 sentence description of what was analysed and the overall health of the integration.]

## Acceptance Criteria

- [ ] All ❌ Missing endpoints are resolved
- [ ] All ⚠️ Mismatched fields are aligned
- [ ] All 🔐 Auth gaps are closed
- [ ] All 🌍 ENV gaps are resolved
- [ ] No regressions introduced to ✅ Aligned endpoints

## Unanswered Questions

| # | Question | Answer | Resolved |
| :---- | :---- | :---- | :---- |
| 1 | [Auto-populated from 🔇 Orphan endpoints — intentional or dead code?] | | ☐ |

## Plan

<!-- Steps are auto-generated from findings, grouped by type -->

### Step 1: Fix Missing Endpoints
<!-- One step per ❌ Missing / 🔴 Breaking finding -->

**Commit:** `feat: [feature-name] - fix missing endpoints`

### Step 2: Align Field Shapes
<!-- One step per ⚠️ Mismatch / 👻 Phantom finding -->

**Commit:** `feat: [feature-name] - align field shapes`

### Step 3: Close Auth Gaps
<!-- One step per 🔐 Auth Gap finding -->

**Commit:** `feat: [feature-name] - close auth gaps`

### Step 4: Resolve ENV Gaps
<!-- One step per 🌍 ENV Gap finding -->

**Commit:** `feat: [feature-name] - resolve env gaps`

## Execution Log

*The AI Agent will update the following sections after every step has been completed.*

### Step 1 - Pending

- Started: —
- Notes: —

### Step 2 - Pending

- Started: —
- Notes: —

### Step 3 - Pending

- Started: —
- Notes: —

### Step 4 - Pending

- Started: —
- Notes: —

## Files Changed

<!-- Agent populates this section during execution -->

## Testing

- Automated tests added/updated:
- Manual testing performed:
- Edge cases verified:

## Final Notes

<!-- Agent populates after all steps complete -->

---

## Contract Matrix

<!-- Full matrix tables go here (copy from printed output above) -->

## Raw Findings List

<!-- Machine-readable, one per line. Consumed by spec-create to seed spec.md -->
<!-- Format: [SEVERITY] [TYPE] [METHOD] [PATH] — [description] -->
<!-- e.g.: HIGH MISSING PATCH /api/v1/profile — endpoint called by FE but not defined in BE -->
```

---

## Step 5 — Auto-Generate Seeded spec.md

Read the Raw Findings List from `bridge-report.md`. Group findings by severity:
- 🔴 Breaking + ❌ Missing + 🔐 Auth Gap → **High priority**
- ⚠️ Mismatch + 👻 Phantom → **Medium priority**
- 🟠 Risk + 🌍 ENV Gap → **Low priority**
- 🔇 Orphan → Unanswered Questions only

Generate `.claude/specs/$FEATURE_NAME/spec.md` using this template:

```markdown
# Spec: [Feature Name]

| Field | Value |
| :---- | :---- |
| **Status** | draft |
| **Branch** | `feat/[feature-name]` |
| **Created** | YYYY-MM-DD |
| **Updated** | YYYY-MM-DD |

## Summary / Description

Auto-seeded from contract analysis in [bridge-report.md](./bridge-report.md).
Fix integration gaps between [BE name] and [FE name] across endpoints, field shapes, auth, and environment config.

## Acceptance Criteria

<!-- One checkbox per REQ, derived from findings -->
- [ ] REQ-001: [verifiable condition]
- [ ] REQ-002: [verifiable condition]

## Unanswered Questions

| # | Question | Answer | Resolved |
| :---- | :---- | :---- | :---- |
| 1 | [METHOD] [PATH] is defined in BE but never called by FE — intentional? | | ☐ |

## Plan

### Step 1: [High Priority Fixes]
<!-- Generated from: Breaking, Missing, Auth Gap findings -->

What this step accomplishes and how.

**Commit:** `feat: [feature-name] - step 1 description`

### Step 2: [Medium Priority Fixes]
<!-- Generated from: Mismatch, Phantom findings -->

What this step accomplishes and how.

**Commit:** `feat: [feature-name] - step 2 description`

### Step 3: [Low Priority Fixes]
<!-- Generated from: Risk, ENV Gap findings -->

What this step accomplishes and how.

**Commit:** `feat: [feature-name] - step 3 description`

## Execution Log

*The AI Agent will update the following sections after every step has been completed.*

### Step 1 - Pending

- Started: —
- Notes: —

### Step 2 - Pending

- Started: —
- Notes: —

### Step 3 - Pending

- Started: —
- Notes: —

## Files Changed

<!-- Agent populates this section during execution -->

## Testing

- Automated tests added/updated:
- Manual testing performed:
- Edge cases verified:

## Final Notes

<!-- Agent populates after all steps complete -->
```

---

## Step 6 — STOP and present Gate 0

> ---
> ## 🔵 Gate 0: Bridge Review
>
> Two files saved to `.claude/specs/$FEATURE_NAME/`:
> - `bridge-report.md` — full contract matrix + execution log
> - `spec.md` — draft spec seeded from findings
>
> **Review both files.** The spec was auto-generated — verify priorities and requirements make sense for your context. Resolve any Unanswered Questions before approving.
>
> When ready, run `/spec-run $FEATURE_NAME` to continue through the approval gates.
> ---

---

## Assumptions
List any assumptions made during analysis here (e.g. inferred base URL, assumed auth scheme, guessed field types).