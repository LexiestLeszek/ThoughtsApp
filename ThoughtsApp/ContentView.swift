//
//  ContentView.swift
//  ThoughtsApp
//
//  Created by Leszek Mielnikow on 21/06/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var messagesManager = MessagesManager()
    @State private var scrollToBottom = false // New state variable
    
    var body: some View {
        VStack {
            VStack {
                TitleRow()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(messagesManager.messages, id: \.id) { message in
                            MessageBubble(message: message)
                        }
                        .onChange(of: scrollToBottom) { newValue in
                            // When scrollToBottom changes, scroll to the bottom of the conversation
                            if newValue {
                                withAnimation {
                                    proxy.scrollTo(messagesManager.lastMessageId, anchor: .bottom)
                                    DispatchQueue.main.async {
                                        scrollToBottom = false // Reset scrollToBottom to false after scrolling
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    .background(.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .onChange(of: messagesManager.lastMessageId) { id in
                        // When the lastMessageId changes, set scrollToBottom to true
                        scrollToBottom = true
                    }
                }

            }
            .background(Color("Pur"))
            
            // Arrow button to scroll to the last message
            Button(action: {
                scrollToBottom = true
            }) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .background(Color.clear)
            }
            
            MessageField()
                .environmentObject(messagesManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
