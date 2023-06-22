//
//  ContentView.swift
//  ThoughtsApp
//
//  Created by Leszek Mielnikow on 21/06/2023.
//


import SwiftUI

struct ContentView: View {
    @StateObject var messagesManager = MessagesManager()
    @State private var scrollToBottom = false
    @State private var searchQuery = ""

    var body: some View {
        VStack {
            VStack {
                TitleRow(searchQuery: $searchQuery)
                
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(filteredMessages, id: \.id) { message in
                            Section(header: MessageDateHeader(date: message.timestamp)) {
                                MessageBubble(message: message)
                            }
                        }
                        .onChange(of: scrollToBottom) { newValue in
                            if newValue {
                                withAnimation {
                                    proxy.scrollTo(messagesManager.lastMessageId, anchor: .bottom)
                                    DispatchQueue.main.async {
                                        scrollToBottom = false
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 10)
                    .background(.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .onChange(of: messagesManager.lastMessageId) { id in
                        scrollToBottom = true
                    }
                }
            }
            .background(Color("Pur"))
            
            Button(action: {
                scrollToBottom = true
            }) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    .padding(.top, 8)
                    .background(.clear)
            }
            
            MessageField()
                .environmentObject(messagesManager)
        }
    }
    
    private var filteredMessages: [Message] {
        if searchQuery.isEmpty {
            return messagesManager.messages
        } else {
            return messagesManager.messages.filter { $0.text.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Rest of the code remains unchanged.


struct MessageDateHeader: View {
    let date: Date
    
    var body: some View {
        if !Calendar.current.isDateInToday(date) {
            Text(formatDate(date))
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.vertical, 8)
        } else {
            EmptyView()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        return dateFormatter.string(from: date)
    }
}
