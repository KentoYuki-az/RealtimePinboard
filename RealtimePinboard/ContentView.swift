//
//  ContentView.swift
//  RealtimePinboard
//
//  Created by 結城 賢斗 on 2025/05/31.
//

import SwiftUI

/// メイン画面
struct ContentView: View {
    @StateObject var vm = ViewModel()
    @State private var isTargeted = false
    
//    let gridSpacing: CGFloat = 8
//    let gridLineWidth: CGFloat = 0.3
    
    var body: some View {
        
        GeometryReader { geometry in
            ZStack{
                //背景
                Image("Background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                
                
                //                Path { path in
                //                    let width = geometry.size.width
                //                    let height = geometry.size.height
                //
                //                    // 垂直線
                //                    stride(from: 0, through: width, by: gridSpacing).forEach { x in
                //                        path.move(to: CGPoint(x: x, y: 0))
                //                        path.addLine(to: CGPoint(x: x, y: height))
                //                    }
                //
                //                    // 水平線
                //                    stride(from: 0, through: height, by: gridSpacing).forEach { y in
                //                        path.move(to: CGPoint(x: 0, y: y))
                //                        path.addLine(to: CGPoint(x: width, y: y))
                //                    }
                //                }
                //                .stroke(Color("GridColor").opacity(0.2), lineWidth: gridLineWidth)
                
                
                //デコレーションアイテムレイヤー
                ForEach(vm.decorationItems){ decorationItem in
                    if let image = decorationItem.image{
                        image
                            .position(decorationItem.position)
                            .opacity(decorationItem.visibleState ? 1 : 0)
                            .scaleEffect(x: decorationItem.isFlip ? -1 : 1, y: 1)
                            .rotationEffect(decorationItem.imageRotation)
                            .onAppear{
                                vm.setDecorationPoint(geometry: geometry,
                                                 id: decorationItem.id)
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() +  0.3) {
                                    withAnimation(.easeIn(duration: 0.8)) {
                                        if let index = vm.decorationItems.firstIndex(where: { $0.id == decorationItem.id }) {
                                            vm.decorationItems[index].visibleState = true
                                        }
                                    }
                                }
                            }
                    }
                }
                
                //写真レイヤー
                ForEach(vm.droppedImages){ droppedImage in
                    if let image = droppedImage.image{
                        PhotoView(targetImage: Image(nsImage: image))
                            .position(droppedImage.position)
                            .opacity(droppedImage.visibleState ? 1 : 0)
                            .rotationEffect(droppedImage.imageRotation)
                            .onAppear{
                                vm.setImagePoint(geometry: geometry,
                                                 id: droppedImage.id)
                                
                                //フェードインアニメーション
                                DispatchQueue.main.asyncAfter(deadline: .now() +  0.3) {
                                    withAnimation(.easeIn(duration: 0.8)) {
                                        if let index = vm.droppedImages.firstIndex(where: { $0.id == droppedImage.id }) {
                                            vm.droppedImages[index].visibleState = true
                                        }
                                    }
                                }
                            }
                    }
                }
                
                
                
                
            }
        }
        .onDrop(of: [.image], isTargeted: $isTargeted){ providers in
            withAnimation(.easeIn(duration: 0.8)) {
                vm.removeFirstImage(limit: 7)
                vm.removeFirstDecoration(limit: 5)
            }
            vm.setDecorationImage()
            return vm.handleDrop(providers: providers)
        }
    }
}

#Preview {
    ContentView()
}



