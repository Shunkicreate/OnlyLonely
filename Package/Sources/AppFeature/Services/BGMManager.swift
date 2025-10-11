//
//  BGMManager.swift
//  OnlyLonely
//
//  BGM管理 - アプリ全体でBGMをループ再生
//

import AVFoundation
import Combine
import SwiftUI

@MainActor
class BGMManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var volume: Float = 0.3 // デフォルト音量（0.0〜1.0）
    private var wasPlayingBeforeBackground = false
    private var cancellables = Set<AnyCancellable>()

    static let shared = BGMManager()

    private init() {
        setupAudioSession()
        setupAppLifecycleObservers()
    }
    
    /// オーディオセッションの設定
    private func setupAudioSession() {
        do {
            // アプリ内のみで再生、バックグラウンドでは停止
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ BGMManager: オーディオセッションの設定に失敗: \(error)")
        }
    }

    /// アプリのライフサイクルイベントを監視
    private func setupAppLifecycleObservers() {
        // バックグラウンドに移行する時
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handleWillResignActive()
                }
            }
            .store(in: &cancellables)

        // フォアグラウンドに戻る時
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task { @MainActor in
                    self?.handleDidBecomeActive()
                }
            }
            .store(in: &cancellables)
    }

    /// バックグラウンドに移行する時の処理
    private func handleWillResignActive() {
        wasPlayingBeforeBackground = isPlaying
        if isPlaying {
            pause()
            print("📱 BGMManager: バックグラウンドに移行したため一時停止")
        }
    }

    /// フォアグラウンドに戻る時の処理
    private func handleDidBecomeActive() {
        // iPadのみで、以前再生していた場合は再開
        if DeviceType.current == .iPad && wasPlayingBeforeBackground {
            resume()
            print("📱 BGMManager: フォアグラウンドに戻ったため再開")
        }
        wasPlayingBeforeBackground = false
    }
    
    /// BGMの再生開始（ループ）
    func play() {
        // すでに再生中の場合は何もしない
        guard !isPlaying else { return }
        
        // BGMファイルのパスを取得
        guard let url = Bundle.main.url(forResource: "SummerFunPop", withExtension: "mp3") else {
            print("❌ BGMManager: SummerFunPop.mp3 が見つかりません")
            return
        }
        
        do {
            // AVAudioPlayerを初期化
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // 無限ループ
            audioPlayer?.volume = volume
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            isPlaying = true
            print("✅ BGMManager: BGM再生開始（ループ）")
        } catch {
            print("❌ BGMManager: BGMの再生に失敗: \(error)")
        }
    }
    
    /// BGMの一時停止
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        print("⏸️ BGMManager: BGM一時停止")
    }
    
    /// BGMの再開
    func resume() {
        audioPlayer?.play()
        isPlaying = true
        print("▶️ BGMManager: BGM再開")
    }
    
    /// フェードイン（指定秒数で音量を上げる）
    func fadeIn(duration: TimeInterval = 2.0) {
        guard let player = audioPlayer else { return }
        
        player.volume = 0.0
        let targetVolume = volume
        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeIncrement = targetVolume / Float(steps)
        
        Task {
            for step in 1...steps {
                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                player.volume = volumeIncrement * Float(step)
            }
        }
        
        print("🎵 BGMManager: フェードイン開始")
    }
    
}

