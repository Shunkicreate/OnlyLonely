# 🎈 OnlyLonely

> 「息で飛ばす、ふたりの風船」

**OnlyLonely** は、ふたりがリアルタイムで「息」を吹きかけて、風船を持った子供を星まで導く対戦レースゲームです。

---

## 🌬 概要

息を吹きかけて、風船を持った子供を星（ゴール）まで導け。  
シンプルだけど、ちょっと切ない。  
ふわふわした空の中で、たったひとつの風を信じて戦う。

iPad がメインディスプレイ、iPhone が風入力端末となり、  
**先に星に到達した方が勝利**。30 秒以内に誰も到達しなければ引き分け。

---

## 📁 ドキュメント

詳細な仕様は以下のドキュメントを参照してください：

### コア設計

- [📖 ストーリー・コンセプト](./docs/story-and-game-concept.md) - 世界観、ストーリー、ゲームコンセプト
- [🎮 ゲーム設計書](./docs/game-design.md) - ゲームルール、パラメータ、勝利条件
- [👦 キャラクター仕様書](./docs/character-spec.md) - 子供と風船の仕様、ダメージシステム

### 技術・ビジュアル

- [⚙️ 技術仕様書](./docs/technical-spec.md) - システム構成、通信仕様、開発ロードマップ
- [🎨 ビジュアル設計書](./docs/visual-design.md) - 演出仕様、画面レイアウト
- [🔊 サウンド設計書](./docs/sound-design.md) - サウンドデザイン、効果音

### ゲーム要素

- [🌟 障害物・ギミック仕様書](./docs/obstacles-and-gimmicks.md) - 障害物とギミックの詳細仕様
- [☁️ 雲配置サンプル](./docs/cloud-config-example.json) - 雲の配置データ（JSON）
- [📱 画面設計書](./docs/screens/README.md) - 全画面の詳細仕様と画面遷移フロー

---

## 🚀 Getting Started

TBD

---

## 🛠 Development

### Requirements

- Xcode 15.0+
- iOS 17.0+
- iPad & iPhone (実機推奨)

### Setup

TBD

### MCP Server (Serena)

このプロジェクトでは、Serena MCP サーバーを使用して IDE 級のセマンティックコード解析・編集を行っています。

#### 1. uv のインストール

```bash
asdf plugin add uv
```

#### 2. serena のインストール

```bash
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)
```

#### 3. serena mcp とプロジェクトの連携

```bash
/mcp__serena__initial_instructions
```

---

## 📝 License

TBD
