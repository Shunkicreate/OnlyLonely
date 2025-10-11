# 🎀 原宿系ふわふわデザインシステム

> **OnlyLonely の原宿スタイル UI 実装ガイド**
> カラフル、ふわふわ、キラキラ、ポップで可愛い世界観を保つための完全リファレンス

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
- **キラキラ**: 絵文字の多用、光の表現、輝くエフェクト
- **親しみやすさ**: ひらがな中心のテキスト、絵文字、優しい言葉遣い
- **楽しさ**: 動きのあるアニメーション、遊び心のあるインタラクション

### デザイン原則

1. **明るさ優先**: 暗い色は極力避け、明るくポジティブな印象を
2. **柔らかさ**: 角を丸く、影を柔らかく、動きをスムーズに
3. **視覚的な楽しさ**: 静的な画面を避け、常に何かが動いている
4. **感情表現**: 絵文字を積極的に使い、感情を視覚化する
5. **統一感**: すべての要素が原宿の世界観に調和している

### 避けるべき表現

❌ **NG例**:
- 暗い色（黒、ダークグレー）の背景
- 直線的で硬い形状
- 無機質なアイコン（システムアイコンのみ）
- カタカナ・漢字のみのテキスト
- 静的で動きのないUI

✅ **OK例**:
- パステルカラーの背景に虹色のアクセント
- 丸みを帯びた形状（border-radius: 20以上）
- 絵文字とカスタムコンポーネントの組み合わせ
- ひらがな中心のやさしいテキスト
- ふわふわ浮かぶアニメーション

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

- **背景**: 常に `RainbowBackground()` または `FluffyCloudBackground()` を使用
- **ボタン**: `candyGradient` または `pinkPurpleGradient`
- **入力フィールド**: `skyGradient` または `blueMintGradient`
- **風船・キャラクター**: 単色のパステルカラー + 白のハイライト

---

## ✏️ タイポグラフィ

### フォントファミリー

```swift
// HarajukuTypography として実装済み

// メインフォント
.rounded  // .systemFont(design: .rounded)
// 用途: すべてのテキスト（原則）

// サブフォント
.heavy    // .system(weight: .heavy)
// 用途: 大きな数字、インパクトのあるタイトル

.bold     // .system(weight: .bold)
// 用途: 強調したいテキスト
```

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
3. **絵文字の活用**: 文末や文頭に感情を表す絵文字を追加
4. **読みやすさ**: フォントサイズは14pt以上、行間は広めに

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

### 例1: タイトル画面

```swift
struct TitleScreen: View {
    @State private var sparkleRotation: Double = 0
    @State private var isFloating = false

    var body: some View {
        ZStack {
            RainbowBackground().ignoresSafeArea()
            FluffyCloudBackground().ignoresSafeArea().opacity(0.5)

            VStack(spacing: HarajukuSpacing.xxxl) {
                // きらきら装飾
                HStack(spacing: 20) {
                    ForEach(["✨", "🌟", "💫"], id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 32))
                            .rotationEffect(.degrees(sparkleRotation))
                    }
                }

                // タイトル
                RainbowText(text: "OnlyLonely", size: 56)

                // 風船
                HStack(spacing: 40) {
                    FluffyBalloon(color: HarajukuColors.pastelPink, size: 100, emoji: "💗")
                    FluffyBalloon(color: HarajukuColors.pastelBlue, size: 120, emoji: "💙")
                    FluffyBalloon(color: HarajukuColors.pastelMint, size: 90, emoji: "💚")
                }
                .offset(y: isFloating ? -15 : 15)
                .animation(HarajukuAnimation.bounce(duration: 2.5), value: isFloating)

                // ボタン
                FluffyButton(
                    title: "はじめる",
                    emoji: "🎈",
                    gradient: HarajukuColors.rainbowGradient,
                    shadowColor: HarajukuColors.pastelPink
                ) {
                    // アクション
                }
            }
        }
        .onAppear {
            isFloating = true
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                sparkleRotation = 360
            }
        }
    }
}
```

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
- [ ] `RainbowBackground()` を使用している
- [ ] `FluffyCloudBackground()` を重ねている
- [ ] 暗い背景色を使用していない

✅ **カラー**
- [ ] パステルカラーのみを使用している
- [ ] 黒やダークグレーを避けている
- [ ] グラデーションを効果的に使っている

✅ **テキスト**
- [ ] ひらがな中心の表現になっている
- [ ] 親しみやすい言葉遣いになっている
- [ ] 絵文字を適切に配置している
- [ ] フォントサイズが14pt以上

✅ **形状**
- [ ] 角が丸い（corner-radius: 20以上）
- [ ] 柔らかい印象の形状
- [ ] 直線的すぎない

✅ **アニメーション**
- [ ] 画面に動きがある
- [ ] バウンス系のアニメーションを使用
- [ ] きらきら装飾が回転している
- [ ] エラー時もネガティブすぎない動き

✅ **絵文字**
- [ ] タイトルや重要な箇所に配置
- [ ] 状態を絵文字で表現している
- [ ] 感情を視覚化している

### コードレビューポイント

**新規コンポーネント作成時**:

1. **HarajukuColors を使っているか？**
   - `Color.blue` ❌ → `HarajukuColors.pastelBlue` ✅

2. **HarajukuTypography を使っているか？**
   - `.font(.title)` ❌ → `HarajukuTypography.title(size: 32)` ✅

3. **HarajukuAnimation を使っているか？**
   - `.easeInOut` ❌ → `HarajukuAnimation.bounce()` ✅

4. **HarajukuSpacing を使っているか？**
   - `.padding(16)` ❌ → `.padding(HarajukuSpacing.lg)` ✅

5. **絵文字を使っているか？**
   - アイコンのみ ❌ → 絵文字 + テキスト ✅

### デバッグ時の確認

**「原宿っぽくない」と感じたら**:

1. **色は明るいか？** → パステルカラーに変更
2. **動きはあるか？** → バウンスアニメーション追加
3. **硬くないか？** → corner-radius を大きく
4. **親しみやすいか？** → ひらがな・絵文字を追加
5. **楽しいか？** → きらきら装飾を追加

---

## 📝 クイックリファレンス

### よく使うコード片

```swift
// 背景セット
ZStack {
    RainbowBackground().ignoresSafeArea()
    FluffyCloudBackground().ignoresSafeArea().opacity(0.4)
    // コンテンツ
}

// きらきら装飾
HStack(spacing: 12) {
    Text("✨")
        .rotationEffect(.degrees(sparkleRotation))
    RainbowText(text: "タイトル", size: 32)
    Text("✨")
        .rotationEffect(.degrees(-sparkleRotation))
}
.onAppear {
    withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
        sparkleRotation = 360
    }
}

// ふわふわ浮遊
.offset(y: isFloating ? -15 : 15)
.animation(HarajukuAnimation.bounce(duration: 2.5), value: isFloating)
.onAppear { isFloating = true }

// 状態表示（絵文字 + テキスト）
HStack(spacing: 6) {
    Text("🎉")  // 状態に応じた絵文字
    Text("メッセージ")
        .font(HarajukuTypography.body(size: 14))
        .foregroundColor(HarajukuColors.pastelMint)
}
```

### 絵文字マッピング

| 状態 | 絵文字 | 用途 |
|------|--------|------|
| 成功 | ✨🎉🌟 | 成功メッセージ、達成 |
| 待機 | 💭🔍⏰ | ローディング、接続中 |
| エラー | 😢💔😿 | エラー、失敗 |
| 入力 | ✏️📝💭 | テキスト入力 |
| 接続 | 📡🌐🔌 | 通信、ネットワーク |
| 開始 | 🎈🚀💫 | スタート、開始 |
| 風船 | 🎈💗💙💚 | キャラクター、プレイヤー |
| 装飾 | ✨🌟💫⭐️💖🌈☁️ | 装飾、きらきら |

---

## 🎯 まとめ

このドキュメントを守ることで、OnlyLonely の原宿系ふわふわデザインは一貫性を保ちます。

**核となる3つの約束**:

1. **明るく、柔らかく、楽しく**
2. **常に動きがあり、絵文字があり、パステルカラー**
3. **ユーザーを笑顔にする UI**

新しいコンポーネントを作る際は、このドキュメントを参照し、既存のコンポーネントを積極的に再利用してください。

---

**実装ファイル**:
- `Package/Sources/AppFeature/UI/HarajukuDesignSystem.swift`
- `Package/Sources/AppFeature/UI/HarajukuComponents.swift`

**作成日**: 2025-10-11
**バージョン**: 1.0.0
