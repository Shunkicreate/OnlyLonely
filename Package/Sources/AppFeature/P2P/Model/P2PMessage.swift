//
//  P2PMessage.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//


import Foundation

enum MessageType: Int, Codable {
    case updateBallStateMessage = 0
    case gameStartMessage = 1
    case gameBallAccelerationMessage = 2
    case gameFinishMessage = 3
    case gameTapActionMessage = 4
}

enum TapAction: String, Codable {
    case up
    case down
    case left
    case right
}

final class TapActionMessage: Codable {
    let action: TapAction
    init(action: TapAction) { self.action = action }
    func toJson() -> String? {
        let encoder = JSONEncoder()
        return try? String(data: encoder.encode(self), encoding: .utf8)
    }
    static func fromJson(_ json: String) -> TapActionMessage? {
        guard let data = json.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(TapActionMessage.self, from: data)
    }
}

class P2PMessage: Codable {
    var type: MessageType
    var jsonData: String
    
    init(type: MessageType, jsonData: String) {
        self.type = type
        self.jsonData = jsonData
    }
    
    func toSendMessage() -> String {
        return "\(type.rawValue):::\(jsonData)"
    }
    
    static func fromReceivedMessage(message: String) -> P2PMessage? {
        let components = message.components(separatedBy: ":::")
        guard components.count == 2 else {
            print("Failed to split message: \(message)")
            return nil
        }
        
        guard let type = MessageType(rawValue: Int(components[0]) ?? -1) else {
            print("Failed to convert message type: \(components[0])")
            return nil
        }
        
        return P2PMessage(type: type, jsonData: components[1])
    }
}

final class UpdateBallStateMessage: Codable {
    var ballState: BallState
    
    init(ballState: BallState) {
        self.ballState = ballState
    }
    
    func toJson() -> String? {
        let encoder = JSONEncoder()
        
        do {
            let jsonData = try encoder.encode(self)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        } catch {
            print("Failed to encode Message to JSON: \(error)")
            return nil
        }
    }
    
    static func fromJson(jsonString: String) -> UpdateBallStateMessage? {
        let decoder = JSONDecoder()
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Failed to convert JSON string to Data.")
            return nil
        }
        
        do {
            let state = try decoder.decode(UpdateBallStateMessage.self, from: jsonData)
            return state
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
}
