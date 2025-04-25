//
//  SwiftUIView.swift
//  SwiftUIRepresentations
//
//  Created by Eli Slade on 2025-04-22.
//

import SwiftUI

struct Menu<Label: View, Content: View>: View {
    
    @ViewBuilder var content: () -> Content
    @ViewBuilder var label: () -> Label
    
    var body: some View {
        if #available(iOS 14.0, tvOS 17.0, *) {
            SwiftUI.Menu{ content() } label: {
                label()
            }
        }
    }
    
}

#Preview {
    Menu{ EmptyView() }label: {
        Text("")
    }
}
