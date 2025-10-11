# 🎨 クリエイティブUI実装プロンプト

## このドキュメントについて

OnlyLonely のUI実装時に使用するプロンプトです。
Claude に UI を実装させる際は、このプロンプトを含めて指示してください。

---

## 基本デザインフィロソフィー

### 世界観
> 「息で飛ばす、ふたりの風船」
> 空には、誰もいない。でも、誰かと同じ空を見上げている。

**OnlyLonely** は「ふわふわ」「切なさ」「つながり」を表現する、詩的で幻想的なゲーム体験です。

### デザインの方向性
- **Appleのデフォルトデザインは避ける** - 標準的なiOSのUIコンポーネントに頼らない
- **ゲームライクな表現** - インタラクティブで没入感のあるUI
- **近未来感** - ミニマルだが先進的、洗練されたビジュアル
- **浮遊感と軽やかさ** - アニメーションとグラデーションで「風」「空」「浮遊」を表現
- **詩的で感情的** - 数字や情報よりも「感覚」を優先

---

## デザインシステム

### カラーパレット

#### 基本色（空のグラデーション）
```swift
// 低高度 - 夕暮れの空
Color(hex: "#FFE5B4") // ピーチ
Color(hex: "#FFB6C1") // ライトピンク
Color(hex: "#DDA0DD") // プラム

// 中高度 - 透明感のある青空
Color(hex: "#87CEEB") // スカイブルー
Color(hex: "#B0E0E6") // パウダーブルー
Color(hex: "#E0F6FF") // アイスブルー

// 高高度 - 宇宙の入り口
Color(hex: "#4A5A8A") // ダークブルー
Color(hex: "#2C3E7C") // ミッドナイトブルー
Color(hex: "#1A1A2E") // スペースブラック
```

#### アクセントカラー
```swift
// 風船 Player A - 温かみのある色
Color(hex: "#FF6B9D") // ピンク
Color(hex: "#FFA07A") // ライトサーモン

// 風船 Player B - 冷たく透明感のある色
Color(hex: "#88D4FF") // ライトブルー
Color(hex: "#A3D5FF") // スカイブルー

// 雷・雲のエフェクト
Color(hex: "#FFD700") // ゴールド（雷）
Color(hex: "#F0E68C") // カーキ（雷の余韻）
Color(hex: "#B0B0B0") // シルバー（雲）
Color(hex: "#808080") // グレー（雲の影）
```

#### UIエレメント
```swift
// テキスト
Color(hex: "#FFFFFF").opacity(0.9) // メインテキスト
Color(hex: "#FFFFFF").opacity(0.6) // セカンダリテキスト
Color(hex: "#FFFFFF").opacity(0.3) // 非アクティブ

// グロウ・発光
Color(hex: "#FFFFFF").opacity(0.4) // ソフトグロウ
Color(hex: "#00FFFF").opacity(0.6) // ネオングロウ
```

### タイポグラフィ

```swift
// タイトル - 大きく詩的に
Font.system(size: 48, weight: .ultraLight, design: .rounded)
  .tracking(8) // レタースペースを広く

// サブタイトル - 繊細に
Font.system(size: 24, weight: .thin, design: .rounded)
  .tracking(4)

// ボディ - 読みやすく
Font.system(size: 16, weight: .light, design: .rounded)
  .tracking(2)

// キャプション - 控えめに
Font.system(size: 12, weight: .ultraLight, design: .rounded)
  .opacity(0.7)

// ゲーム内数値 - ゲームライクに
Font.system(size: 32, weight: .bold, design: .monospaced)
  .monospacedDigit()
```

**フォントの選択基準**:
- `.rounded` で柔らかさと親しみやすさ
- `.ultraLight` / `.thin` で軽やかさと浮遊感
- `.monospaced` でゲームUIらしさ（スコアや時間）

### アニメーション原則

#### タイミング
```swift
// 超スロー - 背景のグラデーション変化
Animation.easeInOut(duration: 3.0)

// スロー - 画面遷移、重要な演出
Animation.spring(response: 0.8, dampingFraction: 0.7, blendDuration: 0.3)

// ミディアム - UI要素の表示/非表示
Animation.spring(response: 0.5, dampingFraction: 0.65, blendDuration: 0.2)

// ファスト - インタラクティブなフィードバック
Animation.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.1)
```

#### アニメーションパターン
1. **浮遊アニメーション** - ふわふわと上下に揺れる
   ```swift
   .offset(y: isFloating ? -10 : 10)
   .animation(
     Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true),
     value: isFloating
   )
   ```

2. **パルスアニメーション** - 呼吸するように拡大縮小
   ```swift
   .scaleEffect(isPulsing ? 1.05 : 1.0)
   .opacity(isPulsing ? 1.0 : 0.8)
   .animation(
     Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
     value: isPulsing
   )
   ```

3. **グロウアニメーション** - 発光エフェクト
   ```swift
   .shadow(color: accentColor.opacity(glowIntensity), radius: 20, x: 0, y: 0)
   .shadow(color: accentColor.opacity(glowIntensity * 0.5), radius: 40, x: 0, y: 0)
   ```

4. **パーティクルアニメーション** - 息、風、星など
   - Canvas API または SpriteKit を使用
   - ランダムな動きと透明度変化
   - 生成と消失を繰り返す

### ビジュアルエフェクト

#### グラデーション
```swift
// 空のグラデーション（垂直方向）
LinearGradient(
  colors: [
    Color(hex: "#FFE5B4"), // 下部
    Color(hex: "#FFB6C1"),
    Color(hex: "#87CEEB"),
    Color(hex: "#4A5A8A")  // 上部
  ],
  startPoint: .bottom,
  endPoint: .top
)

// グラスモーフィズム風の背景
.background(.ultraThinMaterial)
.background(
  LinearGradient(
    colors: [
      Color.white.opacity(0.1),
      Color.white.opacity(0.05)
    ],
    startPoint: .topLeading,
    endPoint: .bottomTrailing
  )
)
```

#### ブラー・グロウ
```swift
// ソフトブラー
.blur(radius: 20)
.brightness(0.1)

// 多重シャドウで発光効果
.shadow(color: glowColor.opacity(0.8), radius: 10, x: 0, y: 0)
.shadow(color: glowColor.opacity(0.5), radius: 20, x: 0, y: 0)
.shadow(color: glowColor.opacity(0.3), radius: 30, x: 0, y: 0)
```

#### ガラス・フロスト効果
```swift
// グラスモーフィズム
struct GlassMorphism: ViewModifier {
  func body(content: Content) -> some View {
    content
      .background(.ultraThinMaterial)
      .background(
        RoundedRectangle(cornerRadius: 20)
          .fill(
            LinearGradient(
              colors: [
                Color.white.opacity(0.2),
                Color.white.opacity(0.05)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: 20)
          .stroke(
            LinearGradient(
              colors: [
                Color.white.opacity(0.5),
                Color.white.opacity(0.1)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 1
          )
      )
      .shadow(color: .black.opacity(0.1), radius: 20, y: 10)
  }
}
```

---

## UI コンポーネントガイド

### ボタン

```swift
// プライマリボタン - グロウ付き
struct PrimaryButton: View {
  let title: String
  let action: () -> Void
  @State private var isPressed = false

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 20, weight: .medium, design: .rounded))
        .tracking(3)
        .foregroundColor(.white)
        .padding(.horizontal, 40)
        .padding(.vertical, 16)
        .background(
          Capsule()
            .fill(
              LinearGradient(
                colors: [
                  Color(hex: "#FF6B9D"),
                  Color(hex: "#FFA07A")
                ],
                startPoint: .leading,
                endPoint: .trailing
              )
            )
        )
        .shadow(color: Color(hex: "#FF6B9D").opacity(0.6), radius: isPressed ? 10 : 20)
        .shadow(color: Color(hex: "#FF6B9D").opacity(0.3), radius: isPressed ? 20 : 40)
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }
    .buttonStyle(PlainButtonStyle())
    .simultaneousGesture(
      DragGesture(minimumDistance: 0)
        .onChanged { _ in isPressed = true }
        .onEnded { _ in isPressed = false }
    )
  }
}

// ゴーストボタン - 透明感
struct GhostButton: View {
  let title: String
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      Text(title)
        .font(.system(size: 16, weight: .light, design: .rounded))
        .tracking(2)
        .foregroundColor(.white.opacity(0.8))
        .padding(.horizontal, 30)
        .padding(.vertical, 12)
        .background(
          Capsule()
            .stroke(Color.white.opacity(0.3), lineWidth: 1)
            .background(
              Capsule()
                .fill(Color.white.opacity(0.05))
            )
        )
    }
    .buttonStyle(PlainButtonStyle())
  }
}
```

### カード

```swift
// ガラスカード
struct GlassCard<Content: View>: View {
  let content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  var body: some View {
    content
      .padding(24)
      .background(.ultraThinMaterial)
      .background(
        RoundedRectangle(cornerRadius: 24)
          .fill(
            LinearGradient(
              colors: [
                Color.white.opacity(0.15),
                Color.white.opacity(0.05)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
      )
      .overlay(
        RoundedRectangle(cornerRadius: 24)
          .stroke(
            LinearGradient(
              colors: [
                Color.white.opacity(0.4),
                Color.white.opacity(0.1)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            ),
            lineWidth: 1.5
          )
      )
      .shadow(color: .black.opacity(0.15), radius: 30, y: 15)
  }
}
```

### プログレスバー・メーター

```swift
// 息の強さメーター（円形）
struct BreathMeter: View {
  let level: Double // 0.0 ~ 1.0

  var body: some View {
    ZStack {
      // 背景円
      Circle()
        .stroke(Color.white.opacity(0.2), lineWidth: 8)

      // プログレス円
      Circle()
        .trim(from: 0, to: level)
        .stroke(
          LinearGradient(
            colors: [
              Color(hex: "#88D4FF"),
              Color(hex: "#00FFFF")
            ],
            startPoint: .leading,
            endPoint: .trailing
          ),
          style: StrokeStyle(lineWidth: 8, lineCap: .round)
        )
        .rotationEffect(.degrees(-90))
        .shadow(color: Color(hex: "#00FFFF").opacity(0.8), radius: 10)

      // 中央のテキスト
      Text("\(Int(level * 100))%")
        .font(.system(size: 32, weight: .bold, design: .monospaced))
        .foregroundColor(.white)
    }
    .frame(width: 200, height: 200)
    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: level)
  }
}

// タイムバー（水平）
struct TimeBar: View {
  let timeRemaining: Double // 0.0 ~ 1.0

  var body: some View {
    GeometryReader { geometry in
      ZStack(alignment: .leading) {
        // 背景
        Capsule()
          .fill(Color.white.opacity(0.1))

        // プログレス
        Capsule()
          .fill(
            LinearGradient(
              colors: timeRemaining > 0.3 ? [
                Color(hex: "#FFD700"),
                Color(hex: "#FFA500")
              ] : [
                Color(hex: "#FF4444"),
                Color(hex: "#CC0000")
              ],
              startPoint: .leading,
              endPoint: .trailing
            )
          )
          .frame(width: geometry.size.width * timeRemaining)
          .shadow(
            color: (timeRemaining > 0.3 ? Color(hex: "#FFD700") : Color(hex: "#FF4444")).opacity(0.6),
            radius: 10
          )
      }
    }
    .frame(height: 8)
    .animation(.linear(duration: 0.1), value: timeRemaining)
  }
}
```

### テキストエフェクト

```swift
// グロウテキスト
struct GlowText: View {
  let text: String
  let size: CGFloat
  let glowColor: Color

  var body: some View {
    Text(text)
      .font(.system(size: size, weight: .ultraLight, design: .rounded))
      .tracking(6)
      .foregroundColor(.white)
      .shadow(color: glowColor.opacity(0.8), radius: 10, x: 0, y: 0)
      .shadow(color: glowColor.opacity(0.5), radius: 20, x: 0, y: 0)
      .shadow(color: glowColor.opacity(0.3), radius: 30, x: 0, y: 0)
  }
}

// タイプライター風テキスト
struct TypewriterText: View {
  let fullText: String
  @State private var displayedText = ""

  var body: some View {
    Text(displayedText)
      .font(.system(size: 20, weight: .light, design: .rounded))
      .tracking(2)
      .foregroundColor(.white.opacity(0.9))
      .onAppear {
        animateText()
      }
  }

  private func animateText() {
    for (index, character) in fullText.enumerated() {
      DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.05) {
        displayedText.append(character)
      }
    }
  }
}
```

---

## 画面別デザインガイド

### タイトル画面

**雰囲気**: 静寂、期待、詩的

```swift
// 背景: ゆっくり変化するグラデーション
// タイトル: 大きく、レタースペース広めに
// サブタイトル: 「息で飛ばす、ふたりの風船」を詩的に表示
// 浮遊する小さなパーティクル（星やほこり）
// ボタンは控えめに、グロウ付き
```

**実装のポイント**:
- タイトルは `.ultraLight` で軽やかに
- 背景グラデーションは `TimelineView` で時間経過とともに変化
- パーティクルは Canvas または SpriteKit で実装
- ボタンは画面下部、中央揃え

### 接続画面（iPhone）

**雰囲気**: 技術的だが温かみ、近未来的

```swift
// 接続状態を視覚的に表現
// パルスアニメーションで「探している」感を演出
// 接続成功時は爽快なアニメーション
```

**実装のポイント**:
- 接続中: パルスアニメーション + 回転するリング
- 接続成功: スケールアップ + グロウエフェクト
- エラー時: 赤いグロウ + シェイクアニメーション

### プレイヤー名入力画面（iPhone）

**雰囲気**: 個人的、親密

```swift
// グラスモーフィズムのテキストフィールド
// 入力中はフォーカスグロウ
// プレースホルダーは詩的な表現
```

**実装のポイント**:
- テキストフィールドは `.ultraThinMaterial` でガラス風
- フォーカス時に枠線がグロウ
- キーボードの上部にカスタムツールバー

### カウントダウン画面（iPhone）

**雰囲気**: 緊張感、期待、高揚

```swift
// 画面中央に大きな数字
// 数字が変わるたびにパルス + グロウ
// 背景は徐々に明るく
```

**実装のポイント**:
- 数字は `.monospaced` で大きく（120pt以上）
- 各数字の表示時にスケールアップ + 回転
- "Start!" は爆発的なアニメーション

### ゲームプレイ画面（iPhone）

**雰囲気**: 集中、没入、リズム

```swift
// 息の強さを円形メーターで表示
// リアルタイムで反応するビジュアル
// 現在の高度を詩的に表現
```

**実装のポイント**:
- メーターはリアルタイムで更新、スムーズなアニメーション
- 背景は高度に応じてグラデーション変化
- 息を吹くとパーティクルエフェクト

### ゲームプレイ画面（iPad）

**雰囲気**: 壮大、美しい、対戦の緊張感

```swift
// 画面を左右に分割
// 背景は高度に応じた空のグラデーション
// 風船はふわふわアニメーション
// 雲と雷は迫力ある演出
```

**実装のポイント**:
- SpriteKit で物理演算とアニメーション
- 風船は常に微細に揺れている
- 雲は種類ごとに異なるビジュアル
- 雷は稲妻エフェクト + フラッシュ

### リザルト画面

**雰囲気**: 達成感、余韻、切なさ

```swift
// 勝者の風船が大きく、敗者の風船は小さく
// スコアは大きく、アニメーションで表示
// 「また空で会おう」的な詩的メッセージ
```

**実装のポイント**:
- 勝者の風船は画面中央で輝く
- スコアはカウントアップアニメーション
- リトライボタンは控えめに

---

## 実装時の注意事項

### 必須事項
1. **標準UIコンポーネントを避ける**
   - `Button` は使うが、スタイルは完全カスタム
   - `TextField` も `.background` と `.overlay` で装飾
   - `List`, `Form` などは使用しない

2. **アニメーションは惜しまない**
   - すべてのUI要素に微細なアニメーション
   - 静止している要素は「死んでいる」と考える
   - `.animation()` は積極的に使用

3. **グロウエフェクトを多用**
   - `.shadow()` を3重に重ねる
   - 発光色は薄く、範囲は広く
   - 動的に変化させる

4. **余白を贅沢に**
   - UI要素間の間隔は広めに
   - パディングは最低 24pt 以上
   - 情報密度は低く、視覚的余裕を持たせる

5. **レスポンシブであること**
   - タップやジェスチャーに即座に反応
   - スプリングアニメーションで有機的な動き
   - 視覚的フィードバックは必須

### パフォーマンス
- アニメーションは `.animation()` より `withAnimation()` を優先
- 複雑なエフェクトは SpriteKit に任せる
- グラデーションやブラーは重いので、適切に使用

### テスト
- 実機でアニメーションの滑らかさを確認
- 異なる画面サイズでレイアウトを検証
- ダークモード対応は不要（常に暗い背景）

---

## コード例: サンプル実装

### タイトル画面の例

```swift
struct TitleScreen: View {
  @State private var isFloating = false
  @State private var glowIntensity = 0.5
  @State private var gradientOffset: CGFloat = 0

  var body: some View {
    ZStack {
      // 動的グラデーション背景
      AnimatedGradientBackground(offset: gradientOffset)
        .ignoresSafeArea()

      // パーティクル
      ParticleView()
        .ignoresSafeArea()

      VStack(spacing: 60) {
        Spacer()

        // タイトル
        VStack(spacing: 16) {
          GlowText(
            text: "OnlyLonely",
            size: 56,
            glowColor: Color(hex: "#FFB6C1")
          )

          Text("息で飛ばす、ふたりの風船")
            .font(.system(size: 18, weight: .ultraLight, design: .rounded))
            .tracking(4)
            .foregroundColor(.white.opacity(0.7))
        }
        .offset(y: isFloating ? -10 : 10)
        .animation(
          Animation.easeInOut(duration: 3).repeatForever(autoreverses: true),
          value: isFloating
        )

        Spacer()

        // ボタン
        VStack(spacing: 20) {
          PrimaryButton(title: "はじめる") {
            // アクション
          }

          GhostButton(title: "あそびかた") {
            // アクション
          }
        }
        .padding(.bottom, 60)
      }
    }
    .onAppear {
      isFloating = true
      startGradientAnimation()
      startGlowAnimation()
    }
  }

  private func startGradientAnimation() {
    withAnimation(.linear(duration: 10).repeatForever(autoreverses: false)) {
      gradientOffset = 1.0
    }
  }

  private func startGlowAnimation() {
    withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
      glowIntensity = glowIntensity == 0.5 ? 1.0 : 0.5
    }
  }
}

struct AnimatedGradientBackground: View {
  let offset: CGFloat

  var body: some View {
    LinearGradient(
      colors: [
        Color(hex: "#1A1A2E"),
        Color(hex: "#2C3E7C"),
        Color(hex: "#4A5A8A"),
        Color(hex: "#87CEEB")
      ],
      startPoint: .top,
      endPoint: .bottom
    )
    .offset(y: offset * 100)
  }
}
```

---

## まとめ: Claude へのプロンプト例

UI実装を依頼する際は、以下のようなプロンプトを使用してください：

```
OnlyLonely の [画面名] を実装してください。

デザイン要件:
- docs/ui-design-prompt.md に記載されているデザインシステムに従ってください
- Appleの標準UIコンポーネントは避け、完全カスタムデザインで実装してください
- 「浮遊感」「軽やかさ」「詩的」な雰囲気を表現してください
- すべてのUI要素に微細なアニメーションを追加してください
- グロウエフェクトを多用し、近未来的な印象を与えてください
- レタースペースを広めにとり、余白を贅沢に使ってください

実装のポイント:
- [画面固有の要件を記載]
- [特に重視する演出を記載]
- [インタラクションの詳細を記載]

参考:
- 世界観: docs/game-design.md
- ビジュアル仕様: docs/visual-design.md
- 画面仕様: docs/screens/[該当ファイル]
```

---

## 参考リソース

### インスピレーション
- **ゲームUI**: Genshin Impact, Sky: Children of the Light, Monument Valley
- **近未来UI**: Cyberpunk 2077, Blade Runner 2049, Ghost in the Shell
- **ミニマル**: Apple Vision Pro UI, Tesla UI
- **詩的表現**: Journey, ABZÛ, GRIS

### SwiftUI テクニック
- Canvas API（パーティクル実装）
- TimelineView（アニメーション制御）
- GeometryReader（レスポンシブレイアウト）
- .matchedGeometryEffect（画面遷移）
- SpriteKit 統合（物理演算）

### カラーツール
- Coolors.co（パレット生成）
- Adobe Color（グラデーション）
- UI Gradients（グラデーション参考）
