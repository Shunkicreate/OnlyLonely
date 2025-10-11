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
}
