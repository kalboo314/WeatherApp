# WeatherApp

A beautiful and functional iOS weather application built with SwiftUI. Get real-time weather information, detailed forecasts, and search for cities worldwide.

## Features

- **Current Weather Display**: View real-time weather conditions including:
  - Current temperature and "feels like" temperature
  - Weather condition and description
  - Humidity, wind speed, and air pressure
  - Visibility and rain risk
  - Weather condition icons

- **Weather Forecasts**: 
  - Daily forecast with high/low temperatures
  - Hourly forecast for detailed weather trends
  - Precipitation information

- **City Search**: 
  - Search for cities with auto-suggestions
  - Real-time search results as you type
  - Quick city selection for instant weather updates

- **Intuitive UI**:
  - Clean and modern interface
  - Weather cards with organized information
  - Search bar with results dropdown
  - Responsive design

## Project Structure

```
WeatherApp/
├── Models.swift              # Data models (Weather, DayForecast, HourlyForecast)
├── WeatherService.swift      # API service for weather data and city search
├── ContentView.swift         # Main app view
├── SearchBarView.swift       # Search bar component
├── WeatherCardView.swift     # Weather display card component
├── WeatherForecastView.swift # Forecast display component
├── UIHelpers.swift           # Helper functions for UI
├── WeatherAppApp.swift       # App entry point
└── Assets.xcassets/          # Images and app icons
```

## Technical Details

### Architecture
- **MVVM Pattern**: Uses ObservableObject and @Published for reactive data binding
- **SwiftUI**: Modern declarative UI framework
- **Async/Await**: Non-blocking API calls

### Key Components
- **WeatherService**: Handles all API requests and city search functionality
- **Models**: Codable structs for Weather, DayForecast, and HourlyForecast
- **UI Components**: Modular SwiftUI views for reusability

### Data Models

**Weather**: Contains current weather data including temperature, conditions, humidity, wind speed, and forecast arrays

**DayForecast**: Daily forecast with high/low temperatures, condition, and precipitation

**HourlyForecast**: Hourly forecast with time-based weather information

## Requirements

- iOS 14.0 or later
- Xcode 13.0 or later
- Swift 5.5+

## Installation

1. Clone the repository:
```bash
git clone https://github.com/kalboo314/WeatherApp.git
```

2. Open the project in Xcode:
```bash
cd WeatherApp
open WeatherApp.xcodeproj
```

3. Build and run on the iOS Simulator or a physical device

## Usage

1. Launch the app
2. The app displays the current location's weather (if permission is granted)
3. Use the search bar to find weather for other cities
4. Tap on a city from the search results to view its weather
5. Scroll to see detailed forecasts and hourly information

## Testing

The project includes test suites:
- **WeatherAppTests**: Unit tests
- **WeatherAppUITests**: UI tests

Run tests using Xcode's Test Navigator or the command line:
```bash
xcodebuild test -scheme WeatherApp
```

## API Integration

The app fetches weather data from a weather API service. The WeatherService class handles:
- Current weather requests
- Forecast data retrieval
- City search and validation

## License

This project is open source and available under the MIT License.

## Author

Created by Class Monitor - Class 1 (May 2026)

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest new features
- Submit pull requests

For major changes, please open an issue first to discuss proposed changes.
