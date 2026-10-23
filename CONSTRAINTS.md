# Constraints

Last reviewed: 2026-10-21 with the project owner.

This is the project's quality contract. Testing and security failures block
completion. Scripts and CI must mirror this file; changes to the quality bar
require the owner's explicit agreement.

## Floor

- Suppressions: add no checker, coverage, or security suppression comments to bypass failures.
- Implementation: deliver working behavior; no placeholder implementations or swallowed failures.
- Tests: preserve tests and meaningful assertions. Explain any necessary deletion or skip in the commit message and handoff; obtain agreement for reduced protection.
- Secrets: keep credentials out of source, fixtures, logs, and reports. Report findings by rule and location only.
- Contract: fix the implementation rather than weaken rules, thresholds, scanner configuration, or check execution.

## Testing expectations

For each behavior change, add or update tests covering the expected behavior,
relevant edge cases, and failure paths. Test observable behavior at the lowest
level that captures it; mocks belong at external boundaries. Reversible changes
to prose or formatting need appropriate validation, not artificial unit tests.

For bug fixes, first reproduce the failure with a regression test when the
environment permits. Verify that it fails for the reported reason, implement
the fix, and verify that it passes. Preserve meaningful assertions; passing
tests that never exercise the behavior do not satisfy this contract.

Run related tests during implementation and the applicable task-end checks
before handoff. A missing runner, unavailable Roblox Studio, timeout, or skipped
check is **unverified**, never a pass. Continue work that can be verified and
report the remaining blocker; do not declare the affected behavior complete.

The first executable behavior change must establish a compatible test runner,
reproducible commands, and CI execution. If Roblox runtime behavior needs Studio,
record the scenario, expected result, and observed result; automated logic tests
alone do not establish that the game works in Studio.

## Checks available now

| Dimension | Rule and reason | Checked by | Runs at |
|-----------|-----------------|------------|---------|
| Floor | Zero detected violations; prevent shortcuts that reduce protection | `node scripts/floor-guard.mjs --base HEAD` locally; CI supplies the PR base | Task end; CI |
| Secrets | Zero findings; credentials must stay out of the repository | `gitleaks dir --redact --no-banner .` and `gitleaks git --redact --no-banner .` | CI; locally when installed |

Node.js is used only for the reference-derived floor guard, not as a choice of
game stack. The guard checks tracked changes and untracked source files. With
no commits it checks new files; otherwise a missing base exits with an error.
For branch-wide review use `--base <target-branch>` with available history.
Exit 0 means clean, 1 means findings, and 2 means the check could not run.

The guard detects common suppressions, stubs, skipped/deleted tests, removed
assertions, numerical threshold reductions, and new exceptions. It uses shallow
patterns: review the diff as well, especially semantic rule changes, multiline
stubs, scanner configuration, and check removal. Documentation examples are not
source-code violations. Guard modifications require reviewing its continued
ability to detect these cases.

## Baselines and checks to establish with code

No executable game code, dependencies, tests, coverage reports, or game runtime
configuration existed at setup. Coverage is **not measured**, not zero.

| Dimension | Required next step | Direction and reason |
|-----------|--------------------|----------------------|
| Coverage | First test setup must produce coverage and record the measured project and changed-line baselines here, with exact commands | Hold or improve the measured baseline; avoid an invented percentage that fails on day one |
| Code security | First source setup must select a scanner that supports the actual language, run it, and document its command | No high or critical findings; prioritize actionable security defects |
| Dependency security | When dependencies are introduced, add a compatible vulnerability scanner and CI command | No high or critical findings; avoid introducing known serious vulnerabilities |

These are setup obligations, not claims that missing tools already enforce
coverage or code security. The change introducing code or dependencies must
also deliver its applicable check setup; do not defer it silently.

For Roblox client/server behavior, verify server-side validation and authority
for client requests, including invalid inputs and relevant abuse cases.

## Lifecycle and budget

- During edits: run applicable checks on changed files; target under 5 seconds to keep feedback useful. Move slower checks to task end or CI.
- Task end: allow 90 seconds for local checks. This keeps verification practical; it is not permission to skip tests. Move longer checks to CI and report them as pending until results arrive.
- CI: no fixed quality-policy duration limit. Floor and secrets jobs are defined in `.github/workflows/constraints.yml`; add game tests and compatible scanners with their tooling.
- Review: compare against the branch point, including changed tests, check configuration, and this contract. A green guard alone does not prove test quality.

Handoff must state the behavior changed, tests added or updated, exact commands
run and their results, and any pending or unavailable checks with reasons.
Failures and unavailable required checks block declaring the affected work
verified and ready to ship. CI jobs only prevent merges when repository branch
protection requires them; this document does not claim that protection is set.

## Chassis prototype measurements (2026-10-21)

The first executable source is a throwaway chassis experiment, not a verified
game release. Its portable driving/input/damage/recovery rules were tested with
official Luau CLI 0.743:

```text
.tools/luau-0.743/luau.exe --coverage prototypes/chassis/tests/drive.test.lua
node scripts/chassis-coverage.mjs
```

Result: 37 assertions passed; DriveModel.lua measured 39/39 instrumented lines
(100%). All those lines are new, so measured changed-line coverage for that
module is also 100%; hold this measured baseline. The coverage command fails
if that module is absent from the report or its line coverage falls below the
baseline. This is the portable-logic subset, not a project-wide result.

The steering-response revision adds 22 behavior assertions (59 total) and
measures 57/57 instrumented DriveModel.lua lines with the same commands and
the same 100% baseline. The original assertions remain, with steering-angle
expectations updated to the owner's request for tighter, faster cornering.
All measured module lines are still new in this unborn repository, so its
measured changed-line subset is also 100%. Engine coverage remains unmeasured.

The subsequent small rollover softening adds two boundary assertions (61 total)
and retains the same 57/57 measured rule lines and 100% baseline.

The sustained-turn buildup revision adds ten temporal assertions (71 total)
and measures 69/69 instrumented rule lines with the same commands (100%).
The measured baseline remains 100%; engine coverage remains unmeasured.

The impact-window/recovery revision adds 11 regression assertions (82 total)
and measures 86/86 portable rule lines (100%) with the same commands.

The gentler acceleration/damage tune adds five assertions (87 total), retaining
86/86 portable rule lines (100%). Gameplay thresholds changed at the owner's
request; no quality threshold or existing behavior category was removed.

Project-wide runtime and engine changed-line coverage remain **unmeasured**.
Build.lua and the client/server integration require Studio evidence; the
portable tests do not execute Roblox physics or establish those baselines.
The original measurement obligations remain outstanding for those paths,
and the affected behavior must remain unverified until they are satisfied.

Source scanning is configured with Semgrep's Lua parser and local security
rules for dynamic execution, numeric remote modules, and runtime asset/network
loading. Prototype source deliberately uses a Lua syntax subset; this is not
a claim that the scanner supports arbitrary typed Luau. Commands:

```text
semgrep scan --config security/chassis.yml --strict --metrics off --json security/chassis.lua > build/security-fixture.json
node scripts/chassis-security-fixtures.mjs
semgrep scan --config security/chassis.yml --error --strict --metrics off prototypes/chassis/src
```

Semgrep 1.182.0 parsed all four source files with zero findings locally. Its
built-in fixture runner does not recognize Lua comment annotations, so the
JSON fixture check above must verify every expected rule/line and reject
unexpected findings or scanner errors. These rules have limited scope and do not replace server-authority tests or
review. Local scanner execution and CI results must be recorded before
claiming this source verified. The chassis workflow defines syntax, logic,
coverage, and source-security jobs; existing floor/secrets jobs still apply.
No runtime library dependencies are introduced.

After the steering revision, the same source-security command scanned all five
runtime source files with three rules, approximately 100% parsed lines and zero
findings. No security or coverage threshold was reduced.

## Exceptions

None. An exception requires explicit owner approval, a named owner, affected
rule and paths, a concrete reason, and an expiry no later than 90 days away.
The expiry keeps temporary compromises from becoming permanent policy.
