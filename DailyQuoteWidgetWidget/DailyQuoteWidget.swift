import WidgetKit
import SwiftUI

struct Quote: Codable {
    let text: String
    let author: String
}

struct QuoteProvider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: Quote(text: "Stay positive, work hard, make it happen.", author: "Unknown"))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> ()) {
        let quote = loadQuote()
        let entry = QuoteEntry(date: Date(), quote: quote)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let quote = loadQuote()
        let currentDate = Date()
        
        var entries: [QuoteEntry] = []
        for hourOffset in 0..<24 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            entries.append(QuoteEntry(date: entryDate, quote: quote))
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    private func loadQuote() -> Quote {
        let defaults = UserDefaults(suiteName: "group.com.yourname.dailyquotewidget")
        if let data = defaults?.data(forKey: "todayQuote"),
           let quote = try? JSONDecoder().decode(Quote.self, from: data) {
            return quote
        }
        return Quote(text: "The best time to plant a tree was 20 years ago. The second best time is now.", author: "Chinese Proverb")
    }
}

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: Quote
}

struct DailyQuoteWidgetEntryView : View {
    var entry: QuoteProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            ContainerRelativeShape()
                .fill(Color.indigo.gradient)
            
            VStack(spacing: family == .systemSmall ? 4 : 8) {
                Image(systemName: "quote.opening")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                
                Text(entry.quote.text)
                    .font(family == .systemSmall ? .caption2 : .caption)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(family == .systemSmall ? 3 : 5)
                    .padding(.horizontal, 8)
                
                Text("— \(entry.quote.author)")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
        }
    }
}

@main
struct DailyQuoteWidget: Widget {
    let kind: String = "DailyQuoteWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteProvider()) { entry in
            DailyQuoteWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Quote")
        .description("Inspirational quotes on your Home Screen")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
