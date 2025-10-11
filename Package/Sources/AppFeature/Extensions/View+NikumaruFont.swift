//
//  View+NikumaruFont.swift
//  OnlyLonely
//
//  07にくまるフォントを簡単に適用するためのView拡張
//

import SwiftUI

extension View {
    /// 07にくまるフォントを適用（タイトル用）
    func nikumaruTitle(size: CGFloat = 48) -> some View {
        self.font(.nikumaru(size: size))
    }

    /// 07にくまるフォントを適用（見出し用）
    func nikumaruHeadline(size: CGFloat = 32) -> some View {
        self.font(.nikumaru(size: size))
    }

    /// 07にくまるフォントを適用（本文用）
    func nikumaruBody(size: CGFloat = 18) -> some View {
        self.font(.nikumaru(size: size))
    }

    /// 07にくまるフォントを適用（キャプション用）
    func nikumaruCaption(size: CGFloat = 14) -> some View {
        self.font(.nikumaru(size: size))
    }

    /// 07にくまるフォントを適用（カスタムサイズ）
    func nikumaru(size: CGFloat) -> some View {
        self.font(.nikumaru(size: size))
    }
}

// MARK: - 使用例のPreview

#Preview("使用例") {
    VStack(spacing: 30) {
        // タイトル
        Text("ふわふわたいむ")
            .nikumaruTitle(size: 58)
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color(hex: "#FF6B9D"),
                        Color(hex: "#A29BFE")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )

        // 見出し
        Text("あなたのなまえは？")
            .nikumaruHeadline(size: 36)
            .foregroundColor(Color(hex: "#6C5CE7"))

        // 本文
        Text("ふうせんにかいてね")
            .nikumaruBody()
            .foregroundColor(Color(hex: "#4A4A4A"))

        // キャプション
        Text("タップしてはじめる")
            .nikumaruCaption()
            .foregroundColor(.gray)

        Divider()

        // 従来の書き方との比較
        VStack(alignment: .leading, spacing: 10) {
            Text("❌ 古い書き方:")
                .font(.system(size: 14, weight: .bold))

            Text("Text(\"あいさつ\")")
                .font(.system(size: 18, design: .rounded))
                .foregroundColor(.red.opacity(0.7))

            Text("✅ 新しい書き方:")
                .font(.system(size: 14, weight: .bold))

            Text("Text(\"あいさつ\")")
                .nikumaruBody()
                .foregroundColor(.green.opacity(0.7))
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    .padding()
}
