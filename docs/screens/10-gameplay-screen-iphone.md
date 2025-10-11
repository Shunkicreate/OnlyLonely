# 10. ゲームプレイ画面（iPhone）

## 対象デバイス

iPhone のみ

## 役割・目的

- プレイヤーの息入力端末
- マイクで音圧をリアルタイムで取得し、iPad に送信
- 自分の風船の状態（高度）をフィードバック表示
- 残り時間を表示
- ゲーム終了後、リザルト画面へ自動遷移

## 表示要素

### 必須要素

- プレイヤー名（Player A / B）
- 現在の高度
- 残り時間
- 音圧レベルメーター（リアルタイム）

### オプション要素

- 自分の風船のプレビュー（簡易表示）
- 相手の高度（比較用）
- エンカレッジメッセージ（「いいぞ！」など）

## UI レイアウト

```
┌─────────────────────────┐
│  残り時間: 45秒         │
├─────────────────────────┤
│                         │
│   Player A 🎈          │
│                         │
│   現在の高度: 250m      │
│                         │
│      🎈                │
│     ✨✨               │
│                         │
│  音圧レベル:            │
│  ▓▓▓▓▓▓▓▓░░░░░░        │
│                         │
│                         │
│   息を吹きかけて        │
│   風船を飛ばそう！      │
│                         │
└─────────────────────────┘
```

## インタラクション

### リアルタイム音圧送信

- マイクで音圧をリアルタイムで取得
- 30Hz (33ms 間隔) で iPad に送信
- 音圧レベルメーターに表示

### 状態受信

- iPad から自分の高度を受信
- リアルタイムで表示更新

### 自動遷移

- 制限時間が 0 になったら、リザルト画面へ自動遷移

## 画面遷移

### 次の画面（時間切れ時）

- **12. リザルト画面（iPhone）** へ自動遷移

## 通信

### 送信メッセージ

#### 息の強さ（音圧）

```json
{
  "type": "wind",
  "playerId": "A",
  "force": 0.72
}
```

- `force`: 0.0 〜 1.0 の範囲
- 30Hz で送信

### 受信メッセージ

#### 状態同期（リアルタイム）

```json
{
  "type": "state",
  "playerId": "A",
  "altitude": 250.3,
  "time_remaining": 45
}
```

#### ゲーム終了

```json
{
  "type": "game_end",
  "winner": "A",
  "playerA_altitude": 350.5,
  "playerB_altitude": 280.3
}
```

## 実装メモ

### 使用技術

- AVAudioEngine でマイク入力
- RMS で音圧計算
- SwiftUI で画面実装
- Timer で定期送信 (30Hz)

### 音圧計算

```swift
// RMS 計算（キャリブレーション済みの閾値を使用）
let rms = sqrt(samples.map { $0 * $0 }.reduce(0, +) / Float(samples.count))
let normalizedForce = (rms - minThreshold) / (maxThreshold - minThreshold)
let clampedForce = max(0.0, min(1.0, normalizedForce))
```

### 送信頻度

- 30Hz (33ms 間隔)

### 状態管理

- 現在の高度
- 残り時間
- 音圧レベル

## デザインメモ

### カラー

- 背景: 空色のグラデーション
- Player A: 赤系
- Player B: 青系
- 音圧メーター: グラデーション（低: 緑 → 高: 赤）

### アニメーション

- 音圧に応じてメーターがリアルタイムで動く
- 風船がふわふわと上下（高度に応じて）
- 息を吹くとパーティクルが発生（オプション）

### サウンド

- 音圧に応じてフィードバック音（オプション）
- 高度が上がると音が軽くなる

### ハプティクス

- 息を吹いた時の振動フィードバック（オプション）
- **衝突時の振動フィードバック**（重要）

### 衝突時のフィードバック（iPhone）

プレイヤーが何かと衝突した際、iPhone でもフィードバックを提供してユーザー体験を向上させます。

#### ハプティクスフィードバック

| 衝突タイプ       | ハプティクスパターン | 説明                               |
| ---------------- | -------------------- | ---------------------------------- |
| キャラクター衝突 | `.medium` タップ     | 相手プレイヤーとぶつかった時       |
| 弱い衝突         | `.light` タップ      | 雲（竹）、流れ星など軽い衝突       |
| 中程度の衝突     | `.medium` タップ     | 電線、カラス、凧揚げ、雲（松）     |
| 強い衝突         | `.heavy` インパクト  | 雲（梅）、隕石などの大きな衝突     |
| 雷ヒット         | `.heavy` + 連続振動  | 風船が割れる時の強い振動           |

#### 視覚的フィードバック

- **衝突インジケーター**: 画面上部に小さなアイコンで衝突を通知
  - 赤い「!」マーク: ダメージを受ける衝突（雷、隕石）
  - 黄色い「!」マーク: 障害物との衝突
  - 青い波紋アイコン: キャラクター同士の衝突
- **画面フラッシュ**: 強い衝突時に画面が軽く白く点滅（0.1秒）
- **風船の揺れ**: 衝突時に風船プレビュー（表示している場合）が揺れる

#### オーディオフィードバック

- iPad で再生される衝突音に連動（空間オーディオの場合）
- オプション: iPhone でも衝突音を再生（iPad との同期）

#### テキスト通知（オプション）

- 大きな衝突時に短いメッセージを表示（0.5秒間）
  - 「カラスに押された！」
  - 「雲にぶつかった！」
  - 「相手とぶつかった！」
  - 「雷に当たった！」

#### 実装メモ

```swift
import CoreHaptics
import UIKit

class CollisionFeedbackManager {
    private var hapticEngine: CHHapticEngine?

    init() {
        prepareHaptics()
    }

    func prepareHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine error: \(error)")
        }
    }

    func playCollisionFeedback(type: CollisionType) {
        switch type {
        case .character:
            triggerImpact(.medium)
        case .weak:
            triggerImpact(.light)
        case .medium:
            triggerImpact(.medium)
        case .strong:
            triggerImpact(.heavy)
            flashScreen()
        case .lightning:
            triggerImpact(.heavy)
            triggerContinuousHaptic(duration: 0.3)
            flashScreen()
        }
    }

    private func triggerImpact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    private func flashScreen() {
        // 画面フラッシュエフェクト
        let flashView = UIView(frame: UIScreen.main.bounds)
        flashView.backgroundColor = .white
        flashView.alpha = 0.5
        // アニメーションで消す
    }
}

enum CollisionType {
    case character  // キャラクター衝突
    case weak       // 弱い衝突
    case medium     // 中程度の衝突
    case strong     // 強い衝突
    case lightning  // 雷ヒット
}
```

## 未定事項

- [ ] 音圧メーターの表示要否
- [ ] 風船プレビューの表示要否
- [ ] 相手の高度表示の要否
- [ ] エンカレッジメッセージの実装
- [ ] ハプティクスフィードバックの有無
- [ ] フィードバック音の有無
- [ ] スリープ防止の実装
- [ ] 衝突インジケーターのデザインと配置
- [ ] テキスト通知の表示要否
- [ ] ハプティクスパターンの強度調整
- [ ] iPad との衝突音同期の実装方法
