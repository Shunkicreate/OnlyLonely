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
- **フレームワーク**: SwiftUI / SpriteKit / AVFoundation
- **通信方式**: MultipeerConnectivity (P2P接続)
- **音声入力**: AVAudioEngine + RMS 音圧計算
- **物理演算**: SpriteKit PhysicsBody
- **最小デプロイメントターゲット**: iOS 18.0
- **開発ツール**: Xcode 16.2
- **デザインシステム**: 原宿系ふわふわデザイン（Nikumaruフォント、パステルカラー）

## 主要コンポーネント

### AppCoordinator
画面遷移を一元管理する Coordinator パターン実装

**重要な機能**:
- `navigateToRoot()`: タイトル画面に戻る際、自動的にP2Pセッションと接続状態をリセット
- `onReturnToTitle` コールバック: アプリ状態のクリーンアップを実行

### P2PSessionManager
iPad-iPhone 間のP2P通信管理（MultipeerKit使用）
- iPad: ホスト（サーバー）役
- iPhone: ゲスト（クライアント）役
- 同一LAN内で自動検出・接続

**主要機能**:
- デバイスの自動検出 (`availablePeers`)
- 招待の送受信 (`invite()`)
- 接続管理 (`connectedPeers`)
- ナビゲーションコマンドの送信（iPad→iPhone）
- 風力データの送信（iPhone→iPad）
- 状態リセット (`reset()`)

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

## 最近の主要な更新

### 2025-10-12: UI改善とバグ修正
1. **接続待機画面のデザイン改善** (ConnectionWaitingScreen)
   - デバイスカードの幅を600pxに制限し、中央配置
   - フォントサイズを拡大（24pt）して視認性向上
   - セクションタイトルにグラスモーフィズム背景とふわふわボーダー追加
   - 「しょうたいちゅう...」状態に黄色インジケーターとバッジを追加
   - 接続中はカードのボーダー色が黄色に変化

2. **ステータステキストの改善** (ConnectionWaitinScreenModel)
   - 全てのステータスメッセージをひらがなに統一
   - ステータステキストに4方向黒枠（ストローク）を追加して視認性向上
   - 更新されたテキスト:
     - "待機中" → "たいきちゅう"
     - "プレイヤーを探索中..." → "ぷれいやーをさがしているよ..."
     - 招待・接続メッセージもすべてひらがな化

3. **タイトル画面への戻りバグ修正** (AppCoordinator, ContentView)
   - `navigateToRoot()` 時に自動的にP2Pセッションと接続状態をリセット
   - `onReturnToTitle` コールバックを実装
   - 状態リセット内容:
     - P2PSessionManager の停止
     - iPad側ホストモデルのリセット
     - iPhone側ゲストモデルのリセット

## タスク完了時のチェックリスト

### コード変更時
1. ビルド確認（エラー・警告の解消）
2. コードレビュー（命名規則、デザインシステム準拠）
3. 動作確認
   - シミュレータ: 画面遷移、UI レイアウト
   - 実機: MotionManager、マイク音圧検出、P2P接続
4. ドキュメント更新（必要に応じて）
5. **デザインチェック**: ひらがな表記、Nikumaruフォント、パステルカラー使用

### コミット前
1. `git status` で変更内容を確認
2. `git diff` で差分を確認
3. 不要なファイルが含まれていないか確認
4. 適切なコミットメッセージを記述
5. CLAUDE.md の更新（大きな変更の場合）

## デザインシステム

### 原宿系ふわふわタイム（Harajuku Fluffy Time）

**カラーパレット**:
- パステルピンク (`#FFC0CB`)
- パステルブルー (`#B0E0E6`)
- パステルイエロー (`#FFFACD`)
- パステルミント (`#98FF98`)
- パステルパープル (`#DDA0DD`)
- パステルオレンジ (`#FFE5B4`)

**フォント**:
- Nikumaru（にくまるフォント）- かわいい丸文字
- サイズ: タイトル 48-64pt、見出し 20-26pt、本文 16-18pt

**UIコンポーネント**:
- `RainbowText`: 虹色グラデーションテキスト
- `FluffyButton`: ふわふわ3D風ボタン
- `FluffyTextField`: パステルカラーの入力欄
- `RainbowBackground`: 虹色グラデーション背景
- `FluffyCloudBackground`: ふわふわ雲アニメーション
- `.fluffyBorder()`: ふわふわボーダーエフェクト

**テキストルール**:
- **全てひらがな表記** (例: "せつぞく" "ぷれいやー" "あいぱっど")
- 黒枠（ストローク）で視認性向上
- 影とグローで立体感を演出

## 開発メモ

- プロジェクトは `PBXFileSystemSynchronizedRootGroup` を使用しているため、`OnlyLonely/` フォルダ内の新しいファイルは自動的にプロジェクトに追加されます
- プレビュー機能が有効化されています（`ENABLE_PREVIEWS = YES`）
- **実機テスト必須**: MotionManager、マイク機能、P2P接続はシミュレータでは動作しません
- **LAN通信**: MultipeerConnectivity は同一ネットワーク内での通信を想定
- **状態管理**: タイトル画面に戻る際は自動的にP2Pセッションと接続状態がリセットされる

## 関連ドキュメント

詳細な仕様は以下のドキュメントを参照してください：

- [🎮 ゲーム設計書](./docs/game-design.md) - ゲームルール、コンセプト、世界観
- [⚙️ 技術仕様書](./docs/technical-spec.md) - システム構成、通信仕様、開発ロードマップ
- [🎨 ビジュアル設計書](./docs/visual-design.md) - 演出仕様、画面レイアウト
- [🎨 UI設計プロンプト](./docs/ui-design-prompt.md) - **クリエイティブUI実装ガイド（Claude実装時に使用）**
- [🔊 サウンド設計書](./docs/sound-design.md) - サウンドデザイン、効果音
- [📱 画面設計書](./docs/screens/README.md) - 全 12 画面の詳細仕様と画面遷移フロー
