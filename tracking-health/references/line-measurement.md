# LINE 量測（台灣特有）：LINE Tag 與加好友歸因

## LINE Tag

台灣做 LINE 廣告平台（LAP）投放時，轉換追蹤要另外安裝 **LINE Tag**（LINE 官方的轉換追蹤標籤），不是 GA4／GTM 就能涵蓋。實務上常見的組合是：GTM 容器裡同時放 GA4 標籤與 LINE Tag，用同一個轉換事件（例如自有官網的 `purchase`）分別觸發兩邊，確保 LINE 廣告投放的成效歸因回得去。

## 加好友：官網量不到「真的加了」，只量得到「點了」

**不要在官網埋一個叫 `line_oa_added` 的事件。** 使用者點下「加入好友」按鈕之後，流程就離開你的網站進到 LINE App，官網的 JavaScript 沒有任何管道知道對方最後有沒有真的按下加入、或中途放棄。把按鈕點擊命名成 `line_oa_added` 會讓報表上的「加好友數」系統性高估（實際加入率通常明顯低於點擊數），後續拿這個數字算 CPA、回推廣告成效都會失真。正確做法分兩層：

| 事件 | 誰來送 | 代表什麼 |
|---|---|---|
| `line_oa_add_clicked` | 官網（GA4／GTM 點擊觸發） | 使用者在你的頁面上點了加入好友按鈕，**意圖**訊號 |
| `line_oa_add_confirmed` | 你自己的伺服器（收到並驗證過 LINE 平台的 `follow` webhook 後寫進自己的資料庫；**只有在拿得到該使用者的網站 `client_id` 時**才另外用 GA4 Measurement Protocol 送一份） | LINE 平台回報這個使用者目前成為好友，**結果**訊號 |

**送進 GA4 之前先確認拿得到合法的 `client_id`。** Measurement Protocol 的必要欄位、`api_secret` 保管、`/debug/mp/collect` 驗證方式，見 [ga4-implementation.md](ga4-implementation.md)「後端送事件：Measurement Protocol 最小規格」。`follow` webhook 本身**不會**給你任何網站識別資訊——除非使用者走過下面第 4 點的 LIFF／LINE Login 綁定、而你在那時把網站的 `client_id` 跟 `userId` 一起存了下來，否則你手上沒有合法的 `client_id`。**這種情況下不要為了「讓數字進 GA4」而隨機產生 `client_id`**（會製造一堆只有一個事件的假使用者，把使用者數與轉換率全部弄髒）：加好友總數留在自己的資料庫做報表，GA4 那邊就誠實地缺這個數字。

## `follow` webhook 不會幫你做歸因——三個常見誤解

依 LINE Messaging API 官方 webhook 事件規格（查證日期：2026-07-25，<https://developers.line.biz/en/reference/messaging-api/>）：

1. **加好友網址上掛的任意 query 參數，不會出現在 `follow` 事件的 payload 裡。** 「在加入好友連結後面帶一個一次性追蹤參數，webhook 收到時就能對回是誰點的」這個做法**在 LINE 上不成立**——`follow` 事件回傳的是事件類型、時間戳、`source.userId`、`webhookEventId`、`deliveryContext`、`replyToken` 與 `follow.isUnblocked` 這些平台定義的欄位，沒有任何管道把你自己塞在網址上的參數帶回來。LINE 官方帳號後台的「加入好友途徑」統計是**帳號層級的彙總數字**，也不會給你單一使用者對應到單一點擊的資料
2. **`follow` 事件 ≠ 新好友。解除封鎖也會送出 `follow`。** 事件裡的 `follow.isUnblocked` 才是區分依據：`true` 代表這個使用者是**解除封鎖**（本來就已經是好友過）、`false` 代表**首次加入好友**。把兩者都記成「新增好友」會系統性高估獲客數，而且被高估的那部分正好是行銷成效最不該算進去的一群。**只有 `isUnblocked === false` 的事件才能計入 `line_oa_add_confirmed`**；`true` 的另記一個 `line_oa_unblocked` 或直接不記
3. **webhook 端點是公開網址，沒驗簽章的話任何人都能偽造事件灌爆你的「加好友數」。** 這不是理論風險——端點網址一旦外流（前端程式碼、公開 repo、錯誤訊息），偽造一個 `follow` JSON POST 進去是幾行程式的事

## `line_oa_add_confirmed` 成立的四項前提（缺一項就退回只記 `line_oa_add_clicked`）

1. **簽章驗證（必做，不是選配）**：LINE 在每個 webhook 請求的 `x-line-signature` 標頭放一段以 **channel secret 為金鑰、對 HTTP request body 做 HMAC-SHA256 後 base64 編碼**的簽章。伺服器端要用**原始未經解析的 request body（raw body）**重算並比對——**不能先 `JSON.parse` 再 `JSON.stringify` 回去算**，那會因為欄位順序、空白、Unicode 逸出方式的差異而算出不同結果，實務上最常見的「簽章一直對不上」就是這個原因（Express 要用 `express.raw()` 或在 JSON parser 之前保留 raw body）。比對要用**時間恆定比較**（`crypto.timingSafeEqual`），不要用 `===`。**驗證失敗一律丟棄並回 4xx，不要記錄任何事件**
2. **冪等去重（必做）**：同一個事件可能被重送——事件物件裡的 `deliveryContext.isRedelivery` 為 `true` 時代表這是重送。以 **`webhookEventId` 為唯一鍵**存進資料庫（唯一索引或 upsert），已存在就直接略過。只靠 `isRedelivery` 判斷不夠保險，那是平台端的標記；`webhookEventId` 才是你自己這邊能落實的去重依據
3. **首次加入／解除封鎖分流（必做）**：依 `follow.isUnblocked` 分流，見上面第 2 點
4. **合法且明確的歸因綁定（沒有就不要做歸因）**：要把「這個 LINE 使用者」對回「網站上的那次點擊」，**唯一站得住腳的做法是走 LIFF 或 LINE Login 的明確綁定流程**——使用者在你的頁面上經過 LINE Login 授權，你才拿得到 `userId` 並能跟該次網站 session 對應起來。沒有走過這個流程，`follow` 事件給你的 `userId` 跟網站上的任何點擊之間**沒有任何可靠的對應關係**，用時間相近去猜（「這個 follow 發生在那次點擊後 30 秒內，應該是同一個人」）是不成立的歸因，流量一大就會大量錯配。

   **「走 LIFF／LINE Login」不是一句話就做完的事，下面四個前提缺一項，拿到的 `userId` 就對不起來或根本不可信**：

   - **same-Provider gate（最容易踩、而且症狀是「資料看起來對但其實全錯」）**：LINE 的 `userId` 是**依 Provider 隔離**的識別碼——同一個真人在不同 Provider 底下拿到的 `userId` **完全不同**。所以 LINE Login／LIFF channel 必須與收 `follow` webhook 的 Messaging API channel **位於同一個 Provider 底下**，兩邊的 `userId` 才是同一個值、才 join 得起來。跨 Provider 時 join 出來的結果不是「比較不準」，而是**永遠比對不到**（或更糟：比對到別人）。**開工第一步就去 LINE Developers Console 確認兩個 channel 的 Provider 是同一個**，不要等資料串不起來才回頭查
   - **不信任前端傳來的 `userId`**：LIFF 前端可以用 `liff.getProfile()` 拿到 `userId`，但那是**跑在使用者裝置上的 JavaScript 回傳的值**，任何人都能改。拿前端 POST 上來的 `userId` 直接寫進資料庫，等於讓任何人宣稱自己是任何一個 LINE 使用者。**後端只接受 access token／ID token，自己去換或自己去驗，絕不接受前端直接送的 `userId`**
   - **後端驗證 token（必做）**：LIFF 前端送 ID token（`liff.getIDToken()`）到後端，後端**驗證簽章**（用 LINE 的公鑰，或呼叫 LINE 官方的 verify 端點），並逐項檢查 claim：`iss` 是不是 LINE 官方簽發者、`aud` 是不是**你自己這個 channel 的 ID**（不是別人的 channel——漏檢查 `aud` 等於接受任何 LINE 應用簽發的 token）、`exp` 有沒有過期、`nonce` 是否與你這次流程產生的值相符。驗過之後，`userId` 從 **token 的 `sub` claim** 取，不是從前端的欄位取
   - **OAuth 流程要有 `state` 與 `nonce`**：走 LINE Login（授權碼流程）時，發起授權前產生一次性的 `state` 與 `nonce` 存進使用者 session，回呼時比對——`state` 擋 login CSRF（攻擊者誘導受害者用攻擊者的帳號完成綁定），`nonce` 擋 ID token 重放。兩者都是一次性的，用過即失效

   **這四項有任何一項做不到，就退回下面的降級做法**，不要用「大致上應該對」的綁定去產出歸因報表——錯配的歸因比沒有歸因更糟，因為它看起來是有數字的

**做不到第 4 點時的正確做法**：`line_oa_add_confirmed` 仍然可以記，但它只是**帳號層級的加好友總數**（且已扣除解除封鎖），**不能拆分到 campaign／來源層級**，報表上要明講「這是總加入數，無法歸因到個別廣告或頁面」。想做來源層級歸因，就得走 LIFF／LINE Login 綁定，或退而使用 LINE 官方帳號後台自己的加入途徑統計（彙總層級）。

**這整套對應關係牽涉到把 LINE 使用者識別碼跟網站行為串起來，屬於可識別特定個人的處理**，套用 [privacy-compliance.md](privacy-compliance.md) 的資料盤點與告知義務流程（LINE Login 的授權畫面本身不等於個資法的告知義務已履行，隱私權政策仍要載明），不要為了做歸因就默默把兩邊的識別碼接起來。
