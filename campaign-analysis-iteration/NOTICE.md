# NOTICE — 授權與來源標註

本技能（`campaign-analysis-iteration/SKILL.md` 及 `references/`）是以下開源專案內容的深度在地化改作，授權條款見 `../LICENSE`（MIT License，著作權人 Corey Haines）。

## 這支技能是「合併」出來的，不是單一上游檔案的改作

本包依「行銷知識由上而下的依賴關係」重畫技能邊界時，發現原版把**同一件事寫成了兩套獨立的方法論**：

- `ads` 技能的 kill/keep/scale 邏輯 → 判斷**廣告**該不該觸發關閉門檻、該不該加碼
- `ad-creative` 技能的「模式二：根據成效數據迭代」→ 判斷**素材**哪個贏、該不該換

兩者要回答的其實是同一個問題（**這份資料能不能支撐我要下的結論？樣本夠不夠？變數控制了沒？**），只是套用物件不同。分開寫的結果是兩組會互相分歧的判準——例如兩邊各自定義的樣本量門檻、各自對「分析單位」的認知，維護時很難保持一致，讀的人也不知道該用哪一套。

**本技能把它們合併成一套**：三道證據關卡（分析單位 → 可比性 → 樣本量）對兩種套用物件都適用，**只有第四關的門檻數字依物件而異**。

## 來源專案

- 專案：[coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills)
- 原作者／著作權人：Corey Haines
- 授權條款：MIT License
- 鎖定版本（commit）：`67264763cb107d61749f418d081c56e5bcbc0209`（2026-07-16T19:07:40Z）
- 擷取日期：2026-07-20

## 逐檔來源對照

| 本檔案 | 來源檔案（鎖定版本） | SHA-256（來源檔案內容） |
|--------|----------------------|--------------------------|
| `references/kill-keep-scale.md` | [`skills/ads/references/b2b-paid-playbook.md`](https://github.com/coreyhaines31/marketingskills/blob/67264763cb107d61749f418d081c56e5bcbc0209/skills/ads/references/b2b-paid-playbook.md) ＋ [`skills/ads/references/meta-decision-system.md`](https://github.com/coreyhaines31/marketingskills/blob/67264763cb107d61749f418d081c56e5bcbc0209/skills/ads/references/meta-decision-system.md) | `21dc1125905f8d985763996afb24a2bf54539330535b7b2b45c052901c5b2006`（b2b-paid-playbook.md）／`8e62e59e3ff959db3e800bd9ed6d1610f34ce24103292ab67fe042a93a45d747`（meta-decision-system.md） |
| `references/evidence-gates.md`、`references/iteration-report.md` | 合併自上列兩份 ＋ [`skills/ad-creative/SKILL.md`](https://github.com/coreyhaines31/marketingskills/blob/67264763cb107d61749f418d081c56e5bcbc0209/skills/ad-creative/SKILL.md) 的成效迭代模式 | `e874d7bde2f55a5f0687c938ea9d3c1f210a73ff948d58ba3ee0e08631587702`（ad-creative/SKILL.md） |
| `references/diagnostic-funnel.md` | [`skills/ads/SKILL.md`](https://github.com/coreyhaines31/marketingskills/blob/67264763cb107d61749f418d081c56e5bcbc0209/skills/ads/SKILL.md) 的「活動優化」段 ＋ [`skills/ad-creative/references/hook-system.md`](https://github.com/coreyhaines31/marketingskills/blob/67264763cb107d61749f418d081c56e5bcbc0209/skills/ad-creative/references/hook-system.md) 的診斷漏斗 | `8be65c0dfa275bb42f238530e7ba4efe9a9d45bee74eaac02f0f2a644a8f1857`（ads/SKILL.md）／`fc5db396eb43d7616ba55e58005f30fac5d0539542bd46cd60e6cf4666bd4de2`（hook-system.md） |
| `SKILL.md` | 本包新寫的路由入口 | — |

原版的 kill/keep/scale 門檻框架標註了自己的來源脈絡：「本檔部分操作規則改編自實務工作者的操作手冊，特別是 Ivan Falco 的 ads-skills」——這份出處鏈保留在 `references/kill-keep-scale.md` 的頁尾。

## 改作性質摘要

- **能力範圍**：**純分析型技能**——只算數字、給判斷、產出報告，不執行任何會改變真實廣告帳戶狀態的操作。所有結論以「建議」語氣呈現。相對於原版，原版 `ads` 含直接操作廣告帳戶的執行流程（預覽／逐次核准／回滾），本包不提供該能力
- **兩套判斷邏輯合併成一套**（見上方）：三道證據關卡對廣告與素材通用，只有門檻依物件而異；並定義了「先等」與「沒效」是兩個不同結論這條硬規則——樣本不足時講成「沒效」，會系統性讓還沒被公平判斷過的東西觸發關閉門檻
- **分析單位的四層定義**（原版無對應內容）：活動／廣告組合／廣告／素材資產各自設定什麼、各自的數字能回答什麼。**CBO 的預算分配是分到廣告組合層**，所以「拿活動預算除以廣告數當成這支素材該拿多少錢」跨了兩層、基準線根本不存在；公平份額檢定因此只適用廣告組合層，素材層改用受控實驗或絕對花費門檻（spend floor）
- **資產層的邊界**（原版無對應內容）：RSA 與 Meta 動態素材的標題會被系統隨機組合，平台**不提供每個標題各自的轉換或 ROAS**，只有曝光佔比與成效評級。因此不得宣稱「某標題勝出」並據此暫停或放大——那個數字不存在，這種結論是憑空補出來的
- **樣本量不只是「≥10 次轉換」**（原版無對應內容）：10 次是「值得開始看」的下限，不是「可以宣布結論」的門檻。要把比較講成結論，至少要有**分母（曝光或點擊）、效果量（率差多少）、不確定性估計**三樣；沒有就只能標成「方向性假設」。嚴謹的統計判定（顯著性、檢定力）明確劃在本技能範圍外
- **邊際指標的方向性**：放大判斷明確區分 **ROAS 是下限（跌破即停）、CPA 是上限（突破即停）**，不共用「未跌破門檻」這種會放行超標 CPA 的說法（目標 CPA NT$100、邊際 CPA NT$200 時，「還沒跌破 100」字面成立但已超標一倍）
- **貢獻毛利打平 vs 公司整體損益兩平**：明確區分毛利口徑與淨利口徑，「毛利貢獻打平」不等於公司賺錢（還沒扣金流手續費、退貨、客服、營運費用）；並提供用貢獻邊際率逼近淨損益兩平的算法
- **決策規則的樣本與資格前置檢查**（原版無對應內容）：維護期關閉廣告門檻規則新增最低成熟轉換數門檻（比值型指標分母太小即為雜訊）；K／M 兩個門檻倍數給出明確的選值規則（依風險容忍度三段，且要寫進交件文件）；CBO 公平份額檢定前先做**投遞診斷四項**（審核狀態／排程與預算資格／受眾與版位資格／技術資格），fail closed，排除「低花費其實是投遞資格問題」卻誤觸發關閉門檻；品質×成本矩陣明確定義合格率與合格名單成本的分子分母與觀察窗，且任何合格率區間都不會跳過成本檢查
- **零轉換規則的誠實化**：新廣告規則不是「不需要樣本量」，只是把樣本量換算成花費——K=2 時期望 2 次卻拿到 0 次是值得行動的訊號，但不是統計上的定論
- **診斷漏斗的多重成因**（原版把每段寫成單一原因）：停下／留下／點擊／轉換四段，每段除了「最先該檢查的方向」都列出其他可能，避免看到弱 CVR 就直接斷定「一定是到達頁的問題」
- **報告的「判斷基礎」段是必填**：分析單位、成熟資料範圍、追蹤健康度、可比性檢查結果、樣本量、使用的門檻與依據、結論等級——沒有這一段，讀者無從分辨「230 次轉換的紮實結論」跟「3 次轉換的猜測」

## 交叉引用的分工（避免同一條規則有兩份會分歧的正本）

- **放大的幅度與節奏**（調升 +20%／單次不到 30%／間隔 3-5 天；調降是另一條規則）正本在 `ads` 技能的 `references/account-structure.md`，本技能只負責**觸發條件**（什麼時候該調）
- **兩活動結構、帳戶命名、預算配比**屬帳戶設定，正本同樣在 `ads`
- **受控實驗的設計方式**寫在本技能的 `references/evidence-gates.md`；嚴謹的統計判定屬 `ab-testing`（未隨本包提供）

## 改作者

syutolee.com，2026-07-25 新建（合併自原 `ads` 與 `ad-creative` 的成效判斷邏輯，該兩支技能的內容自 2026-07-20 起經多輪修訂）。
