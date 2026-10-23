import { readFileSync, writeFileSync } from 'node:fs';

// CLI coverage covers pure control rules. Engine integration is measured in Studio.
const report = readFileSync('coverage.out', 'utf8');
const files = [];
for (const record of report.split('end_of_record')) {
  const name = record.match(/^SF:(.+)$/m)?.[1]?.trim().replaceAll('\\', '/');
  if (!name?.endsWith('/src/DriveModel.lua')) continue;
  const lines = [...record.matchAll(/^DA:(\d+),(\d+)/gm)];
  if (!lines.length) throw new Error('DriveModel has no instrumented lines');
  files.push({ name, covered: lines.filter(line => Number(line[2]) > 0).length, total: lines.length });
}
if (files.length !== 1) throw new Error('Expected exactly one DriveModel coverage record');
const { covered, total } = files[0];
const result = {
  pureRules: { covered, total, percentage: covered / total * 100 },
  projectRuntime: 'unmeasured: Roblox engine scripts require Studio instrumentation',
  changedLines: 'all DriveModel lines are new; engine changed lines remain unmeasured',
};
console.log(JSON.stringify(result, null, 2));
writeFileSync('coverage-summary.json', JSON.stringify(result, null, 2) + '\n');
if (covered !== total) throw new Error('Pure-rule coverage is below its measured full-line baseline');
