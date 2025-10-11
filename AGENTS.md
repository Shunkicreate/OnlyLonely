# OnlyLonely - SwiftUI Project

## プロジェクト概要

**OnlyLonely** は、ふたりがリアルタイムで「息」を吹きかけて風船を飛ばす対戦ゲームアプリ。

> 「息で飛ばす、ふたりの風船」

### コンセプト
- 息を吹きかけて、自分の風船をより高く飛ばせ
- iPad がメインディスプレイ、iPhone が風入力端末
- 制限時間内により高く飛んだ方が勝利
- 雲の障害物（松竹梅）と雷ギミックが存在

### 端末構成
| 端末         | 役割                                       |
| ------------ | ------------------------------------------ |
| iPad         | サーバー、メインディスプレイ（左右分割表示） |
| iPhone A / B | クライアント、マイクで音圧を取得（息の強さ） |

## プロジェクト構成

```
OnlyLonely/
├── OnlyLonely.xcodeproj/        # Xcodeプロジェクト
├── OnlyLonely/                  # アプリエントリーポイント
│   └── main.swift
├── Package/                     # Swift Package
│   └── Sources/
│       └── AppFeature/
│           ├── Navigation/      # 画面遷移管理
│           │   └── AppCoordinator.swift
│           ├── Models/          # データモデル
│           │   ├── WebSocketMessage.swift
│           │   ├── GameState.swift
│           │   ├── DeviceType.swift
│           │   └── PlayerInfo.swift
│           ├── Screens/         # 画面実装
│           │   ├── Common/      # 共通画面（タイトル）
│           │   ├── iPhone/      # iPhone専用画面（7画面）
│           │   └── iPad/        # iPad専用画面（3画面）
│           ├── Services/        # ビジネスロジック
│           │   ├── WebSocketService.swift
│           │   └── GameManager.swift
│           ├── MotionManager.swift
│           ├── MicrophoneLevelManager.swift
│           ├── MicrophonePermissionManager.swift
│           ├── OnlyLonelyApp.swift
│           └── ContentView.swift
├── docs/                        # 設計ドキュメント
│   ├── game-design.md
│   ├── technical-spec.md
│   ├── visual-design.md
│   ├── sound-design.md
│   └── screens/                 # 12画面の詳細仕様
└── CLAUDE.md
```

## 技術スタック

- **言語**: Swift 5.9
- **フレームワーク**: SwiftUI / SpriteKit / AVFoundation / Network
- **通信方式**: WebSocket (URLSessionWebSocketTask)
- **音声入力**: AVAudioEngine + RMS 音圧計算
- **物理演算**: SpriteKit PhysicsBody
- **最小デプロイメントターゲット**: iOS 18.0
- **開発ツール**: Xcode 16.2

## 主要コンポーネント

### AppCoordinator
画面遷移を一元管理する Coordinator パターン実装

### WebSocketService
iPad-iPhone 間の通信管理
- iPad: WebSocket サーバー
- iPhone: WebSocket クライアント
- メッセージ形式: JSON

**通信例**:
```json
// iPhone → iPad（息の強さ）
{
  "type": "wind",
  "playerId": "A",
  "force": 0.72
}

// iPad → iPhone（風船の高度）
{
  "type": "state",
  "playerId": "A",
  "altitude": 250.3
}
```

### GameManager
ゲームロジック管理
- スコア管理
- 時間管理
- 勝敗判定

### MotionManager
CoreMotion を使った端末の傾き検出（iPhone用）

**機能**:
- Pitch（前後の傾き）の検出
- Roll（左右の傾き）の検出
- Yaw（回転）の検出
- リアルタイムでのデータ更新（0.1秒間隔）

**使用方法**:
```swift
@StateObject private var motionManager = MotionManager()

// データへのアクセス
motionManager.pitch  // 前後の傾き（度）
motionManager.roll   // 左右の傾き（度）
motionManager.yaw    // 回転（度）
```

**注意事項**:
- 実機でのみ動作します（シミュレータでは常に0を返します）
- CoreMotionフレームワークが必要です

### MicrophoneLevelManager
AVAudioEngine を使った音圧レベル取得（iPhone用）
- RMS (Root Mean Square) で音圧計算
- 息の強さを検出
- 音声データは送らず、音圧値のみ送信

## 画面構成（全12画面）

### 共通画面（1画面）
- 01. タイトル画面

### iPad専用画面（3画面）
- 03. 接続待機画面
- 04. ゲームプレイ画面（左右分割）
- 05. リザルト画面

### iPhone専用画面（8画面）
- 06. 接続画面
- 07. プレイヤー名入力画面
- 08. キャリブレーション画面（MVP では省略可能）
- 09. 待機画面
- 10. カウントダウン画面
- 11. ゲームプレイ画面（息入力）
- 12. リザルト画面

詳細は [docs/screens/README.md](./docs/screens/README.md) を参照

## 開発コマンド

### ビルド
```bash
# プロジェクトをビルド
xcodebuild -project OnlyLonely.xcodeproj -scheme OnlyLonely -configuration Debug build

# クリーン
xcodebuild clean -project OnlyLonely.xcodeproj -scheme OnlyLonely
```

### Git 操作
```bash
git status
git add .
git commit -m "commit message"
git push origin <branch-name>
```

### Xcode で開く
```bash
open OnlyLonely.xcodeproj
```

## コーディング規約

### 命名規則
- **ファイル名**: PascalCase（例: `TitleScreen.swift`）
- **クラス/構造体**: PascalCase
- **変数/関数**: camelCase
- **Enum**: PascalCase、case は camelCase

### 画面ファイル命名
- 共通: `{機能名}Screen.swift`（例: `TitleScreen.swift`）
- デバイス固有: `{デバイス名}{機能名}Screen.swift`（例: `iPadGameplayScreen.swift`）

### データモデル
- `Codable` を使用して JSON シリアライゼーション対応
- 構造体を優先（値型の利点を活かす）

## タスク完了時のチェックリスト

### コード変更時
1. ビルド確認（エラー・警告の解消）
2. コードレビュー（命名規則、ベストプラクティス）
3. 動作確認
   - シミュレータ: 画面遷移、UI レイアウト
   - 実機: MotionManager、マイク音圧検出
4. ドキュメント更新（必要に応じて）

### コミット前
1. `git status` で変更内容を確認
2. `git diff` で差分を確認
3. 不要なファイルが含まれていないか確認
4. 適切なコミットメッセージを記述

## 開発メモ

- プロジェクトは `PBXFileSystemSynchronizedRootGroup` を使用しているため、`OnlyLonely/` フォルダ内の新しいファイルは自動的にプロジェクトに追加されます
- プレビュー機能が有効化されています（`ENABLE_PREVIEWS = YES`）
- **実機テスト必須**: MotionManager、マイク機能はシミュレータでは動作しません
- **LAN通信**: WebSocket は同一ネットワーク内での通信を想定

## 関連ドキュメント

詳細な仕様は以下のドキュメントを参照してください：

- [🎮 ゲーム設計書](./docs/game-design.md) - ゲームルール、コンセプト、世界観
- [⚙️ 技術仕様書](./docs/technical-spec.md) - システム構成、通信仕様、開発ロードマップ
- [🎨 ビジュアル設計書](./docs/visual-design.md) - 演出仕様、画面レイアウト
- [🎨 UI設計プロンプト](./docs/ui-design-prompt.md) - **クリエイティブUI実装ガイド（Claude実装時に使用）**
- [🔊 サウンド設計書](./docs/sound-design.md) - サウンドデザイン、効果音
- [📱 画面設計書](./docs/screens/README.md) - 全 12 画面の詳細仕様と画面遷移フロー
