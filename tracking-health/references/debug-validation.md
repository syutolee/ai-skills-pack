# 除錯與驗證

## 測試工具

| 工具 | 用途 |
|------|------|
| GA4 DebugView | 即時監控事件（輔助檢查，不是個資驗證的主證據） |
| GTM 預覽模式 | 發布前測試觸發條件 |
| 瀏覽器開發者工具 Network 分頁 | 檢查實際送出的 payload——個資驗證的**主證據**，見 [url-pii-protection.md](url-pii-protection.md) |
| 瀏覽器擴充功能 | Tag Assistant、Data Layer 檢查工具 |
| `/debug/mp/collect` 端點 | 驗證**伺服器端** Measurement Protocol 事件——後端事件驗證的**主證據**。一般 `/mp/collect` 端點對無效 payload 一律回 2xx 且無錯誤訊息，只有 debug 端點會回 `validationMessages`，空陣列才算通過。見 [ga4-implementation.md](ga4-implementation.md) |

## 上線前驗證清單

- [ ] 事件在正確的觸發時機觸發
- [ ] 屬性值正確帶入
- [ ] `transaction_id` 的對應關係正確——**這一條有方向性，兩個方向都要驗，不要只記「不能重複」**：
  - **同一筆交易、同一個 ID**：這是**預期行為**，不是問題。測法：**對後端重送同一則支付 webhook（或直接重跑 outbox 那筆事件）2-3 次**，確認每次送出的 `transaction_id` 都相同，且 GA4 報表的交易數只增加 1。**不要用「重整結帳成功頁」當測法**——成功頁本來就不該送 GA4 `purchase`，重整不送任何東西才是對的
  - **不同交易、不同 ID**：ID 必須全域唯一。測法：連續下兩筆真實測試訂單，確認兩者的 `transaction_id` 不同（共用會導致第二筆被當成重複而漏算營收）
- [ ] `purchase` **只由後端訂單確認／支付 webhook 送出一次**（訂閱制尤其要驗週期性續扣有沒有記到）；**沒有做成「前端先送、後端再送一次」**
- [ ] 付款成功頁的 Network 分頁裡**沒有任何 GA4 `purchase` 請求**——成功頁上若有 Google Ads／Meta Pixel／LINE Tag 的轉換代碼，確認那些是各該平台自己的端點，且是在後端付款確認回應之後才觸發
- [ ] 後端事件走 `pending`／`retryable`／`delivered_unverified`／`verified`／`dead_letter` 五態 outbox：實測「送出後逾時、回應遺失、429、5xx」時該筆轉 `retryable` 且照指數退避重試（不是被當成已送而跳過）、`400`／`401`／本地 schema 驗證失敗直接進 `dead_letter` 不重試、`dead_letter` 有告警不是靜默累積
- [ ] **`delivered_unverified` 不當成完成**：有一支每日對帳作業拿 GA4 報表／BigQuery 匯出比對筆數與金額，對得上才推進 `verified`；超過兩個對帳週期沒推進的會告警
- [ ] 每一種後端事件都打過 `/debug/mp/collect` 且 `validationMessages` 為空；`api_secret` 只存在後端環境變數，不在前端程式碼或版本庫裡
- [ ] 後端事件的 `client_id` 來自真實的瀏覽器 `_ga` cookie（下單時隨訂單存下），**沒有隨機產生**；拿不到合法 `client_id` 的計數（如 LINE 加好友總數）留在自有資料庫，沒有灌進 GA4
- [ ] webhook 端點已驗簽章並以事件 ID 做冪等去重；**驗簽方式照該來源官方文件／SDK**（LINE 是 raw-body HMAC-SHA256，金流商各自不同，沒有直接套用 LINE 的做法）
- [ ] 金流 webhook 三種情境實測過：偽造簽章被拒、重送不重複計、**授權成功但尚未請款時不送 `purchase`**
- [ ] 跨瀏覽器與行動裝置都正常
- [ ] 轉換被正確記錄
- [ ] 沒有個資外洩——已依 [url-pii-protection.md](url-pii-protection.md) 用 **synthetic canary 標記值**實測忘記密碼／結帳成功／站內搜尋等敏感流程，**整段流程的每一個** `/g/collect` 請求（不是只有第一個）都搜不到標記值，不是只憑印象打勾
- [ ] canary 測試涵蓋 **query／path／fragment 三處**，不是只測 query
- [ ] 伺服器存取日誌、CDN／WAF 日誌、錯誤追蹤與 Session 錄影服務都搜過 canary 標記值，遮罩規則確認生效

## 常見問題對照表

| 問題 | 檢查項目 |
|------|----------|
| 事件沒觸發 | 觸發條件設定、GTM 是否載入 |
| 值不正確 | 變數路徑、Data Layer 結構 |
| 營收數字灌水（同一筆訂單被算成多筆） | 多個 GA4 容器同時安裝、觸發條件重複觸發、**同一筆交易每次送出時 `transaction_id` 都不一樣**（例如前端每次頁面重載重新產生 UUID）、或 `transaction_id` 缺失（沒有 ID 就無從去重） |
| 營收數字短少（實際有多筆訂單卻只算到一筆） | **不同交易共用了同一個 `transaction_id`**（例如誤用會員編號、購物車 ID、當日固定字串）——GA4 會把它們判定成同一筆交易的重複事件而只保留一筆 |
| 營收數字短少（訂閱制尤其明顯，或跟金流後台對不起來） | **`purchase` 只埋在前端付款成功頁**——週期性續扣沒有前端所以完全沒記到；第三方支付／超商／ATM 未導回成功頁的訂單也漏掉。改以後端支付 webhook 為權威觸發來源，見 [ga4-implementation.md](ga4-implementation.md) |
| GA4 有營收但金流後台查無此筆（或事後才發現該筆被退款／請款失敗） | `purchase` 在「到達成功頁」就送出，早於後端確認入帳；且退款後沒有補送 `refund` 事件 |
| 加好友數比實際好友成長數高很多 | 官網的按鈕點擊被命名成 `line_oa_added`，把意圖訊號當成結果訊號；或 `follow` webhook 沒有依 `isUnblocked` 排除解除封鎖，見 [line-measurement.md](line-measurement.md) |
| 敏感頁面的 DebugView 看起來乾淨，但客戶回報有個資外洩 | GTM 覆寫寫在標籤之後，**第一個** hit 已經帶著髒網址送出；只看後續事件會誤判成已修好，見 [url-pii-protection.md](url-pii-protection.md) |
| 蝦皮／MOMO 導流查不到任何歸因資料 | 這不是設定漏了——封閉平台不開放賣家安裝第三方代碼，UTM 對賣家不產生可查詢資料，見 [utm-and-attribution.md](utm-and-attribution.md) |
