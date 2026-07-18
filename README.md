# hermes-pc-cleaner

Hermes skill for safe Windows PC cleanup.

## What it does

Wraps mature CLI tools (czkawka, dust) with safety guardrails so a non-technical user can safely clean their PC.

## Tools used

| Tool | Purpose |
|------|--------|
| [czkawka](https://github.com/qarmin/czkawka) | Find duplicates, empty files, big files, temp files |
| [dust](https://github.com/bootandy/dust) | Disk usage visualization |
| PowerShell | System cleanup (temp, recycle bin, browser cache) |

## Safety

1. **Scan first, act later** — never delete without showing results
2. **User confirmation required** — must say "yes" before any cleanup
3. **Move to backup, not delete** — everything goes to a backup dir first
4. **Exclude critical dirs** — never touches Windows, Program Files, Desktop
5. **Log all operations** — every action recorded

## Install

Copy the `pc-cleaner/` directory to `~/.hermes/skills/` on the target machine.

Then run the install script from Hermes:

```
Run the install script at ~/.hermes/skills/pc-cleaner/scripts/install.ps1
```

## Usage

Just tell Hermes:

- "帮我看看电脑空间"
- "找一下重复文件"
- "清理一下临时文件"
- "电脑太卡了"

## License

MIT