//
//  BGMManager.swift
//  OnlyLonely
//
//  BGM管理 - アプリ全体でBGMをループ再生
//

import AVFoundation
import Combine

@MainActor
class BGMManager: ObservableObject {
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying: Bool = false
    @Published var volume: Float = 0.3 // デフォルト音量（0.0〜1.0）
    
    static let shared = BGMManager()
    
    private init() {
        setupAudioSession()
    }
    
    /// オーディオセッションの設定
    private func setupAudioSession() {
        do {
            // バックグラウンド再生は不要、アプリ内のみで再生
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ BGMManager: オーディオセッションの設定に失敗: \(error)")
        }
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
    
    /// BGMの停止
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        print("⏹️ BGMManager: BGM停止")
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
    
    /// 音量の設定（0.0〜1.0）
    func setVolume(_ newVolume: Float) {
        volume = max(0.0, min(1.0, newVolume))
        audioPlayer?.volume = volume
        print("🔊 BGMManager: 音量設定 \(volume)")
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
    
    /// フェードアウト（指定秒数で音量を下げる）
    func fadeOut(duration: TimeInterval = 2.0) {
        guard let player = audioPlayer else { return }
        
        let startVolume = player.volume
        let steps = 20
        let stepDuration = duration / Double(steps)
        let volumeDecrement = startVolume / Float(steps)
        
        Task {
            for step in 1...steps {
                try? await Task.sleep(nanoseconds: UInt64(stepDuration * 1_000_000_000))
                player.volume = startVolume - (volumeDecrement * Float(step))
            }
        }
        
        print("🎵 BGMManager: フェードアウト開始")
    }
}

