# gray-guard

Security warnings on file writes — a gray sidecar plugin port of hermes'
`security-guidance` (patterns forked from Anthropic's
claude-plugins-official, Apache-2.0).

`tool/after` can't see call args, so `tool/before` stashes the write's
`(path, content)` per `(session, tool)` in memory; `tool/after` scans it
against 25 dangerous-code rules and appends a non-blocking
`⚠️ Security warning: <rule> — <reminder>` block to the tool result.
The file is written; the model sees the warning next turn and can fix or
justify.

## Covered patterns (25 rules)

GitHub Actions workflow edits (`${{ github.event.* }}` injection),
`child_process.exec`/`exec(`, `new Function`, `eval(`, `dangerouslySetInnerHTML`,
`document.write`, `.innerHTML =`/`.outerHTML =`/`insertAdjacentHTML`,
pickle/cPickle/cloudpickle/dill/joblib/pandas/numpy `allow_pickle`,
`os.system`, `subprocess … shell=True`, Go `exec.Command("sh"…)`,
`yaml.load`/`yaml.unsafe_load` sans SafeLoader, `crypto.createCipher`,
AES-ECB, TLS verify disabled (`verify=False`, `rejectUnauthorized`,
`InsecureSkipVerify`, …), `marshal.loads`, `shelve.open`, unsafe XML
parsers (XXE), `<script src>` without SRI, `torch.load` sans
`weights_only=True`.

## Scan targets

- Write-shaped tools: `write`, `edit`, `patch`, `write_file`,
  `apply_patch`, `multi_edit`, `notebook_edit` — every string arg scanned,
  `path`/`file_path` drives per-rule path filters.
- `bash` commands containing a heredoc (`<<`) — the `>` redirect target is
  used as the pseudo-path.

Scan cap: 256 KiB per string. Error results are not annotated.

## Env

- `SECURITY_GUIDANCE_BLOCK=1` — deny the write in `tool/before` instead of
  warning after.
- `SECURITY_GUIDANCE_DISABLE=1` — plugin off.

## Wire methods used

- `plugin/manifest`, `plugin/shutdown`
- `tool/before` (hook) — stash + optional block-mode deny
- `tool/after` (hook) — appends warning block to result content

## Install

```sh
gray plugin install guard
```

## Develop

```sh
cargo test
cargo build --release
gray account check
```
