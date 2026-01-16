# GitHub Rulesets

本目錄包含儲存庫的 Rulesets 設定檔。

## 設定檔說明

| 檔案 | 用途 |
|------|------|
| `main-branch-protection.json` | 保護主分支 (main)，要求 PR 審核、禁止強制推送和刪除 |
| `tag-protection.json` | 保護 release 標籤，禁止刪除和強制推送 |

## 如何匯入

使用 GitHub CLI 匯入 rulesets（請將 `{owner}` 和 `{repo}` 替換為實際的儲存庫擁有者和名稱）：

```bash
# 匯入主分支保護規則
gh api repos/{owner}/{repo}/rulesets --method POST --input .github/rulesets/main-branch-protection.json

# 匯入標籤保護規則
gh api repos/{owner}/{repo}/rulesets --method POST --input .github/rulesets/tag-protection.json
```

或使用環境變數：

```bash
# 設定儲存庫資訊
REPO_OWNER="pingqLIN"
REPO_NAME="GemiKey"

# 匯入規則
gh api repos/$REPO_OWNER/$REPO_NAME/rulesets --method POST --input .github/rulesets/main-branch-protection.json
gh api repos/$REPO_OWNER/$REPO_NAME/rulesets --method POST --input .github/rulesets/tag-protection.json
```

## 注意事項

- 這些設定檔作為文件記錄和備份用途
- 透過上述 GitHub API 指令匯入後，rulesets 將會被**實際啟用**並生效
- 也可以在 GitHub 網頁介面手動設定：Settings → Rules → Rulesets
- 匯入前請確認已有適當的權限（需要 repository admin 權限）
