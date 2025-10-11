# OnlyLonely - SwiftUI Project

## プロジェクト概要
SwiftUIを使用したiOSアプリケーションプロジェクト

## プロジェクト構成
```
OnlyLonely/
├── OnlyLonely.xcodeproj/
├── OnlyLonely/
│   ├── OnlyLonelyApp.swift      # アプリケーションのエントリーポイント
│   ├── ContentView.swift         # メインビュー
│   ├── MotionManager.swift       # CoreMotionを使った傾き検出機能
│   └── Preview Content/
└── CLAUDE.md
```

## 技術スタック
- **言語**: Swift 5.0
- **フレームワーク**: SwiftUI
- **最小デプロイメントターゲット**: iOS 18.2
- **開発ツール**: Xcode 16.2

## 主要機能

### MotionManager
CoreMotionフレームワークを使用して端末の傾きを検出するクラス

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

## 開発メモ
- プロジェクトは`PBXFileSystemSynchronizedRootGroup`を使用しているため、OnlyLonelyフォルダ内の新しいファイルは自動的にプロジェクトに追加されます
- プレビュー機能が有効化されています（`ENABLE_PREVIEWS = YES`）

## 初回セットアップ

### Git Hooksの設定
このプロジェクトでは、CLAUDE.mdの変更を自動的にAGENTS.mdに反映するpre-commitフックを使用しています。

初回クローン後、以下のコマンドを実行してください:

```bash
git config core.hooksPath .githooks
```

これにより、CLAUDE.mdをコミットする際に自動的にAGENTS.mdが更新されます。

