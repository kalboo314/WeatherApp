//
//  SearchBarView.swift
//  WeatherApp
//
//  Created by Class Monitor - Class 1 on 2026/5/6.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var onSearch: (String) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.9))
                .font(.system(size: 16, weight: .semibold))

            TextField("Search city...", text: $searchText)
                .font(.system(size: 15, weight: .medium))
                .textFieldStyle(.plain)
                .submitLabel(.search)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .tint(.white)
                .onSubmit {
                    let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmedSearch.isEmpty else { return }
                    onSearch(trimmedSearch)
                }

            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.white.opacity(0.85))
                        .font(.system(size: 14))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .cornerRadius(18)
    }
}

struct SearchResultsView: View {
    let results: [CitySearchResult]
    let onSelect: (CitySearchResult) -> Void

    var body: some View {
        VStack(spacing: 0) {
            ForEach(results) { city in
                Button(action: {
                    onSelect(city)
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(city.name)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.white)

                            Text(city.displayName)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.72))
                        }

                        Spacer()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                }

                if city.id != results.last?.id {
                    Divider()
                        .padding(.leading, 14)
                }
            }
        }
        .background(Color.white.opacity(0.16))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .cornerRadius(18)
    }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant("Rome"), onSearch: { _ in })
            .padding()
    }
}
