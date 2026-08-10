/**
 * Strip the buggy `export const __esModule = !0;` line that leaks out of
 * `trtc-cloud-js-sdk`'s published ESM build.
 *
 * Why this exists
 * ---------------
 * `trtc-cloud-js-sdk.esm.js` (as published to npm) contains a stray
 * declaration:
 *
 *   export const __esModule = !0;
 *
 * That line accidentally re-exports the CommonJS `__esModule` marker as a
 * real ESM binding. Rollup's CJS/ESM interop helper first calls
 * `Object.defineProperty(ns, "__esModule", { value: true })` (which creates
 * a NON-configurable descriptor by default) and then iterates `Object.keys`
 * of the source module. Because the source now has its own `__esModule`
 * key, Rollup calls `Object.defineProperty` a second time and crashes at
 * runtime with:
 *
 *   Uncaught TypeError: Cannot redefine property: __esModule
 *
 * Only Vite 3 / Rollup 2 production builds hit this; Vite 5 / Rollup 4
 * emits a safer interop helper that already handles the case, and Vite dev
 * (any version) serves native ESM without the interop helper at all.
 *
 * The safest fix is to remove the offending line from the installed
 * artifact. This script runs from `prebuild` so it applies regardless of
 * the package manager (npm / pnpm / yarn / CI). It is idempotent and safe
 * to run multiple times.
 */
const fs = require('fs');
const path = require('path');

const OFFENDING = /export\s+const\s+__esModule\s*=\s*!0\s*;?/g;

const targets = [
  'node_modules/trtc-cloud-js-sdk/trtc-cloud-js-sdk.esm.js',
];

let patchedCount = 0;
for (const rel of targets) {
  const abs = path.resolve(__dirname, '..', rel);
  if (!fs.existsSync(abs)) {
    // Not installed yet or hoisted elsewhere; ignore silently.
    continue;
  }
  const before = fs.readFileSync(abs, 'utf8');
  if (!OFFENDING.test(before)) continue;
  // Reset regex state (test() with /g mutates lastIndex).
  OFFENDING.lastIndex = 0;
  const after = before.replace(OFFENDING, '');
  fs.writeFileSync(abs, after, 'utf8');
  console.log(`[patch-trtc-esm] stripped __esModule export from ${rel}`);
  patchedCount++;
}

if (patchedCount === 0) {
  console.log('[patch-trtc-esm] nothing to patch (already clean or not installed).');
}
