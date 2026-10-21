import SwiftUI
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
        // PKDrawing is a class but not Equatable, so compare identity instead of
        // value. Without this guard every SwiftUI redraw would clear the stroke
        // the player is in the middle of drawing.
        if context.coordinator.lastSynced !== drawing {
            view.drawing = drawing
            context.coordinator.lastSynced = drawing
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(drawing: $drawing)
    }

    final class Coordinator: NSObject, PKCanvasViewDelegate {
        var drawing: Binding<PKDrawing>
        var lastSynced: PKDrawing?

        init(drawing: Binding<PKDrawing>) {
            self.drawing = drawing
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            lastSynced = canvasView.drawing
            drawing.wrappedValue = canvasView.drawing
        }
    }
}
