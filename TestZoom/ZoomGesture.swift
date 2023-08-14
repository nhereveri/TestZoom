import SwiftUI

/// `ZoomGesture` es una representación de UIView que permite realizar gestos de zoom y panorámica en una vista.
///
/// Esta clase implementa un gesto de pellizco (pinch) para controlar el nivel de zoom y un gesto de arrastre (pan) para controlar la panorámica en una vista. También captura la posición de escala (zoom) para asegurar que el zoom se realice desde el punto adecuado.
///
/// Se puede utilizar en SwiftUI mediante el protocolo `UIViewRepresentable`.
struct ZoomGesture: UIViewRepresentable {
  /// El tamaño de la vista en la que se aplicarán los gestos.
  var size: CGSize

  /// El valor de escala actual.
  @Binding var scale: CGFloat

  /// El desplazamiento (panorámica) actual.
  @Binding var offset: CGPoint

  /// La posición de la escala (zoom) en la vista.
  @Binding var scalePosition: CGPoint

  /// Crea y devuelve un objeto coordinador para la vista representada.
  ///
  /// - Returns: Un objeto coordinador para la vista.
  func makeCoordinator() -> Coordinator {
    return Coordinator(parent: self)
  }

  /// Crea y configura la vista de interfaz de usuario.
  ///
  /// - Parameters:
  ///   - context: El contexto de la vista en SwiftUI.
  /// - Returns: Una vista de interfaz de usuario configurada para aplicar los gestos.
  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    view.backgroundColor = .clear

    // Configura el gesto de pellizco (pinch) para el zoom.
    let pinchGesture = UIPinchGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePinch(sender:)))
    view.addGestureRecognizer(pinchGesture)

    // Configura el gesto de arrastre (pan) para la panorámica.
    let panGesture = UIPanGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.handlePan(sender:)))
    panGesture.delegate = context.coordinator
    view.addGestureRecognizer(panGesture)

    return view
  }

  /// Actualiza la vista de interfaz de usuario.
  ///
  /// - Parameters:
  ///   - uiView: La vista de interfaz de usuario que se actualizará.
  ///   - context: El contexto de la vista en SwiftUI.
  func updateUIView(_ uiView: UIView, context: Context) {
    // No se necesita ninguna actualización específica en este momento.
  }

  /// El coordinador que maneja los gestos y la interacción con la vista.
  class Coordinator: NSObject, UIGestureRecognizerDelegate {
    /// La instancia principal de la clase `ZoomGesture` que contiene este coordinador.
    var parent: ZoomGesture

    /// Indica si el gesto de pellizco (pinch) ha sido liberado.
    var isPinchReleased: Bool = false

    /// Crea una nueva instancia del coordinador.
    ///
    /// - Parameter parent: La instancia de `ZoomGesture` asociada a este coordinador.
    init(parent: ZoomGesture) {
      self.parent = parent
    }

    /// Un método opcional de delegado que permite que múltiples gestos sean reconocidos simultáneamente.
    ///
    /// - Parameters:
    ///   - gestureRecognizer: El gesto actual.
    ///   - otherGestureRecognizer: Otro gesto que también está activo.
    /// - Returns: `true` si los gestos pueden ser reconocidos simultáneamente; de lo contrario, `false`.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return true
    }

    /// Maneja el gesto de arrastre (pan) para la panorámica en la vista.
    ///
    /// - Parameter sender: El gesto de arrastre.
    @objc func handlePan(sender: UIPanGestureRecognizer) {
      sender.maximumNumberOfTouches = 2

      if sender.state == .began || sender.state == .changed {
        if let view = sender.view, parent.scalePosition != .zero {
          let translation = sender.translation(in: view)
          parent.offset = translation
        }
      } else {
        withAnimation(.easeInOut(duration: 0.35)) {
          parent.offset = .zero
          parent.scalePosition = .zero
        }
      }
    }

    /// Maneja el gesto de pellizco (pinch) para el zoom en la vista.
    ///
    /// - Parameter sender: El gesto de pellizco.
    @objc func handlePinch(sender: UIPinchGestureRecognizer) {
      if sender.state == .began || sender.state == .changed {
        parent.scale = (isPinchReleased ? parent.scale : (sender.scale - 1))
        let scalePoint = CGPoint(x: sender.location(in: sender.view).x / sender.view!.frame.size.width, y: sender.location(in: sender.view).y / sender.view!.frame.size.height)
        parent.scalePosition = (parent.scalePosition == .zero ? scalePoint : parent.scalePosition)
      } else {
        withAnimation(.easeInOut(duration: 0.35)) {
          parent.scale = -1
          parent.scalePosition = .zero
          isPinchReleased = false
        }
      }
    }
  }
}
