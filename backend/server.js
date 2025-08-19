import express from 'express';
import morgan from 'morgan';
import { spawn } from 'child_process';
import { readFileSync, writeFileSync, existsSync, mkdirSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const app = express();
app.use(morgan('dev'));
app.use(express.json({ limit: '1mb' }));
app.use(express.static(resolve(__dirname, '../frontend')));

function run(cmd, args, cwd, env = {}) {
  return new Promise((resolvePromise, reject) => {
    const child = spawn(cmd, args, { cwd, env: { ...process.env, ...env } });
    let out = '';
    let err = '';
    child.stdout.on('data', (d) => (out += d.toString()));
    child.stderr.on('data', (d) => (err += d.toString()));
    child.on('close', (code) => {
      const text = `${out}\n${err}`.trim();
      if (code === 0) resolvePromise(text);
      else reject(new Error(text || `Command failed: ${cmd} ${args.join(' ')}`));
    });
  });
}

function envDir(envName) {
  const base = process.env.TF_WORKDIR || `../infra/environments/${envName}`;
  return resolve(__dirname, base);
}

async function ensureTfvars(dir, tfvarsText) {
  const tfvarsPath = resolve(dir, `${process.env.TF_ENV || 'dev'}.auto.tfvars`);
  writeFileSync(tfvarsPath, tfvarsText);
  return tfvarsPath;
}

async function tfInitPlanApply(kind, envName, tfvarsText) {
  const dir = envDir(envName);
  if (!existsSync(dir)) throw new Error(`Environment directory not found: ${dir}`);
  await ensureTfvars(dir, tfvarsText);
  const initOut = await run('terraform', ['init', '-upgrade'], dir);
  if (kind === 'plan') {
    const planOut = await run('terraform', ['plan', '-no-color'], dir);
    return `INIT:\n${initOut}\n\nPLAN:\n${planOut}`;
  } else {
    const applyOut = await run('terraform', ['apply', '-auto-approve', '-no-color'], dir);
    return `INIT:\n${initOut}\n\nAPPLY:\n${applyOut}`;
  }
}

app.post('/api/plan', async (req, res) => {
  try {
    const envName = (req.body?.cfg?.environment || process.env.TF_ENV || 'dev').toLowerCase();
    const tfvars = req.body?.tfvars || '';
    const out = await tfInitPlanApply('plan', envName, tfvars);
    res.type('text/plain').send(out);
  } catch (e) {
    res.status(500).type('text/plain').send(String(e.message || e));
  }
});

app.post('/api/apply', async (req, res) => {
  try {
    const envName = (req.body?.cfg?.environment || process.env.TF_ENV || 'dev').toLowerCase();
    const tfvars = req.body?.tfvars || '';
    const out = await tfInitPlanApply('apply', envName, tfvars);
    res.type('text/plain').send(out);
  } catch (e) {
    res.status(500).type('text/plain').send(String(e.message || e));
  }
});

const port = process.env.PORT || 8080;
app.listen(port, () => {
  console.log(`Backend listening on :${port}`);
});
