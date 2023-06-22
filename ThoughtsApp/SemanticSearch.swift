//
//  SemanticSearch.swift
//  ThoughtsApp
//
//  Created by Leszek Mielnikow on 22/06/2023.
//

import Foundation
import SimilaritySearchKit
import SimilaritySearchKitDistilbert
import QuickLookThumbnailing

class SemanticSearch: ObservableObject {
    @Published var searchResults: [String] = []

    private var similarityIndex: SimilarityIndex?

    init() {
        loadIndex()
    }

    private func loadIndex() {
        Task {
            similarityIndex = await SimilarityIndex(name: "JSONIndex", model: DistilbertEmbeddings(), metric: DotProduct())
        }
    }

    func searchMessages(query: String) {
        guard let index = similarityIndex else { return }

        Task {
            let results = await index.search(query)

            DispatchQueue.main.async {
                self.searchResults = results.map { $0.text }
            }
        }
    }
}
