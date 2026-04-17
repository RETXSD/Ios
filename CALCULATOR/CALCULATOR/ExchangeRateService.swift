//
//  ExchangeRateService.swift
//  CALCULATOR
//
//  Created by 11 on 2026/3/31.
//

import Foundation

// MARK: - Currency Model

struct Currency: Identifiable, Hashable {
    let id: String  // currency code e.g. "USD"
    let name: String
    let flag: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: Currency, rhs: Currency) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Available Currencies

let availableCurrencies: [Currency] = [
    Currency(id: "USD", name: "US Dollar", flag: "🇺🇸"),
    Currency(id: "EUR", name: "Euro", flag: "🇪🇺"),
    Currency(id: "GBP", name: "British Pound", flag: "🇬🇧"),
    Currency(id: "JPY", name: "Japanese Yen", flag: "🇯🇵"),
    Currency(id: "CNY", name: "Chinese Yuan", flag: "🇨🇳"),
    Currency(id: "IDR", name: "Indonesian Rupiah", flag: "🇮🇩"),
    Currency(id: "SGD", name: "Singapore Dollar", flag: "🇸🇬"),
    Currency(id: "AUD", name: "Australian Dollar", flag: "🇦🇺"),
    Currency(id: "CAD", name: "Canadian Dollar", flag: "🇨🇦"),
    Currency(id: "CHF", name: "Swiss Franc", flag: "🇨🇭"),
    Currency(id: "KRW", name: "South Korean Won", flag: "🇰🇷"),
    Currency(id: "THB", name: "Thai Baht", flag: "🇹🇭"),
    Currency(id: "MYR", name: "Malaysian Ringgit", flag: "🇲🇾"),
    Currency(id: "PHP", name: "Philippine Peso", flag: "🇵🇭"),
    Currency(id: "INR", name: "Indian Rupee", flag: "🇮🇳"),
    Currency(id: "TWD", name: "Taiwan Dollar", flag: "🇹🇼"),
    Currency(id: "HKD", name: "Hong Kong Dollar", flag: "🇭🇰"),
    Currency(id: "NZD", name: "New Zealand Dollar", flag: "🇳🇿"),
    Currency(id: "AED", name: "UAE Dirham", flag: "🇦🇪"),
    Currency(id: "SAR", name: "Saudi Riyal", flag: "🇸🇦"),
]

// MARK: - Exchange Rate Service

class ExchangeRateService: ObservableObject {
    @Published var rates: [String: Double] = [:]
    @Published var isLoading: Bool = false
    @Published var lastUpdated: Date? = nil
    @Published var isOffline: Bool = false

    private let fallbackRates: [String: Double] = [
        // Rates relative to USD (approximate as of 2026)
        "USD": 1.0,
        "EUR": 0.92,
        "GBP": 0.79,
        "JPY": 149.50,
        "CNY": 7.24,
        "IDR": 15850.0,
        "SGD": 1.34,
        "AUD": 1.53,
        "CAD": 1.36,
        "CHF": 0.88,
        "KRW": 1330.0,
        "THB": 35.20,
        "MYR": 4.72,
        "PHP": 56.50,
        "INR": 83.40,
        "TWD": 31.80,
        "HKD": 7.82,
        "NZD": 1.64,
        "AED": 3.67,
        "SAR": 3.75,
    ]

    init() {
        loadCachedRates()
        fetchRates()
    }

    // MARK: - Convert

    func convert(amount: Double, from: String, to: String) -> Double? {
        let activeRates = rates.isEmpty ? fallbackRates : rates
        guard let fromRate = activeRates[from],
              let toRate = activeRates[to],
              fromRate > 0 else { return nil }
        return amount * (toRate / fromRate)
    }

    // MARK: - Fetch from API

    func fetchRates() {
        isLoading = true
        guard let url = URL(string: "https://open.er-api.com/v6/latest/USD") else {
            useFallback()
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false

                if let error = error {
                    print("Exchange rate fetch error: \(error.localizedDescription)")
                    self?.useFallback()
                    return
                }

                guard let data = data else {
                    self?.useFallback()
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let ratesDict = json["rates"] as? [String: Double] {
                        self?.rates = ratesDict
                        self?.lastUpdated = Date()
                        self?.isOffline = false
                        self?.cacheRates(ratesDict)
                    } else {
                        self?.useFallback()
                    }
                } catch {
                    self?.useFallback()
                }
            }
        }.resume()
    }

    // MARK: - Fallback & Cache

    private func useFallback() {
        if rates.isEmpty {
            rates = fallbackRates
            isOffline = true
        }
        isLoading = false
    }

    private func cacheRates(_ rates: [String: Double]) {
        UserDefaults.standard.set(rates, forKey: "cached_exchange_rates")
        UserDefaults.standard.set(Date(), forKey: "cached_rates_date")
    }

    private func loadCachedRates() {
        if let cached = UserDefaults.standard.dictionary(forKey: "cached_exchange_rates") as? [String: Double] {
            rates = cached
            lastUpdated = UserDefaults.standard.object(forKey: "cached_rates_date") as? Date
        } else {
            rates = fallbackRates
            isOffline = true
        }
    }
}
