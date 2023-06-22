//
//  MessageBubble.swift
//  ThoughtsApp
//
//  Created by Leszek Mielnikow on 21/06/2023.
//

import SwiftUI

struct MessageBubble: View {
    var message: Message
    @State private var showTime = false
    
    var body: some View {
        VStack(alignment: .trailing) {
            Text(message.text)
                .padding()
                .background(Color("Pur"))
                .cornerRadius(30)
            
            if showTime {
                Text("\(message.timestamp.formatted(.dateTime.hour().minute()))")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .padding(.trailing, 25)
            }
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .padding(.trailing)
        .padding(.horizontal, 10)
        .onTapGesture {
            showTime.toggle()
        }
    }
}

struct MessageBubble_Previews: PreviewProvider {
    static var previews: some View {
        MessageBubble(
            message:
                Message(
                    id: "12345",
                    text: "I've been coding applications from scratch in SwiftUI and it's so much fun!",
                    received: true,
                    timestamp: Date(),
                    tags: ["#22222"]
                )
        )
    }
}
