# lang-tutor — 給繁體中文使用者的英文與日文助手

在 Codex 或 Claude Code 工作時順便練習英文或日文。所有文法解說、複習摘要與測驗提示使用繁體中文，例句保留目標語言。

## 支援範圍

- 學習目標只有 **English** 與 **Japanese**；已移除其他語言指南與通用 fallback。
- 母語固定為繁體中文（zh-TW），不用另外設定。
- 日文讀音使用假名，不顯示羅馬字；僅替約 N2／N1 難字或特殊讀音標註假名，一般漢字不標音。此規則不代表學習程度設為 N2。
- 英文或日文輸入：提供精簡文法修正與自然說法，再處理原本的工作。
- 繁體中文輸入：提供目標語言翻譯與字彙說明，再處理工作。
- beginner / intermediate / advanced 三種程度；省略時從前幾則訊息校準。
- 保留慣用縮寫、聊天簡寫與省略大小寫，不把這些當成錯誤。
- 舊設定若指定其他學習語言，會要求改選英文或日文，不會默默替換；舊母語設定則在有效啟動時更新為 zh-TW。

## 安裝

### Codex

```sh
codex plugin marketplace add chihong0522/lang-tutor
codex plugin add lang-tutor@lang-tutor-marketplace
```

安裝或更新後開啟新對話；若清單未刷新，重新啟動 Codex。於對話中使用：

```text
$lang-tutor English beginner
$lang-tutor Japanese beginner
$lang-tutor
```

### Claude Code

```text
/plugin marketplace add chihong0522/lang-tutor
/plugin install lang-tutor@lang-tutor-marketplace
/lang-tutor English beginner
/lang-tutor Japanese beginner
```

若有名稱衝突，可用 `/lang-tutor:lang-tutor`。省略參數會讀取保存的設定。舊的三參數寫法若包含 Chinese / Traditional Chinese / zh-TW，仍可相容。

### 本機開發版本

GitHub 安裝取得已發布的 repo 內容。本機尚未推送的修改可用隔離設定驗證：

```sh
CODEX_HOME=/tmp/lang-tutor-dev codex plugin marketplace add /absolute/path/to/lang-tutor
CODEX_HOME=/tmp/lang-tutor-dev codex plugin add lang-tutor@lang-tutor-marketplace
claude --plugin-dir /absolute/path/to/lang-tutor
```

Codex 與 Claude 共用 `skills/`，分別提供 `.codex-plugin/plugin.json` 與 `.claude-plugin/plugin.json`。Codex CLI 可以讀取此 repo 的 `.claude-plugin/marketplace.json`。

## 複習與測驗

| 功能 | Codex | Claude Code |
|---|---|---|
| 複習摘要 | `$lang-tutor-review` | `/lang-tutor-review` |
| 逐題練習 | `$lang-tutor-review-test` | `/lang-tutor-review-test` |

複習可加 `all` 讀取全部月份；測驗可加分類、`easy` 或 `hard`。兩種功能只採用目前英文或日文目標的紀錄，不會刪除舊紀錄。

## 狀態與提醒

設定保存在 `~/.lang-tutor/prefs.md`，學習回饋保存在 `~/.lang-tutor/log-YYYY-MM.md`。兩個工具使用相同位置；技能遵守各自的檔案權限，不修改專案 auto-memory。紀錄只保存語言學習內容，不複製程式碼、路徑或工作資料。

Claude Code 提供選用的 `UserPromptSubmit` 提醒 hook；Codex 使用共用技能，不依賴此 Claude hook。每個新對話都先啟用 tutor；不要假設安裝後每個對話會自動開啟。

## 驗證

不呼叫模型的檢查：

```sh
python3 test/test_package.py
bash -n test/run-skill-tests.sh
bash -n hooks/lang-tutor-reminder.sh
claude plugin validate .claude-plugin/plugin.json
```

`test/run-skill-tests.sh` 是 Claude 的模型行為 smoke tests，需登入 Claude、jq 與 bc，會使用模型額度。涵蓋路由、日文別名、拒絕其他目標、回饋模式與設定保存；不代表 Codex 模型行為測試。測試會暫存並恢復偏好設定，但可能新增學習紀錄，因此請在獨立測試帳號或環境執行。

## 來源與授權

本 fork 源自 [hamsamilton/lang-tutor](https://github.com/hamsamilton/lang-tutor)，保留 MIT 授權。此版本聚焦繁體中文母語者的英文／日文學習，支援 Codex 與 Claude Code，並保留回饋紀錄與複習功能。
