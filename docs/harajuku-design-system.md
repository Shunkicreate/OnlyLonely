# ふわふわたいむ デザインシステム

> **OnlyLonely の原宿スタイル UI 実装ガイド**
> カラフル、ふわふわ、キラキラ、ポップで可愛い世界観を保つための完全リファレンス
>
> **重要**: 絵文字は使用せず、Assets画像を活用してビジュアル表現を行います

---

## 📖 目次

1. [デザイン哲学](#デザイン哲学)
2. [カラーパレット](#カラーパレット)
3. [タイポグラフィ](#タイポグラフィ)
4. [アニメーション](#アニメーション)
5. [コンポーネントライブラリ](#コンポーネントライブラリ)
6. [レイアウトとスペーシング](#レイアウトとスペーシング)
7. [実装例](#実装例)
8. [世界観を守るためのルール](#世界観を守るためのルール)

---

## 🎨 デザイン哲学

### コアコンセプト

**「原宿系ふわふわ」とは何か？**

- **カラフル**: 虹色、パステルカラー、明るくポップな配色
- **ふわふわ**: 柔らかい質感、丸みのある形状、浮遊感のあるアニメーション
- **キラキラ**: グラデーション、光の表現、輝くエフェクト
- **親しみやすさ**: ひらがな中心のテキスト、Assets画像、優しい言葉遣い
- **楽しさ**: 動きのあるアニメーション、遊び心のあるインタラクション
- **ビジュアル重視**: 絵文字ではなくAssetsの画像を使用してキャラクター性を表現

### デザイン原則

1. **明るさ優先**: 暗い色は極力避け、明るくポジティブな印象を
2. **柔らかさ**: 角を丸く、影を柔らかく、動きをスムーズに
3. **視覚的な楽しさ**: 静的な画面を避け、常に何かが動いている
4. **画像による表現**: **絵文字は使用せず**、Assets画像を使ってキャラクター性や感情を視覚化する
5. **統一感**: すべての要素が原宿の世界観に調和している
6. **3D効果**: タイトルやテキストにグラデーション・影・アウトラインで奥行きを表現
7. **レスポンシブデザイン**: **どのiPhoneでもレイアウトが崩れないように設計する**
   - ScrollViewを活用してコンテンツの可視性を確保
   - GeometryReaderで画面サイズに応じた動的レイアウト
   - 固定の高さ・幅ではなく、相対的なサイズ指定（.frame(maxWidth: .infinity)など）
   - 小さい画面（iPhone SE）でも大きい画面（iPhone Pro Max）でも快適に使える
8. **フォント統一**: **すべてのテキストで07にくまるフォントを使用する**
   - `.nikumaruTitle()`, `.nikumaruBody()` などのView修飾子を使用
   - システムフォント（`.font(.system())`）は使用禁止
   - 世界観を統一するため、例外なくNikumaruフォントを指定

### 避けるべき表現

❌ **NG例**:
- 暗い色（黒、ダークグレー）の背景
- 直線的で硬い形状
- 無機質なアイコン（システムアイコンのみ）
- カタカナ・漢字のみのテキスト
- 静的で動きのないUI
- **絵文字の使用**（タイトル、ボタン、装飾などすべて）
- **固定サイズによるレイアウト崩れ**（特定の画面サイズに依存したデザイン）
- スクロールできない長いコンテンツ（小さい画面で見切れる）
- **システムフォントの使用**（`.font(.system())`、`.font(.title)` など）

✅ **OK例**:
- パステルカラーの背景に虹色のアクセント
- 丸みを帯びた形状（border-radius: 20以上）
- **Assets画像を使用したキャラクター表現**
- ひらがな中心のやさしいテキスト
- ふわふわ浮かぶアニメーション
- グラデーション・影・アウトラインによる3D効果
- **ScrollView + 相対サイズ指定によるレスポンシブレイアウト**
- どの画面サイズでも快適に使える柔軟なデザイン
- **Nikumaruフォントの使用**（`.nikumaruTitle()`、`.nikumaruBody()` など）

---

## 🌈 カラーパレット

### プライマリカラー（パステル）

```swift
// HarajukuColors として実装済み

// ベースカラー
.pastelPink      = #FFB3D9  // ふわふわピンク（メイン）
.pastelBlue      = #B3E5FF  // そらいろブルー
.pastelPurple    = #D4B3FF  // ゆめみるパープル
.pastelYellow    = #FFE5B3  // はちみつイエロー
.pastelMint      = #B3FFD9  // ミントグリーン
.pastelPeach     = #FFD4B3  // ももいろピーチ
.pastelLavender  = #E5B3FF  // ラベンダーむらさき
```

### グラデーション

```swift
// 虹色グラデーション（最も重要）
HarajukuColors.rainbowGradient
// 7色のパステルカラーが順に並ぶ
// 用途: 背景、大きなタイトル、重要な要素

// ピンク→パープル
HarajukuColors.pinkPurpleGradient
// 用途: ボタン、入力フィールド

// ブルー→ミント
HarajukuColors.blueMintGradient
// 用途: 入力フィールド、カード

// スカイグラデーション
HarajukuColors.skyGradient
// 用途: 空や雲をイメージする箇所

// キャンディグラデーション
HarajukuColors.candyGradient
// 用途: アクションボタン、強調したい要素
```

### プレイヤーカラー

```swift
// プレイヤーA: ピンク系
.playerAPrimary   = .pastelPink
.playerASecondary = .pastelPeach

// プレイヤーB: ブルー系
.playerBPrimary   = .pastelBlue
.playerBSecondary = .pastelMint
```

### テキストカラー

```swift
// 基本テキスト
.textPrimary     = #4A4A4A  // やや暗いグレー（読みやすさ重視）
.textSecondary   = #8B7B8B  // 紫がかったグレー
.textInactive    = #B8A8B8  // 薄いパステルグレー
```

### 使い方の指針

- **背景**: グラデーション背景を使用（スカイブルー→宇宙、虹色など）
- **ボタン**: シンプルな白文字 + グロー効果
- **タイトル**: 3Dグラデーション効果（グラデーション + 影 + 白いアウトライン）
- **風船・キャラクター**: Assets画像 + 円形グラデーションUI + グロー効果

---

## ✏️ タイポグラフィ

### フォントファミリー

> **🔴 必須ルール**: すべてのテキストで **07にくまるフォント** を使用すること！

#### Nikumaruフォントの使い方

```swift
// 【推奨】View修飾子を使った方法（最も簡単）
Text("ふわふわたいむ")
    .nikumaruTitle(size: 48)     // タイトル用

Text("せつぞく")
    .nikumaruHeadline(size: 32)  // 見出し用

Text("説明文です")
    .nikumaruBody(size: 18)      // 本文用

Text("補足テキスト")
    .nikumaruCaption(size: 14)   // キャプション用

// カスタムサイズ
Text("テキスト")
    .nikumaru(size: 24)          // 任意のサイズ


// 【代替】Font拡張を使った方法
Text("ふわふわたいむ")
    .font(.nikumaru(size: 48))

Text("せつぞく")
    .font(.appTitle(size: 48))    // 便利メソッド
```

#### HarajukuTypography（デザインシステム統合版）

```swift
// デザインシステムのタイポグラフィも自動的にNikumaruフォントを使用
Text("タイトル")
    .font(HarajukuTypography.title(size: 48))

Text("本文")
    .font(HarajukuTypography.body(size: 16))

Text("キャプション")
    .font(HarajukuTypography.caption(size: 12))
```

#### ❌ 使用禁止

```swift
// これは使わない！
.font(.system(size: 18, weight: .bold, design: .rounded))

// これも使わない！
.font(.title)
.font(.body)
.font(.headline)
```

**理由**: システムフォントは原宿スタイルの世界観に合わないため、**必ずNikumaruフォントを指定**すること。

### フォントサイズと用途

```swift
// 超特大タイトル（カウントダウンなど）
HarajukuTypography.title(size: 200)
// weight: .heavy, カラフルなグラデーション必須

// 大タイトル（画面タイトル）
HarajukuTypography.title(size: 32-48)
// RainbowText コンポーネント推奨

// 本文
HarajukuTypography.body(size: 14-18)
// weight: .semibold または .bold

// キャプション
HarajukuTypography.caption(size: 12-14)
// weight: .medium または .semibold
```

### テキストスタイルの原則

1. **ひらがな優先**: 「接続」→「せつぞく」、「開始」→「スタート」
2. **親しみやすい表現**: 「エラーが発生しました」→「うまくいかなかったよ…」
3. **画像の活用**: 文末や文頭に感情を表すAssets画像を配置（絵文字は使用しない）
4. **読みやすさ**: フォントサイズは14pt以上、行間は広めに
5. **3D効果**: 重要なテキストにはグラデーション + 影 + アウトラインで奥行きを

### NG表現リスト

❌ 避けるべき表現:
- 「失敗しました」→ ✅「うまくいかなかった…」
- 「接続中」→ ✅「つなぎちゅう…」
- 「入力してください」→ ✅「かいてね」「いれてね」
- 「待機中」→ ✅「まってるよ」
- 「開始」→ ✅「スタート！」「はじめるよ！」

---

## 🎬 アニメーション

### アニメーションの種類

```swift
// HarajukuAnimation として実装済み

// 1. バウンス（ぽよんと弾む）
HarajukuAnimation.bounce(duration: 0.6)
// spring(response: duration, dampingFraction: 0.6)
// 用途: ボタンタップ、要素の出現、強調

// 2. ジャンプ（上に飛び跳ねる）
HarajukuAnimation.jump
// spring(response: 0.4, dampingFraction: 0.3)
// 用途: アクティブな状態、エラー表示

// 3. スピン（回転）
HarajukuAnimation.spin(duration: 1.0)
// linear(duration: duration)
// 用途: ローディング、待機中

// 4. スパークル（キラキラ）
HarajukuAnimation.sparkle(duration: 2.0)
// easeInOut(duration: duration).repeatForever(autoreverses: true)
// 用途: 装飾的なキラキラエフェクト

// 5. ウィグル（左右に揺れる）
HarajukuAnimation.wiggle(duration: 0.15)
// easeInOut(duration: duration).repeatForever(autoreverses: true)
// 用途: エラー時の小刻みな振動
```

### アニメーションの適用原則

1. **画面遷移**: 常に `bounce` または `jump` を使用
2. **ボタンタップ**: タップ時に `scaleEffect(0.95)` + `bounce`
3. **ローディング**: `spin` と虹色リングの組み合わせ
4. **エラー**: `wiggle` + 😢 絵文字
5. **成功**: `bounce` + スケールアップ + ✨ 絵文字

### 常時アニメーション

ユーザーが何もしていない時も、画面は生きている必要があります：

```swift
// きらきら装飾の回転
@State private var sparkleRotation: Double = 0

.onAppear {
    withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
        sparkleRotation = 360
    }
}

// ふわふわ浮遊
@State private var isFloating = false

.offset(y: isFloating ? -15 : 15)
.animation(HarajukuAnimation.bounce(duration: 2.5), value: isFloating)

.onAppear {
    isFloating = true
}
```

---

## 🧩 コンポーネントライブラリ

### 背景コンポーネント

#### 1. RainbowBackground

虹色グラデーションの背景

```swift
RainbowBackground()
    .ignoresSafeArea()
```

**特徴**:
- 7色のパステルカラーグラデーション
- 対角線方向（topLeading → bottomTrailing）
- すべての画面のベース背景として使用

#### 2. FluffyCloudBackground

ふわふわ雲の背景

```swift
FluffyCloudBackground()
    .ignoresSafeArea()
    .opacity(0.3-0.6)
```

**特徴**:
- 白とパステルブルーの雲模様
- RainbowBackground の上に重ねて使用
- 不透明度で雰囲気を調整

**使用例**:
```swift
ZStack {
    RainbowBackground().ignoresSafeArea()
    FluffyCloudBackground().ignoresSafeArea().opacity(0.4)

    // コンテンツ
}
```

---

### ボタンコンポーネント

#### 1. FluffyButton

メインアクションボタン

```swift
FluffyButton(
    title: "はじめる",
    emoji: "🎈",
    gradient: HarajukuColors.candyGradient,
    shadowColor: HarajukuColors.pastelPink
) {
    // アクション
}
```

**パラメータ**:
- `title: String` - ボタンテキスト（ひらがな推奨）
- `emoji: String` - 絵文字（デフォルト: "🎈"）
- `gradient: LinearGradient` - 背景グラデーション
- `shadowColor: Color` - 影の色

**特徴**:
- ふわふわした影
- タップ時のバウンスアニメーション
- 絵文字 + テキストの組み合わせ

**使い分け**:
- **重要なアクション**: `candyGradient` + "🎈"
- **接続・通信**: `skyGradient` + "📡"
- **開始・スタート**: `rainbowGradient` + "✨"

#### 2. FluffyOutlineButton

サブアクションボタン

```swift
FluffyOutlineButton(
    title: "もどる",
    emoji: "↩️",
    color: HarajukuColors.pastelPurple
) {
    // アクション
}
```

**特徴**:
- 背景透明、枠線のみ
- 控えめなアクション向け

---

### テキスト入力コンポーネント

#### FluffyTextField

ふわふわテキスト入力フィールド

```swift
FluffyTextField(
    placeholder: "なまえをかいてね",
    text: $playerName,
    emoji: "✏️",
    gradient: HarajukuColors.pinkPurpleGradient,
    borderColor: HarajukuColors.pastelPink,
    keyboardType: .default,
    isDisabled: false
)
```

**パラメータ**:
- `placeholder: String` - プレースホルダーテキスト
- `text: Binding<String>` - 入力テキストのバインディング
- `emoji: String` - 左側の絵文字（デフォルト: "💭"）
- `gradient: LinearGradient` - 背景グラデーション
- `borderColor: Color` - 枠線の色
- `keyboardType: UIKeyboardType` - キーボードタイプ
- `isDisabled: Bool` - 無効化フラグ

**特徴**:
- `.ultraThinMaterial` のガラスモルフィズム
- 絵文字でフィールドの用途を表現
- ふわふわした枠線

**使い分け**:
- **名前入力**: "✏️" + `pinkPurpleGradient`
- **IPアドレス**: "🌐" + `skyGradient`
- **ポート番号**: "🔌" + `blueMintGradient`

---

### テキストコンポーネント

#### RainbowText

虹色グラデーションテキスト

```swift
RainbowText(text: "OnlyLonely", size: 56)
```

**特徴**:
- 7色の虹色グラデーション
- `.heavy` フォントウェイト
- キラキラ影エフェクト

**用途**:
- 画面タイトル
- アプリ名
- 重要なメッセージ

#### SparkleText

キラキラ輝くテキスト（カスタム実装例）

```swift
Text("スタート！")
    .font(HarajukuTypography.title(size: 64))
    .foregroundStyle(HarajukuColors.rainbowGradient)
    .sparkleGlow()
```

---

### 風船コンポーネント

#### FluffyBalloon

ふわふわ風船

```swift
FluffyBalloon(
    color: HarajukuColors.pastelPink,
    size: 100,
    emoji: "💗"
)
```

**パラメータ**:
- `color: Color` - 風船の色（パステルカラー推奨）
- `size: CGFloat` - サイズ（60-120推奨）
- `emoji: String?` - 風船に表示する絵文字

**特徴**:
- 外側のグロウエフェクト
- 白いハイライト
- キラキラスパークルの装飾

**使い分け**:
- **プレイヤーA**: `pastelPink` + "💗"
- **プレイヤーB**: `pastelBlue` + "💙"
- **不明**: `pastelYellow` + "❓"

---

### カードコンポーネント

#### FluffyCard

ふわふわカード

```swift
FluffyCard(
    gradient: HarajukuColors.pinkPurpleGradient,
    borderColor: HarajukuColors.pastelPink
) {
    // コンテンツ
    VStack {
        Text("内容")
    }
}
```

**特徴**:
- `.ultraThinMaterial` の半透明背景
- ふわふわした枠線
- グラデーション背景

**用途**:
- 情報のグループ化
- メッセージカード
- プレイヤー情報表示

---

### プログレスコンポーネント

#### FluffyProgressBar

ふわふわプログレスバー

```swift
FluffyProgressBar(
    progress: 0.7,
    gradient: HarajukuColors.rainbowGradient,
    shadowColor: HarajukuColors.pastelPink
)
```

**特徴**:
- 虹色のプログレスバー
- ふわふわした影
- スムーズなアニメーション

**用途**:
- ローディング
- ゲームの進行度
- タイムバー

---

## 📏 レイアウトとスペーシング

### スペーシング値

```swift
// HarajukuSpacing として実装済み

HarajukuSpacing.xs    = 4
HarajukuSpacing.sm    = 8
HarajukuSpacing.md    = 12
HarajukuSpacing.lg    = 16
HarajukuSpacing.xl    = 24
HarajukuSpacing.xxl   = 32
HarajukuSpacing.xxxl  = 48
```

### 余白の原則

1. **画面端**: `.xl` (24pt) 以上
2. **セクション間**: `.xl` ~ `.xxl` (24-32pt)
3. **要素間**: `.md` ~ `.lg` (12-16pt)
4. **密接な要素**: `.sm` (8pt)

### レイアウトパターン

#### 基本画面構成

```swift
ZStack {
    // 1. 背景
    RainbowBackground().ignoresSafeArea()
    FluffyCloudBackground().ignoresSafeArea().opacity(0.4)

    // 2. コンテンツ
    VStack(spacing: HarajukuSpacing.xl) {
        Spacer()

        // タイトルセクション
        VStack(spacing: HarajukuSpacing.md) {
            // きらきら装飾
            HStack {
                Text("✨")
                RainbowText(text: "タイトル", size: 32)
                Text("✨")
            }

            // サブタイトル
            Text("説明テキスト")
        }

        // メインコンテンツ
        // ...

        // ボタンエリア
        FluffyButton(/* ... */)

        Spacer()
    }
}
```

---

## 💡 実装例

### 例1: タイトル画面（最新実装）

```swift
struct TitleScreen: View {
    @State private var backgroundPhase: CGFloat = 0
    @State private var balloonOffsets: [CGFloat] = [0, 0, 0, 0, 0]
    @State private var showStars = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景（スカイブルー→宇宙へのグラデーション変化）
                AnimatedBackground(phase: backgroundPhase)
                    .ignoresSafeArea()

                // 星（宇宙に近づくと表示）
                if showStars {
                    TwinklingStarsView()
                        .opacity(Double(backgroundPhase))
                }

                // 飛んでいく風船たち（Assets画像使用）
                ForEach(0..<5, id: \.self) { index in
                    FloatingBalloon(
                        index: index,
                        screenHeight: geometry.size.height,
                        offset: balloonOffsets[index]
                    )
                }

                // UIオーバーレイ
                VStack(spacing: 40) {
                    Spacer()

                    // タイトルセクション（3D効果）
                    VStack(spacing: 24) {
                        Text("ふわふわたいむ")
                            .font(.system(size: 58, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FF6B9D"),
                                        Color(hex: "#C44569"),
                                        Color(hex: "#A29BFE"),
                                        Color(hex: "#6C5CE7")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color(hex: "#FF6B9D").opacity(0.5), radius: 10)
                            .shadow(color: Color(hex: "#A29BFE").opacity(0.5), radius: 20)
                            .overlay(
                                // 白いアウトライン（3D効果）
                                Text("ふわふわたいむ")
                                    .font(.system(size: 58, weight: .black, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.3))
                                    .offset(x: 0, y: -2)
                            )

                        // サブタイトル（3D効果）
                        Text("息で飛ばす、ふたりの風船")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "#FFFFFF"), Color(hex: "#E0E0FF")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color(hex: "#A29BFE").opacity(0.4), radius: 8)
                            .overlay(
                                Text("息で飛ばす、ふたりの風船")
                                    .foregroundStyle(.white.opacity(0.2))
                                    .offset(x: 0, y: -1)
                            )
                            .tracking(2)
                    }

                    Spacer()

                    // タップしてはじめる（グロー効果）
                    Text("タップしてはじめる")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(opacity)  // グロー用
                }
            }
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // 背景が原宿→宇宙に変化（6秒、1回のみ）
        withAnimation(Animation.easeInOut(duration: 6.0)) {
            backgroundPhase = 1.0
        }

        // 風船が順番に飛んでいく
        for i in 0..<5 {
            let delay = Double(i) * 0.5
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(Animation.easeOut(duration: 6.0)) {
                    balloonOffsets[i] = -UIScreen.main.bounds.height * 1.8
                }
            }
        }

        // 6秒後、風船を戻してふわふわさせる
        DispatchQueue.main.asyncAfter(deadline: .now() + 6.0) {
            balloonOffsets = [0, 0, 0, 0, 0]
        }
    }
}

// 風船コンポーネント（Assets画像 + UI）
struct FloatingBalloon: View {
    let index: Int
    let screenHeight: CGFloat
    let offset: CGFloat

    @State private var swayX: CGFloat = 0
    @State private var swayY: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0

    // Assets画像データ
    private let balloonData: [(imageName: String, color: String, size: CGFloat, xPosition: CGFloat)] = [
        ("red", "#FF1493", 80, 0.15),
        ("blue", "#1E90FF", 95, 0.35),
        ("yellow", "#FFD700", 110, 0.5),
        ("orange", "#FF6347", 85, 0.65),
        ("green", "#32CD32", 90, 0.85)
    ]

    var body: some View {
        let data = balloonData[index]
        let screenWidth = UIScreen.main.bounds.width

        VStack(spacing: 0) {
            ZStack {
                // グロー効果
                Circle()
                    .fill(Color(hex: data.color).opacity(0.5))
                    .frame(width: data.size + 30, height: data.size + 30)
                    .blur(radius: 20)

                // 風船UI（円形グラデーション）
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color(hex: data.color).opacity(0.9),
                                Color(hex: data.color)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: data.size
                        )
                    )
                    .frame(width: data.size, height: data.size)

                // Assets画像をオーバーレイ
                Image(data.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: data.size, height: data.size)
            }

            // 紐
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(
                    to: CGPoint(x: 0, y: data.size * 0.5),
                    control: CGPoint(x: sin(rotation * .pi / 180) * 12, y: data.size * 0.25)
                )
            }
            .stroke(Color(hex: data.color).opacity(0.7), lineWidth: 3)

            // キャラクター画像（風船を持っている）
            Image(data.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: data.size * 1.2, height: data.size * 1.2)
        }
        .position(
            x: screenWidth * data.xPosition + swayX,
            y: screenHeight * 0.6 + offset + swayY
        )
        .rotationEffect(.degrees(rotation))
        .scaleEffect(scale)
        .onAppear {
            // ふわふわアニメーション
            withAnimation(
                Animation.easeInOut(duration: Double.random(in: 2.5...3.5))
                    .repeatForever(autoreverses: true)
            ) {
                swayX = CGFloat.random(in: -40...40)
                swayY = CGFloat.random(in: -20...20)
                rotation = Double.random(in: -25...25)
                scale = CGFloat.random(in: 0.9...1.1)
            }
        }
    }
}
```

**実装のポイント**:
- ✅ 絵文字を一切使用していない
- ✅ Assets画像（red, blue, yellow, orange, green）を活用
- ✅ タイトルに3D効果（グラデーション + 影 + アウトライン）
- ✅ 6秒間のアニメーション後、風船がふわふわ浮遊し続ける
- ✅ スカイブルーから宇宙への背景トランジション
- ✅ キャラクターが風船を持っているビジュアル

### 例2: 入力画面

```swift
struct InputScreen: View {
    @State private var inputText = ""
    @State private var sparkleRotation: Double = 0

    var body: some View {
        ZStack {
            RainbowBackground().ignoresSafeArea()
            FluffyCloudBackground().ignoresSafeArea().opacity(0.3)

            VStack(spacing: HarajukuSpacing.xl) {
                Spacer()

                // タイトル
                HStack(spacing: 12) {
                    Text("🌟")
                        .rotationEffect(.degrees(sparkleRotation))
                    RainbowText(text: "なまえは？", size: 32)
                    Text("🌟")
                        .rotationEffect(.degrees(-sparkleRotation))
                }

                // 入力フィールド
                FluffyTextField(
                    placeholder: "なまえをかいてね",
                    text: $inputText,
                    emoji: "✏️",
                    gradient: HarajukuColors.pinkPurpleGradient,
                    borderColor: HarajukuColors.pastelPink
                )
                .padding(.horizontal, HarajukuSpacing.xl)

                Spacer()

                // ボタン
                FluffyButton(
                    title: "きめる！",
                    emoji: "✨",
                    gradient: HarajukuColors.candyGradient,
                    shadowColor: HarajukuColors.pastelPink
                ) {
                    // アクション
                }

                Spacer()
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
        }
    }
}
```

### 例3: カウントダウン画面

```swift
struct CountdownScreen: View {
    @State private var countdown = 3
    @State private var scale: CGFloat = 1.0
    @State private var sparkleRotation: Double = 0

    var body: some View {
        ZStack {
            RainbowBackground().ignoresSafeArea()
            FluffyCloudBackground().ignoresSafeArea().opacity(0.6)

            // きらきら装飾（周囲に配置）
            ForEach(0..<8, id: \.self) { index in
                Text(["✨", "🌟", "💫", "⭐️", "💖", "🎈", "🌈", "☁️"][index])
                    .font(.system(size: 28))
                    .offset(
                        x: cos(Double(index) * .pi / 4) * 150,
                        y: sin(Double(index) * .pi / 4) * 150
                    )
                    .rotationEffect(.degrees(sparkleRotation + Double(index * 45)))
            }

            // カウントダウン数字
            Text("\(countdown)")
                .font(.system(size: 200, weight: .heavy, design: .rounded))
                .foregroundStyle(HarajukuColors.rainbowGradient)
                .scaleEffect(scale)
                .sparkleGlow()
        }
        .onAppear {
            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
            startCountdown()
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation(HarajukuAnimation.bounce(duration: 0.6)) {
                scale = 1.4
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(HarajukuAnimation.bounce(duration: 0.4)) {
                    scale = 1.0
                }
            }

            if countdown > 1 {
                countdown -= 1
            } else {
                timer.invalidate()
            }
        }
    }
}
```

---

## 🛡️ 世界観を守るためのルール

### 必須チェックリスト

新しい画面やコンポーネントを作る際は、必ず以下を確認：

✅ **背景**
- [ ] グラデーション背景を使用している
- [ ] 暗い背景色を使用していない
- [ ] 必要に応じてアニメーション背景を実装

✅ **カラー**
- [ ] パステルカラーやビビッドカラーを使用している
- [ ] 黒やダークグレーを避けている
- [ ] グラデーションを効果的に使っている

✅ **テキスト**
- [ ] ひらがな中心の表現になっている
- [ ] 親しみやすい言葉遣いになっている
- [ ] **絵文字を使用していない**（重要！）
- [ ] フォントサイズが14pt以上
- [ ] 重要なテキストに3D効果を適用

✅ **形状**
- [ ] 角が丸い（corner-radius: 20以上）
- [ ] 柔らかい印象の形状
- [ ] 直線的すぎない

✅ **アニメーション**
- [ ] 画面に動きがある
- [ ] バウンス系やふわふわ系のアニメーションを使用
- [ ] エラー時もネガティブすぎない動き

✅ **画像の使用**（絵文字の代わり）
- [ ] **絵文字の代わりにAssets画像を使用している**
- [ ] キャラクターや風船にAssets画像を配置
- [ ] 状態を画像で表現している
- [ ] 感情を画像で視覚化している

### コードレビューポイント

**新規コンポーネント作成時**:

1. **適切なカラーを使っているか？**
   - `Color.blue` ❌ → パステルカラーやグラデーション ✅

2. **適切なフォントを使っているか？**
   - `.font(.title)` ❌ → `.system(size: X, weight: Y, design: .rounded)` ✅

3. **適切なアニメーションを使っているか？**
   - 静的 ❌ → ふわふわ、バウンス、グロー ✅

4. **適切なスペーシングを使っているか？**
   - `.padding(16)` → `.padding(24)` など、適切な余白 ✅

5. **絵文字を使っていないか？（最重要）**
   - 絵文字使用 ❌ → **Assets画像を使用** ✅

6. **3D効果を活用しているか？**
   - 平面的なテキスト ❌ → グラデーション + 影 + アウトライン ✅

### デバッグ時の確認

**「原宿っぽくない」と感じたら**:

1. **色は明るいか？** → パステルカラーやビビッドカラーに変更
2. **動きはあるか？** → バウンス、ふわふわアニメーション追加
3. **硬くないか？** → corner-radius を大きく
4. **親しみやすいか？** → ひらがな・Assets画像を追加
5. **楽しいか？** → グロー効果や3D効果を追加
6. **絵文字を使っていないか？** → **絵文字をすべてAssets画像に置き換える**

---

## 📝 クイックリファレンス

### よく使うコード片

```swift
// グラデーション背景
LinearGradient(
    colors: [
        Color(hex: "#87CEEB"),  // スカイブルー
        Color(hex: "#FF6B9D"),  // ピンク
        Color(hex: "#FEA47F")   // オレンジ
    ],
    startPoint: .top,
    endPoint: .bottom
)
.ignoresSafeArea()

// 3Dタイトルテキスト
Text("ふわふわたいむ")
    .font(.system(size: 58, weight: .black, design: .rounded))
    .foregroundStyle(
        LinearGradient(
            colors: [Color(hex: "#FF6B9D"), Color(hex: "#A29BFE")],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
    .shadow(color: Color(hex: "#FF6B9D").opacity(0.5), radius: 10)
    .overlay(
        Text("ふわふわたいむ")
            .foregroundStyle(.white.opacity(0.3))
            .offset(x: 0, y: -2)
    )

// ふわふわ浮遊アニメーション
@State private var swayX: CGFloat = 0
@State private var swayY: CGFloat = 0

.offset(x: swayX, y: swayY)
.onAppear {
    withAnimation(
        Animation.easeInOut(duration: 2.5)
            .repeatForever(autoreverses: true)
    ) {
        swayX = CGFloat.random(in: -40...40)
        swayY = CGFloat.random(in: -20...20)
    }
}

// Assets画像 + グロー効果
ZStack {
    // グロー
    Circle()
        .fill(Color(hex: "#FF1493").opacity(0.5))
        .frame(width: 110, height: 110)
        .blur(radius: 20)

    // 画像
    Image("red")
        .resizable()
        .scaledToFit()
        .frame(width: 80, height: 80)
}

// グロー効果のテキスト
Text("タップしてはじめる")
    .font(.system(size: 24, weight: .bold, design: .rounded))
    .foregroundColor(.white)
    .opacity(opacity)
    .onAppear {
        withAnimation(
            Animation.easeInOut(duration: 1.5)
                .repeatForever(autoreverses: true)
        ) {
            opacity = 1.0
        }
    }
```

### Assets画像マッピング

**重要**: 絵文字は使用せず、すべてAssets画像で表現します。

| 状態 | Assets画像 | 用途 |
|------|------------|------|
| プレイヤーA | red.png | プレイヤーAのキャラクター、風船 |
| プレイヤーB | blue.png | プレイヤーBのキャラクター、風船 |
| 中立 | yellow.png, orange.png, green.png | 装飾、その他のキャラクター |
| 成功 | （今後追加予定） | 成功メッセージ、達成 |
| 待機 | （今後追加予定） | ローディング、接続中 |
| エラー | （今後追加予定） | エラー、失敗 |

**現在利用可能なAssets画像**:
- `red.png` - 赤い風船キャラクター
- `blue.png` - 青い風船キャラクター
- `yellow.png` - 黄色い風船キャラクター
- `orange.png` - オレンジ色の風船キャラクター
- `green.png` - 緑色の風船キャラクター

---

## 🎯 まとめ

このドキュメントを守ることで、OnlyLonely（ふわふわたいむ）のデザインは一貫性を保ちます。

**核となる4つの約束**:

1. **明るく、柔らかく、楽しく**
2. **常に動きがあり、Assets画像があり、グラデーション**
3. **絵文字は使用せず、画像でビジュアル表現**
4. **ユーザーを笑顔にする UI**

新しいコンポーネントを作る際は、このドキュメントを参照し、TOP画面の実装パターンを積極的に再利用してください。

### 最重要ルール

**🚫 絵文字の使用を禁止します**

すべてのビジュアル表現は、Assets画像、グラデーション、3D効果（影・アウトライン）で行います。

---

**実装ファイル**:
- `Package/Sources/AppFeature/Screens/Common/TitleScreen.swift` - 最新のデザイン実装例
- `Package/Sources/AppFeature/UI/HarajukuDesignSystem.swift`
- `Package/Sources/AppFeature/UI/HarajukuComponents.swift`

**Assets画像**:
- `OnlyLonely/Assets.xcassets/red.imageset/red.png`
- `OnlyLonely/Assets.xcassets/blue.imageset/blue.png`
- `OnlyLonely/Assets.xcassets/yellow.imageset/yellow.png`
- `OnlyLonely/Assets.xcassets/orange.imageset/orange.png`
- `OnlyLonely/Assets.xcassets/green.imageset/green.png`

**作成日**: 2025-10-11
**最終更新**: 2025-10-12（TOP画面実装反映、絵文字禁止ルール追加）
**バージョン**: 2.0.0
