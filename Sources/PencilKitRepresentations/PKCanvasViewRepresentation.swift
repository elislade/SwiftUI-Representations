#if canImport(PencilKit) && canImport(UIKit)

import SwiftUI
import PencilKit

public struct PKCanvasViewRepresentation  {
    
    public typealias Drawing = PKDrawing
    
    let drawing: Binding<Drawing>
    let drawingPolicy: PKCanvasViewDrawingPolicy
    let isRulerActive: Bool
    
    public init(
        drawing: Binding<Drawing>,
        policy: PKCanvasViewDrawingPolicy = .anyInput,
        isRulerActive: Bool = false
    ) {
        self.drawing = drawing
        self.drawingPolicy = policy
        self.isRulerActive = isRulerActive
    }
    
    private func sync(view: PKCanvasView) {
        if #available(iOS 14.0, *) {
            view.drawingPolicy = drawingPolicy
        }
        view.drawing = drawing.wrappedValue
        view.isRulerActive = isRulerActive
    }
    
    public func makeCoordinator() -> Coordinator {
        Coordinator({ drawing.wrappedValue = $0 })
    }
    
    public class Coordinator: NSObject, PKCanvasViewDelegate {
        
        var didDraw: (Drawing) -> Void
        
        public init(_ didDraw: @escaping (Drawing) -> Void) {
            self.didDraw = didDraw
        }
        
        public func canvasViewDidFinishRendering(_ canvasView: PKCanvasView) {
            
        }
        
        public func canvasViewDidEndUsingTool(_ canvasView: PKCanvasView) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.didDraw(canvasView.drawing)
            }
        }
        
    }
}


extension PKCanvasViewRepresentation: UIViewRepresentable {
    
    public func makeUIView(context: Context) -> PKCanvasView {
        let view = PKCanvasView()
        view.backgroundColor = .clear
        view.drawingGestureRecognizer.delaysTouchesBegan = true
        view.delegate = context.coordinator
        sync(view: view)
        return view
    }
    
    public func updateUIView(_ uiView: PKCanvasView, context: Context) {
        sync(view: uiView)
    }
    
}

#endif
