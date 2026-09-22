import SwiftUI
import UIKit

private enum GamePhase {
    case idle
    case waiting
    case ready
    case tooSoon
    case roundDone
    case finished
}

struct ContentView: View {
    @AppStorage("bestMs") private var bestMs: Int = 0
    @State private var phase: GamePhase = .idle
    @State private var startDate = Date()
    @State private var results: [Int] = []
    @State private var pending: DispatchWorkItem?

    private let totalRounds = 5

    private var lastMs: Int { results.last ?? 0 }
    private var averageMs: Int {
        guard !results.isEmpty else { return 0 }
        return results.reduce(0, +) / results.count
    }
    private var fastestMs: Int { results.min() ?? 0 }

    var body: some View {
        Group {
            if phase == .waiting || phase == .ready {
                board
                    .contentShape(Rectangle())
                    .onTapGesture(perform: handleTap)
            } else {
                board
            }
        }
        .onDisappear { pending?.cancel() }
    }

    // MARK: - Layout

    private var board: some View {
        ZStack {
            boardColor.ignoresSafeArea()

            VStack(spacing: 20) {
                topBar
                Spacer()
                center
                Spacer()
                bottomBar
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 24)
        }
    }

    private var boardColor: Color {
        switch phase {
        case .idle, .roundDone:
            return Color(red: 0.07, green: 0.09, blue: 0.15)
        case .waiting, .tooSoon:
            return Color(red: 0.75, green: 0.11, blue: 0.11)
        case .ready:
            return Color(red: 0.10, green: 0.62, blue: 0.24)
        case .finished:
            return Color(red: 0.10, green: 0.20, blue: 0.45)
        }
    }

    private var topBar: some View {
        HStack {
            Text("REFLEKS")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
            Text(bestMs > 0 ? "Rekord \(bestMs) ms" : "Rekord: —")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.7))
        }
    }

    @ViewBuilder
    private var center: some View {
        switch phase {
        case .idle:
            VStack(spacing: 16) {
                Text("REFLEKS")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                Text("5 rund. Poczekaj, aż ekran zrobi się zielony, i dotknij go najszybciej, jak potrafisz.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.85))
            }
            primaryButton("GRAJ", action: startGame)

        case .waiting:
            VStack(spacing: 14) {
                Text("Czekaj…")
                    .font(.system(size: 64, weight: .black, design: .rounded))
                Text("Nie klikaj!")
                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            }

        case .ready:
            Text("DOTKNIJ!")
                .font(.system(size: 64, weight: .black, design: .rounded))

        case .tooSoon:
            VStack(spacing: 14) {
                Text("Za wcześnie!")
                    .font(.system(size: 48, weight: .black, design: .rounded))
                Text("Ekran musi się zrobić zielony.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            }
            primaryButton("Powtórz rundę", action: scheduleReady)

        case .roundDone:
            VStack(spacing: 14) {
                Text("\(lastMs) ms")
                    .font(.system(size: 72, weight: .black, design: .rounded))
                Text("To Twój wynik w tej rundzie.")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
            }
            primaryButton(results.count >= totalRounds ? "Zobacz wynik" : "Dalej", action: nextRound)

        case .finished:
            VStack(spacing: 14) {
                Text("Średnia: \(averageMs) ms")
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .minimumScaleFactor(0.5)
                Text("Najszybsza runda: \(fastestMs) ms\nRekord: \(bestMs > 0 ? "\(bestMs) ms" : "—")")
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.85))
            }
            primaryButton("Zagraj jeszcze raz", action: startGame)
        }
    }

    private var bottomBar: some View {
        Group {
            switch phase {
            case .waiting, .ready:
                Text("Runda \(results.count + 1) z \(totalRounds)")
            case .roundDone:
                Text("Runda \(results.count) z \(totalRounds)")
            default:
                Text("")
            }
        }
        .font(.system(size: 14, weight: .regular, design: .rounded))
        .foregroundColor(.white.opacity(0.55))
    }

    private func primaryButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 23, weight: .bold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white.opacity(0.18))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Game logic

    private func handleTap() {
        switch phase {
        case .waiting:
            pending?.cancel()
            UINotificationFeedbackGenerator().notificationOccurred(.error)
            phase = .tooSoon
        case .ready:
            let ms = Int(Date().timeIntervalSince(startDate) * 1000)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            results.append(ms)
            if bestMs == 0 || ms < bestMs {
                bestMs = ms
            }
            phase = .roundDone
        default:
            break
        }
    }

    private func startGame() {
        pending?.cancel()
        results = []
        UIImpactFeedbackGenerator().impactOccurred()
        scheduleReady()
    }

    private func scheduleReady() {
        pending?.cancel()
        phase = .waiting
        let delay = Double.random(in: 1.5...4.0)
        let work = DispatchWorkItem {
            startDate = Date()
            phase = .ready
            UIImpactFeedbackGenerator().impactOccurred()
        }
        pending = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    private func nextRound() {
        if results.count >= totalRounds {
            phase = .finished
        } else {
            scheduleReady()
        }
    }
}

#Preview {
    ContentView()
}
