import SwiftUI
import WidgetKit

class QuoteViewModel: ObservableObject {
    @Published var todayQuote: Quote
    @Published var isPro = false
    @Published var showingPaywall = false
    
    private let defaults = UserDefaults(suiteName: "group.com.yourname.dailyquotewidget")
    private let quoteKey = "todayQuote"
    private let proKey = "isProUser"
    private let lastUpdateKey = "lastQuoteUpdate"
    
    init() {
        isPro = defaults?.bool(forKey: proKey) ?? false
        
        // Check if we need a new quote (daily)
        let lastUpdate = defaults?.object(forKey: lastUpdateKey) as? Date ?? Date.distantPast
        let calendar = Calendar.current
        
        if !calendar.isDateInToday(lastUpdate) || defaults?.data(forKey: quoteKey) == nil {
            todayQuote = defaultQuotes.randomElement()!
            saveQuote()
            defaults?.set(Date(), forKey: lastUpdateKey)
        } else if let data = defaults?.data(forKey: quoteKey),
                  let saved = try? JSONDecoder().decode(Quote.self, from: data) {
            todayQuote = saved
        } else {
            todayQuote = defaultQuotes.first!
        }
        
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func saveQuote() {
        if let encoded = try? JSONEncoder().encode(todayQuote) {
            defaults?.set(encoded, forKey: quoteKey)
        }
    }
    
    func purchasePro() {
        isPro = true
        defaults?.set(true, forKey: proKey)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
