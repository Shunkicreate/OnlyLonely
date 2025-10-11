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

- TBD

### Setup

TBD

---

## 📝 License

| 要素       | 内容                                        |
| ---------- | ------------------------------------------- |
| 入力       | マイクの音圧（息の強さ）をリアルタイム取得  |
| 通信       | WebSocket (LAN 通信) によるリアルタイム同期 |
| 表示       | SpriteKit で描画（ふわふわした挙動）        |
| 重力モデル | 上昇力 − 抵抗 − 重力で算出                  |
| 背景演出   | 上がるほど空が明るく／音が静かに変化        |
| 勝敗判定   | 一定時間後により高い方が勝利                |

---

## ⚙️ 技術仕様

| 項目           | 使用技術                                     |
| -------------- | -------------------------------------------- |
| 言語           | Swift 5.9                                    |
| フレームワーク | SwiftUI / SpriteKit / AVFoundation / Network |
| 通信方式       | WebSocket (URLSessionWebSocketTask)          |
| 音声入力       | AVAudioEngine + RMS 音圧計算                 |
| 物理演算       | SpriteKit PhysicsBody                        |
| デバイス構成   | iPad（サーバー）＋ iPhone ×2（クライアント） |
| 更新周期       | 30Hz (33ms 間隔)                             |

### 通信フォーマット（JSON）

```json
// iPhone → iPad
{
  "type": "wind",
  "playerId": "A",
  "force": 0.72
}

// iPad → iPhone
{
  "type": "state",
  "playerId": "A",
  "altitude": 250.3
}
🎨 演出仕様
イベント	表現
吹く	気流の粒子が発生、風船がふわっと光る
高度上昇	背景が明るく、音が軽くなる
息を止める	ゆっくり下降、風船が揺れる
頂上到達	小さな鐘の音＋淡い光輪
結果発表	Winner の風船が空の上に消える演出

🔊 サウンドデザイン
吹く音圧に合わせてピッチが上がる “風の音”

高度が上がると空気の音が薄くなる

頂上で「ふわ〜ん」と残響

終了時は無音 → タイトル「OnlyLonely」が浮かぶ

🧪 開発ロードマップ
ステージ	内容
1️⃣	iPhone で音圧取得（息入力）
2️⃣	iPad にリアルタイム送信
3️⃣	SpriteKit 上で風船の物理挙動
4️⃣	双方の風船を同期描画（左右分割）
5️⃣	勝敗判定・演出実装
✨	サウンド・背景アニメーション・タイトル画面追加

🌈 世界観
空には、誰もいない。
でも、誰かと同じ空を見上げている。
OnlyLonely は、そんな “ふたりの孤独” をつなぐ風のゲーム。
息を吹きかけるたびに、画面も心も、少しだけ明るくなる。

🧑‍💻 開発者向けメモ
マイク音圧は AVAudioEngine + RMS計算で取得。

通信は URLSessionWebSocketTask (LAN 内接続前提)。

キャリブレーション画面で感度調整必須。

音声データは送らず、音圧値のみ送信。

SpriteKit の SKEmitterNode で風・粒子演出。
```

## Serena

Serena は、LLM を完全なコーディングエージェントに変換するオープンソースの MCP サーバーです。Language Server Protocol (LSP) を活用して IDE 級のセマンティックコード解析・編集機能を提供します。

1. uv のインストール

```
asdf plugin add uv
```

2. serena のインストール

```
claude mcp add serena -- uvx --from git+https://github.com/oraios/serena serena start-mcp-server --context ide-assistant --project $(pwd)
```

3. serena mcp とプロジェクトの連携

```
/mcp__serena__initial_instructions
```

TBD
