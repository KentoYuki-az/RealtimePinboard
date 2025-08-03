//
//  PartsConstant.swift
//  RealtimePinboard
//
//  Created by 結城 賢斗 on 2025/06/15.
//

import Foundation
import SwiftUI


protocol RandomCaseRepresentable: CustomStringConvertible {
    var image: AnyView { get }
}

/// タグ管理
enum Tag: CaseIterable, RandomCaseRepresentable{
    
    case tag1
    case tag2
    case tag3
    
    var image: AnyView{
        switch self{
        case .tag1:
            AnyView(
                Image("Tag_1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
            )
        case .tag2:
            AnyView(
                Image("Tag_2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 55)
            )
        case .tag3:
            AnyView(
                Image("Tag_3")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 65)
            )
        }
    }
    
    var description: String { "\(self)" }
}

/// ラベル管理
enum Label: CaseIterable, RandomCaseRepresentable{
    case label1
    case label2
    
    var image: AnyView{
        switch self{
        case .label1:
            AnyView(
                Image("Label_1")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            )
        case .label2:
            AnyView(
                Image("Label_2")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 180)
            )
        }
    }
    
    var description: String { "\(self)" }
}

/// 紙テープ管理
enum Tape: CaseIterable{
    case tape1
    case tape2
    
    var image: Image{
        switch self{
        case .tape1:
            return Image("Tape_1")
        case .tape2:
            return Image("Tape_2")
        }
    }
    
    var description: String { "\(self)" }
}
