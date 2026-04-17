//
//  ContentView.swift
//  week-1-2
//
//  Created by 11 on 2026/3/13.
//

import SwiftUI

// MARK: - Main View
struct WeatherHomeView: View {
    @StateObject private var viewModel = WeatherViewModel()

    var body: some View {
        ZStack {
            // Background Gradient representing sky
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.blue.opacity(0.4)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Current Weather Header
                    currentWeatherSection
                    
                    // 5-Day Forecast View
                    forecastSection
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.fetchWeather()
        }
    }
    
    // MARK: - UI Components
    private var currentWeatherSection: some View {
        VStack(spacing: 8) {
            Text("Nanjing")
                .font(.system(size: 38, weight: .medium, design: .default))
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)

            if let current = viewModel.currentTemp {
                Text("\(Int(round(current)))°")
                    .font(.system(size: 80, weight: .thin, design: .default))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            } else {
                Text("--°")
                    .font(.system(size: 80, weight: .thin, design: .default))
                    .foregroundColor(.white)
            }

            Text(viewModel.currentCondition)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .padding(.top, 40)
        .padding(.bottom, 20)
    }

    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white.opacity(0.8))
                Text("5-DAY FORECAST")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 10)

            VStack(spacing: 0) {
                ForEach(viewModel.forecasts) { forecast in
                    HStack {
                        Text(forecast.dayOfWeek)
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 60, alignment: .leading)

                        Spacer()

                        Image(systemName: forecast.iconName)
                            .font(.system(size: 22))
                            .symbolRenderingMode(.multicolor)
                            .frame(width: 30)

                        Spacer()

                        HStack(spacing: 12) {
                            Text("\(Int(round(forecast.minTemp)))°")
                                .font(.system(size: 20, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                                .frame(width: 40, alignment: .trailing)
                            
                            // Simple visual progress bar representing temp range
                            Capsule()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.5), .orange.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: 60, height: 4)
                            
                            Text("\(Int(round(forecast.maxTemp)))°")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 40, alignment: .trailing)
                        }
                    }
                    .padding(.vertical, 14)

                    // Add divider between rows except the last one
                    if forecast.id != viewModel.forecasts.last?.id {
                        Divider()
                            .background(Color.white.opacity(0.3))
                    }
                }
            }
            .padding()
            // Glassmorphism effect
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .environment(\.colorScheme, .dark) // Forces the material to look nice with our color
        }
    }
}

// MARK: - View Model
class WeatherViewModel: ObservableObject {
    @Published var currentTemp: Double?
    @Published var currentCondition: String = "Fetching data..."
    @Published var forecasts: [DailyForecast] = []

    func fetchWeather() {
        // Nanjing Coordinates: Lat 32.0617, Lon 118.7778
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=32.0617&longitude=118.7778&current_weather=true&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=Asia%2FShanghai"
        
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async { self?.loadMockData() } // Fallback to mock on error
                return
            }

            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponse.self, from: data)
                
                DispatchQueue.main.async {
                    self.currentTemp = weatherResponse.current_weather.temperature
                    self.currentCondition = self.weatherDescription(for: weatherResponse.current_weather.weathercode)
                    self.processForecasts(weatherResponse.daily)
                }
            } catch {
                DispatchQueue.main.async { self.loadMockData() }
            }
        }.resume()
    }

    private func processForecasts(_ daily: DailyData) {
        var newForecasts: [DailyForecast] = []
        let count = min(daily.time.count, 5) // Fetch first 5 days

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE" // Returns "Mon", "Tue" etc.

        for i in 0..<count {
            guard let date = formatter.date(from: daily.time[i]) else { continue }
            let isToday = Calendar.current.isDateInToday(date)
            let dayString = isToday ? "Today" : dayFormatter.string(from: date)

            let forecast = DailyForecast(
                date: date,
                dayOfWeek: dayString,
                maxTemp: daily.temperature_2m_max[i],
                minTemp: daily.temperature_2m_min[i],
                iconName: weatherIcon(for: daily.weathercode[i])
            )
            newForecasts.append(forecast)
        }
        self.forecasts = newForecasts
    }

    // Fallback data if API goes down or there's no internet
    private func loadMockData() {
        self.currentTemp = 24.0
        self.currentCondition = "Partly Cloudy"

        let today = Date()
        self.forecasts = [
            DailyForecast(date: today, dayOfWeek: "Today", maxTemp: 26, minTemp: 18, iconName: "cloud.sun.fill"),
            DailyForecast(date: today.addingTimeInterval(86400 * 1), dayOfWeek: "Tue", maxTemp: 28, minTemp: 20, iconName: "sun.max.fill"),
            DailyForecast(date: today.addingTimeInterval(86400 * 2), dayOfWeek: "Wed", maxTemp: 23, minTemp: 17, iconName: "cloud.rain.fill"),
            DailyForecast(date: today.addingTimeInterval(86400 * 3), dayOfWeek: "Thu", maxTemp: 21, minTemp: 15, iconName: "cloud.fill"),
            DailyForecast(date: today.addingTimeInterval(86400 * 4), dayOfWeek: "Fri", maxTemp: 24, minTemp: 16, iconName: "cloud.sun.fill")
        ]
    }

    // WMO Weather interpretation codes
    private func weatherDescription(for code: Int) -> String {
        switch code {
        case 0: return "Clear Sky"
        case 1...3: return "Partly Cloudy"
        case 45, 48: return "Fog"
        case 51...55, 61...65, 80...82: return "Rain"
        case 71...75, 85...86: return "Snow"
        case 95...99: return "Thunderstorm"
        default: return "Unknown"
        }
    }

    private func weatherIcon(for code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill"
        case 1...3: return "cloud.sun.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51...55, 61...65, 80...82: return "cloud.rain.fill"
        case 71...75, 85...86: return "snowflake"
        case 95...99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }
}

// MARK: - Data Models
struct DailyForecast: Identifiable {
    let id = UUID()
    let date: Date
    let dayOfWeek: String
    let maxTemp: Double
    let minTemp: Double
    let iconName: String
}

// Open-Meteo decodable models
struct WeatherResponse: Codable {
    let current_weather: CurrentWeather
    let daily: DailyData
}

struct CurrentWeather: Codable {
    let temperature: Double
    let weathercode: Int
}

struct DailyData: Codable {
    let time: [String]
    let temperature_2m_max: [Double]
    let temperature_2m_min: [Double]
    let weathercode: [Int]
}

// MARK: - Previews
struct WeatherHomeView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherHomeView()
    }
}
