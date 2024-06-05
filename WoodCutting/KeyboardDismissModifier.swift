//
//  KeyboardDismissModifier.swift
//  WoodCutting
//
//  Created by Amanada Clouser on 5/23/24.
//

import Foundation
import SwiftUI

struct KeyboardDismissModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .gesture(DragGesture().onChanged { _ in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
    }
}

extension View {
    func dismissKeyboardOnDrag() -> some View {
        self.modifier(KeyboardDismissModifier())
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
