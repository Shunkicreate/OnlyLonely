# ☁️ 空と海のパステルブルーデザインシステム

> **OnlyLonely の青系パステル UI 実装ガイド**
> 空、海、水をイメージした爽やかで優しい世界観を保つための完全リファレンス

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

## 🌊 デザイン哲学

### コアコンセプト

**「空と海のパステルブルー」とは何か？**

- **爽やか**: 青空、海、水のような清涼感と開放感
- **優しさ**: パステルカラーの柔らかさ、雲のような軽やかさ
- **流動性**: 水のように流れる動き、波のようなアニメーション
- **透明感**: ガラスのような質感、水面のキラキラ
- **癒し**: 見ているだけで心が落ち着く、リラックスできる

### デザイン原則

1. **青を基調に**: すべての色は青系のパステルカラーから派生
2. **柔らかな流れ**: 直線的でなく、波のように滑らかな動き
3. **透明感**: `.ultraThinMaterial` を多用し、重ね合わせの美しさ
4. **軽やかさ**: 重たくならない、浮遊感のある表現
5. **統一感**: すべてが空と海の世界に調和している

### イメージソース

- **空**: 晴れた日の青空、雲、朝焼けの空
- **海**: 穏やかな海、波、水面のキラキラ
- **水**: 透明な水、水滴、水しぶき
- **氷**: 氷のような透明感、氷河の青

### 避けるべき表現

❌ **NG例**:
- 暗い青（ネイビー、ダークブルー）
- 鮮やかすぎる原色の青
- 硬い直線的な形状
- 重たい印象の装飾
- 動きのない静的なUI

✅ **OK例**:
- 淡いパステルブルー
- 空から海へのグラデーション
- 丸みを帯びた雲のような形状
- 軽やかで流れるような動き
- 常に何かが揺らいでいる

---

## 🎨 カラーパレット

### プライマリカラー（青系パステル）

```swift
// SkyBlueColors として実装済み

// メインカラー
.skyBlue         = #B3D9FF  // 空の青
.aqua            = #B3F5FF  // 水色
.mintBlue        = #B3FFE5  // ミントブルー
.lavenderBlue    = #C4B3FF  // ラベンダーブルー
.powderBlue      = #D4E5FF  // パウダーブルー
.turquoise       = #B3FFD4  // ターコイズ
.paleBlue        = #E5F2FF  // ペールブルー
```

### アクセントカラー

```swift
// 白・クリーム系（雲や光を表現）
.cloudWhite      = #FFFFFF  // 雲の白
.cream           = #FFF9E5  // クリーム
.lightPeach      = #FFE5D9  // ライトピーチ
```

### カラーの使い分け

| 色 | 用途 | イメージ |
|---|------|----------|
| skyBlue | メイン背景、ボタン | 青空 |
| aqua | アクセント、リンク | 水、海 |
| mintBlue | プレイヤーB、成功表示 | ミント、清涼感 |
| lavenderBlue | サブアクセント | 夕方の空 |
| powderBlue | 背景のハイライト | 淡い空 |
| turquoise | 強調、特別な要素 | エメラルドグリーンの海 |
| paleBlue | 背景のベース | 遠くの空 |
| cloudWhite | ハイライト、光 | 雲 |

### グラデーション

```swift
// 空のグラデーション（最も重要）
SkyBlueColors.skyGradient
// paleBlue → powderBlue → skyBlue → aqua
// 用途: メイン背景

// 海のグラデーション
SkyBlueColors.oceanGradient
// aqua → skyBlue → turquoise → mintBlue
// 用途: 強調したい背景

// 爽やかグラデーション
SkyBlueColors.freshGradient
// skyBlue → aqua → mintBlue
// 用途: ボタン、アクティブな要素

// ラベンダースカイグラデーション
SkyBlueColors.lavenderSkyGradient
// lavenderBlue → skyBlue → aqua
// 用途: 特別な画面、夕方の演出

// 水面グラデーション
SkyBlueColors.waterGradient
// paleBlue → aqua → turquoise → mintBlue → aqua → paleBlue
// 用途: キラキラ効果、プログレスバー

// ミストグラデーション
SkyBlueColors.mistGradient
// cloudWhite → paleBlue → powderBlue (透明度あり)
// 用途: オーバーレイ、霧の表現
```

### テキストカラー

```swift
// 読みやすさを保ちつつ、青の世界観を保つ
.textPrimary     = #4A6B7C  // 青灰色
.textSecondary   = #7B9BAD  // 淡い青灰色
.textInactive    = #B8CDD9  // とても淡いグレー
```

---

## ✏️ タイポグラフィ

### フォントファミリー

```swift
// SkyBlueTypography として実装済み

// メインフォント
.rounded  // .systemFont(design: .rounded)
// 用途: すべてのテキスト（柔らかい印象）

// ウェイト
.bold     // タイトル用
.medium   // 本文用
.regular  // キャプション用
.heavy    // 数字用（カウントダウンなど）
```

### フォントサイズと用途

```swift
// 超特大タイトル（カウントダウンなど）
SkyBlueTypography.number(size: 180-200)
// weight: .heavy

// 大タイトル（画面タイトル）
SkyBlueTypography.title(size: 32-48)
// SkyGradientText コンポーネント推奨

// 本文
SkyBlueTypography.body(size: 14-18)
// weight: .medium

// キャプション
SkyBlueTypography.caption(size: 12-14)
// weight: .regular
```

### テキストスタイルの原則

1. **ひらがな優先**: 「接続中」→「つないでいます」
2. **優しい表現**: 「失敗」→「うまくいきませんでした」
3. **絵文字の活用**: 空・水関連の絵文字（☁️💧💙✨🌊）
4. **読みやすさ**: フォントサイズは14pt以上

### 推奨される表現

✅ **おすすめ表現**:
- 「つながっています」（接続中）
- 「そらにとどく」（高く飛ぶ）
- 「なみのように」（流れるように）
- 「しずくのように」（水滴のように）
- 「ふわり」「すいすい」「キラキラ」

---

## 🌊 アニメーション

### アニメーションの種類

```swift
// SkyBlueAnimation として実装済み

// 1. 波のように揺れる
SkyBlueAnimation.wave(duration: 2.0)
// easeInOut, repeatForever, autoreverses
// 用途: 水面、波、ゆらぎ

// 2. 雲のように浮かぶ
SkyBlueAnimation.float(duration: 3.0)
// easeInOut, 上下に浮遊
// 用途: 雲、風船、浮遊要素

// 3. 水面のキラキラ
SkyBlueAnimation.shimmer(duration: 2.0)
// linear, repeatForever
// 用途: 光の反射、キラキラ効果

// 4. 滑らかな流れ
SkyBlueAnimation.flow(duration: 1.0)
// spring, 水のような流動性
// 用途: 画面遷移、要素の移動

// 5. ふわっと現れる
SkyBlueAnimation.fadeIn(duration: 0.8)
// easeOut
// 用途: 要素の出現

// 6. 水滴のように弾む
SkyBlueAnimation.droplet(duration: 0.5)
// spring, 軽い弾み
// 用途: ボタンタップ、インタラクション
```

### アニメーションの適用原則

1. **画面遷移**: 常に `flow` または `fadeIn` を使用
2. **ボタンタップ**: `droplet` アニメーション
3. **ローディング**: `shimmer` と回転の組み合わせ
4. **背景**: `wave` で常に動き続ける
5. **風船**: `float` で上下に浮遊

### 常時アニメーション

空と海は常に動いています：

```swift
// 雲の移動
@State private var cloudOffset: CGFloat = 0

.offset(x: cloudOffset)
.onAppear {
    withAnimation(.linear(duration: 20).repeatForever(autoreverses: true)) {
        cloudOffset = 100
    }
}

// 水面のキラキラ
@State private var shimmerPhase: CGFloat = 0

.hueRotation(.degrees(shimmerPhase))
.onAppear {
    withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
        shimmerPhase = 360
    }
}

// 波のゆらぎ
@State private var waveOffset: CGFloat = 0

.offset(y: waveOffset)
.animation(SkyBlueAnimation.wave(duration: 3), value: waveOffset)
.onAppear {
    waveOffset = 15
}
```

---

## 🧩 コンポーネントライブラリ

### 背景コンポーネント

#### 1. SkyBackground

空のグラデーション背景

```swift
SkyBackground()
    .ignoresSafeArea()
```

**特徴**:
- paleBlue → powderBlue → skyBlue → aqua の4色グラデーション
- 対角線方向（topLeading → bottomTrailing）
- すべての画面のベース背景

#### 2. CloudBackground

雲の背景レイヤー

```swift
CloudBackground()
    .ignoresSafeArea()
    .opacity(0.3-0.7)
```

**特徴**:
- 3層の雲が異なる速度で移動
- RadialGradient で柔らかい雲を表現
- SkyBackground の上に重ねて使用

#### 3. WaterShimmerBackground

水面のキラキラ背景

```swift
WaterShimmerBackground()
    .ignoresSafeArea()
    .opacity(0.2-0.4)
```

**特徴**:
- 色相回転でキラキラ感
- 水や光の反射を表現
- アクセントとして使用

**使用例**:
```swift
ZStack {
    SkyBackground().ignoresSafeArea()
    CloudBackground().ignoresSafeArea().opacity(0.5)
    WaterShimmerBackground().ignoresSafeArea().opacity(0.3)

    // コンテンツ
}
```

---

### ボタンコンポーネント

#### 1. SkyButton

メインアクションボタン

```swift
SkyButton(
    title: "はじめる",
    emoji: "☁️",
    gradient: SkyBlueColors.freshGradient
) {
    // アクション
}
```

**パラメータ**:
- `title: String` - ボタンテキスト
- `emoji: String` - 絵文字（デフォルト: "☁️"）
- `gradient: LinearGradient` - 背景グラデーション

**特徴**:
- `.ultraThinMaterial` の半透明背景
- 雲のような枠線
- 水滴のようなタップアニメーション

**使い分け**:
- **重要なアクション**: `freshGradient` + "✨"
- **接続**: `oceanGradient` + "☁️"
- **開始**: `waterGradient` + "🌊"

#### 2. SkyOutlineButton

サブアクションボタン

```swift
SkyOutlineButton(
    title: "もどる",
    emoji: "↩️",
    color: SkyBlueColors.skyBlue
) {
    // アクション
}
```

---

### テキスト入力コンポーネント

#### SkyTextField

空のようなテキストフィールド

```swift
SkyTextField(
    placeholder: "なまえをいれてください",
    text: $playerName,
    emoji: "💭",
    gradient: SkyBlueColors.freshGradient,
    keyboardType: .default,
    isDisabled: false
)
```

**特徴**:
- ガラスモルフィズム
- 雲のような枠線
- 絵文字でフィールドの用途を表現

**使い分け**:
- **名前入力**: "💭" + `freshGradient`
- **IPアドレス**: "☁️" + `skyGradient`
- **ポート番号**: "💧" + `oceanGradient`

---

### テキストコンポーネント

#### SkyGradientText

空のグラデーションテキスト

```swift
SkyGradientText(text: "OnlyLonely", size: 56)
```

**特徴**:
- 水面のような6色グラデーション
- 柔らかい影エフェクト

**用途**:
- 画面タイトル
- アプリ名
- 重要なメッセージ

---

### 風船コンポーネント

#### SkyBalloon

空の風船

```swift
SkyBalloon(
    color: SkyBlueColors.skyBlue,
    size: 100,
    emoji: "💙"
)
```

**パラメータ**:
- `color: Color` - 風船の色
- `size: CGFloat` - サイズ
- `emoji: String?` - 風船に表示する絵文字

**特徴**:
- 外側のグロウエフェクト
- 白いハイライト（光の反射）
- キラキラスパークル装飾

**使い分け**:
- **プレイヤーA**: `skyBlue` + "💙"
- **プレイヤーB**: `mintBlue` + "💚"
- **不明**: `aqua` + "💭"

---

### カードコンポーネント

#### SkyCard

空のようなカード

```swift
SkyCard(gradient: SkyBlueColors.freshGradient) {
    // コンテンツ
    VStack {
        Text("内容")
    }
}
```

**特徴**:
- `.ultraThinMaterial` の半透明背景
- 雲のような枠線
- グラデーション背景

---

### プログレスコンポーネント

#### SkyProgressBar

空のようなプログレスバー

```swift
SkyProgressBar(
    progress: 0.7,
    gradient: SkyBlueColors.waterGradient
)
```

**特徴**:
- 水面のような6色グラデーション
- キラキラ輝く表面
- スムーズなアニメーション

---

### インジケーターコンポーネント

#### SkyConnectionIndicator

接続状態インジケーター

```swift
SkyConnectionIndicator(isConnecting: true)
```

**特徴**:
- 波のように揺れる外側のリング
- 回転する水面グラデーション
- 絵文字で状態を表現

---

## 📏 レイアウトとスペーシング

### スペーシング値

```swift
// SkyBlueSpacing として実装済み

SkyBlueSpacing.xs    = 4
SkyBlueSpacing.sm    = 8
SkyBlueSpacing.md    = 12
SkyBlueSpacing.lg    = 16
SkyBlueSpacing.xl    = 24
SkyBlueSpacing.xxl   = 32
SkyBlueSpacing.xxxl  = 48
```

### 基本画面構成

```swift
ZStack {
    // 1. 背景
    SkyBackground().ignoresSafeArea()
    CloudBackground().ignoresSafeArea().opacity(0.5)

    // 2. コンテンツ
    VStack(spacing: SkyBlueSpacing.xl) {
        Spacer()

        // タイトルセクション
        VStack(spacing: SkyBlueSpacing.md) {
            HStack {
                Text("☁️")
                SkyGradientText(text: "タイトル", size: 36)
                Text("☁️")
            }

            Text("説明テキスト")
        }

        // メインコンテンツ
        // ...

        // ボタンエリア
        SkyButton(/* ... */)

        Spacer()
    }
}
```

---

## 💡 実装例

### 例1: タイトル画面

```swift
struct SkyTitleScreen: View {
    @State private var cloudOffset: CGFloat = 0
    @State private var isFloating = false

    var body: some View {
        ZStack {
            SkyBackground().ignoresSafeArea()
            CloudBackground().ignoresSafeArea().opacity(0.6)

            VStack(spacing: SkyBlueSpacing.xxxl) {
                // 雲装飾
                HStack(spacing: 20) {
                    ForEach(["☁️", "💙", "✨"], id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 32))
                            .offset(x: cloudOffset)
                    }
                }
                .onAppear {
                    withAnimation(.linear(duration: 10).repeatForever(autoreverses: true)) {
                        cloudOffset = 30
                    }
                }

                // タイトル
                SkyGradientText(text: "OnlyLonely", size: 56)

                // 風船
                HStack(spacing: 40) {
                    SkyBalloon(color: SkyBlueColors.skyBlue, size: 100, emoji: "💙")
                    SkyBalloon(color: SkyBlueColors.aqua, size: 120, emoji: "💧")
                    SkyBalloon(color: SkyBlueColors.mintBlue, size: 90, emoji: "💚")
                }
                .offset(y: isFloating ? -15 : 15)
                .animation(SkyBlueAnimation.float(duration: 3), value: isFloating)
                .onAppear { isFloating = true }

                // ボタン
                SkyButton(
                    title: "はじめる",
                    emoji: "☁️",
                    gradient: SkyBlueColors.freshGradient
                ) {
                    // アクション
                }
            }
        }
    }
}
```

### 例2: 接続画面

```swift
struct SkyConnectionScreen: View {
    @State private var ipAddress = ""
    @State private var port = "8080"
    @State private var isConnecting = false

    var body: some View {
        ZStack {
            SkyBackground().ignoresSafeArea()
            CloudBackground().ignoresSafeArea().opacity(0.4)
            WaterShimmerBackground().ignoresSafeArea().opacity(0.2)

            VStack(spacing: SkyBlueSpacing.xl) {
                Spacer()

                // タイトル
                HStack(spacing: 12) {
                    Text("☁️")
                    SkyGradientText(text: "つなぐ", size: 36)
                    Text("☁️")
                }

                // インジケーター
                SkyConnectionIndicator(isConnecting: isConnecting)
                    .frame(height: 120)

                // 入力フィールド
                VStack(spacing: SkyBlueSpacing.lg) {
                    SkyTextField(
                        placeholder: "IPアドレス",
                        text: $ipAddress,
                        emoji: "☁️",
                        gradient: SkyBlueColors.skyGradient
                    )

                    SkyTextField(
                        placeholder: "ポート",
                        text: $port,
                        emoji: "💧",
                        gradient: SkyBlueColors.oceanGradient,
                        keyboardType: .numberPad
                    )
                }
                .padding(.horizontal, SkyBlueSpacing.xl)

                Spacer()

                // ボタン
                SkyButton(
                    title: isConnecting ? "つないでいます…" : "つなぐ",
                    emoji: "✨",
                    gradient: SkyBlueColors.freshGradient
                ) {
                    // アクション
                }

                Spacer()
            }
        }
    }
}
```

### 例3: カウントダウン画面

```swift
struct SkyCountdownScreen: View {
    @State private var countdown = 3
    @State private var scale: CGFloat = 1.0
    @State private var shimmerPhase: CGFloat = 0

    var body: some View {
        ZStack {
            SkyBackground().ignoresSafeArea()
            WaterShimmerBackground().ignoresSafeArea().opacity(0.4)

            // 波紋エフェクト
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        SkyBlueColors.waterGradient.opacity(0.3),
                        lineWidth: 2
                    )
                    .frame(width: 200 + CGFloat(index) * 50, height: 200 + CGFloat(index) * 50)
                    .scaleEffect(scale)
            }

            // カウントダウン数字
            Text("\(countdown)")
                .font(SkyBlueTypography.number(size: 180))
                .foregroundStyle(SkyBlueColors.waterGradient)
                .scaleEffect(scale)
                .skyShadow(color: SkyBlueColors.skyBlue, radius: 30)
                .hueRotation(.degrees(shimmerPhase))
        }
        .onAppear {
            withAnimation(.linear(duration: 6).repeatForever(autoreverses: false)) {
                shimmerPhase = 360
            }
            startCountdown()
        }
    }

    private func startCountdown() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            withAnimation(SkyBlueAnimation.droplet()) {
                scale = 1.3
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(SkyBlueAnimation.flow()) {
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

✅ **背景**
- [ ] `SkyBackground()` を使用している
- [ ] `CloudBackground()` を重ねている
- [ ] 暗い背景色を使用していない

✅ **カラー**
- [ ] 青系パステルカラーのみを使用
- [ ] ネイビーやダークブルーを避けている
- [ ] グラデーションを効果的に使っている

✅ **テキスト**
- [ ] ひらがな中心の表現
- [ ] 空・水関連の絵文字を使用（☁️💧💙✨🌊）
- [ ] フォントサイズが14pt以上

✅ **形状**
- [ ] 角が丸い（corner-radius: 20以上）
- [ ] 雲のような柔らかい形状

✅ **アニメーション**
- [ ] 波や水の流れを感じる動き
- [ ] 常に何かが揺らいでいる
- [ ] 軽やかな動き

✅ **質感**
- [ ] `.ultraThinMaterial` を使用
- [ ] 透明感・ガラス感がある

### コードレビューポイント

1. **SkyBlueColors を使っているか？**
   - `Color.blue` ❌ → `SkyBlueColors.skyBlue` ✅

2. **SkyBlueTypography を使っているか？**
   - `.font(.title)` ❌ → `SkyBlueTypography.title(size: 32)` ✅

3. **SkyBlueAnimation を使っているか？**
   - `.easeInOut` ❌ → `SkyBlueAnimation.wave()` ✅

4. **空・水関連の絵文字を使っているか？**
   - ⭐️ ❌ → ☁️💧✨ ✅

### デバッグ時の確認

**「空っぽくない」と感じたら**:

1. **色は青系か？** → パステルブルーに変更
2. **動きは流れているか？** → wave/float アニメーション追加
3. **透明感はあるか？** → .ultraThinMaterial を追加
4. **軽やかか？** → corner-radius を大きく、影を柔らかく
5. **癒されるか？** → 雲や水面のキラキラを追加

---

## 📝 クイックリファレンス

### よく使うコード片

```swift
// 背景セット
ZStack {
    SkyBackground().ignoresSafeArea()
    CloudBackground().ignoresSafeArea().opacity(0.5)
    // コンテンツ
}

// 雲装飾
HStack(spacing: 12) {
    Text("☁️")
    SkyGradientText(text: "タイトル", size: 36)
    Text("☁️")
}

// 浮遊アニメーション
.offset(y: isFloating ? -15 : 15)
.animation(SkyBlueAnimation.float(duration: 3), value: isFloating)
.onAppear { isFloating = true }

// 波のゆらぎ
.offset(y: waveOffset)
.animation(SkyBlueAnimation.wave(duration: 2), value: waveOffset)
```

### 絵文字マッピング

| 状態 | 絵文字 | 用途 |
|------|--------|------|
| 成功 | ✨💙🌟 | 成功メッセージ |
| 待機 | ☁️💭💧 | ローディング、接続中 |
| エラー | 💔😢🌧 | エラー、失敗 |
| 入力 | 💭💧✏️ | テキスト入力 |
| 接続 | ☁️🌐💙 | 通信、ネットワーク |
| 開始 | 🌊✨💙 | スタート、開始 |
| 風船 | 💙💧💚☁️ | キャラクター |
| 装飾 | ☁️✨💙💧🌊 | 装飾、キラキラ |

---

## 🎯 まとめ

**核となる3つの約束**:

1. **青系パステルで爽やかに**
2. **常に流れ、揺らぎ、輝く**
3. **ユーザーに癒しを与える UI**

---

**実装ファイル**:
- `Package/Sources/AppFeature/UI/SkyBlueDesignSystem.swift`
- `Package/Sources/AppFeature/UI/SkyBlueComponents.swift`

**作成日**: 2025-10-11
**バージョン**: 1.0.0
