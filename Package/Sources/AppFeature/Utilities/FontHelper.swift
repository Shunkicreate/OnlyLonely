//
//  FontHelper.swift
//  OnlyLonely
//
//  フォント関連のヘルパー
//

import UIKit

enum FontHelper {
    /// インストール済みのすべてのフォント名をコンソールに出力（デバッグ用）
    static func printAllFonts() {
        #if DEBUG
        print("📝 インストール済みフォント一覧:")
        for family in UIFont.familyNames.sorted() {
            print("  ファミリー: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("    - \(name)")
            }
        }
        #endif
    }

    /// 07にくまるフォントが正しく読み込まれているか確認
    static func verifyNikumaruFont() -> Bool {
        let fontNames = [
            "07NikumaruFont",
            "07にくまるフォント",
            "Nikumaru"
        ]

        for fontName in fontNames {
            if UIFont(name: fontName, size: 12) != nil {
                print("✅ にくまるフォント読み込み成功: \(fontName)")
                return true
            }
        }

        print("❌ にくまるフォントが見つかりません")
        print("利用可能なフォントファミリー:")
        for family in UIFont.familyNames.sorted() {
            print("  - \(family)")
        }
        return false
    }
}
