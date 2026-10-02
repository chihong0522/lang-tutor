# lang-tutor — 給繁體中文使用者的英文與日文助手

在 Codex 或 Claude Code 工作時順便練習英文或日文。所有文法解說、複習摘要與測驗提示使用繁體中文，例句保留目標語言。

## 使用畫面

以下是實際的輸出格式，Codex 與 Claude Code 相同。語言回饋會先出現，接著才是原本的工作回覆。

### 用英文下指令 → 語言回饋

> Why build fail? And is suitable for our repo?

> **🗣️ 語言回饋**
>
> ❌ Why build fail?
> ✅ Why did the build fail?
> 　　→ 英文問句要有助動詞 did 撐起時態，主要動詞回原形；特定那一次 build 要加 the。中文問句不換語序，是主要干擾來源
>
> ❌ And is suitable for our repo?
> ✅ And is it suitable for our repo?
> 　　→ 英文子句不能省略主詞，要補 it
>
> 💡 **更道地的說法**
> 　　Why did the build fail, and would this approach work for our repo?

### 用中文下指令 → 翻譯與拆解

> 幫我確認這個改動會不會影響到其他功能

> **🗣️ 繁體中文 → 英文**
>
> 📝 **目標語言說法**
> 　　Can you double-check whether this change affects anything else?
>
> 🔑 **關鍵字彙**
> 　　• double-check — 再確認一次 · 比 confirm 口語，後面接 whether / that 子句
> 　　• affect — 影響 · 動詞；名詞是 effect，兩者常被混用
>
> 🔍 **間接問句**
> 　　「會不會…」放在 check / know / confirm 後面時用 whether 引導，並改回陳述語序：whether this change affects，不是 whether does this change affect

### `/lang-tutor-review` → 複習摘要

讀取 `~/.lang-tutor/log-*.md`，依根本原因分類，並列出你自己寫過的句子。不出題，也不需要回覆。

<details>
<summary>展開範例</summary>

> ## 1. 問句沒有 do/does/did 撐住（6 筆）
>
> **規則**：送出問句前，先看句中有沒有 do/does/did/is/can，而且它要放在主詞前面。如果是嵌在 know / confirm 後面的間接問句，就改用 whether 加陳述語序。
> **為什麼**：中文問句只在句尾加「嗎」，語序不變，所以會出現兩種方向相反的錯：直接問句忘了倒裝，間接問句反而多倒裝了。
>
> | ❌ 你寫的 | ✅ 正確 |
> |---|---|
> | why build fail? | Why did the build fail? |
> | what kind of linker we used before? | What kind of linker did we use before? |
> | wanna confirm do we really need it | I want to confirm whether we really need it |
>
> ## 2. 冠詞 the / a / an（4 筆）
> …
>
> ## 已經在改善的
> - 「let 接第二個動詞」只出現在月初，之後沒再出現
>
> ## 還沒自己用過的
> - `double-check`、`side effect`、`walk me through`
>
> ## 下一步
> 先練「問句的助動詞」：`/lang-tutor-review-test 助動詞`

</details>

### `/lang-tutor-review-test` → 逐題練習

從紀錄挑出一個弱點，一次問一題，題目都放在工作情境裡。預設是 `easy`：每題只有一個錯，並且會告訴你是哪一類錯。

<details>
<summary>展開範例</summary>

> **目標**：問句的助動詞。你的紀錄裡有 6 筆問句缺 do/does/did。
> **規則**：wh- 問句要把助動詞放到主詞前面，主要動詞回原形。
>
> **第 1 題（code review）**：這句的助動詞有問題，改一下
> 　　What kind of linker we used before?

使用者回答：

> What kind of linker did we use before?

> **正確。** did 提前、use 回原形，兩點都對。這個句型你在紀錄裡錯過兩次，這次自己改對了。
>
> **第 2 題（stand-up）**：填空
> 　　Why ___ the test fail on CI yesterday?

</details>

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

## 支援範圍

- 學習目標只有 **English** 與 **Japanese**；已移除其他語言指南與通用 fallback。
- 母語固定為繁體中文（zh-TW），不用另外設定。
- 日文讀音使用假名，不顯示羅馬字；僅替約 N2／N1 難字或特殊讀音標註假名，一般漢字不標音。此規則不代表學習程度設為 N2。
- 英文或日文輸入：提供精簡文法修正與自然說法，再處理原本的工作。
- 繁體中文輸入：提供目標語言翻譯與字彙說明，再處理工作。
- beginner / intermediate / advanced 三種程度；省略時從前幾則訊息校準。
- 保留慣用縮寫、聊天簡寫與省略大小寫，不把這些當成錯誤。
- 舊設定若指定其他學習語言，會要求改選英文或日文，不會默默替換；舊母語設定則在有效啟動時更新為 zh-TW。

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

兩個 host 都提供選用的 `UserPromptSubmit` 提醒 hook：

- **Codex**：偵測該對話中的明確 `$lang-tutor` 啟用指令，之後每則訊息補上 tutor 提醒；對話結束時清除啟用狀態。狀態以 Codex plugin 的 `PLUGIN_DATA` 儲存，不解析不穩定的 transcript 格式。
- **Claude Code**：檢查 transcript 是否載入 `Language Tutor Mode` 標記，再補上提醒。

Codex 安裝後須在 hook trust review 中檢查並信任目前版本的 hook 定義，否則 hook 不會執行。啟用 plugin 或安裝技能不會自動啟用 tutor；每個新對話仍須使用 `$lang-tutor` 或 `/lang-tutor` 明確啟動。

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
