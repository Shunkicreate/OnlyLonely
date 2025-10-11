# ⚙️ 技術仕様書

## システム構成

```
[iPhone A]       [iPhone B]
    ↓                 ↓
 (息の入力)       (息の入力)
    ↓                 ↓
 ───────────────────────────────
                    [iPad]
     メインビュー & ロジック処理
 左右に画面を分割し、それぞれの
 風船の上昇をリアルタイム表示
 ───────────────────────────────
```

## 端末構成

| 端末         | 役割                                       |
| ------------ | ------------------------------------------ |
| iPhone A / B | プレイヤー入力端末（マイクで音圧を取得）   |
| iPad         | メインディスプレイ（風船の挙動・対戦処理） |

---

## 技術スタック

| 項目           | 使用技術                                     |
| -------------- | -------------------------------------------- |
| 言語           | Swift 5.9                                    |
| フレームワーク | SwiftUI / SpriteKit / AVFoundation / Network |
| 通信方式       | MultipeerKit（MultipeerConnectivity ベースの P2P） |
| 音声入力       | AVAudioEngine + RMS 音圧計算                 |
| 物理演算       | SpriteKit PhysicsBody                        |
| デバイス構成   | iPad（サーバー）＋ iPhone ×2（クライアント） |
| 更新周期       | 30Hz (33ms 間隔)                             |

---

## 通信仕様

### 通信方式

- MultipeerKit によるローカル P2P 通信（内部的に MultipeerConnectivity を利用）
- iPad がホスト（手動招待で iPhone を参加させる）、iPhone がゲスト（ホストからの招待を待受）

### 通信フォーマット（JSON）

#### iPhone → iPad（P2P メッセージ）

```json
{
  "type": "wind",
  "playerId": "A",
  "force": 0.72
}
```

**Note**: `force` は息の強さを表し、風船を持った子供を上昇させます。

#### iPad → iPhone（P2P メッセージ）

```json
{
  "type": "state",
  "playerId": "A",
  "altitude": 250.3
}
```

#### 雷イベント（iPad → iPhone）

```json
{
  "type": "lightning_hit",
  "playerId": "A",
  "altitude": 200.0
}
```

#### 虹色の綿菓子取得（iPad → 双方 iPhone）

```json
{
  "type": "cotton_candy_trigger",
  "ownerId": "A",
  "targetId": "B",
  "duration": 2.0,
  "penalty": -10.0
}
```

#### シャボン玉発射（iPad → 双方 iPhone）

```json
{
  "type": "bubble_attack",
  "ownerId": "B",
  "sequence": 1,
  "travelTime": 1.2
}
```

#### シャボン玉命中（iPad → 双方 iPhone）

```json
{
  "type": "bubble_hit",
  "targetId": "A",
  "penalty": -5.0,
  "flinchDuration": 0.5
}
```

### 今後定義すべきメッセージ

- [ ] 接続確立メッセージ（P2P 接続時のロール/参加通知）
- [ ] ゲーム開始メッセージ
- [ ] ゲーム終了メッセージ
- [ ] エラーメッセージ
- [ ] 切断メッセージ
- [x] 雷ヒット通知メッセージ（追加済み）
- [x] 攻撃アイテム取得・効果同期メッセージ（虹色の綿菓子、シャボン玉）

---

## 音声入力仕様

### マイク入力

- `AVAudioEngine` で音声データ取得
- RMS (Root Mean Square) で音圧計算
- 音声データは送らず、**音圧値のみ送信**

### 音圧計算

- TBD: サンプリングレート
- TBD: バッファサイズ
- TBD: 平滑化アルゴリズム

### キャリブレーション

- 感度調整必須
- TBD: キャリブレーション方法

---

## 物理演算仕様

### 重力モデル

- 上昇力 − 抵抗 − 重力で算出
- SpriteKit の `PhysicsBody` を使用

### パラメータ（仮）

- 重力: TBD
- 空気抵抗: TBD
- 風船の質量: TBD
- 上昇力の係数: TBD

---

## 雲システム仕様

### 雲の種類と物理特性

| 種類 | タイプ       | 物理挙動                                          |
| ---- | ------------ | ------------------------------------------------- |
| 松   | ギミック付き | 通り抜けにくさ + 雷エフェクト                     |
| 竹   | 速度依存障害 | 速度閾値チェック + 条件付き通過                   |
| 梅   | 完全障害物   | PhysicsBody の `isDynamic = false` で完全ブロック |

### 雲データフォーマット（JSON）

雲の配置は JSON ファイルで管理します。  
サンプルファイル: [`cloud-config-example.json`](./cloud-config-example.json)

```json
{
  "clouds": [
    {
      "id": 1,
      "type": "pine",
      "position": { "x": 200, "y": 150 },
      "size": { "width": 100, "height": 50 }
    },
    {
      "id": 2,
      "type": "bamboo",
      "position": { "x": 350, "y": 300 },
      "size": { "width": 120, "height": 60 },
      "speedThreshold": 50
    },
    {
      "id": 3,
      "type": "pine",
      "position": { "x": 150, "y": 450 },
      "size": { "width": 150, "height": 70 },
      "lightningInterval": 3.0
    }
  ],
  "items": [
    {
      "id": 101,
      "type": "cottonCandy",
      "spawnAltitude": { "min": 200, "max": 550 },
      "cooldown": 8.0,
      "penalty": -10.0,
      "duration": 2.0
    },
    {
      "id": 102,
      "type": "bubbleWand",
      "spawnAltitude": { "min": 150, "max": 350 },
      "cooldown": 10.0,
      "shots": 3,
      "penalty": -5.0,
      "flinchDuration": 0.5
    }
  ]
}
```

### 雲のタイプ定義

```swift
enum CloudType: String, Codable {
    case pine     // 松：雷ギミック付き
    case bamboo   // 竹：強い勢いで通過可能
    case plum     // 梅：通り抜け不可
}

struct CloudData: Codable {
    let id: Int
    let type: CloudType
    let position: CGPoint
    let size: CGSize
    let speedThreshold: CGFloat?        // 竹のみ
    let lightningInterval: TimeInterval? // 松のみ
}

enum AttackItemType: String, Codable {
    case cottonCandy
    case bubbleWand
}

struct AttackItemData: Codable {
    let id: Int
    let type: AttackItemType
    let spawnAltitude: ClosedRange<CGFloat>
    let cooldown: TimeInterval
    let penalty: CGFloat
    let duration: TimeInterval?
    let shots: Int?
    let flinchDuration: TimeInterval?
}
```

### 雷システム（松の雲）

#### 雷の発生

- 松の雲から `lightningInterval` 秒ごとに雷が発生
- 雷は下方向に降り注ぐアニメーション
- SKEmitterNode で視覚的に表現

#### 当たり判定

```swift
// 風船と雷の衝突検出
func didBegin(_ contact: SKPhysicsContact) {
    if contact.bodyA.categoryBitMask == PhysicsCategory.balloon
       && contact.bodyB.categoryBitMask == PhysicsCategory.lightning {
        handleLightningHit()
    }
}

func handleLightningHit() {
    // 1. 風船が割れる演出
    // 2. 高度を減少（ペナルティ）
    // 3. 新しい風船を生成
}
```

### 風船再生成

- 雷に当たったら、風船が割れる演出
- 落下距離と再生成時間は [ゲームパラメータ：ダメージ設定](./game-parameters.md#ダメージ設定) を参照
- 再生成中は入力を無効化（オプション）

### 攻撃アイテムシステム

#### 虹色の綿菓子

- `AttackItemManager` がアイテムリストを監視し、クールダウン経過後に指定高度帯へスポーン。
- プレイヤーが接触した瞬間、対象プレイヤー（相手）の頭上に `RainbowCottonCloud` ノードを生成。
- 雲は `duration` 秒間、定期的に `penalty / duration` の割合で高度を減少させる。
- 効果中は対象プレイヤーの `verticalForce` に減衰係数を掛け、見た目や音をトリガー。
- 効果終了後は `cotton_candy_end` イベントを送信し、雲ノードとパーティクルをフェードアウト。

#### シャボン玉セット

- 取得イベントを検知すると `BubbleLauncher` コンポーネントを起動し、相手側の画面端から吹き棒（SpriteKit ノード）をアニメーション表示。
- `shots` 回分、一定間隔で `BubbleProjectile` を生成。物理ボディは低速で相手方向に移動。
- プロジェクタイルがプレイヤーに当たったら `bubble_hit` メッセージを送信し、怯み時間とペナルティを適用。命中したバブルは破裂アニメーション。
- 当たらなかったバブルは一定距離でフェードアウト。全弾処理後に吹き棒は退場し、再スポーンタイマーを開始。
- iPhone には `bubble_attack` / `bubble_hit` 通知で UI・ハプティクスを同期。

---

## アーキテクチャ設計

### iPad (ホスト側)

- TBD

### iPhone (ゲスト側)

- TBD

---

## パフォーマンス要件

- 更新周期: 30Hz (33ms 間隔)
- 通信遅延: < 50ms (目標)
- フレームレート: 60fps

---

## 開発ロードマップ

| ステージ | 内容                                       |
| -------- | ------------------------------------------ |
| 1️⃣       | iPhone で音圧取得（息入力）                |
| 2️⃣       | iPad にリアルタイム送信                    |
| 3️⃣       | SpriteKit 上で風船の物理挙動               |
| 4️⃣       | 双方の風船を同期描画（左右分割）           |
| 5️⃣       | 勝敗判定・演出実装                         |
| ✨       | サウンド・背景アニメーション・タイトル画面 |

---

## 開発者向けメモ

- マイク音圧は `AVAudioEngine` + RMS 計算で取得
- 通信は `MultipeerKit`（内部で MultipeerConnectivity を利用）を使用
- キャリブレーション画面で感度調整必須
- 音声データは送らず、音圧値のみ送信
- SpriteKit の `SKEmitterNode` で風・粒子演出
