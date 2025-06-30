//
//  FavoriteButton.swift
//  receipt-share
//
//  Created by 東　真史 on 2025/06/08.
//

import SwiftUI

struct FavoriteButton: View {
    // Bindingは、ビューの状態を親ビューと共有するために使用されます。
    @Binding var isSetFavorite: Bool
    
    var body: some View {
        Button {
            isSetFavorite.toggle()
        } label: {
            Label("Toggle Favorite", systemImage: isSetFavorite ? "star.fill" : "star")
                .labelStyle(.iconOnly)
                .foregroundColor(isSetFavorite ? .yellow : .gray)
        }
    }
}
