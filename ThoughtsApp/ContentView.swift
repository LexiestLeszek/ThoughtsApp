//
//  ContentView.swift
//  ThoughtsApp
//
//  Created by Leszek Mielnikow on 21/06/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var messagesManager = MessagesManager()
    @StateObject var searchManager = SearchManager()
    @State private var scrollToBottom = false
    @State private var selectedMessage: Message?
    @State private var isEditMessageSheetPresented = false
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .cornerRadius(50)
                    } placeholder: {
                        ProgressView()
                    }
                    
                    TextField("Search", text: $searchManager.searchQuery, onCommit: {
                        // Perform search based on searchQuery
                        // Add your logic here to handle the search functionality
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal, 3)
                    .frame(maxWidth: .infinity)
                }
                .padding()
                
                ScrollViewReader { proxy in
                    ScrollView {
                        ForEach(searchManager.filterMessages(messagesManager.messages), id: \.id) { message in
                            Section(header: MessageDateHeader(date: message.timestamp)) {
                                MessageBubble(message: message)
                                    .onLongPressGesture {
                                        selectedMessage = message
                                        isEditMessageSheetPresented = true
                                    }
                                    .sheet(isPresented: $isEditMessageSheetPresented) {
                                        EditMessageView(message: $selectedMessage, isPresented: $isEditMessageSheetPresented)
                                            .environmentObject(messagesManager)
                                    }
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
    
    private var imageUrl = URL(fileURLWithPath: "/Users/leszekmielnikow/Coding/ThoughtsApp/ThoughtsApp/Assets.xcassets/AppIcon.appiconset/AppIcon~ios-marketing.png")
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


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

struct EditMessageView: View {
    @Binding var message: Message?
    @Binding var isPresented: Bool
    @EnvironmentObject var messagesManager: MessagesManager
    @State private var editedText: String
    
    init(message: Binding<Message?>, isPresented: Binding<Bool>) {
        _message = message
        _isPresented = isPresented
        _editedText = State(initialValue: message.wrappedValue?.text ?? "")
    }
    
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter message", text: $editedText)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Button(action: {
                    updateMessage()
                }) {
                    Text("Save Changes")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .disabled(editedText.isEmpty)
                
                Spacer()
            }
            .navigationBarTitle("Edit Message")
            .navigationBarItems(leading: cancelButton, trailing: deleteButton)
        }
    }
    
    private func updateMessage() {
        if let message = message {
            messagesManager.updateMessage(message, with: editedText)
            dismiss()
        }
    }
    
    private func deleteMessage() {
        if let message = message {
            messagesManager.deleteMessage(message)
            dismiss()
        }
    }
    
    private func dismiss() {
        message = nil
        isPresented = false
    }
    
    private var cancelButton: some View {
        Button(action: {
            dismiss()
        }) {
            Text("Cancel")
        }
    }
    
    private var deleteButton: some View {
        Button(action: {
            deleteMessage()
        }) {
            Text("Delete")
                .foregroundColor(.red)
        }
    }
}

// Working similarity search

/*
 import SwiftUI
 import SimilaritySearchKit
 import SimilaritySearchKitMiniLMAll

 struct ContentView: View {
     @StateObject private var messagesManager = MessagesManager()
     @State private var querySentence: String = ""
     @State private var similarityResults: [SearchResult] = []
     @State private var similarityIndex: SimilarityIndex?

     func loadIndex() async {
         similarityIndex = await SimilarityIndex(
             model: MiniLMEmbeddings(),
             metric: CosineSimilarity()
         )
     }

     private func searchSimilarity() async {
         guard let index = similarityIndex else { return }
         index.indexItems = []

         for message in messagesManager.messages {
             await index.addItem(id: message.id, text: message.text, metadata: ["source": "MessagesManager"])
         }

         let results = await index.search(querySentence)
         similarityResults = results
     }

     var body: some View {
         VStack {
             List(messagesManager.messages, id: \.id) { message in
                 Text(message.text)
             }
             .padding()

             TextField("Query sentence", text: $querySentence)
                 .textFieldStyle(RoundedBorderTextFieldStyle())
                 .padding()
                 .background(Color.green.opacity(0.2))
                 .cornerRadius(5)

             Button("Run Similarity Search") {
                 Task {
                     await searchSimilarity()
                 }
             }
             .foregroundColor(.white)
             .padding()
             .background(Color.blue)
             .cornerRadius(8)
             .padding()

             List(similarityResults, id: \.id) { result in
                 Text("Score: \(result.score)\nText: \(result.text)")
             }
             .padding()
             .onAppear {
                 Task {
                     await loadIndex()
                 }
             }
         }
     }
 }

 struct ContentView_Previews: PreviewProvider {
     static var previews: some View {
         ContentView()
     }
 }

 */

