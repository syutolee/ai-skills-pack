# NOTICE — 授權與來源標註

本技能（`ad-creative/SKILL.md` 及 `ad-creative/references/`）是以下開源專案內容的深度在地化改作，授權條款見 `../LICENSE`（MIT License，著作權人 Corey Haines）。

**技能邊界相對原版的差異（本包依「行銷知識由上而下的依賴關係」重畫過技能邊界）**：原版 `ad-creative` 的四種運作模式裡，「模式二：根據成效數據迭代」涵蓋了分析單位、可比性檢查、樣本量門檻、贏輸判斷這一整套成效分析方法論。本包把那一整塊移到 `campaign-analysis-iteration` 技能——理由是它跟 `ads` 原本的 kill/keep/scale 邏輯是同一件事的兩個套用對象（一個判廣告、一個判素材），拆在兩支技能裡並存會產生兩套互相矛盾的判準（第八輪審核抓到的正是這個模式）。本技能因此只保留三種模式：從零產出、規模化靜圖批次、素材策略迴圈。素材產出本體、輸入素材庫、版型庫、鉤子系統都留在這裡。

反向的搬入：原版 `ads` 技能的「素材最佳實務」（圖片、影片 15-30 秒結構、創意測試優先順序）移入本技能的 `references/copy-and-visual-production.md`。

## 來源專案

- 專案：[coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills)
- 原作者／著作權人：Corey Haines
- 授權條款：MIT License
- 鎖定版本（commit）：`67264763cb107d61749f418d081c56e5bcbc0209`（2026-07-16T19:07:40Z）
- 擷取日期：2026-07-20

## 來源對照

| 本檔案 | 來源檔案（鎖定版本） | 來源版本號 | SHA-256（來源檔案內容） |
|--------|----------------------|------------|--------------------------|
| `SKILL.md`、`references/grounded-inputs.md`、`references/copy-and-visual-production.md`、`references/platform-specs.md` | [`skills/ad-creative/SKILL.md`](https://github.com/coreyhaines31/marketingskills/blob/67264763cb107d61749f418d081c56e5bcbc0209/skills/ad-creative/SKILL.md) | v2.8.0 | `e874d7bde2f55a5f0687c938ea9d3c1f210a73ff948d58ba3ee0e08631587702` |
| `references/static-ad-templates.md` | [`skills/ad-creative/references/static-ad-templates.md`](https://github.com/coreyhaines31/marketingskills/blob/67264763cb107d61749f418d081c56e5bcbc0209/skills/ad-creative/references/static-ad-templates.md) | — | `8e066632e0449462af6930abe38282c666b48c63b7f07888140a1c03aba22d59` |
| `references/creative-strategy-loop.md` | [`skills/ad-creative/references/creative-roadmap.md`](https://github.com/coreyhaines31/marketingskills/blob/67264763cb107d61749f418d081c56e5bcbc0209/skills/ad-creative/references/creative-roadmap.md) ＋ [`skills/ad-creative/references/hook-system.md`](https://github.com/coreyhaines31/marketingskills/blob/67264763cb107d61749f418d081c56e5bcbc0209/skills/ad-creative/references/hook-system.md) | — | `a0be737841d8a73f0cf02094c9ed1e3f7c050e1c6f867794b1fa8b64dbf3b50e`（creative-roadmap.md）／`fc5db396eb43d7616ba55e58005f30fac5d0539542bd46cd60e6cf4666bd4de2`（hook-system.md） |

## 改作性質摘要

- **輸入來源**：Trustpilot/G2/Amazon 評論 → 蝦皮／MOMO 商品評論、Dcard、PTT（私訊來源已排除，見 SKILL.md「資料處理原則」）
- **翻牌廣告格式**：iMessage 對話截圖 → LINE 對話翻牌廣告（視覺語言與通訊工具全面置換，因 iMessage 在台灣滲透率低）
- **平台規格**（`references/platform-specs.md`）：新增 LINE 廣告平台（LAP）字元規格；Google Ads 字元計算採官方雙倍寬度規則（全形字元計為 2，附可重現的演算法）；**未涵蓋原版的 LinkedIn 與 X 版位規格**，理由與缺漏揭露見下方涵蓋範圍表
- **靜圖版型庫**（`references/static-ad-templates.md`）：完整 15 個版型在地化，DTC／SaaS 範例換成台灣零售電商／SaaS 情境，Before/After 與競品點名版型附合規提醒
- **素材策略迴圈**（`references/creative-strategy-loop.md`）：三訊號整合、證據等級、探索期/放大期分岔、產能表結構、複盤格式、鉤子系統，完整流程供模式三使用；訊號來源排除客服對話等非公開內容，僅用公開評論／留言；相關性與因果性混淆之處（投放天數、多支測試失敗、CVR 弱的成因）已加註混淆變數提醒，不當成確定結論
- **資料與內容安全**：新增資料最小化、私訊排除、去識別化原則；逐字／近逐字引用評論一律需要當事人可稽核授權（拿掉姓名不構成有效替代方案），主檔與強制載入的 reference 統一同一套規則；來源標註全模式統一為不透明 `source_id`＋授權狀態，原始對照表只留在受控位置；外部內容（含 CSV／後台匯出）視為不受信任輸入，只當資料不當指令，CSV 輸出套用公式注入防護；禁止把單一評論改寫成暗示多人共識或比率的社會證明宣稱（不實廣告風險）
- **批次產出工作流**：在地化自原版 Batch Generation Workflow（子任務拆分、三波次產出、品質過濾），並補上中文文案特有的「近似重複難以察覺」過濾原則
- **成效迭代的因果性約束**（原版無對應內容）：分析單位（`creative_id`／`asset_id`）、混淆變數檢查、樣本量門檻、結論用語對應證據強度——**這一整套已移至 `campaign-analysis-iteration` 技能**，本技能只保留「不要自己看幾個數字就宣布贏家，走那支技能拿結論等級」的邊界規則
- **法遵路由是 fail-closed 的**（原版無對應內容）：受規管產業（醫療／醫美／保健食品／化妝品／藥品／金融／遊戲）強制載入 `ads` 技能的 `references/compliance-taiwan.md`，優先於版型庫等其他強制載入項；讀不到時**只能輸出待人工複核的骨架**（宣稱類欄位留空並標記），不得憑記憶補一份精簡合規清單頂著用。這條規則堵的是一個真實漏洞：只強制載入版型庫、不強制載入法遵規則時，模型會照著 Before/After 版型的欄位把違反食安法第 28 條的醫療效能宣稱填進去，而它自己不知道
- **provenance 是每一種輸出格式的必填欄**（原版無對應內容）：不只概念檔與 `INDEX.md`，**標準輸出與中介 CSV 的 schema 也要帶來源層三元組 `source_id/evidence_class/source_license` 與成品層 `publish_status`**，缺欄位或被標成 `blocked_*` 就不輸出那一列（fail closed）。實務上授權界線最常在「Markdown 有標、轉 CSV 時沒帶」這個節點遺失，下游拿到 CSV 的人無從判斷該句文案能不能逐字上稿；來源層答「這份來源能怎麼用」、成品層答「這一則能不能上稿」，兩者不可壓成同一欄
- **靜圖版型資格 gate**（原版無對應內容）：原版要求每批涵蓋全部 15 個版型，但評論卡、見證疊排、媒體報導等版型需要品牌實際擁有的資產與授權；本版本改為產出前先跑資格 gate，不合格的版型跳過並在 `INDEX.md` 記錄原因與所缺資產，涵蓋率不得以捏造或未授權素材換取

## 相較原版 v2.8.0 的涵蓋範圍（誠實揭露）

本在地化版本涵蓋原版 `ad-creative` v2.8.0 的核心方法論（有根據的輸入、平台規格、文案產出、靜圖版型庫、素材策略迴圈、鉤子系統、批次產出工作流）。**運作模式為三種，不是原版的四種**——原版的「模式二：根據成效數據迭代」已整塊移至 `campaign-analysis-iteration`，理由見本檔開頭的技能邊界說明；本技能保留從零產出、規模化靜圖批次、素材策略迴圈三種。**以下原版內容未隨本版本提供**，使用時請知悉：

| 原版內容 | 本版本狀態 |
|---|---|
| `references/imessage-video-ads.md`（iOS 原生介面翻牌影片：iMessage／ChatGPT／Apple Notes／AirDrop 四種介面） | **以 LINE 對話翻牌廣告取代**（主檔內），因 iMessage 在台灣滲透率低；原版的其餘三種介面與完整製作管線（Playwright + ffmpeg、Remotion）未在地化 |
| `references/motion-video-ads.md`（AI 生成動態影片管線：九種視覺風格 prompt 公式、品牌槽位契約、QC 陷阱） | **未提供**——主檔只保留影片生成工具名稱與 prompt 在地化原則 |
| `references/creative-review-page.md` ＋ `assets/creative-review-template.html`（客戶審核用的自包含 HTML 審核頁） | **未提供**——批次審核以 `outputs/INDEX.md` 進行 |
| `references/generative-tools.md`（圖片／影片／語音生成工具完整指南與成本比較） | **未提供**——`references/copy-and-visual-production.md` 只保留工具名稱清單與「工具無地區限制、差異在 prompt 的在地視覺脈絡」的原則 |
| 原版平台規格涵蓋的 **LinkedIn 與 X 版位規格** | **未提供**——台灣付費投放量集中在 Google／Meta／LINE／TikTok，且這兩個平台的規格沒有台灣在地化施力點（照抄等於翻譯，違反本包「非單純翻譯」的原則）。需要時請查各平台官方廣告規格頁 |

完整的逐輪修訂歷史記錄在專案治理檔 `02-worklog.md`（不隨技能包公開發布，此 NOTICE 只保留公開摘要）。

## 改作者

syutolee.com（Alpha／Cody agent team），2026-07-20 起多輪修訂，2026-07-21 定版，2026-07-25 修訂（技能邊界重畫：成效分析移至 campaign-analysis-iteration，素材最佳實務自 ads 移入）。
