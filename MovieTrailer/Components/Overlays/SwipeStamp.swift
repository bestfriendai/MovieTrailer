//
//  SwipeStamp.swift
//  MovieTrailer
//

import SwiftUI

struct SwipeStamp: View {
    let type: StampType
    let opacity: Double

    enum StampType {
        case love
        case skip
        case watchLater

        var text: String {
            switch self {
            case .love: return "LOVE"
            case .skip: return "NOPE"
            case .watchLater: return "LATER"
            }
        }

        var icon: String {
            switch self {
            case .love: return "heart.fill"
            case .skip: return "xmark"
            case .watchLater: return "bookmark.fill"
            }
        }

        var color: Color {
            switch self {
            case .love: return .green
            case .skip: return .red
            case .watchLater: return .cyan
            }
        }

        var rotation: Double {
            switch self {
            case .love: return -15
            case .skip: return 15
            case .watchLater: return 0
            }
        }

        var alignment: Alignment {
            switch self {
            case .love: return .topTrailing
            case .skip: return .topLeading
            case .watchLater: return .top
            }
        }

        var offset: CGSize {
            switch self {
            case .love: return CGSize(width: -20, height: 60)
            case .skip: return CGSize(width: 20, height: 60)
            case .watchLater: return CGSize(width: 0, height: 40)
            }
        }
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: type.icon)
                .font(.system(size: 28, weight: .bold))

            Text(type.text)
                .font(.system(size: 32, weight: .black, design: .rounded))
                .tracking(2)
        }
        .foregroundColor(type.color)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(type.color, lineWidth: 4)
                .background(type.color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        )
        .rotationEffect(.degrees(type.rotation))
        .opacity(opacity)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: opacity)
    }
}

// MARK: - Swipe Stamp Overlay Modifier

struct SwipeStampOverlay: ViewModifier {
    let swipeDirection: SwipeDirection?
    let swipeProgress: Double

    enum SwipeDirection {
        case left, right, up
    }

    func body(content: Content) -> some View {
        content.overlay(alignment: stampAlignment) {
            if let direction = swipeDirection, swipeProgress > 0.1 {
                SwipeStamp(type: stampType(for: direction), opacity: min(swipeProgress * 1.5, 1.0))
                    .offset(stampOffset)
            }
        }
    }

    private func stampType(for direction: SwipeDirection) -> SwipeStamp.StampType {
        switch direction {
        case .left: return .skip
        case .right: return .love
        case .up: return .watchLater
        }
    }

    private var stampAlignment: Alignment {
        guard let direction = swipeDirection else { return .center }
        return stampType(for: direction).alignment
    }

    private var stampOffset: CGSize {
        guard let direction = swipeDirection else { return .zero }
        return stampType(for: direction).offset
    }
}

extension View {
    func swipeStampOverlay(direction: SwipeStampOverlay.SwipeDirection?, progress: Double) -> some View {
        modifier(SwipeStampOverlay(swipeDirection: direction, swipeProgress: progress))
    }
}
