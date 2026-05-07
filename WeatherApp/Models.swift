//
//  Models.swift
//  WeatherApp
//
//  Created by Class Monitor - Class 1 on 2026/5/6.
//

import Foundation

struct Weather: Identifiable, Codable {
    let id = UUID()
    let city: String
    let temperature: Int
    let condition: String
    let description: String
    let humidity: Int
    let windSpeed: Double
    let feelsLike: Int
    let airPressure: Int
    let visibilityKilometers: Double
    let rainRisk: Int
    let icon: String
    let forecast: [DayForecast]
    let hourly: [HourlyForecast]

    enum CodingKeys: String, CodingKey {
        case city, temperature, condition, description, humidity, windSpeed, feelsLike, airPressure, visibilityKilometers, rainRisk, icon, forecast, hourly
    }
}

struct DayForecast: Identifiable, Codable {
    let id = UUID()
    let day: String
    let date: String
    let highTemp: Int
    let lowTemp: Int
    let condition: String
    let icon: String
    let precipitation: Int

    enum CodingKeys: String, CodingKey {
        case day, date, highTemp, lowTemp, condition, icon, precipitation
    }
}

struct HourlyForecast: Identifiable, Codable {
    let id = UUID()
    let time: String
    let temperature: Int
    let condition: String
    let icon: String

    enum CodingKeys: String, CodingKey {
        case time, temperature, condition, icon
    }
}

struct CitySearchResult: Identifiable, Hashable {
    let name: String
    let state: String?
    let country: String
    let latitude: Double
    let longitude: Double

    var id: String {
        "\(name)-\(country)-\(latitude)-\(longitude)"
    }

    var displayName: String {
        [name, state, country]
            .compactMap { value in
                guard let value, !value.isEmpty else { return nil }
                return value
            }
            .joined(separator: ", ")
    }
}

struct OpenWeatherGeocodingResult: Decodable {
    let name: String
    let localNames: [String: String]?
    let lat: Double
    let lon: Double
    let country: String
    let state: String?

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat
        case lon
        case country
        case state
    }
}

struct OpenWeatherCurrentResponse: Decodable {
    let dt: Int
    let timezone: Int
    let name: String
    let weather: [WeatherEntry]
    let main: Main
    let wind: Wind

    struct Main: Decodable {
        let temp: Double
        let feelsLike: Double
        let humidity: Int
        let pressure: Int

        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case humidity
            case pressure
        }
    }

    let visibility: Int

    struct Wind: Decodable {
        let speed: Double
    }
}

struct OpenWeatherForecastResponse: Decodable {
    let list: [ForecastItem]
    let city: City

    struct ForecastItem: Decodable {
        let dt: Int
        let main: Main
        let weather: [WeatherEntry]
        let pop: Double

        struct Main: Decodable {
            let temp: Double
            let tempMin: Double
            let tempMax: Double

            enum CodingKeys: String, CodingKey {
                case temp
                case tempMin = "temp_min"
                case tempMax = "temp_max"
            }
        }
    }

    struct City: Decodable {
        let timezone: Int
    }
}

struct WeatherEntry: Decodable {
    let main: String
    let description: String
    let icon: String
}
