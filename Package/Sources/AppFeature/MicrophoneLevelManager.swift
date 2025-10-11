//
//  MicrophoneLevelManager.swift
//  OnlyLonely
//
//  Created by Taishin Miyamoto on 2025/10/11.
//

import AVFoundation
import Foundation

final class MicrophoneLevelManager: NSObject, ObservableObject {
    @Published private(set) var peakHoldLevel: Float?
    @Published private(set) var isMonitoring = false

    private let captureSession = AVCaptureSession()
    private let audioOutput = AVCaptureAudioDataOutput()
    private let sessionQueue = DispatchQueue(label: "com.onlylonely.microphone.session", qos: .userInitiated)
    private let sampleBufferQueue = DispatchQueue(label: "com.onlylonely.microphone.samplebuffer", qos: .utility)
    private var isSessionConfigured = false

    override init() {
        super.init()
        captureSession.automaticallyConfiguresApplicationAudioSession = false
    }

    func startMonitoring() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard !self.captureSession.isRunning else { return }
            guard MicrophonePermissionManager.isPermissionGranted() else {
                // TODO: エラー処理
                return
            }

            do {
                try self.configureAudioSession()
                try self.configureCaptureSessionIfNeeded()
                self.captureSession.startRunning()
                DispatchQueue.main.async {
                    self.isMonitoring = true
                }
            } catch {
                // TODO: エラー処理
            }
        }
    }

    func stopMonitoring() {
        sessionQueue.async { [weak self] in
            guard let self else { return }
            guard self.captureSession.isRunning else { return }
            self.captureSession.stopRunning()
            try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
            DispatchQueue.main.async {
                self.isMonitoring = false
                self.peakHoldLevel = nil
            }
        }
    }

    private func configureAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playAndRecord, mode: .measurement, options: [.mixWithOthers])
            try audioSession.setActive(true, options: [])
        } catch {
            throw MicrophoneLevelManagerError.audioSessionConfigurationFailed(underlying: error)
        }
    }

    private func configureCaptureSessionIfNeeded() throws {
        guard !isSessionConfigured else { return }

        captureSession.beginConfiguration()
        defer { captureSession.commitConfiguration() }

        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {
            throw MicrophoneLevelManagerError.microphoneUnavailable
        }

        let audioInput: AVCaptureDeviceInput
        do {
            audioInput = try AVCaptureDeviceInput(device: audioDevice)
        } catch {
            throw MicrophoneLevelManagerError.audioInputCreationFailed(underlying: error)
        }

        guard captureSession.canAddInput(audioInput) else {
            throw MicrophoneLevelManagerError.unableToAddInput
        }
        captureSession.addInput(audioInput)

        audioOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)

        guard captureSession.canAddOutput(audioOutput) else {
            throw MicrophoneLevelManagerError.unableToAddOutput
        }
        captureSession.addOutput(audioOutput)

        isSessionConfigured = true
    }
}

extension MicrophoneLevelManager: AVCaptureAudioDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let channels = connection.audioChannels
        guard !channels.isEmpty else { return }

        let peak = channels.reduce(Float(0)) { $0 + $1.peakHoldLevel } / Float(channels.count)

        DispatchQueue.main.async {
            self.peakHoldLevel = peak
        }
    }
}

private enum MicrophoneLevelManagerError: LocalizedError {
    case permissionNotGranted
    case microphoneUnavailable
    case audioInputCreationFailed(underlying: Error)
    case unableToAddInput
    case unableToAddOutput
    case audioSessionConfigurationFailed(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .permissionNotGranted:
            return "マイクの権限が許可されていません。"
        case .microphoneUnavailable:
            return "マイクデバイスを取得できませんでした。"
        case let .audioInputCreationFailed(underlying):
            return "マイク入力の作成に失敗しました: \(underlying.localizedDescription)"
        case .unableToAddInput:
            return "マイク入力をセッションに追加できませんでした。"
        case .unableToAddOutput:
            return "マイク出力をセッションに追加できませんでした。"
        case let .audioSessionConfigurationFailed(underlying):
            return "オーディオセッションの設定に失敗しました: \(underlying.localizedDescription)"
        }
    }
}
