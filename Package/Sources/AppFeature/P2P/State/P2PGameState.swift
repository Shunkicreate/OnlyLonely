//
//  P2PGameState.swift
//  OnlyLonely
//
//  Created by shunsuke tamura on 2025/10/11.
//


import MultipeerConnectivity

enum P2PGamePhase: Int, Codable {
    case prepare = 0
    case started = 1
    case gaming = 2
    case finished = 3
}


class P2PGameState: ObservableObject, Equatable {
    @Published var session: MCSession? = nil
    @Published var ballState: BallState? = nil
    @Published var phase: P2PGamePhase = P2PGamePhase.prepare
    
    @Published var ballAcceleration: BallAcceleration = .init(x: 0, y: 0, z: 0)
    
    func setProperties(_session: MCSession, _ballState: BallState) {
        self.session = _session
        self.ballState = _ballState
    }
    
    func updateBallState(_ballState: BallState) {
        self.ballState = _ballState
    }
    
    func updateSession(_session: MCSession) {
        self.session = _session
    }
    
    func updatePhase(phase: P2PGamePhase) {
        self.phase = phase
    }
    
    static func ==(lhs: P2PGameState, rhs: P2PGameState) -> Bool {
        return lhs.session == rhs.session && lhs.ballState == rhs.ballState
    }
}
