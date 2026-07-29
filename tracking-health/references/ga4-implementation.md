# GA4 實作：事件命名、電商 schema、營收正確性

主檔 `SKILL.md` 的紅線 3、4 的展開。這份檔案回答「事件要怎麼命名、電商事件要帶什麼、為什麼營收數字對不起來」。

## 追蹤計畫框架

```
事件名稱 | 分類 | 屬性 | 觸發時機 | 備註
```

| 類型 | 範例 |
|------|------|
| 頁面瀏覽 | 自動觸發，可附加額外屬性 |
| 使用者行為 | 按鈕點擊、表單送出、功能使用 |
| 系統事件 | 完成註冊、購買、訂閱異動 |
| 自訂轉換 | 目標達成、漏斗階段 |

## 事件命名規則

### 一般自訂事件：物件_動作

```
signup_completed
button_clicked
form_submitted
article_read
```

- 全小寫、底線分隔
- 要具體：`cta_hero_clicked` 優於 `button_clicked`
- 情境放在屬性裡，不要塞進事件名稱
- 避免空格與特殊符號
- 每個命名決策都記錄下來

**電商事件是例外，不要自創命名。** 但要**精確說明「不用官方保留字會壞什麼」，不要誇大**：自訂事件名稱（例如 `product_viewed`、`checkout_started`）一樣可以在 GA4 管理介面標記為關鍵事件（Key Event）並匯入 Google Ads 當轉換動作——這件事本身不會被擋下來。真正壞掉的是：GA4 內建的 Monetization／電商報表（商品層級營收、購買漏斗、與 Shopping／購物廣告串接的商品資料）只認官方保留字與對應的 `items` 參數結構，自訂事件不會出現在這些報表裡；`transaction_id` 也只有官方 `purchase` 事件會拿來做交易去重，自訂事件沒有這個機制，容易重複計算同一筆訂單的營收。

## 核心事件

### 官網／行銷網站

| 事件 | 屬性 |
|------|------|
| cta_clicked | button_text, location |
| form_submitted | form_type |
| signup_completed | method, source |
| demo_requested | - |
| line_oa_add_clicked | source（點擊「加入好友」按鈕的頁面位置／來源）——**官網只量得到這一層**，理由與 `line_oa_add_confirmed` 的成立前提見 [line-measurement.md](line-measurement.md) |

### 產品／App（非付款的行為事件）

| 事件 | 屬性 |
|------|------|
| onboarding_step_completed | step_number, step_name |
| feature_used | feature_name |
| subscription_started | plan（訂閱生命週期狀態變化，不是付款動作本身） |
| subscription_plan_changed | old_plan, new_plan |
| subscription_cancelled | reason |

**訂閱制產品的付款事件一律用官方 `purchase`，不要用自訂的 `purchase_completed`**：不管是零售電商的單次購買，還是訂閱制的首次扣款／週期性續訂扣款，只要是「使用者實際付了錢」這個動作，都用官方 `purchase` 事件。為訂閱制另外發明一套自訂命名，會讓營收報表對不起來。`subscription_started`／`subscription_plan_changed`／`subscription_cancelled` 記錄的是訂閱**狀態**變化，通常跟 `purchase` 在同一次操作中一起觸發（訂閱成立時，`purchase` 記這筆錢、`subscription_started` 記狀態），但兩者職責不同，不要互相取代。**週期性續扣沒有前端頁面可埋，必須由後端支付 webhook 觸發 `purchase`**，見下方「`purchase` 的權威觸發來源」。

## 電商事件（GA4 官方 ecommerce schema，強制使用官方保留字）

依 GA4 官方文件（<https://developers.google.com/analytics/devguides/collection/ga4/reference/events>，查證日期：2026-07-20），電商事件的參數必要性分「required」「conditionally required」「optional」三級：

| GA4 官方事件 | 觸發時機 | 事件層級參數必要性 |
|--------------|----------|----------|
| `view_item` | 瀏覽商品詳情頁 | **required：`items`（陣列）**；conditionally required：`currency`（**若**有帶 `value` 才必要，`value` 本身不是強制欄位）；optional：`value` |
| `add_to_cart` | 加入購物車 | **required：`items`**；conditionally required：`currency`（同上）；optional：`value` |
| `begin_checkout` | 進入結帳流程 | **required：`items`**；conditionally required：`currency`（同上）；optional：`value` |
| `purchase` | 後端確認付款成功時（含訂閱首次扣款與週期性續訂扣款）——**不是「使用者看到付款成功頁」** | **required：`transaction_id`、`items`**；conditionally required：`currency`（**若**帶了 `value` 才必要——多數電商會帶 `value` 做營收報表，但 `value` 本身不是 GA4 強制擋下事件的欄位，不要假設它永遠存在）；optional：`value`、`shipping`、`tax` |

**`items` 陣列內部的欄位必要性**：每個項目物件裡，**`item_id` 與 `item_name` 只要求擇一提供**（不是兩個都要），`price`、`quantity`、`item_category` 都是選填。實務建議仍然盡量都填（商品層級報表與 Google Ads 動態再行銷素材需要完整資料），但技術上只有「`item_id` 或 `item_name` 至少一個」加上事件層級的 `transaction_id`／`items` 陣列本身，才是真正會被 GA4 判定缺漏的必要欄位。

### `transaction_id` 不可反查特定人

`transaction_id` 是 `purchase` 的必要欄位，GA4 用它防止同一筆交易被重複計算，但**不要直接把客戶看得到、可預期規律的訂單編號（如 `ORDER_20260720_001`）當成 `transaction_id`**——GA4 資料常會被匯出（BigQuery、Google Ads 轉換匯入、代理商權限）給比對原始訂單系統更小範圍的對象看到，連號、可預期的識別碼容易被列舉或跟其他外洩資料集比對回特定客戶。正確做法：`transaction_id` 用**跟客戶看到的訂單編號無關聯、隨機產生的不透明值**（例如 UUID），後端另外維護「GA4 transaction_id ↔ 內部訂單編號」的對應表（存在自己的資料庫，不進 GA4）。訂閱制續訂扣款一樣適用：每次扣款產生一個新的隨機 ID，不要用「訂閱 ID + 序號」這種可預期組合。

**這個隨機 `transaction_id` 本身是假名識別碼，也就是個資**（你後端那張對應表就是反查管道），不是「處理過所以沒事了」。它可以進 GA4——直接識別資訊不行、假名識別碼可以，但要過保留期限與權限控管那四個前提，見 [privacy-compliance.md](privacy-compliance.md)「直接識別資訊與假名識別碼」。特別注意**那張對應表的存取權限**：能拿到它的人，看到的等同直接識別資訊。

### `transaction_id` 去重的三種情況（除錯時不要簡化成「ID 不能重複」）

| 情況 | GA4 的行為 | 這是問題嗎 |
|---|---|---|
| 同一筆交易、每次都帶**同一個** ID | 判定為同一筆交易的重複事件，只計一次 | **不是問題，這正是設計目的**——同一則支付 webhook 被金流商重送、或 outbox 重試未確認的事件，都應該落在這一格 |
| 同一筆交易、每次帶**不同** ID（或沒帶 ID） | 每個事件都被當成獨立交易 | **是問題：營收灌水**。典型成因是前端每次載入就 `crypto.randomUUID()` 現產一個，或後端沒有把 ID 持久化 |
| **不同**交易、共用同一個 ID | 後來的交易被當成前一筆的重複事件而被丟棄 | **是問題：營收漏算**。典型成因是拿會員編號、購物車 ID、或「訂閱 ID」當 `transaction_id`（訂閱續訂每次扣款都是獨立交易，必須各自有新 ID） |

一句話：**ID 要跟「交易」一對一綁定**——同一筆交易永遠同一個 ID，不同交易永遠不同 ID。

同一筆交易重試或頁面重載時要重用同一個**持久化**的 ID：ID 應該從伺服器端這筆交易記錄本身讀出來（跟這筆訂單綁定、持久化保存），每次觸發 `purchase` 都帶同一個值。寫在前端、頁面重載就重新產生的做法會失去去重效果。

### `purchase` 的權威觸發來源是後端訂單確認或支付 webhook

「在付款成功頁埋 `purchase`」是最常見的做法，也是最常見的營收數字對不上的原因。這個做法**兩個方向都會錯**：

- **會漏記**：①**訂閱的週期性自動續扣根本沒有前端**——使用者不會每個月回來看一次付款成功頁，這些扣款在前端埋點的架構下完全量不到，訂閱制的營收會系統性短少 ②使用者付完款直接關掉分頁、或第三方支付（LINE Pay、街口、超商代碼、ATM 轉帳）沒有導回成功頁 ③超商／ATM 這類非即時付款，「下單」跟「付款完成」差好幾天，成功頁根本不是付款完成的時點
- **會早記或誤記**：到達成功頁不等於錢真的入帳——授權成功但請款失敗、風控事後攔截、使用者立刻取消，都會讓一筆已經記進 GA4 的營收其實不存在

**正確做法：以後端「訂單狀態變成已付款」為權威來源，而且整筆交易只送一次 GA4 `purchase`**——收到金流商的支付 webhook（或主動查詢對帳結果）並確認狀態後，由**伺服器端用 GA4 Measurement Protocol 送出**。付款成功頁**不送 GA4 `purchase`**，它不是次要來源、不是備援，就是不送。

- **「前端先送、後端確認後再送一次」不是安全做法，不要這樣設計**。`transaction_id` 去重只在**同一個 GA4 資料串流、且 GA4 判定為同一個使用者**時才成立；前端 `gtag` 用的是瀏覽器 cookie 裡的 `client_id`，後端 Measurement Protocol 若沒有沿用同一個 `client_id`，兩筆會落在不同使用者身上，GA4 不保證會併成一筆。更根本的問題是**去重不等於更正**：前端先送的那筆若金額錯誤、或付款最後根本沒成立，後端這筆蓋不掉它——`transaction_id` 沒有「撤回」語意，只有 `refund` 能沖銷，而且沖銷是另一筆事件不是修正
- **瀏覽器端要觸發別的廣告平台轉換代碼是另一件事，不要混為一談**。有些團隊會在付款成功頁跑 Google Ads 轉換代碼、Meta Pixel `Purchase`、LINE Tag 轉換——那些是**各該廣告平台自己的轉換事件**，跟 GA4 各走各的管道，**不構成第二筆 GA4 `purchase`**。可以做，但要滿足兩個條件：①**等後端付款確認的回應回來才觸發**，不是到達成功頁就觸發（否則廣告平台那邊一樣會早記）②那段程式碼裡**不得出現 `gtag('event', 'purchase', ...)` 或任何往 GA4 資料串流送 `purchase` 的呼叫**。健檢時看到成功頁有 GA4 `purchase`，不論後端有沒有送，都是要修的問題
- **訂閱續扣一律走後端**：每次扣款是一筆獨立交易，各自產生新的隨機 `transaction_id`，由支付 webhook 觸發
- **金流 webhook 的驗證方式不能比照 LINE**（見下節「金流 webhook 驗證」），但**驗簽＋冪等去重這兩件事一定要做**，否則偽造的付款通知會直接變成假營收
- **退款／取消**要對應送出 GA4 的 `refund` 事件（帶同一個 `transaction_id`），不要只在自己的資料庫改狀態而放著 GA4 的營收數字不動

下面是 payload 形狀的示意（**這是後端 Measurement Protocol 的事件內容**，完整請求格式見下節）：

```json
{
  "name": "purchase",
  "params": {
    "transaction_id": "a1e4c9f0-6b2d-4e77-9c3a-8f21d6b7c9e2",
    "currency": "TWD",
    "value": 1280,
    "items": [
      { "item_id": "SKU123", "item_name": "保濕精華", "price": 640, "quantity": 2 }
    ]
  }
}
```

`transaction_id` 是後端在建立訂單時產生並持久化的隨機 UUID，對應表存在自己後端。**這份 payload 沒有前端版本**——本節開頭那條規則沒有例外。

**適用範圍**：這套 ecommerce schema 只適用於**能安裝 GA4 的自有網站**（自架站、91APP、Shopline 等）。蝦皮、MOMO 這類封閉電商平台不開放賣家安裝第三方追蹤代碼，這些平台上的行為無法用這套 schema 追蹤，只能參考平台後台自帶的報表，見 [utm-and-attribution.md](utm-and-attribution.md)。

### 後端送事件：Measurement Protocol 最小規格

只要事件是由伺服器送的（後端 `purchase`、LINE `follow` 加好友總數），走的就是 GA4 Measurement Protocol。**規格沒填對的失敗是靜默的**——所以下面四件事都要照做。

**① 最小請求**

```
POST https://www.google-analytics.com/mp/collect?measurement_id=G-XXXXXXX&api_secret=<SECRET>
Content-Type: application/json

{
  "client_id": "1234567890.1234567890",
  "events": [
    { "name": "purchase", "params": { "transaction_id": "...", "currency": "TWD", "value": 1280, "items": [...] } }
  ]
}
```

| 欄位 | 位置 | 說明 |
|---|---|---|
| `measurement_id` | query string | Web 資料串流的 `G-` 開頭 ID（**不是**資源 ID、不是 App 用的 `firebase_app_id`） |
| `api_secret` | query string | 在「管理 → 資料串流 → Measurement Protocol API 密鑰」建立。**只能存在後端環境變數／密鑰管理服務**，一旦出現在前端程式碼或版本庫，任何人都能用它偽造事件灌你的成效數字，必須立刻作廢重發。**完整的 request URL（含 `api_secret`）不得寫進任何 access log、APM trace、例外堆疊或 outbox 的 `last_error` 欄位**——這些地方通常比程式碼庫更少人注意到，卻一樣會外洩；送出前組好含密鑰的 URL，記錄時只留路徑與遮罩過的參數 |
| `client_id` | body 必要 | 這筆事件要算在哪個使用者身上。詳見下面第 ③ 點 |
| `events` | body 必要 | 事件陣列，事件參數的必要性跟前端 gtag 完全相同（見上方 ecommerce schema 表） |

**② 一般端點回 2xx 不代表事件有效**

`/mp/collect` 對格式錯誤、事件名稱不合法、缺欄位一律回 2xx 且沒有錯誤訊息。**驗證一定要打 `https://www.google-analytics.com/debug/mp/collect`**（同樣的 query string 與 body），它會回一個 `validationMessages` 陣列——空陣列才代表這個 payload 通過驗證。上線前每一種後端事件都要跑一次 debug 端點並把回應存進驗證紀錄，見 [debug-validation.md](debug-validation.md)。

**③ `client_id` 決定事件能不能跟網站行為串起來**

- **有網站來源時**：從瀏覽器的 `_ga` cookie 取出 `client_id`（格式為 `GA1.1.<client_id>` 的後兩段，即 `1234567890.1234567890`），在下單流程中隨訂單一起存進後端資料庫，後端送事件時沿用這個值。這是唯一能讓後端 `purchase` 跟使用者前面的瀏覽行為落在同一個使用者身上的做法
- **session 關聯是另一回事**：即使 `client_id` 對了，後端事件也不會自動掛進使用者當時那個 session。要做到需要另外帶 `session_id`（同樣從前端取得並隨訂單存下）與 `timestamp_micros`，而且 Measurement Protocol 對回填時間有上限，隔太久的事件不會被歸進原 session。**歸因報表因此可能把後端 `purchase` 算成 direct**——這是已知限制，要在追蹤計畫文件裡寫清楚，不要事後被當成「追蹤壞了」
- **沒有合法網站 `client_id` 時不要亂編**：隨機產生 `client_id` 會製造大量只有一個事件的假使用者，把使用者數與轉換率全部弄髒。LINE `follow` 這種純後端、沒有對應瀏覽器 session 的計數（見 [line-measurement.md](line-measurement.md)），**總數留在自己的資料庫做報表**，不要為了「看起來有進 GA4」而灌假 `client_id`

**④ 冪等：要用有狀態的 outbox，不是「已存在就跳過」**

Measurement Protocol 沒有重試去重機制，重送就是重複計算——但**單純「送出前建一筆 unique 紀錄、下次看到紀錄存在就跳過」會靜默漏數**：紀錄建立之後、GA4 回應之前，請求可能根本沒送出去、可能送到了但回應在網路上掉了、也可能行程直接掛掉。只憑「紀錄存在」無法分辨這三種情況，一律跳過就等於把沒送成功的事件永久丟掉，而且不會有任何錯誤訊息。

正確做法是 **transactional outbox**：事件跟它的狀態存在同一個資料庫交易裡。

**狀態不要叫 `sent`。** 正式端點 `/mp/collect` 對**無效的 payload 一樣回 2xx**（見上方第 ② 點），`api_secret` 失效時也照樣回 2xx，所以「收到 2xx」只能證明**傳輸被接受**，不能證明事件有效、更不能證明它會出現在報表裡。一個叫 `sent` 的狀態，三個月後接手的人一定會讀成「送成功了」，然後拿 `sent` 的筆數去當實際入帳數——**這個誤讀是設計出來的，換掉名字比加註解有效**。所以這裡用兩個名字分開兩件事：

- **`delivered_unverified`**：HTTP 傳輸已被端點接受（2xx）。**這是關於連線的事實，不是關於資料的事實**
- **`verified`**：已經在 GA4 Realtime／報表／BigQuery 匯出裡**實際對到這筆事件**（見下方報表對帳）。只有這個狀態才代表「GA4 真的收到了」

**任何「從 production 2xx 判斷這筆事件成功了」的推論都是錯的**——那個訊號不存在。`delivered_unverified` 停留過久（例如超過對帳週期兩輪）本身就是一個要告警的狀況。

因此**有效性檢查必須發生在送出之前**（入列時），不是事後從回應猜：

- **入列前跑本地 schema 驗證**：事件名稱合法（不是保留名、長度與字元符合規範）、必要參數齊全（`purchase` 要有 `transaction_id`／`currency`／`value`／`items`）、型別正確、`client_id` 格式正確。**沒過就直接寫 `dead_letter`，根本不要送出去**（這類錯誤重試一萬次結果一樣）
- **每一種事件型別在上線前跑一次 `debug/mp/collect`**，把 `validationMessages` 為空的回應存進驗證紀錄（見 [debug-validation.md](debug-validation.md)）。schema 或程式碼改動後要重跑。這是唯一能確認 payload 語意有效的管道，而它是**上線前的動作，不是每筆事件的即時檢查**

| 狀態 | 什麼時候寫進去 | 重試工作要怎麼處理 |
|---|---|---|
| `pending` | 業務交易（訂單狀態改成已付款）**的同一個資料庫交易內**寫入，帶事件 ID 的 unique 約束、完整 payload、`attempt_count`、`next_attempt_at`、`last_error` | 到 `next_attempt_at` 就送出 |
| `retryable` | 送出後遇到**暫時性失敗**：連線逾時、DNS／TLS 失敗、回應遺失、`408`／`429`／`5xx` | **要重試**，照下方退避表排下一次 `next_attempt_at`。這是「狀態未知或暫時不行」，不是失敗也不是成功 |
| `delivered_unverified` | 收到正式端點的 2xx 之後改。**語意是「HTTP 傳輸完成」，不是「事件有效」也不是「報表裡看得到」** | 不再重試。等對帳把它推進 `verified` |
| `verified` | 報表對帳（Realtime／GA4 報表／BigQuery 匯出）**實際比對到這筆事件**之後改 | 終態，收工 |
| `dead_letter` | 兩種進法：①**入列前的本地 schema 驗證沒過**（不可重試，重送一萬次結果一樣）②`retryable` 用完最大嘗試次數或時間上限 | 停止自動重試並**告警**，進人工處理佇列 |

**可重試 vs 不可重試，判準寫死不要靠當下判斷**：

| 錯誤 | 分類 | 理由 |
|---|---|---|
| 連線逾時、連線中斷、TLS 失敗、DNS 失敗、回應遺失 | `retryable` | 事件可能送到也可能沒送到；`purchase` 靠 `transaction_id` 去重，重送安全 |
| `408`／`429`／`500`／`502`／`503`／`504` | `retryable` | 對方端的暫時狀況；`429` 尤其要照 `Retry-After` 拉長 |
| `400`／`401`／`403`／`404`／`413`（請求本身有問題） | `dead_letter` | 重送不會變好。要人去看是 URL 錯、密鑰錯還是 payload 太大 |
| 本地 schema 驗證沒過 | `dead_letter`（**根本不送出**） | 送出去只會拿到一個騙人的 2xx |

**退避與上限（沒有這幾個數字，`retryable` 等於無限重試）**：

- **指數退避加抖動**：第 n 次重試間隔 = `min(2^n × base, cap)` 再乘上 `0.5–1.5` 的隨機抖動。建議 `base = 30 秒`、`cap = 1 小時`
- **最大嘗試次數 8 次**、**或距離入列超過 24 小時**，先到的先算——超過就轉 `dead_letter`
- **`429` 帶 `Retry-After` 時以該值為準**，不要用自己算的間隔壓過去
- **重試工作要能並行安全**：取件時用 `SELECT ... FOR UPDATE SKIP LOCKED`（或等效機制）鎖住那一列，避免兩個 worker 同時送同一筆

**`dead_letter` 的人工補送流程（要寫進追蹤計畫文件，不是口頭約定）**：

1. `dead_letter` 的**筆數與金額**進每日告警，**靜默累積等同漏數**
2. 人工看 `last_error` 判斷原因：schema 問題 → 修程式碼後**用原本的 `transaction_id`／事件 ID 重新入列**（不要產生新 ID，那會變成兩筆）；密鑰／設定問題 → 修好設定後整批重新入列
3. Measurement Protocol 對回填有時間上限，隔太久的事件即使補送成功也不會歸進原 session（見上方第 ③ 點）——**補送前先確認補進去的資料要用在哪份報表**，補一筆歸因錯誤的事件不一定比缺一筆好
4. 判定為不補的，在追蹤計畫文件裡記一筆「已知缺口」（期間、筆數、原因），下次有人問「為什麼那週數字對不起來」時查得到

**兩個 `delivered_unverified` 之後才抓得到的問題，各自要有獨立機制**（不要期待它們會反映在單筆回應上）：

- **密鑰健康檢查**：`api_secret` 失效或被作廢時，正式端點**照樣回 2xx**，事件全部靜默消失。做法是排一個定期作業，用同一組 `measurement_id` + `api_secret` 打 **debug 端點**送一筆測試事件，回應異常就告警。密鑰輪替後也要跑一次。**部署前的 smoke test 也走同一條路**：新環境上線、換密鑰、改 payload 結構之後，先打 debug 端點確認 `validationMessages` 為空、再打一筆真的到 production 並在 Realtime 報表裡看到它，兩關都過才算部署完成
- **報表對帳（catch-all，也是 `verified` 的唯一來源）**：每日比對「outbox 裡 `delivered_unverified` 的 `purchase` 筆數與金額」vs「GA4 報表（或 BigQuery 匯出）裡同期間的 `purchase` 筆數與金額」。對得上的推進 `verified`；對不上的**不要靜默留著**——差異超過容許範圍就告警，這是唯一能發現「傳輸成功但事件沒進報表」的方法，也是整套機制的最後一道網
  - 對帳延遲：Realtime 大約幾分鐘內、標準報表 24-48 小時、BigQuery 每日匯出隔天。**容許窗要照這個延遲訂**，不要在事件送出 10 分鐘後就判定它沒進報表
  - `delivered_unverified` 超過兩個對帳週期還沒推進 `verified` → 告警，當成疑似漏報處理

事件 ID 用來源系統給的那一個（金流商 webhook 的事件 ID、LINE 的 `webhookEventId`），unique 約束是防**來源重送**造成的重複建檔，不是拿來當「送過了」的判斷依據——那是 `status` 的事。

- **`purchase` 的重試是安全的**：同一筆交易永遠沿用同一個持久化的 `transaction_id`，重送多次 GA4 會判定為同一筆交易的重複事件而只計一次（見上方去重表第一列）。所以 `purchase` 走 at-least-once，寧可重送也不要漏送
- **非 `purchase` 事件沒有 GA4 內建去重**，重送就是多一筆。這類事件要在追蹤計畫文件裡明寫兩件事：①採 at-least-once（可能重複）還是 at-most-once（可能漏）②如果選 at-least-once，下游怎麼去重——通常是在 BigQuery 匯出層用事件 ID 去重，GA4 介面報表本身無法去重，這個誤差要寫進報表註記。**沒有想清楚這一段之前，不要把重要決策指標放在非 `purchase` 的後端事件上**

### 金流 webhook 驗證：依各家官方做法，不要比照 LINE

LINE 的 raw-body HMAC-SHA256 是 LINE Messaging API 的規格，**不是通用做法**。台灣常見金流商各自不同：有的是把參數排序後串接再雜湊的檢查碼（如綠界的 `CheckMacValue`、藍新的 `TradeSha`），有的走 AES 解密後比對內容（藍新的 `TradeInfo`），有的用非對稱簽章驗證公鑰。**把 LINE 那套套上去只會驗不過，然後被開發者直接關掉驗證**——這正是假營收灌進來的入口。

規則：

1. **照該金流商官方文件的 canonicalization 規則實作，或直接用官方 SDK**。查證方式是打開該金流商的技術文件確認欄位名稱與雜湊順序，不是憑印象寫
2. **比對用時間常數比較**（如 Node 的 `crypto.timingSafeEqual`，先確認兩邊長度相同再比，長度不同會拋例外）
3. **時間窗檢查只在該金流商的官方規格「有提供 timestamp 且該 timestamp 被簽章保護」時才做**，容忍值照該供應商文件寫的值，沒寫就不要自己訂一個。理由：①不是每家通知都帶 timestamp ②帶了但沒進簽章計算範圍的 timestamp 可以被竄改，拿它擋重放沒有意義 ③延遲通知、批次入帳、金流商自己的重送機制都可能讓一則**合法**通知在幾十分鐘甚至隔天才到，硬套「5 分鐘」會把真的付款擋掉，而漏掉的訂單比重放攻擊更常發生。**規格沒有可信 timestamp 時，擋重放靠的是**：金流商官方的重放防護機制、事件 ID 的 unique 約束（見上節 outbox）、以及訂單狀態機——已經是「已付款」的訂單再收到一次付款成功通知，是 no-op 不是第二筆營收
4. **驗簽通過只代表「這則通知真的來自金流商」，不代表「錢已經進來」**——還要看通知裡的付款狀態碼。授權成功（authorized）≠ 請款成功（captured），超商代碼／ATM 是「取號成功」≠ 已付款。**只有狀態機走到「已付款」才送 `purchase`**，其餘狀態只更新自己的訂單狀態
5. **金鑰只存後端**（環境變數／密鑰管理服務），不進版本庫、不進前端

## GA4 快速設定

1. 建立 GA4 資源與資料串流
2. 安裝 gtag.js 或 GTM
3. 開啟增強型評估（Enhanced Measurement）——**開啟前先讀 [url-pii-protection.md](url-pii-protection.md)**，這是自動蒐集功能，不會幫你過濾網址裡的個資
4. 設定自訂事件與電商事件（見上方官方 schema）
5. 在管理介面標記轉換
