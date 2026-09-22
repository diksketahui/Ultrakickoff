#!/usr/bin/env node
// Pantau GitHub Actions workflow `godot` hingga hijau, memakai node + curl binary.
// Tanpa dependencies/npm install. Token via env GH_PAT (jangan commit).
// Usage:
//   GH_PAT=xxx node scripts/watch-godot.mjs --sha <commit_sha>
//   GH_PAT=xxx node scripts/watch-godot.mjs --run-id <id>
import { spawnSync } from "node:child_process";

const REPO = process.env.GH_REPO || "diksketahui/Ultrakickoff";
const TOKEN = process.env.GH_PAT || process.env.GITHUB_TOKEN || "";
const WORKFLOW = "godot.yml";

function parseArgs() {
  const a = { sha: "", runId: "", timeout: 1800, interval: 20 };
  const argv = process.argv.slice(2);
  for (let i = 0; i < argv.length; i++) {
    if (argv[i] === "--sha") a.sha = argv[++i] || "";
    else if (argv[i] === "--run-id") a.runId = argv[++i] || "";
    else if (argv[i] === "--timeout") a.timeout = parseInt(argv[++i] || "1800", 10);
    else if (argv[i] === "--interval") a.interval = parseInt(argv[++i] || "20", 10);
  }
  return a;
}

function curlJson(url) {
  const args = ["-sS", "-H", "Accept: application/vnd.github+json", url];
  if (TOKEN) args.splice(1, 0, "-H", `Authorization: Bearer ${TOKEN}`);
  const r = spawnSync("curl", args, { encoding: "utf8", maxBuffer: 10 * 1024 * 1024 });
  if (r.status !== 0) throw new Error(`curl gagal: ${(r.stderr || "").slice(0, 500)}`);
  return JSON.parse(r.stdout);
}

function sleep(ms) {
  return new Promise((res) => setTimeout(res, ms));
}

const args = parseArgs();
if (!TOKEN) {
  console.error("GH_PAT kosong. Set env GH_PAT dulu (jangan print token).");
  process.exit(2);
}

let runId = args.runId;
const deadline = Date.now() + args.timeout * 1000;
console.log(`[watch] repo=${REPO} workflow=${WORKFLOW} sha=${args.sha || "-"} runId=${runId || "-"}`);

while (true) {
  if (Date.now() > deadline) {
    console.error("[watch] TIMEOUT: workflow belum hijau dalam batas waktu.");
    process.exit(1);
  }
  try {
    if (!runId) {
      // cari run terbaru untuk sha (atau terbaru workflow godot.yml)
      let url;
      if (args.sha) {
        url = `https://api.github.com/repos/${REPO}/actions/workflows/${WORKFLOW}/runs?per_page=10&head_sha=${encodeURIComponent(args.sha)}`;
      } else {
        url = `https://api.github.com/repos/${REPO}/actions/workflows/${WORKFLOW}/runs?per_page=5`;
      }
      const data = curlJson(url);
      const runs = data.workflow_runs || [];
      if (runs.length === 0) {
        console.log("[watch] belum ada run, tunggu...");
      } else {
        runId = String(runs[0].id);
        console.log(`[watch] run ditemukan: id=${runId} sha=${runs[0].head_sha?.slice(0, 7)} status=${runs[0].status} conclusion=${runs[0].conclusion}`);
      }
    }
    if (runId) {
      const run = curlJson(`https://api.github.com/repos/${REPO}/actions/runs/${runId}`);
      const status = run.status;
      const conclusion = run.conclusion;
      const name = run.name;
      console.log(`[watch] ${new Date().toISOString()} run=${runId} workflow=${name} status=${status} conclusion=${conclusion || "-"}`);
      if (status === "completed") {
        const jobs = curlJson(`https://api.github.com/repos/${REPO}/actions/runs/${runId}/jobs?per_page=50`);
        for (const j of jobs.jobs || []) {
          console.log(`  - job ${j.name}: ${j.status}/${j.conclusion}`);
          for (const s of j.steps || []) {
            if (s.conclusion && s.conclusion !== "success" && s.conclusion !== "skipped") {
              console.log(`    x step ${s.name}: ${s.conclusion}`);
            }
          }
        }
        console.log(`HTML_URL=${run.html_url}`);
        if (conclusion === "success") {
          console.log("[watch] HIJAU ✅ godot build sukses.");
          process.exit(0);
        } else {
          console.error(`[watch] MERAH ❌ conclusion=${conclusion}`);
          process.exit(1);
        }
      }
    }
  } catch (e) {
    console.error(`[watch] error poll: ${e.message}`);
  }
  await sleep(args.interval * 1000);
}
