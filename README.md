# 🎈 OnlyLonely

> 「息で飛ばす、ふたりの風船」

**OnlyLonely** は、ふたりがリアルタイムで「息」を吹きかけて風船を飛ばす対戦ゲームです。

---

## 🌬 概要

息を吹きかけて、自分の風船をより高く飛ばせ。  
シンプルだけど、ちょっと切ない。  
ふわふわした空の中で、たったひとつの風を信じて戦う。

iPad がメインディスプレイ、iPhone が風入力端末となり、  
「どちらの風船がより高く飛べるか」を競います。

---

## 📁 ドキュメント

詳細な仕様は以下のドキュメントを参照してください：

- [🎮 ゲーム設計書](./docs/game-design.md) - ゲームルール、コンセプト、世界観
- [⚙️ 技術仕様書](./docs/technical-spec.md) - システム構成、通信仕様、開発ロードマップ
- [🎨 ビジュアル設計書](./docs/visual-design.md) - 演出仕様、画面レイアウト
- [🔊 サウンド設計書](./docs/sound-design.md) - サウンドデザイン、効果音

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
