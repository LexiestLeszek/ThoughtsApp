//
//  JSONsearch.swift
//  ThoughtsApp
//
//  Created by Leszek Mielnikow on 21/06/2023.
//  Working implementation of a semantic similarity search inside a json file

import SwiftUI
import SimilaritySearchKit
import SimilaritySearchKitDistilbert
import UIKit
import MobileCoreServices
import QuickLookThumbnailing

struct ContentView: View {
    @State private var documentText: String = ""
    @State private var fileName: String = ""
    @State private var fileIcon: UIImage? = nil
    @State private var totalCharacters: Int = 0
    @State private var totalTokens: Int = 0
    @State private var progress: Double = 0
    @State private var chunks: [String] = []
    @State private var embeddings: [[Float]] = []
    @State private var searchText: String = ""
    @State private var searchResults: [String] = []
    @State private var isLoading: Bool = false

    @State private var similarityIndex: SimilarityIndex?

    var body: some View {
        VStack {
            Text("🔍 JSON Search")
                .font(.largeTitle)
                .bold()
                .padding()

            Button(action: selectFromFiles) {
                Text("📂 Select JSON to Search")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: 500)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding()

            if !fileName.isEmpty {
                HStack {
                    if let fileIcon = fileIcon {
                        Image(uiImage: fileIcon)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                    }

                    VStack(alignment: .leading) {
                        Text("File: \(fileName)")
                            .font(.headline)
                        Text("🔡 Total Tokens: \(totalTokens)")
                    }
                }
                .padding()

                Button("🤖 Create Embedding Vectors") {
                    vectorizeChunks()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: 500)
                .padding()
                .background(Color.blue)
                .cornerRadius(8)
                .padding()
            }

            if !embeddings.isEmpty {
                Text("🔢 Total Embeddings: \(embeddings.count)")
                    .font(.headline)
                    .padding()

                if embeddings.count != chunks.count {
                    ProgressView(value: Double(embeddings.count), total: Double(chunks.count))
                        .frame(height: 10)
                        .frame(maxWidth: 500)
                        .padding()
                } else {
                    TextField("🔍 Search document", text: $searchText, onCommit: searchDocument)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .frame(maxWidth: 500)

                    List(searchResults, id: \.self) { result in
                        Text(result)
                    }
                    .frame(maxWidth: 500)
                }
            }
            Spacer()
        }
        .onAppear {
            loadIndex()
        }
    }

    func loadIndex() {
        Task {
            similarityIndex = await SimilarityIndex(name: "JSONIndex", model: DistilbertEmbeddings(), metric: DotProduct())
        }
    }

    func selectFromFiles() {
        let picker = DocumentPicker(document: $documentText, fileName: $fileName, fileIcon: $fileIcon, totalCharacters: $totalCharacters, totalTokens: $totalTokens)
        let hostingController = UIHostingController(rootView: picker)
        UIApplication.shared.connectedScenes
            .map { ($0 as? UIWindowScene)?.windows.first?.rootViewController }
            .compactMap { $0 }
            .first?
            .present(hostingController, animated: true, completion: nil)
    }

    func vectorizeChunks() {
        guard let index = similarityIndex else { return }

        Task {
            let jsonChunks = try? JSONSerialization.jsonObject(with: Data(documentText.utf8), options: []) as? [[String: Any]]
            guard let chunks = jsonChunks else { return }

            embeddings = []
            if let miniqa = index.indexModel as? DistilbertEmbeddings {
                for chunk in chunks {
                    if let text = chunk["text"] as? String, let embedding = await miniqa.encode(sentence: text) {
                        self.chunks.append(text)
                        embeddings.append(embedding)
                    }
                }
            }

            for (idx, chunk) in chunks.enumerated() {
                if let text = chunk["text"] as? String {
                    await index.addItem(id: "id\(idx)", text: text, metadata: ["source": fileName], embedding: embeddings[idx])
                }
            }
        }
    }

    func searchDocument() {
        guard let index = similarityIndex else { return }

        Task {
            let results = await index.search(searchText)

            searchResults = results.map { $0.text }
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    @Binding var document: String
    @Binding var fileName: String
    @Binding var fileIcon: UIImage?
    @Binding var totalCharacters: Int
    @Binding var totalTokens: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = context.coordinator
        picker.shouldShowFileExtensions = true
        return picker
    }

    func updateUIViewController(_: UIDocumentPickerViewController, context _: Context) {}

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker

        init(_ parent: DocumentPicker) {
            self.parent = parent
        }

        func documentPicker(_: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first, let jsonData = try? Data(contentsOf: url), let jsonString = String(data: jsonData, encoding: .utf8) else { return }

            parent.document = jsonString
            parent.fileName = url.lastPathComponent
            parent.totalCharacters = jsonData.count

            if let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []), let jsonArray = jsonObject as? [[String: Any]] {
                let totalTokens = jsonArray.reduce(0) { (result, dict) -> Int in
                    if let text = dict["text"] as? String {
                        return result + BertTokenizer().tokenize(text: text).count
                    }
                    return result
                }
                parent.totalTokens = totalTokens
            }

            // Create the thumbnail
            let size: CGSize = CGSize(width: 60, height: 60)
            let scale = UIScreen.main.scale
            let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: scale, representationTypes: .all)
            let generator = QLThumbnailGenerator.shared
            generator.generateRepresentations(for: request) { thumbnail, _, error in
                DispatchQueue.main.async {
                    guard thumbnail?.uiImage != nil, error == nil else { return }
                    self.parent.fileIcon = thumbnail?.uiImage
                }
            }
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
