import UIKitRepresentations

struct CALayerExample: View {
    
    var body: some View {
        CALayerRepresentation{
            let l = CATextLayer()
            l.string = "Hello, World!"
            l.fontSize = 60
            l.alignmentMode = .center
            l.foregroundColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
            l.frame.origin.x = 100
            return l
        }
        .padding()
        .border(Color.black)
    }
    
}


#Preview("CALayer Example") {
    CALayerExample()
}
