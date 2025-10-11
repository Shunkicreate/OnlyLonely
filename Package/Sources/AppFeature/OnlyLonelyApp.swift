//
//  OnlyLonelyApp.swift
//  OnlyLonely
//
//  Created by Taishin Miyamoto on 2025/10/11.
//

import SwiftUI

public struct OnlyLonelyApp: App {
    public init() {
        #if DEBUG
        // フォントの読み込み確認（デバッグビルドのみ）
        _ = FontHelper.verifyNikumaruFont()
        // すべてのフォントを表示（必要に応じてコメント解除）
        // FontHelper.printAllFonts()
        #endif
    }

    public var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
