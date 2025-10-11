# 画面設計書

## 画面一覧

### 共通画面

- [01. タイトル画面](./01-title-screen.md) - アプリ起動時の最初の画面

### iPad 専用画面

- [00. スタート演出画面（iPad）](./00-start-screen.md) - 風船を放す演出
- [03. 接続待機画面（iPad）](./03-connection-waiting-screen-ipad.md) - プレイヤーの接続を待つ
- [04. ゲームプレイ画面（iPad）](./04-gameplay-screen-ipad.md) - メインゲーム画面（左右分割）
- [05. リザルト画面（iPad）](./05-result-screen-ipad.md) - 勝敗結果表示

### iPhone 専用画面

- [06. 接続画面（iPhone）](./06-connection-screen-iphone.md) - iPad に接続
- [07. プレイヤー名入力画面（iPhone）](./07-player-selection-screen-iphone.md) - プレイヤー名を入力
- [09. 待機画面（iPhone）](./09-waiting-screen-iphone.md) - ゲーム開始待ち
- [10. カウントダウン画面（iPhone）](./10-countdown-screen-iphone.md) - 3, 2, 1, Start!
- [11. ゲームプレイ画面（iPhone）](./11-gameplay-screen-iphone.md) - 息入力画面
- [12. リザルト画面（iPhone）](./12-result-screen-iphone.md) - 勝敗結果表示

---

## 画面遷移フロー

### iPad のフロー

```
01. タイトル画面
      ↓ (iPad を自動判定)
03. 接続待機画面（iPad）
      ↓ (両プレイヤー接続完了)
      ↓ (両プレイヤー準備完了)
00. スタート演出画面（iPad）
      ↓ (風船を放す演出)
04. ゲームプレイ画面（iPad）
      ↓ (時間切れ: 30秒)
05. リザルト画面（iPad）
      ↓ (リトライ or 終了)
03. 接続待機画面 or 01. タイトル画面
```

### iPhone のフロー

```
01. タイトル画面
      ↓ (iPhone を自動判定)
06. 接続画面（iPhone）
      ↓ (接続成功)
07. プレイヤー名入力画面（iPhone）
      ↓ (名前入力完了)
09. 待機画面（iPhone）
      ↓ (両プレイヤー準備完了)
10. カウントダウン画面（iPhone）
      ↓ (カウントダウン終了)
11. ゲームプレイ画面（iPhone）
      ↓ (ゴール到達 or 時間切れ: 30秒)
12. リザルト画面（iPhone）
      ↓ (リトライ or 終了)
06. 接続画面 or 01. タイトル画面
```

---

## ファイル命名規則

- `XX-screen-name-device.md` 形式
- XX: 番号（フロー順）
- screen-name: 画面名（kebab-case）
- device: デバイス指定がある場合のみ（ipad/iphone）

## 実装優先度

### 必須（MVP）

- 01, 00, 03, 04, 05, 06, 07, 09, 10, 11, 12

---

## 各画面仕様に含めるべき項目

1. **画面名**
2. **対象デバイス**
3. **役割・目的**
4. **表示要素**
5. **UI レイアウト** (ASCII art またはテキスト説明)
6. **インタラクション** (ボタン、タップ、入力など)
7. **画面遷移**
8. **通信**（WebSocket で送受信するデータ）
9. **実装メモ**
10. **デザインメモ**
