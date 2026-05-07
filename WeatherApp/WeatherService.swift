//
//  WeatherService.swift
//  WeatherApp
//
//  Created by Class Monitor - Class 1 on 2026/5/6.
//

import Foundation

@MainActor
final class WeatherService: ObservableObject {
    @Published var weather: Weather?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchResults: [CitySearchResult] = []

    private let session = URLSession.shared
    private var searchTask: Task<Void, Never>?

    func updateSearchQuery(_ query: String) {
        searchTask?.cancel()

        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedQuery.count >= 2 else {
            searchResults = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            guard !Task.isCancelled else { return }

            do {
                let results = try await fetchCityMatches(for: trimmedQuery)
                guard !Task.isCancelled else { return }
                searchResults = results
            } catch {
                guard !Task.isCancelled else { return }
                searchResults = []
            }
        }
    }

    func clearSearchResults() {
        searchTask?.cancel()
        searchResults = []
    }

    func searchWeather(for city: String) {
        Task {
            await loadWeather(forCityQuery: city)
        }
    }

    func searchWeather(for location: CitySearchResult) {
        Task {
            await loadWeather(for: location)
        }
    }

    private func loadWeather(forCityQuery city: String) async {
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedCity.isEmpty else { return }

        isLoading = true
        errorMessage = nil

        do {
            let matches = try await fetchCityMatches(for: trimmedCity)
            guard let bestMatch = matches.first else {
                errorMessage = "No matching city was found."
                isLoading = false
                return
            }

            searchResults = matches
            try await loadWeatherDetails(for: bestMatch)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func loadWeather(for location: CitySearchResult) async {
        isLoading = true
        errorMessage = nil
        searchResults = []

        do {
            try await loadWeatherDetails(for: location)
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func loadWeatherDetails(for location: CitySearchResult) async throws {
        async let currentResponse = fetchCurrentWeather(latitude: location.latitude, longitude: location.longitude)
        async let forecastResponse = fetchForecast(latitude: location.latitude, longitude: location.longitude)

        let (current, forecast) = try await (currentResponse, forecastResponse)
        weather = makeWeather(current: current, forecast: forecast, cityName: location.displayName)
        isLoading = false
    }

    private func fetchCityMatches(for query: String) async throws -> [CitySearchResult] {
        let apiKey = try openWeatherAPIKey()

        var components = URLComponents(string: "https://api.openweathermap.org/geo/1.0/direct")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "limit", value: "5"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        guard let url = components?.url else {
            throw WeatherServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validate(response: response)

        let decodedResults = try JSONDecoder().decode([OpenWeatherGeocodingResult].self, from: data)
        return decodedResults.map {
            CitySearchResult(
                name: $0.name,
                state: $0.state,
                country: $0.country,
                latitude: $0.lat,
                longitude: $0.lon
            )
        }
    }

    private func fetchCurrentWeather(latitude: Double, longitude: Double) async throws -> OpenWeatherCurrentResponse {
        let apiKey = try openWeatherAPIKey()

        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        guard let url = components?.url else {
            throw WeatherServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validate(response: response)

        return try JSONDecoder().decode(OpenWeatherCurrentResponse.self, from: data)
    }

    private func fetchForecast(latitude: Double, longitude: Double) async throws -> OpenWeatherForecastResponse {
        let apiKey = try openWeatherAPIKey()

        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
        components?.queryItems = [
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lon", value: String(longitude)),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "appid", value: apiKey)
        ]

        guard let url = components?.url else {
            throw WeatherServiceError.invalidURL
        }

        let (data, response) = try await session.data(from: url)
        try validate(response: response)

        return try JSONDecoder().decode(OpenWeatherForecastResponse.self, from: data)
    }

    private func validate(response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherServiceError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw WeatherServiceError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }

    private func openWeatherAPIKey() throws -> String {
        let key = Bundle.main.object(forInfoDictionaryKey: "OpenWeatherAPIKey") as? String
        let trimmedKey = key?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !trimmedKey.isEmpty, trimmedKey != "YOUR_OPENWEATHER_API_KEY" else {
            throw WeatherServiceError.missingAPIKey
        }

        return trimmedKey
    }

    private func makeWeather(
        current: OpenWeatherCurrentResponse,
        forecast: OpenWeatherForecastResponse,
        cityName: String
    ) -> Weather {
        let currentCondition = Self.condition(from: current.weather.first)
        let hourly = makeHourlyForecasts(from: forecast.list, timezoneOffset: forecast.city.timezone)
        let daily = makeDailyForecasts(from: forecast.list, timezoneOffset: forecast.city.timezone)
        let rainRisk = Int(((forecast.list.prefix(8).map(\.pop).max() ?? 0) * 100).rounded())

        return Weather(
            city: cityName,
            temperature: Int(current.main.temp.rounded()),
            condition: currentCondition.label,
            description: currentCondition.description,
            humidity: current.main.humidity,
            windSpeed: current.wind.speed,
            feelsLike: Int(current.main.feelsLike.rounded()),
            airPressure: current.main.pressure,
            visibilityKilometers: Double(current.visibility) / 1000,
            rainRisk: rainRisk,
            icon: currentCondition.icon,
            forecast: daily,
            hourly: hourly
        )
    }

    private func makeDailyForecasts(
        from items: [OpenWeatherForecastResponse.ForecastItem],
        timezoneOffset: Int
    ) -> [DayForecast] {
        let groupedItems = Dictionary(grouping: items) {
            Self.dayKey(from: $0.dt, timezoneOffset: timezoneOffset)
        }

        return groupedItems.keys.sorted().compactMap { key in
            guard
                let dayItems = groupedItems[key],
                let middayItem = Self.middayItem(from: dayItems, timezoneOffset: timezoneOffset)
            else {
                return nil
            }

            let condition = Self.condition(from: middayItem.weather.first)
            let highTemp = dayItems.map(\.main.tempMax).max() ?? middayItem.main.tempMax
            let lowTemp = dayItems.map(\.main.tempMin).min() ?? middayItem.main.tempMin
            let precipitation = (dayItems.map(\.pop).max() ?? 0) * 100

            return DayForecast(
                day: Self.weekdayString(from: middayItem.dt, timezoneOffset: timezoneOffset),
                date: Self.shortDateString(from: middayItem.dt, timezoneOffset: timezoneOffset),
                highTemp: Int(highTemp.rounded()),
                lowTemp: Int(lowTemp.rounded()),
                condition: condition.label,
                icon: condition.icon,
                precipitation: Int(precipitation.rounded())
            )
        }
    }

    private func makeHourlyForecasts(
        from hourly: [OpenWeatherForecastResponse.ForecastItem],
        timezoneOffset: Int
    ) -> [HourlyForecast] {
        hourly.prefix(24).map { hour in
            let condition = Self.condition(from: hour.weather.first)
            return HourlyForecast(
                time: Self.hourString(from: hour.dt, timezoneOffset: timezoneOffset),
                temperature: Int(hour.main.temp.rounded()),
                condition: condition.label,
                icon: condition.icon
            )
        }
    }

    private static func condition(from weather: WeatherEntry?) -> WeatherConditionStyle {
        let label = weather?.main ?? "Weather"
        let description = weather?.description.capitalized ?? "Weather conditions updated"
        let iconCode = weather?.icon ?? ""

        return WeatherConditionStyle(
            label: label,
            description: description,
            icon: iconName(for: iconCode, label: label)
        )
    }

    private static func iconName(for iconCode: String, label: String) -> String {
        switch iconCode {
        case "01d":
            return "sun.max.fill"
        case "01n":
            return "moon.stars.fill"
        case "02d", "03d", "04d":
            return "cloud.sun.fill"
        case "02n", "03n", "04n":
            return "cloud.moon.fill"
        case "09d", "09n", "10d", "10n":
            return "cloud.rain.fill"
        case "11d", "11n":
            return "cloud.bolt.rain.fill"
        case "13d", "13n":
            return "snowflake"
        case "50d", "50n":
            return "cloud.fog.fill"
        default:
            switch label.lowercased() {
            case "clear":
                return "sun.max.fill"
            case "clouds":
                return "cloud.fill"
            case "rain", "drizzle":
                return "cloud.rain.fill"
            case "thunderstorm":
                return "cloud.bolt.rain.fill"
            case "snow":
                return "snowflake"
            case "mist", "fog", "haze":
                return "cloud.fog.fill"
            default:
                return "cloud.sun.fill"
            }
        }
    }

    private static func weekdayString(from unixTime: Int, timezoneOffset: Int) -> String {
        weekdayFormatter(with: timezoneOffset).string(from: Date(timeIntervalSince1970: TimeInterval(unixTime)))
    }

    private static func shortDateString(from unixTime: Int, timezoneOffset: Int) -> String {
        dayMonthFormatter(with: timezoneOffset).string(from: Date(timeIntervalSince1970: TimeInterval(unixTime)))
    }

    private static func hourString(from unixTime: Int, timezoneOffset: Int) -> String {
        hourFormatter(with: timezoneOffset).string(from: Date(timeIntervalSince1970: TimeInterval(unixTime)))
    }

    private static func dayKey(from unixTime: Int, timezoneOffset: Int) -> String {
        dayKeyFormatter(with: timezoneOffset).string(from: Date(timeIntervalSince1970: TimeInterval(unixTime)))
    }

    private static func middayItem(
        from items: [OpenWeatherForecastResponse.ForecastItem],
        timezoneOffset: Int
    ) -> OpenWeatherForecastResponse.ForecastItem? {
        items.min { lhs, rhs in
            abs(Self.hourOfDay(from: lhs.dt, timezoneOffset: timezoneOffset) - 12) <
                abs(Self.hourOfDay(from: rhs.dt, timezoneOffset: timezoneOffset) - 12)
        }
    }

    private static func hourOfDay(from unixTime: Int, timezoneOffset: Int) -> Int {
        let formatter = hourValueFormatter(with: timezoneOffset)
        return Int(formatter.string(from: Date(timeIntervalSince1970: TimeInterval(unixTime)))) ?? 0
    }

    private static func weekdayFormatter(with timezoneOffset: Int) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEEE"
        formatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        return formatter
    }

    private static func dayMonthFormatter(with timezoneOffset: Int) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "MMM d"
        formatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        return formatter
    }

    private static func hourFormatter(with timezoneOffset: Int) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "ha"
        formatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        return formatter
    }

    private static func dayKeyFormatter(with timezoneOffset: Int) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        return formatter
    }

    private static func hourValueFormatter(with timezoneOffset: Int) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "H"
        formatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        return formatter
    }
}

private struct WeatherConditionStyle {
    let label: String
    let description: String
    let icon: String
}

private enum WeatherServiceError: LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case requestFailed(statusCode: Int)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Add your OpenWeather API key to the app build settings under OpenWeatherAPIKey before searching cities."
        case .invalidURL:
            return "The weather request could not be created."
        case .invalidResponse:
            return "The weather service returned an invalid response."
        case .requestFailed(let statusCode):
            return "The request failed with status code \(statusCode)."
        }
    }
}
