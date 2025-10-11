//
//  DeviceType.swift
//  OnlyLonely
//

import UIKit

enum DeviceType {
    case iPad
    case iPhone

    static var current: DeviceType {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .iPad
        } else {
            return .iPhone
        }
        #else
        return .iPhone
        #endif
    }
}
