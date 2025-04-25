import UIKitRepresentations


struct TabBarExample: View {
    
    @Namespace private var ns
    @State private var index = 0
    let numberOfTabs: Int = 5
    
    @State private var optional: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            TabViewRepresentation(index: index){
                Color.orange.ignoresSafeArea()
                
                ScrollView {
                    Text("Scroll Content")
                        .font(.largeTitle.bold())
                        .frame(height: 1200)
                        .frame(maxWidth: .infinity)
                }
                .ignoresSafeArea()
                
                Image(systemName: "3.circle.fill")
                    .resizable()
                    .scaledToFit()
                
                OSViewController.exampleController
                
                Circle()
                    .fill(.pink)
                    .padding()
            }
            .edgesIgnoringSafeArea(.all)
            
            Divider().ignoresSafeArea()
            
            HStack(spacing: 0) {
                ForEach(1...numberOfTabs, id: \.self){ i in
                    Button(action: { index = i - 1 }){
                        Text("\(i)")
                            .font(.largeTitle.bold())
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                    }
                    .background(
                        VStack{
                            Spacer()
                            if index + 1 == i {
                                Capsule()
                                    .padding(.horizontal)
                                    .frame(height: 7)
                                    .matchedGeometryEffect(id: "s", in: ns)
                            }
                        }
                    )
                }
            }
            .animation(.bouncy, value: index)
            .buttonStyle(.plain)
            .padding()
        }
    }
    
}


extension OSViewController {
    
    static let exampleController = {
        let ctrl = OSViewController()
        let t = OSTextView(frame: .zero)
        t.translatesAutoresizingMaskIntoConstraints = false
        t.textAlignment = .center
        t.text = "View Controller"
        t.font = .systemFont(ofSize: 44)
        t[\.borderColor] = OSColor.white.cgColor
        t[\.borderWidth] = 1
        t.textColor = .white
        t.backgroundColor = .black
        ctrl.view.addSubview(t)
        t.heightAnchor.constraint(equalToConstant: 70).isActive = true
        t.widthAnchor.constraint(equalToConstant: 330).isActive = true
        t.centerXAnchor.constraint(equalTo: ctrl.view.centerXAnchor).isActive = true
        t.centerYAnchor.constraint(equalTo: ctrl.view.centerYAnchor).isActive = true
        return ctrl
    }()
    
}

#Preview("TabBar Example") {
    TabBarExample()
        .previewSize()
}
