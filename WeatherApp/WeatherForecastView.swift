//
//  WeatherForecastView.swift
//  WeatherApp
//
//  Created by Class Monitor - Class 1 on 2026/5/6.
//

import SwiftUI

struct WeatherForecastView: View {
    let forecast: [DayForecast]
    let hourly: [HourlyForecast]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("FORECAST")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white.opacity(0.78))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(hourly.prefix(6)) { hour in
                        VStack(spacing: 10) {
                            Text(hour.time)
                                .font(.system(size: 11, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.76))

                            Image(systemName: hour.icon)
                                .font(.system(size: 18))
                                .foregroundColor(.white)

                            Text("\(hour.temperature)°")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(width: 66)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.12))
                        .cornerRadius(18)
                    }
                }
            }

            VStack(spacing: 10) {
                ForEach(forecast.dropFirst().prefix(4)) { day in
                    ForecastItemView(dayForecast: day)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.14))
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
        .cornerRadius(28)
        .padding(.horizontal, 20)
    }
}

struct ForecastItemView: View {
    let dayForecast: DayForecast

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: dayForecast.icon)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                Text(dayForecast.day)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)

                Text(dayForecast.date.uppercased())
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.65))
            }

            Spacer()

            if dayForecast.precipitation > 0 {
                Text("\(dayForecast.precipitation)%")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.76))
            }

            Text("\(dayForecast.highTemp)°/\(dayForecast.lowTemp)°")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.84))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.08))
        .cornerRadius(16)
    }
}

struct DetailCardView: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)

            Text(title.uppercased())
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.68))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.1))
        .cornerRadius(18)
    }
}
