import SwiftUI
import UIKit
import PencilKit

/// A bare drawing surface: no tool picker, no undo bar, nothing to configure.
///
/// The whole scene depends on the player writing without being given a UI to
/// explore, so the only tool is a pencil and there is nothing else on screen.
struct PencilCanvas: UIViewRepresentable {
    @Binding var drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        let view = PKCanvasView()
        view.backgroundColor = .clear
        view.isOpaque = false
        view.drawingPolicy = .anyInput
        view.isScrollEnabled = false
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = false
        view.tool = PKInkingTool(
            .pen,
            color: UIColor(red: 0.16, green: 0.16, blue: 0.18, alpha: 1.0),
            width: 2.4
        )
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ view: PKCanvasView, context: Context) {
        // Deliberately empty.
        //
        // The canvas owns the drawing; the binding only mirrors it outward for
        // whoever wants to inspect it. Writing the binding back here would wipe
        // the stroke the player is in the middle of drawing, and comparing the
        // two values with `!==` does not compile: PKDrawing does not satisfy the
        // AnyObject constraint in this SDK.
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var drawing: Binding<PKDrawing>

        init(drawing: Binding<PKDrawing>) {
            self.drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            drawing.wrappedValue = canvasView.drawing
        }
    }
}
