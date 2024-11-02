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
                    Button(action: { view.goToPreviousPage(nil) }){
                        Image(systemName: "arrow.left")
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
                    
                    Spacer(minLength: 10)
                    
                    Button(action: { view.goToNextPage(nil) }){
                        Image(systemName: "arrow.right")
                            .font(.system(size: 28).bold())
                    }
                    .disabled(!view.canGoToNextPage)
                }
            }
            .padding()
        }
    }
}


#Preview("PDFKit Example"){
    PDFKitExample()
}
