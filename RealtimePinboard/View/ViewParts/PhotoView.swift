//
//  PhotoView.swift
//  RealtimePinboard
//
//  Created by 結城 賢斗 on 2025/07/26.
//

import SwiftUI

/// 写真表示ビュー(装飾付き)
struct PhotoView: View {
    let targetImage: Image
    @State private var tape: Image?
    var body: some View {
        ZStack(alignment: .top){
            PhotoPaperEffectView(targetImage: targetImage)
            if let tape = tape{
                tape
                    .resizable()
                    .scaledToFit()
                    .frame(height: 40)
            }
            
        }
        .onAppear {
            if tape == nil {
                tape = Tape.allCases.randomElement()?.image ?? Tape.tape1.image
            }
        }
    }
}

#Preview {
    PhotoView(targetImage: Image("Label_1"))
}


/// 写真加工(白枠＋影)
struct PhotoPaperEffectView: View {
    let targetImage: Image
    var body: some View {
        targetImage
            .resizable()
            .scaledToFit()
            .padding(10)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            .shadow(color: Color.black.opacity(0.07), radius: 4, x: 0, y: 4)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 10)
            .padding()
            .frame(width: 300)
    }
}
