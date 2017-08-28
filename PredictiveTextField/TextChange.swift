//
//  TextChange.swift
//  PredictiveTextField
//
//  Created by AJ Bartocci on 8/25/17.
//  Copyright © 2017 AJ Bartocci. All rights reserved.
//

import Foundation

enum TextChange {
    case none
    case added(text: String)
    case removed(text: String, added: String?)
}

extension TextChange: Equatable {
    static func ==(lhs: TextChange, rhs: TextChange) -> Bool {
        switch lhs {
        case .added(text: let lhsAdd):
            switch rhs {
            case .added(text: let rhsAdd):
                return lhsAdd == rhsAdd
            default:
                return false
            }
        case .removed(text: let lhsRemove, added: let lhsAdd):
            switch rhs {
            case .removed(text: let rhsRemove, added: let rhsAdd):
                return rhsRemove == lhsRemove && rhsAdd == lhsAdd
            default:
                return false
            }
        case .none:
            switch rhs {
            case .none:
                return true
            default:
                return false
            }
        }
    }
}
