---
name: tracking-health
description: "當使用者需要建立、健檢或除錯行銷追蹤與成效量測時使用。也適用於使用者提到「設定追蹤」「GA4」「轉換追蹤」「事件追蹤」「UTM」「GTM」「追蹤計畫」「LINE Tag」「加好友追蹤」「這樣算有在追蹤成效嗎」「事件有沒有正常觸發」「報表數字對不起來」等情境。這是整個行銷技能包的地基——投放、素材、到達頁、成效分析的判斷都建立在這裡的數字可不可信。A/B 測試量測請見 ab-testing（未隨本包提供）。"
license: MIT
metadata:
  version: 2.0.0
  localized_from: coreyhaines31/marketingskills analytics v2.0.0
  source_commit: 67264763cb107d61749f418d081c56e5bcbc0209
  locale: zh-TW
---

# 追蹤健康度

你負責讓行銷數字**可信**。這個技能是本技能包的橫向地基：`ads`（投放）、`ad-creative`（素材）、`landing-page-cro`（到達頁）、`campaign-analysis-iteration`（成效分析）算出來的每一個判斷，前提都是這裡的數據沒有壞。**追蹤壞掉時，上層所有技能的結論都是錯的**——所以本技能的第一個動作永遠是確認資料本身站不站得住腳，不是趕快多埋幾個事件。

> 台灣在地化說明：GA4／GTM 是全球工具，不需要改；但原版的隱私合規段落以 GDPR／CCPA 架構寫成，台灣的法律基礎是**個人資料保護法（PDPA）**，蒐集與利用個資的原則不一樣；另外台灣電商代操最常撞到的結構性問題——蝦皮、MOMO 等封閉平台無法安裝第三方 Pixel、以及 LINE 官方帳號的加好友歸因限制——原版完全沒提到，這裡補上。授權與來源見 `NOTICE.md`。
>
> **法規段落的性質**：涉及個人資料保護法的內容附有來源與查證日期，是操作面提醒與現行條文摘要，不是法律意見；具體適用需視個案事實而定，正式導入前建議請客戶端法務或合規顧問複核。

## 開始前

若專案內有 `.agents/product-marketing.md`（或 `.claude/product-marketing.md`）先讀過，已涵蓋的資訊不要重複問。

實作或健檢追蹤前，先搞清楚三件事：**①這份數據要支撐什麼決策 ②現在已經有什麼在追蹤 ③技術架構與個資／合規限制**。答不出①就先別動手埋點——為了有數據而追蹤，最後只會得到一堆沒人看的事件。

**本技能不需要切角／價值主張文件**：追蹤健康度是橫向地基，不依賴上游的策略設計（`ads`、`ad-creative`、`landing-page-cro` 才需要，見各自的「開始前」）。

## 硬性紅線（任何情境都不得違反，違反就是這個技能失敗）

1. **直接識別資訊不得進入分析工具**——email、電話、姓名、身分證字號、地址、信用卡號、可反查特定人的完整訂單編號，都不得出現在事件屬性、事件名稱、或**網址的任何部分**（query string 不行，path 也不行）。這條同時是 Google 的平台政策（違反可能導致資源被停用），沒有「取得同意就可以」的例外。網址裡的個資有四條各自獨立的外洩管道，「關掉增強型評估」只擋得到其中一條的一部分：載入 [references/url-pii-protection.md](references/url-pii-protection.md)。
2. **opaque 假名識別碼可以用，但要當個資管**——`client_id`、隨機 UUID 的 `transaction_id`、後端隨機產生的 `user_id` 這類「只有你自己後端反查得到人、第三方拿到值也對不出是誰」的識別碼，是**假名化個人資料**，個資法照樣管，但它們**不在第 1 條的禁令範圍內**。用它們的四個前提：①講得出第 19／20 條的合法基礎與特定目的 ②最小化（能用粗粒度就不要用細的、能不送就不送）③訂保留期限並真的刪 ④限制誰能存取、誰能拿到反查對應表。**`account_id`／會員編號要逐案判斷**——實際上等於登入帳號、公開商家代號或連號可枚舉的，是第 1 條的直接識別資訊，判不出來就當直接識別資訊處理。判準見 [references/privacy-compliance.md](references/privacy-compliance.md)。
3. **雜湊過的 email／電話／身分證字號仍是直接識別資訊，受第 1 條禁令**——這些欄位取值空間小、格式固定，拿到雜湊值就能用已知名單逐一比對回本人，加 salt 只是提高成本。分界線是「第三方拿到這個值能不能反推出是誰」，不是「有沒有雜湊」。Enhanced Conversions／CAPI 要送雜湊 email 是**平台指定的專用欄位與端點**，不代表同樣的值可以塞進 GA4 一般事件參數，而且那是另一個利用目的要另過第 20 條。要做到真匿名靠的是聚合／泛化／抑制，見 [references/privacy-compliance.md](references/privacy-compliance.md)。
4. **不捏造數據，也不捏造「已經量到」的宣稱**——量不到的東西就講量不到（例如官網量不到「真的加了 LINE 好友」、封閉平台賣家拿不到站內歸因）。把意圖訊號講成結果訊號，等於幫客戶把報表灌水。
5. **`purchase` 由後端在訂單確認已付款後送出，整筆交易只送一次**——付款成功頁不送 GA4 `purchase`（它不是次要來源也不是備援），更不要設計成「前端先送、後端再送一次」，去重不等於更正。成功頁上的其他廣告平台轉換代碼是各該平台的事件，不算第二筆 GA4 `purchase`。理由與正確做法見 [references/ga4-implementation.md](references/ga4-implementation.md)。
6. **webhook 一律驗簽章＋冪等去重**（LINE `follow`、金流通知都適用），但**驗簽方式必須照該來源官方文件或官方 SDK**——LINE 的 raw-body HMAC 是 LINE 的規格，台灣金流商各自不同（檢查碼串接雜湊、AES 解密比對、非對稱簽章都有），**不可以泛化套用**。另外驗簽通過只證明來源，不證明錢已入帳，還要看付款狀態機。做法見 [references/ga4-implementation.md](references/ga4-implementation.md)「金流 webhook 驗證」。

## 核心原則

- **為決策而追蹤**：每個事件都要能對應到一個決策，答不出「拿到這個數字我會做什麼」就不要埋。
- **命名先訂規則再實作**：全小寫、底線分隔、物件_動作；電商事件是例外，一律用 GA4 官方保留字。
- **資料品質 > 資料數量**：一個驗證過的乾淨事件，勝過十個沒人敢用的事件。

## 健檢順序（接到「幫我看一下追蹤」時照這個順序跑）

1. **資料可信度**——事件有沒有在對的時機觸發？營收有沒有灌水或漏算（`transaction_id` 方向性）？→ `references/ga4-implementation.md`、`references/debug-validation.md`
2. **個資外洩**——敏感頁面的第一個 GA4 請求 payload 乾不乾淨？→ `references/url-pii-protection.md`
3. **歸因鏈完整性**——UTM／click ID／封閉平台限制／LINE 加好友這幾段串不串得起來？→ `references/utm-and-attribution.md`、`references/line-measurement.md`
4. **合規基礎**——資料盤點做了嗎？隱私權政策涵蓋實際的利用目的嗎？→ `references/privacy-compliance.md`
5. **交付**——追蹤計畫文件、驗證紀錄 → `references/output-templates.md`

## 參考路由（依需求載入，不要一次全讀）

| 使用者意圖 | 載入 | 涵蓋內容 |
|---|---|---|
| 設定 GA4／命名事件／電商事件／營收數字對不起來 | [references/ga4-implementation.md](references/ga4-implementation.md) | 事件命名規則、核心事件表、GA4 官方 ecommerce schema 與參數必要性、`transaction_id` 去重的三種情況、`purchase` 的權威觸發來源、訂閱制付款事件 |
| 網址帶個資、GTM 白名單、`gclid`／`fbclid` 該怎麼驗 | [references/url-pii-protection.md](references/url-pii-protection.md) | 四條外洩管道拆解、依防漏程度排序的五層防護、參數名稱不是來源認證、字元集檢查的能與不能、上線前驗證的主證據 |
| GTM 容器結構、UTM 命名、蝦皮／MOMO 追不到、自建轉址 | [references/utm-and-attribution.md](references/utm-and-attribution.md) | GTM 元件與 dataLayer、UTM 參數表與台灣常見組合、封閉電商平台的結構性限制、中繼轉址的三項必做防護 |
| LINE Tag、LINE 官方帳號加好友要怎麼算 | [references/line-measurement.md](references/line-measurement.md) | LINE Tag 安裝、`line_oa_add_clicked` vs `line_oa_add_confirmed` 兩層、`follow` webhook 的三個常見誤解、簽章驗證與冪等的四項前提 |
| 個資法、GDPR、隱私權政策、要不要同意機制 | [references/privacy-compliance.md](references/privacy-compliance.md) | 個資法第 5／8／19／20 條分層（蒐集 vs 利用是兩關）、假名化 vs 匿名化的判準、GDPR 第 3(2) 條兩個獨立分支、CCPA 門檻、拒絕行銷的技術落實 |
| 事件沒觸發、數字怪怪的、上線前要驗什麼 | [references/debug-validation.md](references/debug-validation.md) | 測試工具、驗證清單（含 `transaction_id` 雙向測試）、常見問題對照表 |
| 要交付追蹤計畫文件 | [references/output-templates.md](references/output-templates.md) | 追蹤計畫文件範本、自訂維度與轉換表、事件屬性標準表 |

## 任務啟動提問清單

1. 目前用什麼工具（GA4、GTM、其他）？已經有什麼在追蹤？
2. 想追蹤哪些關鍵行為？涉及電商交易嗎（要用官方 ecommerce schema）？
3. 這份數據要支撐什麼決策？
4. 誰負責實作——開發還是行銷？
5. 有沒有個資／合規要求要注意？產業敏感嗎（金融、醫療）？
6. 有沒有投放 LINE 廣告平台，需要另外裝 LINE Tag？
7. 商品銷售走自有官網還是蝦皮／MOMO 等封閉平台？（決定能不能安裝第三方追蹤代碼）

## 相關技能

**本包已含：**
- **ads**：投放執行；投放前的追蹤驗證是本技能的職責
- **campaign-analysis-iteration**：觸發關閉門檻／留／放大與素材贏輸判斷；判斷的前提是這裡的數據可信
- **ad-creative**、**landing-page-cro**：迭代與優化都要看這裡設定的成效數據

**未隨本包提供（第三方技能，你的 agent 環境需另外安裝）：**
- **ab-testing**：實驗設計與量測
