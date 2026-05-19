//
//  ContentView.swift
//  week-1-2
//
//  Created by 11 on 2026/3/13.
//

import SwiftUI

enum WeatherTab: Hashable {
    case home
    case search
}

// MARK: - Root Tab View with Bottom Nav
struct WeatherRootView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var selectedTab: WeatherTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            WeatherHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(WeatherTab.home)

            SearchCityView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search City")
                }
                .tag(WeatherTab.search)
        }
        .environmentObject(viewModel)
    }
}

// MARK: - Home View (uses EnvironmentObject)
struct WeatherHomeView: View {
    @EnvironmentObject var viewModel: WeatherViewModel

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
                VStack(spacing: 24) {
                    // Current Weather Header
                    currentWeatherSection

                    // Next 5 hours forecast
                    hourlySection

                    // 5-Day Forecast View
                    forecastSection
                }
                .padding()
            }
        }
        .onAppear {
            if viewModel.currentTemp == nil {
                viewModel.fetchWeather() // default location only once
            }
        }
    }

    // MARK: - UI Components
    private var currentWeatherSection: some View {
        VStack(spacing: 8) {
            Text(viewModel.displayLocation)
                .font(.system(size: 34, weight: .medium))
                .foregroundColor(.white)

            if let current = viewModel.currentTemp {
                Text("\(Int(round(current)))°")
                    .font(.system(size: 76, weight: .thin))
                    .foregroundColor(.white)
            } else {
                Text("--°")
                    .font(.system(size: 76, weight: .thin))
                    .foregroundColor(.white)
            }

            Text(viewModel.currentCondition)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundColor(.white)
        }
        .padding(.top, 36)
        .padding(.bottom, 8)
    }

    private var hourlySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.white.opacity(0.9))
                Text("NEXT 5 HOURS")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.9))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 18) {
                    ForEach(viewModel.nextFiveHours) { point in
                        VStack(spacing: 8) {
                            Text(point.hourLabel)
                                .foregroundColor(.white.opacity(0.9))
                                .font(.caption)

                            Image(systemName: point.iconName)
                                .font(.title2)
                                .symbolRenderingMode(.multicolor)

                            Text("\(Int(round(point.temp)))°")
                                .foregroundColor(.white)
                                .font(.headline)
                        }
                        .padding(12)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 6)
            }
        }
        .padding(.vertical, 6)
    }

    private var forecastSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.white.opacity(0.8))
                Text("5-DAY FORECAST")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white.opacity(0.8))
            }

            VStack(spacing: 0) {
                ForEach(viewModel.forecasts) { forecast in
                    HStack {
                        Text(forecast.dayOfWeek)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 70, alignment: .leading)

                        Spacer()

                        Image(systemName: forecast.iconName)
                            .font(.system(size: 22))
                            .symbolRenderingMode(.multicolor)
                            .frame(width: 30)

                        Spacer()

                        HStack(spacing: 12) {
                            Text("\(Int(round(forecast.minTemp)))°")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 44, alignment: .trailing)

                            Capsule()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue.opacity(0.5), .orange.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .frame(width: 60, height: 4)

                            Text("\(Int(round(forecast.maxTemp)))°")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 44, alignment: .trailing)
                        }
                    }
                    .padding(.vertical, 12)

                    if forecast.id != viewModel.forecasts.last?.id {
                        Divider()
                            .background(Color.white.opacity(0.25))
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(16)
            .environment(\.colorScheme, .dark)
        }
    }
}

// MARK: - Search View
struct SearchCityView: View {
    @EnvironmentObject var viewModel: WeatherViewModel
    @Binding var selectedTab: WeatherTab
    @State private var query: String = ""
    @State private var suggestions: [GeocodingPlace] = []
    @State private var searching = false
    @State private var showError = false
    @State private var noResults = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                HStack {
                    TextField("Type a city name", text: $query)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: query) { _ in
                            searchSuggestions()
                        }

                    Button(action: search) {
                        if searching {
                            ProgressView()
                        } else {
                            Image(systemName: "magnifyingglass")
                        }
                    }
                    .disabled(query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || searching)
                }
                .padding()

                if !suggestions.isEmpty {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(suggestions) { place in
                                Button(action: {
                                    select(place: place)
                                }) {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 3) {
                                            Text(place.displayName)
                                                .font(.system(.body, design: .default))
                                                .fontWeight(.medium)
                                                .foregroundColor(.primary)
                                                .lineLimit(1)
                                            
                                            if !place.subtitle.isEmpty {
                                                Text(place.subtitle)
                                                    .font(.system(.caption, design: .default))
                                                    .foregroundColor(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 14)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(10)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxHeight: 400)
                } else if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Start typing a city name to see suggestions.")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else if noResults {
                    Text("No cities found for \(query). Try another name.")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    Text("Searching for cities...")
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }

                Spacer()
            }
            .navigationTitle("Search City")
            .alert("City not found", isPresented: $showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please try a different city name.")
            }
        }
    }

    private func searchSuggestions() {
        let city = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else {
            suggestions = []
            noResults = false
            return
        }

        viewModel.searchLocations(forCityName: city) { results in
            self.suggestions = results
            self.noResults = results.isEmpty
        }
    }

    private func select(place: GeocodingPlace) {
        searching = true
        viewModel.fetchWeather(latitude: place.latitude, longitude: place.longitude, placeName: place.displayName) { success in
            searching = false
            if success {
                query = ""
                suggestions = []
                selectedTab = .home
            } else {
                showError = true
            }
        }
    }

    private func search() {
        let city = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !city.isEmpty else { return }
        searching = true
        viewModel.fetchWeather(forCityName: city) { success in
            searching = false
            if success {
                query = ""
                selectedTab = .home
            } else {
                showError = true
            }
        }
    }
}

// MARK: - View Model (updated with hourly + search)
class WeatherViewModel: ObservableObject {
    @Published var currentTemp: Double?
    @Published var currentCondition: String = "Fetching data..."
    @Published var forecasts: [DailyForecast] = []
    @Published var nextFiveHours: [HourlyPoint] = []
    @Published var displayLocation: String = "Nanjing"

    private var isoFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    func fetchWeather() {
        fetchWeather(latitude: 32.0617, longitude: 118.7778, placeName: "Nanjing")
    }

    func fetchWeather(latitude: Double, longitude: Double, placeName: String? = nil, completion: ((Bool) -> Void)? = nil) {
        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&current_weather=true&hourly=temperature_2m,weathercode&daily=temperature_2m_max,temperature_2m_min,weathercode&timezone=Asia%2FShanghai"
        guard let url = URL(string: urlString) else { completion?(false); return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else {
                DispatchQueue.main.async { self?.loadMockData(); completion?(false) }
                return
            }

            do {
                let weatherResponse = try JSONDecoder().decode(WeatherResponseFull.self, from: data)
                DispatchQueue.main.async {
                    self.currentTemp = weatherResponse.current_weather.temperature
                    self.currentCondition = self.weatherDescription(for: weatherResponse.current_weather.weathercode)
                    self.processForecasts(weatherResponse.daily)
                    self.processHourly(weatherResponse.hourly)
                    if let name = placeName { self.displayLocation = name }
                    completion?(true)
                }
            } catch {
                DispatchQueue.main.async { self.loadMockData(); completion?(false) }
            }
        }.resume()
    }

    func searchLocations(forCityName name: String, completion: @escaping ([GeocodingPlace]) -> Void) {
        guard let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=10") else {
            DispatchQueue.main.async { completion([]) }
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion([]) }
                return
            }

            do {
                let result = try JSONDecoder().decode(GeocodingResponse.self, from: data)
                DispatchQueue.main.async { completion(result.results ?? []) }
            } catch {
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }

    func fetchWeather(forCityName name: String, completion: ((Bool) -> Void)? = nil) {
        // Use Open-Meteo geocoding
        guard let encoded = name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://geocoding-api.open-meteo.com/v1/search?name=\(encoded)&count=1") else { completion?(false); return }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self, let data = data, error == nil else { DispatchQueue.main.async { completion?(false) } ; return }

            do {
                let result = try JSONDecoder().decode(GeocodingResponse.self, from: data)
                if let place = result.results?.first {
                    DispatchQueue.main.async {
                        self.fetchWeather(latitude: place.latitude, longitude: place.longitude, placeName: place.name, completion: completion)
                    }
                } else {
                    DispatchQueue.main.async { completion?(false) }
                }
            } catch {
                DispatchQueue.main.async { completion?(false) }
            }
        }.resume()
    }

    private func processForecasts(_ daily: DailyData) {
        var newForecasts: [DailyForecast] = []
        let count = min(daily.time.count, 5)

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"

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

    private func processHourly(_ hourly: HourlyData) {
        var points: [HourlyPoint] = []

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]

        let now = Date()
        for (i, timeStr) in hourly.time.enumerated() {
            if let date = formatter.date(from: timeStr), date > now {
                let temp = hourly.temperature_2m[i]
                let code = (hourly.weathercode.indices.contains(i) ? hourly.weathercode[i] : 0)
                let hourLabel = hourLabelFrom(date)
                let point = HourlyPoint(date: date, hourLabel: hourLabel, temp: temp, iconName: weatherIcon(for: code))
                points.append(point)
                if points.count == 5 { break }
            }
        }

        // If none found (timezones etc.), fallback to first 5 entries
        if points.isEmpty {
            for i in 0..<min(5, hourly.time.count) {
                let temp = hourly.temperature_2m[i]
                let code = (hourly.weathercode.indices.contains(i) ? hourly.weathercode[i] : 0)
                let hourLabel = String(hourly.time[i].suffix(5))
                points.append(HourlyPoint(date: Date(), hourLabel: hourLabel, temp: temp, iconName: weatherIcon(for: code)))
            }
        }

        self.nextFiveHours = points
    }

    private func hourLabelFrom(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "HH:mm"
        return df.string(from: date)
    }

    // Fallback data if API goes down or there's no internet
    private func loadMockData() {
        self.currentTemp = 24.0
        self.currentCondition = "Partly Cloudy"
        self.displayLocation = "Nanjing"

        let today = Date()
        self.forecasts = [
            DailyForecast(date: today, dayOfWeek: "Today", maxTemp: 26, minTemp: 18, iconName: "cloud.sun.fill"),
            DailyForecast(date: today.addingTimeInterval(86400 * 1), dayOfWeek: "Tue", maxTemp: 28, minTemp: 20, iconName: "sun.max.fill"),
            DailyForecast(date: today.addingTimeInterval(86400 * 2), dayOfWeek: "Wed", maxTemp: 23, minTemp: 17, iconName: "cloud.rain.fill"),
            DailyForecast(date: today.addingTimeInterval(86400 * 3), dayOfWeek: "Thu", maxTemp: 21, minTemp: 15, iconName: "cloud.fill"),
            DailyForecast(date: today.addingTimeInterval(86400 * 4), dayOfWeek: "Fri", maxTemp: 24, minTemp: 16, iconName: "cloud.sun.fill")
        ]

        self.nextFiveHours = [
            HourlyPoint(date: Date().addingTimeInterval(3600 * 1), hourLabel: "01:00", temp: 24, iconName: "cloud.sun.fill"),
            HourlyPoint(date: Date().addingTimeInterval(3600 * 2), hourLabel: "02:00", temp: 23, iconName: "cloud.sun.fill"),
            HourlyPoint(date: Date().addingTimeInterval(3600 * 3), hourLabel: "03:00", temp: 22, iconName: "cloud.sun.fill"),
            HourlyPoint(date: Date().addingTimeInterval(3600 * 4), hourLabel: "04:00", temp: 21, iconName: "cloud.fill"),
            HourlyPoint(date: Date().addingTimeInterval(3600 * 5), hourLabel: "05:00", temp: 20, iconName: "cloud.rain.fill")
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

struct HourlyPoint: Identifiable {
    let id = UUID()
    let date: Date
    let hourLabel: String
    let temp: Double
    let iconName: String
}

// Open-Meteo decodable models (extended)
struct WeatherResponseFull: Codable {
    let current_weather: CurrentWeather
    let daily: DailyData
    let hourly: HourlyData
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

struct HourlyData: Codable {
    let time: [String]
    let temperature_2m: [Double]
    let weathercode: [Int]
}

// Geocoding
struct GeocodingResponse: Codable {
    let results: [GeocodingPlace]?
}
struct GeocodingPlace: Codable, Identifiable {
    var id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?

    enum CodingKeys: String, CodingKey {
        case name, latitude, longitude, country, admin1
    }

    var displayName: String {
        let parts = [name, admin1, country].compactMap { $0 }
        return parts.joined(separator: ", ")
    }

    var subtitle: String {
        if let country = country {
            return country
        }
        return ""
    }
}

// MARK: - Previews
struct WeatherRootView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherRootView()
    }
}
