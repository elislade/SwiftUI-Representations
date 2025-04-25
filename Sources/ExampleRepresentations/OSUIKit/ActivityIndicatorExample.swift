import UIKitRepresentations


struct ActivityIndicatorExample: View {
    
    #if !os(tvOS)
    @State private var size: ControlSize = .regular
    #endif
    
    var body: some View {
        VStack {
            ZStack {
                Color.clear
                ActivityIndicatorViewRepresentation()
                    #if !os(tvOS)
                    .controlSize(size)
                    #endif
            
            }
            
            #if !os(tvOS)
            HStack {
                Text("Control Size")
                    .font(.headline)
                
                Spacer()
                
                Picker(selection: $size) {
                    ForEach(ControlSize.allCases, id: \.self) { size in
                        Text("\(size)".capitalized).tag(size)
                    }
                } label: {
                    EmptyView()
                }
                .frame(width: 120)
            }
            .padding()
            #endif
        }
    }
    
}


#Preview("Activity Indication Example") {
    ActivityIndicatorExample()
        .previewSize()
}
