---
name: foreman-review
description: Comprehensive PR review following Foreman project standards - automated convention checks and AI-based code quality assessment
---

# Foreman PR Review

Perform a comprehensive review of the current branch's changes following
Foreman project standards.

## Token budget rules

Each conversation turn re-reads ~70k+ cached tokens (system prompt + MCP
schemas). **Minimizing turns is the highest-leverage cost optimization.**

- **Small/medium PRs (≤1000 lines):** 2 turns — one bash call, then report.
- **Large PRs (>1000 lines):** 3 turns — setup, targeted reads, report.
- Never read mechanical files individually. Files with ≤5 lines changed
  that follow an obvious pattern (prop threading, import additions) can be
  assessed from the stat line alone. Read ONE representative example if needed
  to confirm the pattern, then list the remaining files it covers.
- Batch file reads: run one `git diff` covering all files needed, not one per
  file. When multiple checks examine the same files, combine into one read.
- Do not chase call targets unnecessarily. If a change is trivially correct
  from the diff alone (e.g., passing an additional optional argument), do not
  read the callee definition.

## Step 1: Setup, Convention Checks & Diff (ONE bash call)

Run the review script in a **single bash invocation**:

```bash
bash ~/.claude/skills/foreman-review/foreman-review.sh
```

The script outputs compact results: project type, commits, stat, convention
check failures only (passing checks print one "ALL PASS" line), and the full
diff for PRs ≤1000 lines. This keeps output under the inline display limit
to avoid a file-read round-trip.

**After this call:**

- **Full diff in context (≤1000 lines):** Proceed directly to the AI
  Assessment and then the report. Do NOT make additional `git diff` calls.
  Only make a targeted lookup if you need context NOT in the diff (e.g.,
  checking a model file for validators on a new column, checking an existing
  permission block).

- **Large PR (>1000 lines):** Triage from the stat output:
  - **Substantial** (>5 lines changed): read in at most 2 parallel `git diff`
    calls, grouped by language (Ruby in one, JS in another).
  - **Mechanical** (≤5 lines): assess from stat + one representative example.
  Then proceed to AI Assessment.

## Step 2: AI-Based Assessment

**Use the changed files list to decide which checks to run.** Skip any check
whose trigger does not match the changed files. Mark skipped checks as
"SKIP — no relevant files changed."

Only report findings where you have evidence — do not speculate.

**i18n (convention check 10):** Look for added strings in views (`.erb`) and
controllers that lack `_()` wrapping, especially in `flash`, `render`,
`redirect_to`, and error messages.

### 2.1 Does the PR address the stated issue?
**Always run.** Read commit messages for `Fixes/Refs #XXXX`. Flag if changes
appear unrelated or scope seems wrong for the stated fix.

### 2.2 Unrelated changes
**Always run.** Flag whitespace-only changes in unrelated files, style-only
refactors mixed with bug fixes, or cleanups that should be separate PRs.

### 2.3 Test coverage
**Run when:** changed files include `app/` or `lib/` code (not just tests/config).
Check for corresponding tests in `test/` (Ruby) or `__tests__/` (JS). Flag
new behavior without test coverage. If a test file has >100 changed lines in
the stat, focus on whether **new behavior** has tests, not on reading every
line of mechanical test setup (e.g., the same parameter added to 10 cases).

### 2.4 Permissions for non-admin users
**Run when:** changed files include `app/controllers/`.
Check new actions for `authorize` calls, `before_action :find_resource`, and
permission definitions in `security_block` or `access_control.rb`.
For core: also check `app/models/permission.rb`.
For plugins: check the `Foreman::Plugin.register` block.

### 2.5 ActiveRecord validators on new fields
**Run when:** changed files include `db/migrate/`.
Check corresponding models for `validates` on new columns, especially NOT NULL
columns that lack presence validators.

### 2.6 Exception handling
**Run when:** changed files include `.rb` under `app/` or `lib/`.
Flag `rescue` blocks that swallow errors silently (empty block, only info-level
logging, returning `nil` or generic error without details).

### 2.7 Apipie documentation
**Run when:** changed files include `app/controllers/api/`.
Check for `api`, `param` declarations on new actions. Verify `:required`
accuracy. Flag undocumented API endpoints.

### 2.8 API backward compatibility
**Run when:** changed files include `app/controllers/api/`.
Flag removed params, changed response structure, or changed routes without
`Foreman::Deprecation.api_deprecation_warning`. Exception: already-deprecated
params being removed is the expected final step — mark PASS.

### 2.9 Performance patterns
**Run when:** changed files include `.rb` under `app/` or `lib/`.
Flag N+1 queries, unbounded `.all`/`.where` in controllers, `.to_a` on large
relations, missing indexes on new foreign keys, string allocations in loops.
Only flag with clear evidence.

### 2.10 API counterparts for new controllers
**Run when:** new files under `app/controllers/` (not `api/`).
Note if a matching `api/v2/` controller is missing (reminder, not hard rule).

## Step 3: Output

```
## Foreman PR Review: [commit title or branch name]

**Project type:** core | plugin | smart_proxy
**Commits reviewed:** [count]
**Base:** [branch]

### Convention Checks
[Pass/Warn/Fail per check]

### AI Assessment

#### [Check name] — [PASS | WARNING | ISSUE]
[Explanation with file:line references]

...

### Human Follow-up Required
- [ ] Hammer CLI counterpart
- [ ] Packaging
- [ ] User documentation
- [ ] Community demo
- [ ] Upgrade notes

### Summary
[1-2 sentence overall assessment: ready to merge, needs changes, or needs discussion]
```
