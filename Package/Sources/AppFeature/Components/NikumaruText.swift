//
//  NikumaruText.swift
//  OnlyLonely
//
//  07にくまるフォントを使用したTextコンポーネント
//

import SwiftUI

/// 07にくまるフォントを使用したText（タイトル用）
struct NikumaruTitle: View {
    let text: String
    let size: CGFloat

    init(_ text: String, size: CGFloat = 48) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.nikumaru(size: size))
    }
}

/// 07にくまるフォントを使用したText（見出し用）
struct NikumaruHeadline: View {
    let text: String
    let size: CGFloat

    init(_ text: String, size: CGFloat = 32) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.nikumaru(size: size))
    }
}

/// 07にくまるフォントを使用したText（本文用）
struct NikumaruBody: View {
    let text: String
    let size: CGFloat

    init(_ text: String, size: CGFloat = 18) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.nikumaru(size: size))
    }
}

/// 07にくまるフォントを使用したText（キャプション用）
struct NikumaruCaption: View {
    let text: String
    let size: CGFloat

    init(_ text: String, size: CGFloat = 14) {
        self.text = text
        self.size = size
    }

    var body: some View {
        Text(text)
            .font(.nikumaru(size: size))
    }
}

// MARK: - Previews

#Preview("タイトル") {
    VStack(spacing: 20) {
        NikumaruTitle("ふわふわたいむ", size: 58)
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

        NikumaruHeadline("あなたのなまえは？", size: 36)
            .foregroundColor(Color(hex: "#6C5CE7"))

        NikumaruBody("ふうせんにかいてね", size: 18)
            .foregroundColor(Color(hex: "#4A4A4A"))

        NikumaruCaption("タップしてはじめる", size: 14)
            .foregroundColor(.gray)
    }
    .padding()
}
