//
//  CurrencyConverterView.swift
//  CALCULATOR
//
//  Created by 11 on 2026/3/31.
//

import SwiftUI

// MARK: - Currency Converter View

struct CurrencyConverterView: View {
    @ObservedObject var service: ExchangeRateService

    @State private var fromCurrency: Currency = availableCurrencies[0]  // USD
    @State private var toCurrency: Currency = availableCurrencies[5]    // IDR
    @State private var inputAmount: String = "1"
    @State private var showFromPicker: Bool = false
    @State private var showToPicker: Bool = false

    private var convertedAmount: String {
        guard let amount = Double(inputAmount),
              let result = service.convert(amount: amount, from: fromCurrency.id, to: toCurrency.id) else {
            return "—"
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter.string(from: NSNumber(value: result)) ?? "—"
    }

    private var rateText: String {
        guard let rate = service.convert(amount: 1, from: fromCurrency.id, to: toCurrency.id) else {
            return ""
        }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        return "1 \(fromCurrency.id) = \(formatter.string(from: NSNumber(value: rate)) ?? "—") \(toCurrency.id)"
    }

    // Number pad buttons
    private let padButtons: [[String]] = [
        ["7", "8", "9"],
        ["4", "5", "6"],
        ["1", "2", "3"],
        ["C", "0", "."],
    ]

    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 14
            let horizontalPadding: CGFloat = 16
            let availableWidth = geometry.size.width - (horizontalPadding * 2) - (spacing * 2)
            let padButtonSize: CGFloat = availableWidth / 3

            ZStack {
                Theme.background.ignoresSafeArea()

                // Subtle gradient glow
                RadialGradient(
                    gradient: Gradient(colors: [
                        Theme.operatorButton.opacity(0.06),
                        Color.clear
                    ]),
                    center: .center,
                    startRadius: 30,
                    endRadius: 350
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    // Status indicator
                    HStack {
                        Spacer()
                        if service.isLoading {
                            HStack(spacing: 6) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Theme.operatorButton))
                                    .scaleEffect(0.7)
                                Text("Updating rates...")
                                    .font(.system(size: 12))
                                    .foregroundColor(Theme.textSecondary)
                            }
                        } else if service.isOffline {
                            Text("📡 Offline rates")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.operatorButton.opacity(0.7))
                        } else if let date = service.lastUpdated {
                            Text("Updated \(timeAgo(date))")
                                .font(.system(size: 12))
                                .foregroundColor(Theme.textSecondary)
                        }
                        Spacer()
                    }
                    .padding(.bottom, 12)

                    // Exchange rate info
                    Text(rateText)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Theme.operatorButton)
                        .padding(.bottom, 20)

                    // FROM currency card
                    currencyCard(
                        label: "From",
                        currency: fromCurrency,
                        amount: formatInputDisplay(inputAmount),
                        isInput: true,
                        showPicker: $showFromPicker
                    )
                    .padding(.horizontal, horizontalPadding)

                    // Swap button
                    Button(action: swapCurrencies) {
                        ZStack {
                            Circle()
                                .fill(Theme.operatorButton)
                                .frame(width: 44, height: 44)
                                .shadow(color: Theme.operatorButton.opacity(0.4), radius: 8, y: 4)
                            Image(systemName: "arrow.up.arrow.down")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(Theme.background)
                        }
                    }
                    .padding(.vertical, 12)

                    // TO currency card
                    currencyCard(
                        label: "To",
                        currency: toCurrency,
                        amount: convertedAmount,
                        isInput: false,
                        showPicker: $showToPicker
                    )
                    .padding(.horizontal, horizontalPadding)

                    Spacer()
                        .frame(height: 24)

                    // Number pad
                    VStack(spacing: spacing) {
                        ForEach(0..<padButtons.count, id: \.self) { row in
                            HStack(spacing: spacing) {
                                ForEach(padButtons[row], id: \.self) { label in
                                    Button(action: { handlePadPress(label) }) {
                                        ZStack {
                                            Circle()
                                                .fill(label == "C" ? Theme.functionButton : Theme.numberButton)
                                                .frame(width: padButtonSize, height: padButtonSize)
                                            Circle()
                                                .fill(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Theme.glassHighlight,
                                                            Color.clear,
                                                            Color.black.opacity(0.05)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                                .frame(width: padButtonSize, height: padButtonSize)
                                            Circle()
                                                .fill(Theme.glassOverlay)
                                                .frame(width: padButtonSize, height: padButtonSize)
                                            Circle()
                                                .strokeBorder(
                                                    LinearGradient(
                                                        gradient: Gradient(colors: [
                                                            Theme.glassBorder,
                                                            Color.clear,
                                                            Theme.glassBorder.opacity(0.3)
                                                        ]),
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 0.8
                                                )
                                                .frame(width: padButtonSize, height: padButtonSize)
                                            Text(label)
                                                .font(.system(size: padButtonSize * 0.35, weight: .medium))
                                                .foregroundColor(Theme.textPrimary)
                                        }
                                        .frame(width: padButtonSize, height: padButtonSize)
                                        .shadow(color: Color.black.opacity(0.3), radius: 6, y: 3)
                                    }
                                    .buttonStyle(GlassButtonStyle())
                                }
                            }
                        }
                    }
                    .padding(.horizontal, horizontalPadding)
                    .padding(.bottom, 32)
                }
            }
        }
        .sheet(isPresented: $showFromPicker) {
            CurrencyPickerView(selected: $fromCurrency, isPresented: $showFromPicker)
        }
        .sheet(isPresented: $showToPicker) {
            CurrencyPickerView(selected: $toCurrency, isPresented: $showToPicker)
        }
    }

    // MARK: - Currency Card

    private func currencyCard(label: String, currency: Currency, amount: String, isInput: Bool, showPicker: Binding<Bool>) -> some View {
        HStack(spacing: 12) {
            // Currency selector
            Button(action: { showPicker.wrappedValue = true }) {
                HStack(spacing: 8) {
                    Text(currency.flag)
                        .font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(currency.id)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Theme.textPrimary)
                        Text(currency.name)
                            .font(.system(size: 11))
                            .foregroundColor(Theme.textSecondary)
                    }
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.textSecondary)
                }
            }

            Spacer()

            // Amount
            Text(amount)
                .font(.system(size: isInput ? 28 : 28, weight: .light))
                .foregroundColor(isInput ? Theme.textPrimary : Theme.operatorButton)
                .lineLimit(1)
                .minimumScaleFactor(0.4)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Theme.numberButton)
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Theme.glassHighlight.opacity(0.5),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Theme.glassBorder, lineWidth: 0.8)
            }
        )
        .shadow(color: Color.black.opacity(0.2), radius: 8, y: 4)
    }

    // MARK: - Pad Input

    private func handlePadPress(_ label: String) {
        switch label {
        case "C":
            inputAmount = "1"

        case ".":
            if !inputAmount.contains(".") {
                inputAmount += "."
            }

        default: // number
            if inputAmount == "0" || inputAmount == "1" {
                inputAmount = label
            } else {
                let digitCount = inputAmount.replacingOccurrences(of: ".", with: "").count
                if digitCount < 12 {
                    inputAmount += label
                }
            }
        }
    }

    private func formatInputDisplay(_ value: String) -> String {
        if value.hasSuffix(".") || value.contains(".") {
            // Show as-is during decimal input
            let parts = value.split(separator: ".", maxSplits: 1, omittingEmptySubsequences: false)
            guard let intPart = parts.first, let intVal = Int(intPart) else { return value }
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formatted = formatter.string(from: NSNumber(value: intVal)) ?? String(intPart)
            if parts.count > 1 {
                return formatted + "." + String(parts[1])
            }
            return formatted + "."
        }
        guard let num = Double(value) else { return value }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: num)) ?? value
    }

    private func swapCurrencies() {
        let temp = fromCurrency
        fromCurrency = toCurrency
        toCurrency = temp
    }

    private func timeAgo(_ date: Date) -> String {
        let seconds = Int(-date.timeIntervalSinceNow)
        if seconds < 60 { return "just now" }
        if seconds < 3600 { return "\(seconds / 60)m ago" }
        if seconds < 86400 { return "\(seconds / 3600)h ago" }
        return "\(seconds / 86400)d ago"
    }
}

// MARK: - Currency Picker

struct CurrencyPickerView: View {
    @Binding var selected: Currency
    @Binding var isPresented: Bool
    @State private var searchText: String = ""

    private var filtered: [Currency] {
        if searchText.isEmpty { return availableCurrencies }
        return availableCurrencies.filter {
            $0.id.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()

                List(filtered) { currency in
                    Button(action: {
                        selected = currency
                        isPresented = false
                    }) {
                        HStack(spacing: 12) {
                            Text(currency.flag)
                                .font(.system(size: 32))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(currency.id)
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(Theme.textPrimary)
                                Text(currency.name)
                                    .font(.system(size: 13))
                                    .foregroundColor(Theme.textSecondary)
                            }
                            Spacer()
                            if currency.id == selected.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Theme.operatorButton)
                                    .font(.system(size: 22))
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listRowBackground(Theme.numberButton)
                }
                .listStyle(.plain)
                .searchable(text: $searchText, prompt: "Search currency")
            }
            .navigationTitle("Select Currency")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { isPresented = false }
                        .foregroundColor(Theme.operatorButton)
                }
            }
        }
    }
}
