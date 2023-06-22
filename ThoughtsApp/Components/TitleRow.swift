//
//  TitleRow.swift
//  ThoughtsApp
//
//  Created by Leszek Mielnikow on 21/06/2023.
//

import SwiftUI

struct TitleRow: View {
    @Binding var searchQuery: String
    
    var imageUrl = URL(fileURLWithPath: "/Users/leszekmielnikow/Coding/ThoughtsApp/ThoughtsApp/Assets.xcassets/AppIcon.appiconset/AppIcon~ios-marketing.png")
    var name = "Thoughts"
    
    var body: some View {
        HStack(spacing: 20) {
            AsyncImage(url: imageUrl) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .cornerRadius(50)
            } placeholder: {
                ProgressView()
            }
            
            TextField("Search", text: $searchQuery, onCommit: {
                // Perform search based on searchQuery
                // Add your logic here to handle the search functionality
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding(.horizontal, 3)
            .frame(maxWidth: .infinity)
            
            Button(action: {
                // Perform search based on searchQuery
                // Add your logic here to handle the search functionality
                
                // Reset search query after performing the search
                searchQuery = ""
            }) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                    .padding(15)
                    .background(.white)
                    .cornerRadius(60)
            }
        }
        .padding()
    }
}

struct TitleRow_Previews: PreviewProvider {
    static var previews: some View {
        TitleRow(searchQuery: .constant(""))
            .background(Color("Pur"))
    }
}

// Rest of the code remains unchanged.
