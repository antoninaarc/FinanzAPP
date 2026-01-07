
# 💰 FinanzApp (v3.5)

[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Framework-blue.svg)](https://developer.apple.com/xcode/swiftui/)
[![iOS](https://img.shields.io/badge/iOS-16.0%2B-brightgreen.svg)](https://apple.com)
[![License](https://img.shields.io/badge/License-MIT-lightgrey.svg)](LICENSE)

**FinanzApp** is a robust personal finance tracker built with SwiftUI, specifically tailored for the **Dutch market**. While it serves as a powerful personal expense manager, its "Freelancer Mode" unlocks specialized tools for **ZZP'ers**, automating VAT (BTW) calculations and quarterly tax savings.

<p align="center">
  <img src="https://raw.githubusercontent.com/antoninaarc/FinanzAPP/main/Screenshots/dashboard.png" width="280" alt="Main Dashboard">
  <img src="https://raw.githubusercontent.com/antoninaarc/FinanzAPP/main/Screenshots/stats.png" width="280" alt="Statistics View">
  <img src="https://raw.githubusercontent.com/antoninaarc/FinanzAPP/main/Screenshots/add_transaction.png" width="280" alt="Add Transaction">
</p>

## ✨ Key Features

### 🇳🇱 Netherlands-Specific (ZZP Features)
- **BTW Calculator:** Integrated Dutch tax rates (21%, 9%, 0%) with automatic breakdown.
- **BTW Spaarkluis (Savings Vault):** A dedicated tracker to ensure you have enough saved for your quarterly VAT filing.
- **Deadline Countdown:** Visual reminders for Belastingdienst quarterly deadlines (Jan, Apr, Jul, Oct).
- **Daily Savings Insights:** Smart suggestions on how much to save daily to meet tax targets.

### 🧠 Smart Tools
- **AI Receipt Scanning:** Powered by **Vision Framework** & **OCR** to extract amount, date, and merchant automatically.
- **Smart Categorization:** Automatic detection of categories from scanned receipts.
- **Interactive Analytics:** Animated donut charts with 3D effects and category-specific breakdowns.
- **Flexible Modes:** Switch between **Basic Mode** (Personal) and **Freelancer Mode** (Business/BTW).

### 📊 Management & Export
- **Custom Categories:** Choose from 106+ emojis and create parent-child relationships.
- **CSV Export:** Generate reports ready for your accountant.
- **Time Filtering:** View data by week, month, or custom 30-day periods.

## 📸 Screenshots

| Dashboard & VAT Vault | Statistics & Charts | Transaction Entry |
| :---: | :---: | :---: |
| ![Dashboard] | ![Stats] | ![Entry] |
| *Visual indicators for tax savings* | *Interactive category breakdown* | *Easy BTW selection* |


## 🛠️ Technical Stack

- **UI:** SwiftUI (100% Native)
- **Architecture:** MVVM (Model-View-ViewModel)
- **Frameworks:**
  - **Vision & VisionKit:** OCR and document scanning.
  - **Combine:** Reactive state management.
  - **Foundation:** Data logic and formatting.
- **Persistence:** Currently `UserDefaults` with JSON serialization (Migration to Core Data in progress).
- **Minimum iOS:** 16.0

## 📂 Project Structure

```text
FinanzApp/
├── Models/          # Data structures (Transaction, Category, UserMode)
├── Views/           # SwiftUI screens and navigation logic
├── Components/      # Reusable UI elements (BalanceCard, BTWVaultCard)
├── Utils/           # OCR Parsers, Image Pickers, and CSV Exporters
└── Assets/          # Icons, Colors, and Mock Data

👨‍💻 Author
Antonina - GitHub Profile

Disclaimer: This app is a financial tool. Always verify your tax calculations with a certified accountant or the Belastingdienst.
