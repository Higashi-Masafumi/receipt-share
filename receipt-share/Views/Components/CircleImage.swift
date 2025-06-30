//
//  CircleImage.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//

import SwiftUI

struct CircleImage: View {
    var imageURL: URL
    var size: CGFloat = 150  // デフォルトサイズを150に設定
    
    var body: some View {
        AsyncImage(url: imageURL) { image in
            image
                .resizable()  // 重要：リサイズ可能にする
                .aspectRatio(contentMode: .fill)  // アスペクト比を保持しつつ全体を埋める
                .frame(width: size, height: size)  // 固定サイズを指定
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                .shadow(radius: 7)
        } placeholder: {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                .frame(width: size, height: size)  // プレイスホルダーも同じサイズ
        }
    }
}
