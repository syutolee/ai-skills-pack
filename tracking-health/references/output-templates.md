# 輸出格式：追蹤計畫文件

## 事件屬性標準表（設計追蹤計畫時的欄位參考）

| 分類 | 屬性 |
|------|------|
| 頁面 | page_title, page_location, page_referrer |
| 使用者 | user_id, user_type, account_id, plan_type（**都是假名識別碼＝個資**，用之前先過 [privacy-compliance.md](privacy-compliance.md) 的四個前提；能用 `user_type` 這種粗粒度回答決策時就不要送 `user_id`。**`account_id`／會員編號要逐案判斷**——等於登入帳號、公開商家代號或連號可枚舉的，是直接識別資訊，不得送） |
| 廣告活動 | source, medium, campaign, content, term |
| 商品 | product_id, product_name, category, price |

最佳實務：屬性命名保持一致、附上相關情境、不要重複自動帶入的屬性、**屬性裡不放直接識別資訊**（email／電話／姓名／身分證字號／地址／可反查的完整訂單編號，無例外），**假名識別碼要逐欄填下方的資料盤點表**（見 [privacy-compliance.md](privacy-compliance.md) 的兩層對照表與四個前提，以及 [url-pii-protection.md](url-pii-protection.md)——`page_location` 由 GA4 隨每個事件自動帶入，不是靠這張表的欄位設計擋得掉的）。

## 追蹤計畫文件範本

```markdown
# [網站／產品] 追蹤計畫

## 總覽
- 工具：GA4、GTM、LINE Tag
- 最後更新：[日期]

## 事件

| 事件名稱 | 說明 | 屬性 | 觸發時機 |
|----------|------|------|----------|
| purchase | GA4 官方電商事件 | transaction_id, currency, value, items | 後端訂單狀態確認為已付款時（支付 webhook）**由伺服器送出唯一一筆**；付款成功頁不送 GA4 purchase（成功頁若有其他廣告平台的轉換代碼，那是各該平台的事件，不是第二筆 GA4 purchase） |
| signup_completed | 使用者完成註冊 | method, plan | 成功頁 |
| line_oa_add_clicked | 點擊加入好友按鈕（意圖訊號，非加入數） | source | 按鈕點擊 |

## 自訂維度

| 名稱 | 範圍 | 參數 |
|------|------|------|
| user_type | 使用者 | user_type |

## 轉換

| 轉換 | 事件 | 計算方式 |
|------|------|----------|
| 購買 | purchase | 依 transaction_id 去重計算 |
| 註冊 | signup_completed | 每個 session 計一次 |

## 資料盤點結果（個資法第 19／20 條判斷依據）

> 每一列都要實際填，**不要沿用範本的預設判斷**——同一個欄位在不同客戶、不同利用目的下的答案不一樣。

| 欄位 | 分類 | 判斷理由 | 第 19 條合法基礎與特定目的 | 利用目的 | 第 20 條是否超出原目的 | 保留期限 | 可存取者 |
|---|---|---|---|---|---|---|---|
| client_id | 假名識別碼（個資） | 可跨 session 關聯回同一裝置 | 〔填：哪一款、告知的特定目的是什麼〕 | 〔填〕 | 〔填：是／否＋理由〕 | 〔填：GA4 資料保留設定值〕 | 〔填〕 |
| user_id | 假名識別碼（個資） | 後端有對應表可反查真實會員 | 〔填〕 | 〔填〕 | 〔填〕 | 〔填：含後端對應表的刪除排程〕 | 〔填：含誰能存取對應表〕 |

## 驗證紀錄

| 檢查項 | 日期 | 結果 | 證據 |
|---|---|---|---|
| 敏感頁**整段流程**所有 GA4 payload 無直接識別資訊（不只第一個請求） | | | Network 分頁欄位清單／canary 測試結果 |
| 網址 path／query／fragment 三處都檢查過 | | | 逐處檢查紀錄 |
| transaction_id 雙向測試 | | | 重整 3 次同 ID／兩筆訂單不同 ID |
| 後端事件過 /debug/mp/collect（validationMessages 為空） | | | debug 端點回應 |
| 金流 webhook：偽造簽章被拒、重送不重複計、授權未請款不送 purchase | | | 三種情境的測試紀錄 |
```

**交付時要一併說明能量到什麼、量不到什麼**——特別是封閉電商平台的歸因限制與 LINE 加好友的量測邊界，不要讓客戶誤以為報表上的每個數字都有同樣的可信度。
