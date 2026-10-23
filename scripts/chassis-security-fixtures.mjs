import { readFileSync } from 'node:fs';

// Semgrep's annotation test runner does not recognize Lua's -- comments.
// Compare its real JSON findings against every annotated fixture instead.
const fixture = readFileSync('security/chassis.lua', 'utf8').split(/\r?\n/);
const expected = new Set();
for (let index = 0; index < fixture.length; index++) {
  const rule = fixture[index].match(/^-- ruleid: (.+)$/)?.[1];
  if (rule) expected.add(`${rule}:${index + 2}`);
}
if (expected.size !== 7) throw new Error('Expected all seven unsafe source fixtures');
const reportText = readFileSync(process.argv[2] ?? 'build/security-fixture.json', 'utf8');
const report = JSON.parse(reportText.replace(/^\uFEFF/, ''));
if (!Array.isArray(report.results) || !Array.isArray(report.errors)) {
  throw new Error('Invalid Semgrep JSON report');
}
if (report.errors.length) throw new Error('Security fixture scan had scanner/parser errors');
const observed = new Set();
for (const result of report.results) {
  if (!result.path.replaceAll('\\', '/').endsWith('security/chassis.lua')) {
    throw new Error('Unexpected file in security fixture report');
  }
  const rule = result.check_id.split('.').at(-1);
  const key = `${rule}:${result.start.line}`;
  if (!expected.has(key)) throw new Error(`Unexpected security finding: ${key}`);
  observed.add(key);
}
for (const key of expected) {
  if (!observed.has(key)) throw new Error(`Security rule failed to detect fixture: ${key}`);
}
console.log('PASS: all seven unsafe calls detected; safe ModuleScript require unflagged');
