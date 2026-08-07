# AI 廣告技能包 v2（免費層）— syutolee.com

*[Read this in English](README.en.md)*

給 Claude Code 等 agent 工具直接載入的數位廣告技能包，符合 [Agent Skills 規格](https://agentskills.io/specification.md)。全英文技能內容（含台灣在地 GEO 模組），這份 README 是唯一的中文門面。部分內容深度在地化改作自 [coreyhaines31/marketingskills](https://github.com/coreyhaines31/marketingskills)（MIT），經本包自己的 v1 沿用至今；完整來源鏈見 `NOTICE.md`，授權見 `LICENSE`。

## 這個包在做什麼

一套跑數位廣告的資產層。貼一個產品或商店網址，agent 掃描首頁，寫出起手 `profile.md` 跟幾個未驗證的切角候選，接著分兩條線走：**策略線**（設角度、上架、出素材）跟**資料線**（追蹤健不健康、數字判斷該不該繼續燒）。

```
kickoff（掃網址）→ quick-angle（切角）
                        │
          ┌─────────────┴─────────────┐
          ↓                           ↓
    ads + ad-creative           tracking-health
    （選平台/預算/受眾/       （追蹤設定/除錯/
     文案/素材規格）           隱私合規）
          │                           │
          └─────────────┬─────────────┘
                        ↓
              campaign-analysis
        （絕對停損判斷：燒過頭了沒）
                        │
                        └──→ 判斷結果回饋到 ads / ad-creative，迴圈繼續
```

## 免費層六支技能

| 技能 | 負責什麼 |
|---|---|
| `kickoff` | 靜態掃描產品網址，寫出起手 `profile.md` 跟 2-3 個未驗證切角候選 |
| `quick-angle` | 三個問題（要打誰、憑什麼贏、對比誰），整理成 `.agents/positioning.md` |
| `ads` | 平台選擇、帳戶結構、預算、受眾、合規複核，只給建議，不動真帳戶 |
| `ad-creative` | 角度、文案、視覺規格：標題、內文、靜圖概念 |
| `tracking-health` | 追蹤有沒有壞：驗證、除錯、修（GA4/GTM/像素/UTM） |
| `campaign-analysis` | 絕對停損判斷：燒錢有沒有燒過該停手的點 |

這六支技能組成一個完整的「掃描、定角度、上架、出素材、查追蹤、抓停損」迴圈，沒有一支會因為缺付費模組就卡住不動；各自的降級寫法見對應 `SKILL.md`。

## 怎麼安裝

Clone 這個 repo，或直接下載後解壓縮，把技能目錄放進你的 agent 環境的 skills 目錄：

```
git clone https://github.com/syutolee/ai-skills-pack.git
```

- **Claude Code**：`~/.claude/skills/`（全域）或專案的 `.claude/skills/`
- **符合 Agent Skills 規格的其他 host**：`.agents/skills/`

把 `contracts/`、`shared/` 跟六支技能目錄放在同一層，不要巢狀塞進某支技能底下。每支技能 `SKILL.md` frontmatter 的 `name` 要跟目錄名稱一致。建議整包一起裝：技能之間會互相檢查對方在不在，缺了會走各自的降級分支，但功能受限。

## 付費層

另外有一組付費模組，涵蓋比較性成效判斷、到達頁診斷、追蹤架構設計、實驗設計跟素材渲染。細節與洽詢見 [syutolee.com](https://syutolee.com)。

## 授權

MIT。`LICENSE` 內兩則版權聲明：**Copyright (c) 2025 Corey Haines**（上游 `coreyhaines31/marketingskills`，依 MIT 條款隨改作保留）與 **Copyright (c) 2026 syutolee.com**（本包原創內容跟英文重寫改作）。逐檔來源與改作性質見 `NOTICE.md`。
