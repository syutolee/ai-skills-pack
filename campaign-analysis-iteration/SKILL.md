---
name: campaign-analysis-iteration
description: "當使用者拿著成效資料要判斷「該不該繼續」時使用。也適用於使用者提到「這支廣告該不該觸發關閉門檻」「預算該加碼多少」「哪個素材是贏家」「這個角度有沒有用」「ROAS 多少才划算」「目標 CPA 怎麼算」「廣告疲乏了嗎」「CPA 變高該查什麼」「要不要換素材」等情境。判斷邏輯只有一套，套用物件可以是廣告、廣告組合或素材。這是純分析型技能，只算數字、給判斷、產出報告，不執行任何會改變真實廣告帳戶狀態的操作。投放設定請見 ads；素材產出請見 ad-creative；到達頁請見 landing-page-cro。"
license: MIT
metadata:
  version: 1.0.0
  localized_from: "coreyhaines31/marketingskills — ads/references/b2b-paid-playbook.md ＋ ads/references/meta-decision-system.md ＋ ad-creative/SKILL.md 的成效迭代模式"
  source_commit: 67264763cb107d61749f418d081c56e5bcbc0209
  locale: zh-TW
---

# 成效分析與迭代判斷

你負責回答一件事：**這筆錢該繼續花嗎？**

觸發關閉門檻、加碼預算、換素材、宣布某個角度有效——這些都是同一類判斷的不同套用對象。**本技能只有一套判斷邏輯**，先確認資料能不能支撐結論，再套門檻。

**兩條範圍邊界：**

1. **不執行帳戶操作**——所有結論都用「建議」的語氣（「建議暫停這支廣告」「建議把每日預算提高到 NT$X」），實際動作交由使用者自己到後台執行。即使呼叫你的 agent 環境有串接廣告平台 API 或 MCP 工具也一樣。
2. **不產出素材、不改設定**——判斷完之後要出新素材走 `ad-creative`，要改投放設定走 `ads`。

> 台灣在地化說明：判斷框架在地化自 marketingskills 的 `b2b-paid-playbook.md`（損益兩平公式、觸發關閉門檻規則、放大象限）與 `meta-decision-system.md`（TCPL 決策引擎），並**合併**原版 `ad-creative` 的成效迭代模式（素材贏輸分析）——原版把它們寫成兩套獨立邏輯，一套判廣告、一套判素材，本包合併成一套。授權與來源見 `NOTICE.md`。

## 開始前

**本技能不需要切角／價值主張文件**（跟 `ads`／`ad-creative`／`landing-page-cro` 不同）——它處理的是「已經投出去的東西表現如何」，不直接面對策略設計。切角層的判斷（這個切角假設本身還成不成立、要不要繞回去重新設計）需要的是 `strategy-recalibration` 模組（未隨本包提供，見包根目錄 `ROADMAP.md`）；本技能只在判斷結果指向「不是素材問題也不是投放問題」時，指出「這可能是切角層的問題」，不越級做那個判斷。

**先確認追蹤本身是健康的**：如果 Pixel 或轉換追蹤壞了，這裡所有的門檻計算都是在對垃圾資料做決策。同時期的其他廣告有沒有正常記錄到轉換？沒有的話**先修追蹤再談判斷**，見 `tracking-health` 技能。

## 判斷流程（四關，順序不能顛倒）

```
第一關：分析單位  →  第二關：可比性  →  第三關：樣本量  →  第四關：套門檻
   對不對得上         有沒有混淆變數      夠不夠下結論    觸發關閉門檻／留／放大
        ↓                  ↓                  ↓
   不明 → 回報需要      不可比 → 只能報      不足 → 「先等」
   帶識別碼的匯出      「待驗證線索」        不是「沒效」
```

**前三關是「這份資料能不能拿來下結論」，第四關才是「結論是什麼」。** 跳過前三關直接套門檻，是本技能最常見也最貴的錯誤——它會產出看起來很有依據、實際上把相關性當因果性的建議。前三關的完整規則在 [references/evidence-gates.md](references/evidence-gates.md)，**任何判斷都要先載入那份檔案**。

## 硬性規則

1. **「先等」跟「沒效」是兩個不同的結論，不要混用**——樣本不足時的正確結論是「訊號不足，繼續觀察」或「調整結構讓它拿到量」，不是「這個素材／角度沒用」。把前者講成後者，會系統性讓還沒被公平判斷過的東西觸發關閉門檻。**但「訊號不足」也不等於「不能停」**：樣本不足擋的是比較型結論（哪個角度有效），不擋依絕對商業門檻止損（花費已經遠超過該產生的轉換）。兩者是不同的判斷，各有各的門檻，見 [references/evidence-gates.md](references/evidence-gates.md)「先分清楚你要下的是哪一種判斷」。停損時要寫成「依絕對商業門檻止損」，不要寫成「這個角度沒效」。
2. **零花費或低花費不是讓素材觸發關閉門檻的理由**——在 CBO 底下那多半是廣告組合層的分配結果或投遞資格問題，不是這支素材的品質評價。**先跑投遞診斷**（fail closed：診斷沒過就不觸發關閉門檻），見 [references/kill-keep-scale.md](references/kill-keep-scale.md)。
3. **RSA 與 Meta 動態素材的資產層數字，不能當成單一標題的獨立貢獻**——平台**可能**提供資產關聯層（asset association）的點擊、轉換或轉換價值欄位，但同一次曝光包含多個資產，那個數字的語意是「含有這個資產的曝光帶來的結果」，不是「這個資產造成的結果」（所以資產層轉換加總會超過廣告層）。**不得解讀成互斥歸因，也不得宣稱「某個標題勝出」並據此暫停或放大。** 另外 `creative_id` 是 **creative 物件**的識別碼，不是廣告層識別碼——**同一個 creative 可被多支 `ad_id` 共用**（複製到不同廣告組合、受眾、版位），拿它當分組鍵會把不同投遞條件的成效混在一起。**Meta 匯出要 `ad_id` 與 `creative_id` 都有，分組用 `ad_id`**；動態素材再往下的元件層結論還要另外拿到 asset breakdown 維度，拿不到就不得輸出元件層結論。完整規則見 [references/evidence-gates.md](references/evidence-gates.md)「資產層的邊界」。
4. **暫停一支廣告前，永遠要有替補廣告已經準備好**——不要留下暫停後的空窗。
5. **所有門檻都是實務起點值，不是保證數字**——上線 30 天後用自己帳戶的真實數據重新校準。給建議時**明講你用了哪一組值與依據**，不要只丟一個區間讓對方自己猜。

## 參考路由（依需求載入）

| 使用者意圖 | 載入 | 涵蓋內容 |
|---|---|---|
| **任何判斷的入口**（前三關） | [references/evidence-gates.md](references/evidence-gates.md) | 分析單位（活動／廣告組合／廣告／素材四層與各自能回答什麼）、可比性檢查表、樣本量門檻與效果量、結論用語對應證據強度 |
| 這支廣告該不該觸發關閉門檻、該加碼多少、ROAS／CPA 門檻怎麼算、疲乏了嗎 | [references/kill-keep-scale.md](references/kill-keep-scale.md) | 貢獻毛利打平 CPA 與 ROAS 門檻（含毛利口徑與淨利口徑的差異）、通用關閉廣告門檻規則與 K／M 選值、Meta TCPL 決策引擎（投遞診斷、品質×成本矩陣、畢業條件、疲乏偵測）、放大象限 |
| CPA 變高／CTR 偏低／CPM 偏高該查什麼；素材死在漏斗哪一段 | [references/diagnostic-funnel.md](references/diagnostic-funnel.md) | 依目標看核心指標、優化槓桿、素材診斷漏斗（停下／留下／點擊／轉換四段）、每段弱的時候該先排除什麼 |
| 要交付一份成效分析或迭代報告 | [references/iteration-report.md](references/iteration-report.md) | 廣告成效報告範本、素材迭代報告範本、RSA／動態素材的額外規則、週檢視重點 |

## 判斷結果之後往哪走

| 結論 | 下一步 |
|---|---|
| 建議暫停／換素材 | 出新素材：`ad-creative`（帶著本技能的結論等級過去，不要讓它自己重新判斷） |
| 建議加碼 | 調升幅度與節奏：`ads` 的 `references/account-structure.md` |
| 投遞資格問題（審核／排程／受眾重疊） | 修設定：`ads` 的 `references/audience-and-targeting.md`、`references/account-structure.md` |
| 點擊很多但不轉換 | 先確認流量品質，再查到達頁：`landing-page-cro` |
| 數字本身可疑（追蹤壞了） | `tracking-health` |
| 素材、投放、到達頁都排除了，還是不行 | **這可能是切角層的問題**——如實告知使用者，並指路 `strategy-recalibration`（未隨本包提供，見 `ROADMAP.md`）。**不要自己越級判斷切角要不要換** |

## 相關技能

**本包已含：** `tracking-health`（判斷的資料地基）、`ads`（投放設定）、`ad-creative`（素材產出）、`landing-page-cro`（到達頁）

**未隨本包提供（規劃中的付費模組，見包根目錄 `ROADMAP.md`）：** `usp-discovery`、`campaign-strategy`、**`strategy-recalibration`**（本技能判斷結果指向切角層時的下一站）

**未隨本包提供（第三方技能）：** `ab-testing`（受控實驗的設計與統計判定）
