//
//  CharacterAssignment.swift
//  OnlyLonely
//
//  キャラクター割り当て管理
//

import Foundation

struct CharacterInfo: Codable, Hashable {
    let imageName: String  // red, blue, yellow, orange, green
    let color: String      // HEX color

    static let allCharacters: [CharacterInfo] = [
        CharacterInfo(imageName: "red", color: "#FF1493"),
        CharacterInfo(imageName: "blue", color: "#1E90FF"),
        CharacterInfo(imageName: "yellow", color: "#FFD700"),
        CharacterInfo(imageName: "orange", color: "#FF6347"),
        CharacterInfo(imageName: "green", color: "#32CD32")
    ]

    static func random() -> CharacterInfo {
        allCharacters.randomElement() ?? allCharacters[0]
    }
}

/// キャラクター割り当てメッセージ
struct CharacterAssignmentMessage: Codable {
    let playerId: String  // "A" or "B"
    let character: CharacterInfo
}

/// キャラクター管理クラス
@MainActor
class CharacterAssignmentManager: ObservableObject {
    @Published private(set) var playerACharacter: CharacterInfo?
    @Published private(set) var playerBCharacter: CharacterInfo?

    /// ランダムに2つの異なるキャラクターを割り当て
    func assignRandomCharacters() {
        let shuffled = CharacterInfo.allCharacters.shuffled()
        playerACharacter = shuffled[0]
        playerBCharacter = shuffled[1]
    }

    /// プレイヤーIDからキャラクターを取得
    func character(for playerId: String) -> CharacterInfo {
        switch playerId {
        case "A":
            return playerACharacter ?? CharacterInfo.allCharacters[0]
        case "B":
            return playerBCharacter ?? CharacterInfo.allCharacters[1]
        default:
            return CharacterInfo.allCharacters[0]
        }
    }

    /// キャラクター割り当てをセット（ホストから送信された情報を受信）
    func setAssignment(playerId: String, character: CharacterInfo) {
        switch playerId {
        case "A":
            playerACharacter = character
        case "B":
            playerBCharacter = character
        default:
            break
        }
    }

    func reset() {
        playerACharacter = nil
        playerBCharacter = nil
    }
}
