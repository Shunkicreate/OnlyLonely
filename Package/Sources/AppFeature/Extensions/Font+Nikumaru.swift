//
//  Font+Nikumaru.swift
//  OnlyLonely
//
//  07にくまるフォントの拡張
//

import SwiftUI

extension Font {
    /// 07にくまるフォント（カスタムフォント）
    static func nikumaru(size: CGFloat) -> Font {
        return .custom("07NikumaruFont", size: size)
    }

    /// 07にくまるフォント（デフォルトサイズ）
    static var nikumaru: Font {
        return .custom("07NikumaruFont", size: 17)
    }

    /// 07にくまるフォント（太字）
    static func nikumaruBold(size: CGFloat) -> Font {
        // にくまるフォントは1種類なので同じフォントを返す
        return .custom("07NikumaruFont", size: size)
    }
}

/// アプリ全体のデフォルトフォントスタイル
extension Font {
    /// タイトル用（大）
    static func appTitle(size: CGFloat = 48) -> Font {
        return .nikumaru(size: size)
    }

    /// 見出し用（中）
    static func appHeadline(size: CGFloat = 32) -> Font {
        return .nikumaru(size: size)
    }

    /// 本文用（小）
    static func appBody(size: CGFloat = 18) -> Font {
        return .nikumaru(size: size)
    }

    /// キャプション用（極小）
    static func appCaption(size: CGFloat = 14) -> Font {
        return .nikumaru(size: size)
    }
}
