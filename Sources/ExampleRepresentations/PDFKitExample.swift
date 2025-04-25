import PDFKitRepresentations


struct PDFKitExample: View {
    
    @StateObject private var view = PDFViewObservable()
    
    var body: some View {
        VStack(spacing: 0){
            PDFViewRepresentation(view)
                .onAppear{
                    view.document = PDFDocument(url: .appleEnvironment2024PDF)!
                }
            
            Divider().edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 16) {
                HStack(spacing: 0) {
                    Button{ view.goToPreviousPage(nil) } label: {
                        Label("Previous Page", systemImage: "arrow.left")
                            .font(.system(size: 28).bold())
                    }
                    .disabled(!view.canGoToPreviousPage)
                    
                    Spacer(minLength: 10)
                    
                    HStack {
                        Text("\(view.currentPageIndex)")
                            .font(.body.weight(.bold).monospacedDigit())
                        
                        Text("of").opacity(0.6)
                        
                        Text("\(view.pageCount)")
                            .font(.body.weight(.bold).monospacedDigit())
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel(Text("Page"))
                    
                    Spacer(minLength: 10)
                    
                    Button{ view.goToNextPage(nil) } label: {
                        Label("Next Page", systemImage: "arrow.right")
                            .font(.system(size: 28).bold())
                    }
                    .disabled(!view.canGoToNextPage)
                }
                .labelStyle(.iconOnly)
            }
            .padding()
        }
    }
}


#Preview("PDFKit Example"){
    PDFKitExample()
        .previewSize()
}
