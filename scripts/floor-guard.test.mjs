import assert from 'node:assert/strict';
import { spawnSync } from 'node:child_process';
import { mkdtempSync, writeFileSync, rmSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const guard = fileURLToPath(new URL('./floor-guard.mjs', import.meta.url));

test('initial-push scan handles large diffs without losing findings or errors', () => {
  const directory = mkdtempSync(join(tmpdir(), 'van-floor-regression-'));
  const git = (...args) => {
    const result = spawnSync('git', args, { cwd: directory, encoding: 'utf8' });
    assert.equal(result.status, 0, result.stderr);
    return result.stdout.trim();
  };
  const run = base => spawnSync(process.execPath, [guard, '--base', base], {
    cwd: directory, encoding: 'utf8',
  });
  try {
    git('init', '--quiet');
    const source = '// harmless padding\n'.repeat(70000);
    writeFileSync(join(directory, 'large.js'), source);
    git('add', 'large.js');
    git('-c', 'user.name=Regression', '-c', 'user.email=regression@example.invalid',
      'commit', '--quiet', '-m', 'Large initial source');
    const empty = spawnSync('git', ['hash-object', '-t', 'tree', '-w', '--stdin'], {
      cwd: directory, input: Buffer.alloc(0), encoding: 'utf8',
    });
    assert.equal(empty.status, 0, empty.stderr);
    const base = empty.stdout.trim();
    const clean = run(base);
    assert.equal(clean.status, 0, clean.stderr);
    assert.match(clean.stdout, /floor-guard: clean/);

    const marker = '@ts-' + 'ignore';
    writeFileSync(join(directory, 'large.js'), source + '// ' + marker + '\n');
    const violation = run(base);
    assert.equal(violation.status, 1, violation.stderr);
    assert.match(violation.stderr, /silenced-checker.*large\.js/);

    const missing = run('nonexistent-review-base');
    assert.equal(missing.status, 2, missing.stderr);
    assert.match(missing.stderr, /no merge base/);
  } finally {
    const expectedPrefix = resolve(tmpdir(), 'van-floor-regression-');
    assert.ok(resolve(directory).startsWith(expectedPrefix));
    rmSync(directory, { recursive: true, force: true });
  }
});
