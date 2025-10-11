//
//  ConnectionWaitingScreen.swift
//  OnlyLonely
//
//  03. せつぞくまちがめん（iPad）- 原宿系ふわふわバージョン
//  iPad のみ
//

import SwiftUI

struct ConnectionWaitingScreen: View {
    @EnvironmentObject private var coordinator: AppCoordinator
    @EnvironmentObject private var hostModel: ConnectionWaitinScreenModel
    @EnvironmentObject private var characterManager: CharacterAssignmentManager

    @State private var sparkleRotation: Double = 0
    @State private var balloonFloat: CGFloat = 0

    var body: some View {
        ZStack {
            // カラフル虹色背景
            RainbowBackground()
                .ignoresSafeArea()

            // ふわふわ雲
            FluffyCloudBackground()
                .ignoresSafeArea()
                .opacity(0.3)

            ScrollView {
                VStack(spacing: HarajukuSpacing.xl) {
                    Spacer()
                        .frame(height: 40)

                    // タイトルセクション
                    titleSection

                    // ステータスセクション
                    statusSection

                    // 接続可能なデバイス一覧
                    if !hostModel.availableDevices.isEmpty {
                        availableDevicesSection
                    }

                    // 接続済みデバイス一覧
                    if !hostModel.connectedDevices.isEmpty {
                        connectedDevicesSection
                    }

                    // デバッグボタン
                    debugButton

                    Spacer()
                        .frame(height: 60)
                }
            }
        }
        .onAppear {
            hostModel.configure(characterManager: characterManager)
            hostModel.startHosting()
            startAnimations()
        }
        .onChange(of: hostModel.connectedDevices.count) { _, count in
            if count >= 2 {
                hostModel.advanceConnectedDevicesToCountdown()
                coordinator.navigate(to: .iPadCountdown)
            }
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(spacing: HarajukuSpacing.md) {
            HStack(spacing: 12) {
                Image("yellow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(sparkleRotation))

                RainbowText(text: "せつぞくまち", size: 48)

                Image("yellow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 48, height: 48)
                    .rotationEffect(.degrees(-sparkleRotation))
            }
            .animation(HarajukuAnimation.sparkle(duration: 3), value: sparkleRotation)

            Text("あいふぉんがつながるのをまってるよ！")
                .nikumaruBody(size: 18)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, HarajukuSpacing.xl)
    }

    // MARK: - Status Section

    private var statusSection: some View {
        VStack(spacing: HarajukuSpacing.md) {
            // 風船アニメーション
            HStack(spacing: 20) {
                Image("blue")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .offset(y: balloonFloat)
                    .shadow(color: HarajukuColors.pastelBlue.opacity(0.6), radius: 10)

                Image("red")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .offset(y: -balloonFloat)
                    .shadow(color: HarajukuColors.pastelPink.opacity(0.6), radius: 10)
            }

            // ステータスメッセージ
            VStack(spacing: 8) {
                Text(hostModel.statusMessage)
                    .nikumaruHeadline(size: 20)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black, radius: 0, x: -1, y: -1)
                    .shadow(color: .black, radius: 0, x: 1, y: -1)
                    .shadow(color: .black, radius: 0, x: -1, y: 1)
                    .shadow(color: .black, radius: 0, x: 1, y: 1)

                if let error = hostModel.lastErrorMessage {
                    Text(error)
                        .nikumaruCaption(size: 14)
                        .foregroundColor(Color(hex: "#FF6B9D"))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                                .fluffyBorder(color: Color(hex: "#FF6B9D"), width: 2)
                        )
                }
            }
            .padding(.horizontal, HarajukuSpacing.xl)
        }
    }

    // MARK: - Available Devices Section

    private var availableDevicesSection: some View {
        VStack(spacing: HarajukuSpacing.xl) {
            // セクションタイトル
            HStack(spacing: 12) {
                Image("green")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)

                Text("みつかったあいふぉん")
                    .nikumaruHeadline(size: 26)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                Image("green")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
            .padding(.horizontal, HarajukuSpacing.lg)
            .padding(.vertical, HarajukuSpacing.md)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .fluffyBorder(color: HarajukuColors.pastelMint, width: 2)
            )
            .shadow(color: HarajukuColors.pastelMint.opacity(0.3), radius: 8, x: 0, y: 4)

            // デバイス一覧
            VStack(spacing: HarajukuSpacing.lg) {
                ForEach(hostModel.availableDevices) { device in
                    DeviceCard(
                        deviceName: device.name,
                        isInviting: hostModel.invitingPeerID == device.id,
                        onInvite: {
                            hostModel.invite(device)
                        }
                    )
                }
            }
        }
    }

    // MARK: - Connected Devices Section

    private var connectedDevicesSection: some View {
        VStack(spacing: HarajukuSpacing.xl) {
            // セクションタイトル
            HStack(spacing: 12) {
                Image("blue")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)

                Text("つながったあいふぉん")
                    .nikumaruHeadline(size: 26)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                Image("blue")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 36, height: 36)
            }
            .padding(.horizontal, HarajukuSpacing.lg)
            .padding(.vertical, HarajukuSpacing.md)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .fluffyBorder(color: HarajukuColors.pastelBlue, width: 2)
            )
            .shadow(color: HarajukuColors.pastelBlue.opacity(0.3), radius: 8, x: 0, y: 4)

            // 接続済みデバイス一覧
            VStack(spacing: HarajukuSpacing.lg) {
                ForEach(hostModel.connectedDevices) { peer in
                    ConnectedDeviceCard(deviceName: peer.name)
                }
            }

            // 接続数表示
            Text("\(hostModel.connectedDevices.count) / 2 たいつながったよ")
                .nikumaruHeadline(size: 20)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .fluffyBorder(color: HarajukuColors.pastelMint, width: 2)
                )
                .shadow(color: HarajukuColors.pastelMint.opacity(0.4), radius: 10, x: 0, y: 4)
        }
    }

    // MARK: - Debug Button

    private var debugButton: some View {
        Button {
            coordinator.navigate(to: .iPadResult)
        } label: {
            Text("けっかがめんへちょくせついどう (DEBUG)")
                .nikumaruBody(size: 16)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(Color.orange.opacity(0.8))
                )
        }
    }

    // MARK: - Animations

    private func startAnimations() {
        // きらきら回転
        withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }

        // 風船ふわふわ
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            balloonFloat = 15
        }
    }
}

// MARK: - Device Card

struct DeviceCard: View {
    let deviceName: String
    let isInviting: Bool
    let onInvite: () -> Void

    var body: some View {
        HStack(spacing: HarajukuSpacing.lg) {
            // デバイス名
            VStack(alignment: .leading, spacing: 8) {
                Text(deviceName)
                    .nikumaruHeadline(size: 24)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

                if isInviting {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(HarajukuColors.pastelYellow)
                            .frame(width: 8, height: 8)
                            .shadow(color: HarajukuColors.pastelYellow.opacity(0.8), radius: 4)

                        Text("しょうたいちゅう...")
                            .nikumaruBody(size: 18)
                            .foregroundColor(HarajukuColors.pastelYellow)
                            .shadow(color: .black.opacity(0.3), radius: 1, x: 0, y: 1)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(HarajukuColors.pastelYellow.opacity(0.2))
                            .fluffyBorder(color: HarajukuColors.pastelYellow, width: 1.5)
                    )
                }
            }

            Spacer()

            // 招待ボタン
            Button {
                onInvite()
            } label: {
                HStack(spacing: 10) {
                    Image("red")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)

                    Text("しょうたい")
                        .nikumaruBody(size: 18)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    HarajukuColors.pastelPink,
                                    HarajukuColors.pastelPurple
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .shadow(color: HarajukuColors.pastelPink.opacity(0.6), radius: 8, x: 0, y: 4)
            }
            .disabled(isInviting)
            .opacity(isInviting ? 0.5 : 1.0)
        }
        .padding(.horizontal, HarajukuSpacing.xl)
        .padding(.vertical, HarajukuSpacing.lg)
        .frame(maxWidth: 600)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .fluffyBorder(
                    color: isInviting ? HarajukuColors.pastelYellow : HarajukuColors.pastelPink,
                    width: 2
                )
        )
        .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Connected Device Card

struct ConnectedDeviceCard: View {
    let deviceName: String

    var body: some View {
        HStack(spacing: HarajukuSpacing.lg) {
            // チェックマークアイコン
            Circle()
                .fill(
                    LinearGradient(
                        colors: [
                            HarajukuColors.pastelMint,
                            HarajukuColors.pastelBlue
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                )
                .shadow(color: HarajukuColors.pastelMint.opacity(0.6), radius: 8)

            // デバイス名
            Text(deviceName)
                .nikumaruHeadline(size: 24)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)

            Spacer()

            // 接続完了バッジ
            Text("つながった！")
                .nikumaruBody(size: 16)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(HarajukuColors.pastelMint)
                )
                .shadow(color: HarajukuColors.pastelMint.opacity(0.6), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, HarajukuSpacing.xl)
        .padding(.vertical, HarajukuSpacing.lg)
        .frame(maxWidth: 600)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .fluffyBorder(color: HarajukuColors.pastelMint, width: 3)
        )
        .shadow(color: HarajukuColors.pastelMint.opacity(0.4), radius: 12, x: 0, y: 5)
    }
}

#Preview {
    let coordinator = AppCoordinator()
    let sessionManager = P2PSessionManager()
    let hostModel = ConnectionWaitinScreenModel(sessionManager: sessionManager)
    return NavigationStack {
        ConnectionWaitingScreen()
            .environmentObject(coordinator)
            .environmentObject(sessionManager)
            .environmentObject(hostModel)
    }
}
