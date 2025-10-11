//
//  CreditsScreen.swift
//  OnlyLonely
//
//  クレジット画面 - BGMライセンス情報
//

import SwiftUI

struct CreditsScreen: View {
    @EnvironmentObject var coordinator: AppCoordinator
    @State private var showContent = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 背景（原宿系グラデーション）
                LinearGradient(
                    colors: [
                        Color(hex: "#FFE0F0"),
                        Color(hex: "#E0E7FF"),
                        Color(hex: "#F0E0FF")
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        Spacer()
                            .frame(height: 60)
                        
                        // タイトル
                        VStack(spacing: 12) {
                            Text("📄")
                                .font(.system(size: 48))
                            
                            ZStack {
                                // 影
                                Text("クレジット")
                                    .nikumaruTitle(size: 36)
                                    .foregroundStyle(.black.opacity(0.3))
                                    .offset(x: 0, y: 3)
                                    .blur(radius: 3)
                                
                                // メインテキスト
                                Text("クレジット")
                                    .nikumaruTitle(size: 36)
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
                            }
                            .shadow(color: Color(hex: "#FF6B9D").opacity(0.4), radius: 10, x: 0, y: 4)
                        }
                        .opacity(showContent ? 1 : 0)
                        .scaleEffect(showContent ? 1 : 0.8)
                        
                        // クレジット情報カード
                        VStack(spacing: 24) {
                            // BGMセクション
                            CreditCard(
                                title: "BGM",
                                emoji: "🎵",
                                content: """
                                このアプリで使用しているBGM:
                                Fretbound作「Summer Fun Pop」
                                
                                この楽曲は、クリエイティブ・コモンズ 表示 4.0 ライセンスのもとでライセンスされています。
                                """,
                                links: [
                                    ("楽曲ページ", "https://freemusicarchive.org/music/fretbound/pop-background-music/summer-fun-pop/"),
                                    ("ライセンス情報", "https://creativecommons.org/licenses/by/4.0/")
                                ]
                            )
                            
                            // アプリ情報
                            CreditCard(
                                title: "アプリ情報",
                                emoji: "ℹ️",
                                content: """
                                ふわふわたいむ
                                息で飛ばす、ふたりの風船
                                
                                Version 1.0
                                """
                            )
                        }
                        .padding(.horizontal, 24)
                        .opacity(showContent ? 1 : 0)
                        .offset(y: showContent ? 0 : 20)
                        
                        Spacer()
                            .frame(height: 40)
                        
                        // 戻るボタン
                        Button {
                            coordinator.navigateBack()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("もどる")
                                    .nikumaruBody(size: 18)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, 32)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "#FF6B9D"),
                                        Color(hex: "#A29BFE")
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: Color(hex: "#FF6B9D").opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .opacity(showContent ? 1 : 0)
                        
                        Spacer()
                            .frame(height: 60)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                showContent = true
            }
        }
    }
}

// MARK: - クレジットカード

struct CreditCard: View {
    let title: String
    let emoji: String
    let content: String
    var links: [(title: String, url: String)] = []
    
    @State private var bounce = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // タイトル
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 32))
                    .offset(y: bounce ? -4 : 0)
                
                Text(title)
                    .nikumaruHeadline(size: 22)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(hex: "#FF6B9D"),
                                Color(hex: "#C44569")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // コンテンツ
            Text(content)
                .nikumaruBody(size: 14)
                .foregroundStyle(Color(hex: "#4A4A4A"))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
            
            // リンク
            if !links.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(links, id: \.title) { link in
                        if let url = URL(string: link.url) {
                            Link(destination: url) {
                                HStack(spacing: 8) {
                                    Image(systemName: "link")
                                        .font(.system(size: 12, weight: .semibold))
                                    Text(link.title)
                                        .nikumaruBody(size: 13)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.system(size: 10, weight: .semibold))
                                }
                                .foregroundStyle(Color(hex: "#A29BFE"))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(Color(hex: "#A29BFE").opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.white)
                .shadow(color: Color(hex: "#FF6B9D").opacity(0.15), radius: 15, x: 0, y: 8)
        )
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 1.2)
                    .repeatForever(autoreverses: true)
            ) {
                bounce = true
            }
        }
    }
}

#Preview {
    CreditsScreen()
        .environmentObject(AppCoordinator())
}

