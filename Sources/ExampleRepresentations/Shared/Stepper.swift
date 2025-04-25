import SwiftUI

struct Stepper<Label: View>: View {
    
    var onIncrement: (() -> Void)?
    var onDecrement: (() -> Void)?
    var label: () -> Label
    
    var body: some View {
        #if os(tvOS)
        HStack {
            label()
            
            Spacer()
            
            HStack(spacing: 16) {
                Button{ onDecrement?() } label: {
                    SwiftUI.Label{ Text("Decrement") } icon: {
                        Text("AA")
                            .hidden()
                            .overlay {
                                Image(systemName: "minus")
                                    .aspectRatio(1, contentMode: .fit)
                            }
                    }
                }
                .disabled(onDecrement == nil)
                
                Button{ onIncrement?() } label: {
                    SwiftUI.Label{ Text("Increment") } icon: {
                        Text("AA")
                            .hidden()
                            .overlay {
                                Image(systemName: "plus")
                                    .aspectRatio(1, contentMode: .fit)
                            }
                    }
                }
                .disabled(onIncrement == nil)
            }
            .labelStyle(.iconOnly)
        }
        #else
        SwiftUI.Stepper(
            onIncrement: onIncrement,
            onDecrement: onDecrement,
            label: label
        )
        #endif
    }
    
    
}


#Preview {
    Stepper(){
        Text("Stepper")
    }
}
