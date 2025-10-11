# .github/copilot-instructions.md

## プロジェクト概要

**OnlyLonely**は、SwiftUIを使用して開発されたiOSアプリケーションプロジェクトです。このアプリは、iPhoneとiPadを使用して「息を吹きかけて風船を飛ばす」というユニークなゲーム体験を提供します。

## プロジェクト構成

```
OnlyLonely/
├── OnlyLonely.xcodeproj/          # Xcodeプロジェクトファイル
├── OnlyLonely/                    # アプリケーションの主要コード
│   ├── OnlyLonelyApp.swift        # アプリケーションのエントリーポイント
│   ├── ContentView.swift          # メインビュー
│   ├── MotionManager.swift        # CoreMotionを使った傾き検出機能
│   └── Preview Content/           # プレビュー用のアセット
├── Package/                       # Swift Package Manager関連
│   ├── Package.swift              # パッケージ定義
│   └── Sources/AppFeature/        # アプリケーションの主要機能
├── docs/                          # ドキュメント
│   ├── game-design.md             # ゲームデザイン仕様
│   ├── technical-spec.md          # 技術仕様
│   ├── visual-design.md           # ビジュアルデザイン仕様
│   ├── sound-design.md            # サウンドデザイン仕様
│   └── screens/                   # 各画面の仕様
└── .github/                       # GitHub関連設定
    └── copilot-instructions.md    # このファイル
```

## 開発の重要ポイント

### 1. **主要コンポーネント**
- **MotionManager**: CoreMotionを使用してデバイスの傾きを検出します。
- **MicrophonePermissionManager**: マイクの権限を管理します。
- **MicrophoneLevelManager**: マイク入力の音圧レベルをリアルタイムで取得します。
- **ContentView**: アプリのメインUIを構築します。

### 2. **開発環境**
- **言語**: Swift 5.0
- **フレームワーク**: SwiftUI
- **最小デプロイメントターゲット**: iOS 18.2
- **開発ツール**: Xcode 16.2

### 3. **ビルドと実行**
- Xcodeで`OnlyLonely.xcodeproj`を開き、ターゲットデバイスを選択してビルド・実行します。
- 実機での動作を推奨します（シミュレータでは一部の機能が制限されます）。

### 4. **プロジェクト固有の設定**
- `PBXFileSystemSynchronizedRootGroup`を使用しているため、`OnlyLonely`フォルダ内の新しいファイルは自動的にプロジェクトに追加されます。
- プレビュー機能が有効化されています（`ENABLE_PREVIEWS = YES`）。

### 5. **テストとデバッグ**
- 実機でのテストを推奨します。
- マイクやモーションセンサーを使用する機能は、シミュレータでは動作しません。

## コーディング規約

### 1. **命名規則**
- クラス名: `PascalCase`（例: `MotionManager`）
- 変数名: `camelCase`（例: `microphonePermission`）
- 定数: `UPPER_SNAKE_CASE`（例: `MAX_VOLUME_LEVEL`）

### 2. **コメント**
- 各クラスやメソッドには簡潔な説明を記載してください。
- 特に非同期処理やエラー処理には詳細なコメントを追加してください。

### 3. **エラー処理**
- `do-catch`を使用してエラーを適切に処理してください。
- ユーザーにエラー内容を通知する場合は、UIに反映する仕組みを実装してください。

## 外部依存

- **CoreMotion**: デバイスのモーションデータを取得するために使用。
- **AVFoundation**: マイク入力を処理するために使用。

## 参考資料

- [ゲームデザイン仕様](./docs/game-design.md)
- [技術仕様](./docs/technical-spec.md)
- [ビジュアルデザイン仕様](./docs/visual-design.md)
- [サウンドデザイン仕様](./docs/sound-design.md)

---

このファイルは、AIエージェントがプロジェクトに迅速に適応するためのガイドラインとして機能します。必要に応じて更新してください。