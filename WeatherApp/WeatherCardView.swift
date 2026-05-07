//
//  WeatherCardView.swift
//  WeatherApp
//
//  Created by Class Monitor - Class 1 on 2026/5/6.
//

import SwiftUI

struct WeatherCardView: View {
    let weather: Weather

    var body: some View {
        VStack(spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(weather.city.uppercased())
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text(weather.description.uppercased())
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.78))
                }

                Spacer()

                Image(systemName: "gearshape.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
            }

            Text("\(weather.temperature)°")
                .font(.system(size: 78, weight: .thin, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 150, height: 150)

                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    .frame(width: 170, height: 170)

                Image(systemName: weather.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 88, height: 88)
                    .foregroundColor(iconColor)
                    .symbolRenderingMode(.multicolor)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)

            HStack(spacing: 12) {
                CompactMetricView(value: "\(weather.humidity)%", label: "Humidity")
                CompactMetricView(value: "\(weather.feelsLike)°", label: "Feels Like")
                CompactMetricView(value: "\(Int(weather.windSpeed.rounded())) km/h", label: "Wind")
            }

            VStack(spacing: 10) {
                DetailRowView(
                    icon: "gauge.medium",
                    title: "Air Pressure",
                    value: "\(weather.airPressure) hPa"
                )
                DetailRowView(
                    icon: "eye.fill",
                    title: "Visibility",
                    value: String(format: "%.1f km", weather.visibilityKilometers)
                )
                DetailRowView(
                    icon: "umbrella.fill",
                    title: "Rain Risk",
                    value: "\(weather.rainRisk)%"
                )
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.29, green: 0.73, blue: 0.96),
                    Color(red: 0.22, green: 0.60, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 34)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .cornerRadius(34)
        .shadow(color: Color.black.opacity(0.16), radius: 20, x: 0, y: 14)
        .padding(.horizontal, 20)
    }

    private var iconColor: Color {
        switch weather.condition.lowercased() {
        case "clear":
            return .yellow
        case "clouds":
            return .white
        case "rain", "drizzle":
            return .cyan
        case "thunderstorm":
            return .yellow
        case "snow":
            return .white
        default:
            return .yellow
        }
    }
}

private struct CompactMetricView: View {
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label.uppercased())
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

private struct DetailRowView: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 18)

            Text(title)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.82))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.12))
        .cornerRadius(14)
    }
}
