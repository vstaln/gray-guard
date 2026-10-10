<div align="center">
  <img alt="gray-guard" src="assets/icon.svg" width="120" height="120" />
  <h1>gray-guard</h1>
  <p><strong>Scan written code for dangerous patterns and warn the model after each write.</strong></p>
  <p>
    <a href="https://gray.alignment.id">Website</a> ·
    <a href="https://gray.alignment.id/plugins/gray-guard">Store</a> ·
    <a href="https://github.com/vstaln/gray-guard">Source</a> ·
    <a href="https://github.com/vstaln/gray">gray</a>
  </p>
  <p>
    <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-1c1c20?style=flat-square&labelColor=0a0a0b" /></a>
    <a href="https://www.rust-lang.org"><img alt="Built with Rust" src="https://img.shields.io/badge/built%20with-rust-1c1c20?style=flat-square&labelColor=0a0a0b&logo=rust&logoColor=d4a373" /></a>
    <a href="https://gray.alignment.id/plugins/gray-guard"><img alt="gray plugin" src="https://img.shields.io/badge/gray-plugin-1c1c20?style=flat-square&labelColor=0a0a0b&color=7aa2f7" /></a>
  </p>
</div>

<br/>

```bash
gray plugin install gray-guard
```

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

## Tags

`gray` `plugin` `guard` `rust`

---
Part of the [gray](https://github.com/vstaln/gray) plugin ecosystem —
the open-source AI agent harness. <https://gray.alignment.id>
