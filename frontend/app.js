const form = document.getElementById('deploy-form');
const out = document.getElementById('output');

function collect() {
  const data = new FormData(form);
  const cfg = Object.fromEntries(data.entries());
  cfg.enable_app_hosting = data.get('enable_app_hosting') === 'on';
  cfg.ai_foundry = data.get('ai_foundry') === 'on';
  cfg.openai = data.get('openai') === 'on';
  cfg.openai_model = cfg.openai_model || 'gpt-4o';
  cfg.openai_version = cfg.openai_version || '2024-05-01';
  return cfg;
}

function tfvarsFromConfig(cfg) {
  const deployments = `{
    "${cfg.openai_model}": {
      model_format  = "OpenAI"
      model_name    = "${cfg.openai_model}"
      model_version = "${cfg.openai_version}"
      scale_type    = "Standard"
    }
  }`;

  return `name = "${cfg.name}"
location = "${cfg.location}"
tags = { environment = "${cfg.environment}" }
enable_app_hosting = ${cfg.enable_app_hosting}
openai_deployments = ${deployments}
`;
}

async function post(path, payload) {
  const res = await fetch(`/api/${path}`, {
    method: 'POST', headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });
  const text = await res.text();
  return { ok: res.ok, text };
}

document.getElementById('plan').addEventListener('click', async () => {
  const cfg = collect();
  out.textContent = 'Planning...';
  const resp = await post('plan', { cfg, tfvars: tfvarsFromConfig(cfg) });
  out.textContent = resp.text;
});

form.addEventListener('submit', async (e) => {
  e.preventDefault();
  const cfg = collect();
  out.textContent = 'Applying...';
  const resp = await post('apply', { cfg, tfvars: tfvarsFromConfig(cfg) });
  out.textContent = resp.text;
});
