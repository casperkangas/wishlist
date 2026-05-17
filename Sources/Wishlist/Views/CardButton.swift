//  Views/CardButton.swift
//  Shared interactive chip used by WishCardView and TrashedCardView.

import SwiftUI

struct CardButton: View {
    let tint: Color
    var bordered: Bool = false
    let action: () -> Void
    let label: AnyView

    @State private var isHovered = false
    @State private var isPressed = false

    init(tint: Color, bordered: Bool = false, action: @escaping () -> Void, @ViewBuilder label: () -> some View) {
        self.tint     = tint
        self.bordered = bordered
        self.action   = action
        self.label    = AnyView(label())
    }

    var body: some View {
        label
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(isHovered ? tint.opacity(0.18) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(bordered ? tint.opacity(0.45) : Color.clear, lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.93 : 1.0)
            .animation(.easeOut(duration: 0.10), value: isHovered)
            .animation(.easeOut(duration: 0.06), value: isPressed)
            .onHover { isHovered = $0 }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in if !isPressed { isPressed = true } }
                    .onEnded   { _ in isPressed = false; action() }
            )
            .contentShape(Rectangle())
    }
}
