import HostedCollectionRepresentation


@available(iOS 16, macOS 12, *)
struct HostedCollectionExample: View {
    
    struct Section: Equatable {
        var name: String
        var layout: CollectionSection.Layout
        var colors: [Color]
        
        init(
            name: String = UUID().uuidString,
            layout: CollectionSection.Layout = .init(pinHeader: true),
            colors: [Color] = [.new(), .new(), .new(), .new()]
        ) {
            self.name = name
            self.layout = layout
            self.colors = colors
        }
        
    }
    
    @State private var sectionIndex: Int = 0
    @State private var sections: [Section] = [.init(), .init()]
    
    private var header: some View {
        Stepper(
            onIncrement: { sections.append(.init()) },
            onDecrement: sections.isEmpty ? nil : { sections.removeLast() }
        ){
            Menu {
                Picker(selection: $sectionIndex){
                    ForEach(sections.indices, id: \.self){
                        Text("Section \($0 + 1)")
                            #if os(iOS)
                            .font(.largeTitle.weight(.bold))
                            #endif
                            .tag($0)
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
            } label: {
                Text("Section \(sectionIndex + 1)")
                    #if os(iOS)
                    .font(.largeTitle.weight(.bold).monospacedDigit())
                    .contentTransition(.numericText())
                    #endif
                    .fixedSize()
                
                Image(systemName: "chevron.down.circle.fill")
                    .symbolRenderingMode(.hierarchical)
                    .font(.title2.weight(.bold))
            }
        }
        .padding()
    }
    
    private func binding(for index: Int) -> Binding<Section> {
        _sections.projectedValue[index]
    }
    
    var body: some View {
        GeometryReader { inner in
            HostedCollectionRepresentation(
                updateDiffing: true,
                insets: inner.safeAreaInsets,
                sectionIndex: $sectionIndex.animation(.smooth)
            ){
                ForEach(sections.indices, id: \.self){ index in
                    let section = sections[index]
                    CollectionSection(layout: section.layout) {
                        ForEach(section.colors){ color in
                            Button(action: {
                                sections[index].colors.removeAll(where: { $0 == color })
                            }){
                                color
                                   .aspectRatio(1, contentMode: .fit)
                           }
                           .buttonStyle(.plain)
                        }
                        
                        Button(action: { sections[index].colors.append(.new()) }){
                            Color.gray
                                .opacity(0.2)
                                .aspectRatio(1, contentMode: .fit)
                                .overlay {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60)
                                }
                        }
                        .buttonStyle(.plain)
                        .id("Add")
                   } header: {
                       SectionHeader(section: binding(for: index))
                   }
                }
            }
            .ignoresSafeArea()
        }
        .safeAreaInset(edge: .top, spacing: 0){
            header.background(.regularMaterial)
        }

    }
    
    
    struct SectionHeader: View {
        
        @State private var isPresented = false
        @Binding var section: Section
        
        var body: some View {
            HStack {
                TextField("Section Name", text: $section.name)
                    .font(.title2.weight(.bold))
                
                Spacer()
                
                Button("Edit"){ isPresented.toggle() }
            }
            .lineLimit(1)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.regularMaterial)
            .sheet(isPresented: $isPresented){
                if #available(iOS 16.4, macOS 13.3, tvOS 16.4, watchOS 9.4, *) {
                    SectionLayoutEditor(layout: $section.layout)
                        .presentationDetents([.height(340)])
                        .presentationBackground(.thickMaterial)
                } else {
                    SectionLayoutEditor(layout: $section.layout)
                    #if os(iOS)
                        .presentationDetents([.height(340)])
                    #endif
                }
            }
        }
    }
    
    
    struct SectionLayoutEditor: View {
        
        @Environment(\.dismiss) private var dismiss
        @Binding var layout: CollectionSection.Layout
        
        var body: some View {
            VStack(spacing: 0) {
                HStack {
                    Text("Layout")
                    Spacer()
                    Button(action: { dismiss() }){
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                    }
                }
                .font(.title.bold())
                .padding()
                
                Divider().ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        Toggle(isOn: $layout.pinHeader){
                            Text("Pinned Headers")
                                .font(.headline)
                        }
                        .padding()
                        
                        Divider()
                        
                        ColumnGroup(columns: $layout.columns)
                            .padding()
     
                        Divider()
                        
                        SpacingGroup(spacing: $layout.spacing)
                            .padding()
                        
                        Divider()
                        
                        InsetGroup(insets: $layout.insets)
                            .padding()
                    }
                }
            }
        }
        
        
        struct ColumnGroup: View {
            
            @Binding var columns: Int
            
            var body: some View {
                Stepper(
                    onIncrement: { columns += 1 },
                    onDecrement: columns >= 1 ? { columns -= 1 } : nil
                ){
                    Text("Columns")
                        .font(.headline)
                }
            }
            
        }
        
        
        struct InsetGroup: View {
            
            @Binding var insets: EdgeInsets
        
            var body: some View {
                VStack {
                    HStack {
                        Text("Insets")
                            .font(.headline)
                        Spacer()
                    }
                    HStack {
                        Text("Top")
                            .font(.footnote.bold())
                            .opacity(0.6)
                            .frame(width: 60, alignment: .leading)
                        
                        Slider(value: $insets.top, in: 0...100)
                    }
                    HStack {
                        Text("Bottom")
                            .font(.footnote.bold())
                            .opacity(0.6)
                            .frame(width: 60, alignment: .leading)
                        
                        Slider(value: $insets.bottom, in: 0...100)
                    }
                    HStack {
                        Text("Leading")
                            .font(.footnote.bold())
                            .opacity(0.6)
                            .frame(width: 60, alignment: .leading)
                        
                        Slider(value: $insets.leading, in: 0...100)
                    }
                    HStack {
                        Text("Trailing")
                            .font(.footnote.bold())
                            .opacity(0.6)
                            .frame(width: 60, alignment: .leading)
                        
                        Slider(value: $insets.trailing, in: 0...100)
                    }
                }
            }
        }
    
        
        struct SpacingGroup: View {
            
            @Binding var spacing: Double
            
            var body: some View {
                VStack {
                    HStack {
                        Text("Spacing")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(Int(spacing))").monospacedDigit()
                    }
                    
                    Slider(value: $spacing, in: 0...30, step: 1)
                }
            }
        }
        
    }
    
}


@available(iOS 16, macOS 12, *)
#Preview("Hosted Collection Example") {
    HostedCollectionExample()
        .previewSize()
}


extension Color: @retroactive Identifiable {
    public var id: Int { hashValue }
    
    static func new() -> Self {
        .init(hue: .random(in: 0...1), saturation: .random(in: 0...1), brightness: 1)
    }
}
