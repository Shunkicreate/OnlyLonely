# GitHub Issue 自動解決コマンド（OnlyLonely）

OnlyLonely プロジェクトの GitHub issue を取得し、解決から PR 作成までを自動化します。

## 使用方法

### 1. オープン issue 一覧を確認

```bash
gh issue list --repo Shunkicreate/OnlyLonely --state open
```

### 2. 特定 issue の詳細確認

```bash
gh issue view <ISSUE_NUMBER> --repo Shunkicreate/OnlyLonely
```

### 3. issue 解決開始

```bash
# ブランチ作成
git checkout main && git pull origin main
git checkout -b fix/<ISSUE_NUMBER>-<short-description>

# 例: issue #5の場合
git checkout -b fix/5-websocket-connection
```

### 4. 実装

以下の要件を守って実装：

- **パフォーマンス要件**: 60fps、30Hz 通信更新周期
- **コーディング規約**: CLAUDE.md に従う
  - ファイル名: PascalCase（例: `TitleScreen.swift`）
  - 画面ファイル: `{デバイス名}{機能名}Screen.swift`
- **Package構成**: `Package/Sources/AppFeature/` 配下に配置
- **ビルド**: Xcode 16.2、iOS 18.0以上

### 5. 品質チェック

```bash
# ビルド確認
xcodebuild clean build \
  -project OnlyLonely.xcodeproj \
  -scheme OnlyLonely \
  -configuration Debug \
  -quiet

# エラー・警告の確認
xcodebuild build \
  -project OnlyLonely.xcodeproj \
  -scheme OnlyLonely 2>&1 | grep -E "error:|warning:"
```

### 6. コミット

```bash
git add -A
git commit -m "fix: <issue title> (#<ISSUE_NUMBER>)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 7. PR 作成

```bash
git push -u origin $(git branch --show-current)
gh pr create \
  --title "fix: [Issue #<ISSUE_NUMBER>] <issue title>" \
  --body "Closes #<ISSUE_NUMBER>" \
  --repo Shunkicreate/OnlyLonely
```

## クイック実行コマンド（一括）

Issue #5 を解決する場合の例：

```bash
# 1. 開始
git checkout main && git pull origin main && \
git checkout -b fix/5-websocket-connection

# 2. 実装後、品質チェック＆コミット＆PR（一括）
xcodebuild clean build -project OnlyLonely.xcodeproj -scheme OnlyLonely -configuration Debug -quiet && \
git add -A && \
git commit -m "fix: WebSocket接続が不安定 (#5)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>" && \
git push -u origin fix/5-websocket-connection && \
gh pr create \
  --title "fix: [Issue #5] WebSocket接続が不安定" \
  --body "Closes #5" \
  --repo Shunkicreate/OnlyLonely
```

## 全オープン issue 確認

```bash
# オープンissue一覧と番号を取得
gh issue list --repo Shunkicreate/OnlyLonely --state open --json number,title | \
jq -r '.[] | "Issue #\(.number): \(.title)"'
```

## 実装のポイント

### issue 内容から修正箇所を特定

1. キーワードで検索

```bash
# Swiftファイル内を検索
rg "WebSocket|GameManager|MotionManager" --type swift

# 特定ディレクトリ内を検索
rg "音圧|マイク" Package/Sources/AppFeature/ --type swift
```

2. 関連ファイルを確認

```bash
# 画面ファイルを探す
find Package/Sources/AppFeature/Screens -name "*.swift"

# サービスファイルを探す
find Package/Sources/AppFeature/Services -name "*.swift"

# 特定の機能を含むファイル
find . -name "*WebSocket*.swift" -o -name "*GameManager*.swift"
```

### パフォーマンスチェック

- **通信**: WebSocket 30Hz更新、遅延 < 50ms
- **描画**: SpriteKit 60fps維持
- **メモリ**: weak self 使用、Timer/WebSocket の適切な解放
- **音声入力**: AVAudioEngine の効率的な使用、RMS 計算最適化

### OnlyLonely 固有の注意点

#### デバイス別実装
- **iPad**: ゲームロジック、WebSocketサーバー、画面分割表示
- **iPhone**: 音圧入力、WebSocketクライアント、傾き検出

#### 実機テスト必須
- MotionManager: シミュレータでは動作しない
- MicrophoneLevelManager: 実機でのみ正確に動作
- WebSocket通信: 同一LAN内の実機間でテスト

#### ディレクトリ構造
```
Package/Sources/AppFeature/
├── Navigation/      # AppCoordinator
├── Models/          # データモデル
├── Screens/         # 画面実装
│   ├── Common/      # 共通画面
│   ├── iPhone/      # iPhone専��（8画面）
│   └── iPad/        # iPad専用（3画面）
└── Services/        # WebSocketService, GameManager
```

### コード品質

- 命名規則遵守（CLAUDE.md 参照）
- ビルドエラー・警告 0 件
- 既存のコードスタイルに従う
- ドキュメント更新（必要に応じて）

## デバッグコマンド

```bash
# ビルドログ全体を確認
xcodebuild build -project OnlyLonely.xcodeproj -scheme OnlyLonely

# 特定のエラーのみ表示
xcodebuild build -project OnlyLonely.xcodeproj -scheme OnlyLonely 2>&1 | grep "error:"

# プロジェクト情報確認
xcodebuild -list -project OnlyLonely.xcodeproj
```

## 関連ドキュメント

実装前に以下を確認：
- [CLAUDE.md](../CLAUDE.md) - プロジェクト概要・コーディング規約
- [docs/technical-spec.md](../docs/technical-spec.md) - 技術仕様
- [docs/screens/](../docs/screens/) - 画面設計書
