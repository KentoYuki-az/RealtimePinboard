//
//  NoiseView.swift
//  RealtimePinboard
//
//  Created by 結城 賢斗 on 2025/06/01.
//

import SwiftUI

/// 背景用ノイズ
struct NoiseView: View {
    var body: some View {
        Canvas { context, size in
            for _ in 0..<5000 {
                let x = CGFloat.random(in: 0..<size.width)
                let y = CGFloat.random(in: 0..<size.height)
                
                context.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: 1, height: 1)),
                    with: .color(.black)
                )
            }
        }
    }
}

#Preview {
    NoiseView()
}
