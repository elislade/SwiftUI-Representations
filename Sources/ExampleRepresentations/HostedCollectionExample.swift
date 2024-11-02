import HostedCollectionRepresentation


@available(iOS 16, macOS 12, *)
struct HostedCollectionExample: View {
    
    @State private var sectionCount: Int = 2
    @State private var itemCount: Int = 10
    
    @State private var aspect: Double = 1
    @State private var spacing: Double = 1
    @State private var cols: Int = 5
    @State private var pinnedHeader: Bool = false
    
    private var layout: CollectionSection.Layout {
        .init(columns: cols, spacing: spacing, isHeaderPinned: pinnedHeader)
    }
    
    struct CellView: View {
        let hue: Double
        @Binding var aspect: Double
        
        var body: some View {
            Color(
                hue: hue,
                saturation: 1,
                brightness: 1
            )
            .aspectRatio(aspect, contentMode: .fit)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HostedCollectionViewControllerRepresentation(updateDiffing: true){
                ForEach(0..<sectionCount, id: \.self){ i in
                    CollectionSection(layout: layout) {
                        ForEach(0..<itemCount, id: \.self){ i in
                            Button(action: {}){
                                CellView(
                                    hue: Double(i) / Double(itemCount),
                                    aspect: $aspect
                                )
                            }
                        }
                    } header: {
                        Text("\(i)").padding()
                    }
                }
            }
            .animation(.smooth, value: cols)
            .buttonStyle(.plain)
            .ignoresSafeArea()
            
            Divider()
            
            ScrollView {
                VStack(spacing: 0) {
                    Stepper(
                        onIncrement: { cols += 1 },
                        onDecrement: cols > 1 ? { cols -= 1 } : nil
                    ){
                        Text("Columns")
                            .font(.headline)
                    }
                    .padding()
                    
                    Divider()
                    
                    Stepper(
                        onIncrement: { aspect += 0.1 },
                        onDecrement: { aspect -= 0.1 }
                    ){
                        Text("Aspect")
                            .font(.headline)
                    }
                    .padding()
                    
                    Divider()
                    
                    Stepper(
                        onIncrement: { sectionCount += 1 },
                        onDecrement: { sectionCount -= 1 }
                    ){
                        Text("Sections")
                            .font(.headline)
                        
                        Text("\(sectionCount)")
                    }
                    .padding()
                    
                    Divider()
                    
                    Stepper(
                        onIncrement: { itemCount += 1 },
                        onDecrement: { itemCount -= 1 }
                    ){
                        Text("Items")
                            .font(.headline)
                        
                        Text("\(itemCount)")
                    }
                    .padding()
                    
                    Divider()
                    
                    VStack {
                        HStack {
                            Text("Spacing")
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(spacing)").monospacedDigit()
                        }
                        
                        Slider(value: $spacing, in: 0...30)
                    }
                    .padding()
                    
                    Divider()
                    
                    Toggle(isOn: $pinnedHeader){
                        Text("Pinned Headers")
                            .font(.headline)
                    }
                    .padding()

                }
            }
        }
    }
}

@available(iOS 16, macOS 12, *)
#Preview("Hosted Collection Example") {
    HostedCollectionExample()
}
