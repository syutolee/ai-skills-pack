# NOTICE — 授權與來源標註

本技能（`tracking-health/SKILL.md` 及 `tracking-health/references/`）是以下開源專案內容的深度在地化改作，授權條款見 `../LICENSE`（MIT License，著作權人 Corey Haines）。

**技能命名與結構相對原版的差異**：原版技能名為 `analytics`，本包依「行銷知識由上而下的依賴關係」重畫技能邊界後改名為 `tracking-health`——它在本包的定位是**橫向地基**（投放、素材、到達頁、成效分析的判斷都建立在這裡的數字可不可信），不是依賴鏈上的一環。內容由單一 SKILL.md 改為「輕量路由入口＋主題化 `references/`」的漸進揭露結構，方法論實質不變。

## 來源專案

- 專案：[coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills)
- 原作者／著作權人：Corey Haines
- 授權條款：MIT License
- 鎖定版本（commit）：`67264763cb107d61749f418d081c56e5bcbc0209`（2026-07-16T19:07:40Z）
- 擷取日期：2026-07-20

## 來源對照

| 本檔案 | 來源檔案（鎖定版本） | 來源版本號 | SHA-256（來源檔案內容） |
|--------|----------------------|------------|--------------------------|
| `SKILL.md` ＋ `references/*.md`（全部 7 份） | [`skills/analytics/SKILL.md`](https://github.com/coreyhaines31/marketingskills/blob/67264763cb107d61749f418d081c56e5bcbc0209/skills/analytics/SKILL.md) | v2.0.0 | `16aab197f87bf6e2599d179061f1947d96acafe0a340837432d8ab96d2f8c55a` |

本技能的 `references/` 全部拆分自同一份來源檔案（原版 `analytics/SKILL.md`）加上台灣在地化新增內容，不是各自對應到不同的上游檔案：`ga4-implementation.md`、`url-pii-protection.md`、`utm-and-attribution.md`、`line-measurement.md`、`privacy-compliance.md`、`debug-validation.md`、`output-templates.md`。

## 改作性質摘要

- **隱私合規框架**：原版 GDPR（歐盟）／CCPA（美國）框架 → 台灣個人資料保護法（PDPA）框架，附法規來源與查證日期；隱私權政策告知義務採條件式強制（先盤點資料是否構成個資，再判斷是否觸發告知義務，不限縮於特定欄位名稱）；GA4 服務條款本身另有獨立於 PDPA 的揭露要求；多法域適用性（PDPA／GDPR／CCPA）視為可疊加判斷，不是依訪客所在地互斥選擇；GDPR 第 3(2) 條的域外適用有**兩個各自獨立的分支**——①**鎖定歐盟市場**（提供歐盟語言版本、以歐元計價、寄送歐盟地區、對歐盟受眾投放廣告等）或②**監控歐盟境內人士的行為**（對歐盟訪客做行為追蹤／輪廓分析，網站分析與再行銷 pixel 都可能落入此分支），**任一成立即適用，不是只有「鎖定市場」一條路**；反過來說，單純偶有歐盟訪客路過、且未對其做行為監控，不自動成立
- **假名化 vs 匿名化**：內部系統可反查的分析 ID 正名為「假名化」，不稱「匿名化」——可反查回特定個人的 ID 在個資法底下通常仍是個人資料
- **LINE Tag**：新增章節，因 LINE 廣告平台在台灣的轉換追蹤需要另外安裝（原版無對應內容）
- **電商事件**：改用 GA4 官方 ecommerce schema（`view_item`／`add_to_cart`／`begin_checkout`／`purchase`），依 GA4 官方文件標示各參數 required／conditionally required／optional（`items` 內部僅要求 `item_id`／`item_name` 擇一）；`transaction_id` 範例採隨機不透明 UUID，並要求同一筆交易重試/重載時重用持久化的 `transaction_id`
- **蝦皮／MOMO 追蹤限制**：說明封閉平台無法安裝第三方 Pixel，UTM 參數對賣家不會產生任何可用的歸因資料（除非目的地有你能存取的分析工具）——同時講清楚參數並非「消失」，它照樣送達平台伺服器、CDN／WAF 與各層日誌，差別在存取權；列出實際可行的替代做法，並補上自建中繼轉址的必要防護（目的地固定 allowlist 以避免 open redirect、最少日誌欄位、最短保留期限）
- **URL 個資外洩防護**：新增專節拆解四條各自獨立的外洩管道（GA4 payload、同源 Referer、跨源 Referer、頁面腳本直接讀取），依防護有效性分層說明；明確指出 `page_location` 由基礎 Google tag 的自動 `page_view` 送出，**關閉增強型評估並不會停止它**，敏感頁面須在任何標籤載入前就清掉 query；GTM 白名單驗證改為「先解碼再比對該參數應有的形狀」，並明講 `gclid`／`fbclid` 只是任何人都能偽造的 query 名稱、參數名稱不構成來源認證，其值一律要驗；上線驗證的主證據改為 Network 分頁裡**第一個** `/g/collect` 請求的 payload，不是 DebugView
- **`transaction_id` 去重的方向性**：明確拆成三種情況（同交易同 ID＝預期行為；同交易換 ID／缺 ID＝營收灌水；不同交易共用 ID＝營收漏算），除錯表與驗證清單同步改寫，避免被簡化記成「ID 不能重複」
- **假名化與匿名化的判準**：匿名化的認定改以**重識別風險評估**為準，手段是聚合／泛化／抑制與準識別欄位組合評估；明確否定「雜湊過就是匿名化」（email、電話這類取值空間小的欄位可被枚舉比對），雜湊後的資料預設仍視為假名化的個人資料
- **LINE 官方帳號加好友的量測邊界**：官網只量得到 `line_oa_add_clicked`（按鈕點擊意圖），`line_oa_add_confirmed` 需要 LINE `follow` webhook 與合法的歸因鏈結才成立，並須通過本檔的資料盤點與告知義務流程。`follow` webhook 的三個常見誤解一併寫死：①加好友網址上的任意 query 參數**不會**回傳到 webhook payload（LINE 不提供這個管道）②`follow` ≠ 新好友，解除封鎖也會送出，須依 `follow.isUnblocked` 分流 ③公開端點必須用 **raw body** 做 HMAC-SHA256 簽章驗證＋以 `webhookEventId` 冪等去重，否則任何人都能偽造加好友事件
- **第 20 條「利用」與第 19 條「蒐集」分成兩關**：第 19 條只回答「當初能不能蒐集」，不回答「現在能不能拿去做這個用途」；純內部分析／廣告串接回傳／廣告個人化再行銷三種利用目的分開判斷，後兩者通常超出原特定目的，並須落實第 20 條第 2、3 項的免付費拒絕方式與拒絕後立即停止（要做成 suppression list 這種技術措施，不是留在客服信箱裡）

## 改作者

syutolee.com，2026-07-20 起多輪修訂，2026-07-21 定版，2026-07-25 修訂。
