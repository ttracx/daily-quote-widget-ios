import SwiftUI

struct Quote: Identifiable, Codable {
    let id = UUID()
    let text: String
    let author: String
    let category: String
}

let defaultQuotes: [Quote] = [
    Quote(text: "The only way to do great work is to love what you do.", author: "Steve Jobs", category: "Work"),
    Quote(text: "Believe you can and you're halfway there.", author: "Theodore Roosevelt", category: "Motivation"),
    Quote(text: "It always seems impossible until it's done.", author: "Nelson Mandela", category: "Inspiration"),
    Quote(text: "Don't watch the clock; do what it does. Keep going.", author: "Sam Levenson", category: "Productivity"),
    Quote(text: "The future belongs to those who believe in the beauty of their dreams.", author: "Eleanor Roosevelt", category: "Dreams")
]

struct ContentView: View {
    @StateObject private var viewModel = QuoteViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Today's Quote Card
                VStack(spacing: 16) {
                    Image(systemName: "quote.opening")
                        .font(.system(size: 40))
                        .foregroundColor(.blue)
                    
                    Text(viewModel.todayQuote.text)
                        .font(.title3)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("— \(viewModel.todayQuote.author)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // Widget Preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Widget Preview")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.blue.gradient)
                        
                        VStack(spacing: 8) {
                            Text(viewModel.todayQuote.text.prefix(60) + "...")
                                .font(.caption)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                            
                            Text(viewModel.todayQuote.author)
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(height: 120)
                    .padding(.horizontal)
                }
                
                // Categories
                List {
                    Section("Quote Categories") {
                        ForEach(Array(Set(defaultQuotes.map { $0.category })), id: \.self) { category in
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(.blue)
                                Text(category)
                                Spacer()
                                if viewModel.isPro || category == "Motivation" {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                } else {
                                    Image(systemName: "lock.fill")
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Section {
                        Button(action: { viewModel.showingPaywall = true }) {
                            HStack {
                                Image(systemName: viewModel.isPro ? "checkmark.circle.fill" : "crown.fill")
                                Text(viewModel.isPro ? "Pro Active" : "Unlock All Categories - $0.99")
                                Spacer()
                            }
                            .foregroundColor(viewModel.isPro ? .green : .orange)
                        }
                        .disabled(viewModel.isPro)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Daily Quote")
            .sheet(isPresented: $viewModel.showingPaywall) {
                PaywallView(viewModel: viewModel)
            }
        }
    }
}

struct PaywallView: View {
    @ObservedObject var viewModel: QuoteViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Daily Quote Pro")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack { Image(systemName: "books.vertical").foregroundColor(.blue); Text("500+ inspirational quotes") }
                    HStack { Image(systemName: "tag").foregroundColor(.blue); Text("All categories unlocked") }
                    HStack { Image(systemName: "arrow.clockwise").foregroundColor(.blue); Text("Hourly quote updates") }
                    HStack { Image(systemName: "heart").foregroundColor(.blue); Text("Save favorite quotes") }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Text("$0.99")
                        .font(.system(size: 48, weight: .bold))
                    
                    Text("One-time purchase")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Button(action: {
                    viewModel.purchasePro()
                    dismiss()
                }) {
                    Text("Purchase Pro")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationBarItems(trailing: Button("Close") { dismiss() })
        }
    }
}
