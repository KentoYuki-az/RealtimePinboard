//
//  ViewModel.swift
//  RealtimePinboard
//
//  Created by 結城 賢斗 on 2025/06/01.
//

import SwiftUI



/// 設置画像
struct DroppedImage: Identifiable, Equatable{
    var id = UUID()
    var image: NSImage?
    var position = CGPoint(x: 0, y: 0)
    var visibleState = false
    var imageRotation: Angle
}

/// 装飾パーツ
struct DecorationItem: Identifiable{
    var id = UUID()
    var image: AnyView?
    var position = CGPoint(x: 0, y: 0)
    var visibleState = false
    var isFlip: Bool
    var imageRotation: Angle
}

/// メイン画面用ViewModel
class ViewModel: ObservableObject{
    @Published var droppedImages = [DroppedImage]()
    @Published var decorationItems = [DecorationItem]()
    
    /// ドロップされたオブジェクトがImageであれば配列に追加
    /// - Parameter providers: ドロップされたオブジェクト
    /// - Returns: 追加されたか
    func handleDrop(providers: [NSItemProvider]) -> Bool{
        for provider in providers{
            if provider.canLoadObject(ofClass: NSImage.self){
                provider.loadObject(ofClass: NSImage.self) { object, _ in
                    DispatchQueue.main.async {
                        if let image = object as? NSImage {
                            self.droppedImages.append(DroppedImage(image: image,
                                                                   imageRotation: Angle(degrees: Double.random(in: -1...1))))
                        }
                    }
                }
                return true
            }
        }
        return false
    }
    
    /// ランダムな確率でデコレーションアイテムをランダムにセット
    func setDecorationImage(){
        let randomBool = Bool.random()
        if randomBool == true{
            let allCases: [RandomCaseRepresentable] = Tag.allCases + Label.allCases
            
            if let random = allCases.randomElement() {
                decorationItems.append(DecorationItem(image: random.image,
                                                      isFlip: Bool.random(),
                                                      imageRotation: Angle(degrees: Double.random(in: -7...7))))
            }
        }
    }
    
    func setDecorationPoint(geometry: GeometryProxy, id: UUID){
        if let index = decorationItems.firstIndex(where: { $0.id == id }) {
            let width = geometry.size.width
            let height = geometry.size.height
            
            //試行回数
            var attempts = 0
            //最大試行回数
            let maxAttempts = 100
            
            //他の画像の位置と重ならないランダムな位置を出力
            while attempts < maxAttempts {
                attempts += 1
                
                let randomX = CGFloat.random(in: 150...(width - 150))
                let randomY = CGFloat.random(in: 150...(height - 150))
                
                let randomPosition = CGPoint(x: randomX, y: randomY)
                let frame = CGRect(x: randomPosition.x,
                                   y: randomPosition.y,
                                   width: 300,
                                   height: 300)
                let overlap = decorationItems.contains{existing in
                    //すでに設置されている画像の中心から100px以内の座標になっていないか
                    let existingFrame = CGRect(x: existing.position.x,
                                               y: existing.position.y,
                                               width: 300,
                                               height: 300)
                    return frame.intersects(existingFrame)
                }
                if !overlap{
                    decorationItems[index].position = randomPosition
                    break
                }
            }
        }
    }
    
    /// 画像をランダムな位置に配置
    /// - Parameters:
    ///   - geometry: Viewで用意したGeometryProxy
    ///   - id: 対象画像のID
    func setImagePoint(geometry: GeometryProxy, id: UUID){
        if let index = droppedImages.firstIndex(where: { $0.id == id }) {
            let width = geometry.size.width
            let height = geometry.size.height
            
            //試行回数
            var attempts = 0
            //最大試行回数
            let maxAttempts = 100
            
            //他の画像の位置と重ならないランダムな位置を出力
            while attempts < maxAttempts {
                attempts += 1
                
                let randomX = CGFloat.random(in: 150...(width - 150))
                let randomY = CGFloat.random(in: 150...(height - 150))
                
                let randomPosition = CGPoint(x: randomX, y: randomY)
                let frame = CGRect(x: randomPosition.x,
                                   y: randomPosition.y,
                                   width: 300,
                                   height: 300)
                let overlap = droppedImages.contains{existing in
                    //すでに設置されている画像の中心から100px以内の座標になっていないか
                    let existingFrame = CGRect(x: existing.position.x,
                                               y: existing.position.y,
                                               width: 100,
                                               height: 100)
                    return frame.intersects(existingFrame)
                }
                if !overlap{
                    droppedImages[index].position = randomPosition
                    break
                }
            }
        }
    }
    
    /// 配列の要素数がリミットを超えたら最も古いものを削除
    /// - Parameters:
    ///   - array: 写真の配列
    ///   - limit: リミット
    func removeFirstImage(limit: Int){
        if droppedImages.count > limit {
            droppedImages[0].visibleState = false
            DispatchQueue.main.asyncAfter(deadline: .now() +  0.8) {
                self.droppedImages.removeFirst()
            }
        }
    }
    
    func removeFirstDecoration(limit: Int){
        if decorationItems.count > limit {
            decorationItems[0].visibleState = false
            DispatchQueue.main.asyncAfter(deadline: .now() +  0.8) {
                self.decorationItems.removeFirst()
            }
        }
    }
}
