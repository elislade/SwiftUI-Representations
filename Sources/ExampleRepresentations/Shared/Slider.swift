import SwiftUI

struct Slider<Value: BinaryFloatingPoint>: View where Value.Stride: BinaryFloatingPoint {
    
    let value: Binding<Value>
    var `in`: ClosedRange<Value>? = nil
    var step: Value.Stride? = nil
    
    var body: some View {
        #if os(tvOS)
        Stepper(
            onIncrement: { value.wrappedValue += step ?? 0.1 },
            onDecrement: { value.wrappedValue -= step ?? 0.1 }
        ){
            EmptyView()
        }
        #else
        if let range = `in` {
            if let step {
                SwiftUI.Slider(value: value, in: range, step: step)
            } else {
                SwiftUI.Slider(value: value, in: range)
            }
        } else {
            SwiftUI.Slider(value: value)
        }
        #endif
    }
    
}


#Preview {
    Slider(value: .constant(0.5))
}
