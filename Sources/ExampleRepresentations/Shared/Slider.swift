import SwiftUI

struct Slider<Value: BinaryFloatingPoint>: View where Value.Stride: BinaryFloatingPoint {
    
    let value: Binding<Value>
    var `in`: ClosedRange<Value>? = nil
    var step: Value? = nil
    
    var body: some View {
        #if os(tvOS)
        Stepper(
            onIncrement: { value.wrappedValue += step ?? 0.1 },
            onDecrement: { value.wrappedValue -= step ?? 0.1 }
        ){
            EmptyView()
        }
        #else
        SwiftUI.Slider(value: value)
        #endif
    }
    
}


#Preview {
    Slider(value: .constant(0.5))
}
