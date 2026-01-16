# GitHub Rulesets

本目錄包含儲存庫的 Rulesets 設定檔。

## 設定檔說明

| 檔案 | 用途 |
|------|------|
| `main-branch-protection.json` | 保護主分支 (main)，要求 PR 審核、禁止強制推送和刪除 |
| `tag-protection.json` | 保護 release 標籤，禁止刪除和強制推送 |

## 如何匯入

使用 GitHub CLI 匯入 rulesets：

```bash
# 匯入主分支保護規則
gh api repos/{owner}/{repo}/rulesets --method POST --input .github/rulesets/main-branch-protection.json

# 匯入標籤保護規則
gh api repos/{owner}/{repo}/rulesets --method POST --input .github/rulesets/tag-protection.json
```

## 注意事項

- 這些設定檔僅作為文件記錄和備份用途
- 實際啟用需要透過 GitHub API 或在 Settings → Rules → Rulesets 手動設定
