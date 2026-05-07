//
//  ContentView.swift
//  WeatherApp
//
//  Created by Class Monitor - Class 1 on 2026/5/6.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var weatherService = WeatherService()
    @State private var searchText = ""

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.24, green: 0.73, blue: 0.92),
                    Color(red: 0.20, green: 0.63, blue: 0.96)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    SearchBarView(searchText: $searchText) { city in
                        weatherService.searchWeather(for: city)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                    if !weatherService.searchResults.isEmpty && !weatherService.isLoading {
                        SearchResultsView(results: weatherService.searchResults) { city in
                            searchText = city.displayName
                            weatherService.searchWeather(for: city)
                        }
                        .padding(.horizontal, 20)
                    }

                    if let errorMessage = weatherService.errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18)
                            .padding(.vertical, 12)
                            .background(Color.red.opacity(0.22))
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                    }
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 18) {
                        if let weather = weatherService.weather {
                            WeatherCardView(weather: weather)
                                .transition(.opacity)

                            WeatherForecastView(forecast: weather.forecast, hourly: weather.hourly)
                        } else if weatherService.isLoading {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .scaleEffect(1.5)

                                Text("Loading weather...")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.88))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 120)
                        } else {
                            VStack(spacing: 14) {
                                Image(systemName: "cloud.sun")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white)

                                Text("Search for a city to see the weather")
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.88))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 120)
                        }

                        Spacer()
                            .frame(height: 28)
                    }
                }
            }
        }
        .onChange(of: searchText) { newValue in
            if newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                weatherService.clearSearchResults()
            } else {
                weatherService.updateSearchQuery(newValue)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
