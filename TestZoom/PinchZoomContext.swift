import SwiftUI

/// Extensión de `View` que agrega la funcionalidad de gestos de zoom y panorámica a la vista.
///
/// Esta extensión proporciona una forma conveniente de envolver cualquier vista en un contexto de zoom y panorámica utilizando la estructura `PinchZoomContext`. Esto permite que la vista sea escalable y desplazable mediante gestos.
///
/// - Note: Asegúrate de importar `SwiftUI` antes de usar esta extensión.
///
/// ## Example
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         Image("landscape")
///             .resizable()
///             .aspectRatio(contentMode: .fit)
///             .addPinchZoom() // Agrega la funcionalidad de zoom y panorámica
///     }
/// }
/// ```
extension View {
  /// Agrega la funcionalidad de gestos de zoom y panorámica a la vista.
  ///
  /// Puedes utilizar esta función para envolver cualquier vista en un contexto de zoom y panorámica. La vista resultante será escalable y desplazable mediante gestos de pellizco y arrastre.
  ///
  /// - Returns: La vista original envuelta en un contexto de zoom y panorámica.
  ///
  /// - Note: Asegúrate de importar `SwiftUI` antes de usar esta función.
  ///
  /// - SeeAlso: `PinchZoomContext`
  func addPinchZoom() -> some View {
    return PinchZoomContext {
      self
    }
  }
}

/// `PinchZoomContext` proporciona un contexto para aplicar gestos de zoom y panorámica a una vista en SwiftUI.
///
/// Puedes usar esta estructura para envolver cualquier vista en SwiftUI y habilitar la funcionalidad de zoom y panorámica en la misma.
///
/// - Note: Asegúrate de importar `SwiftUI` antes de usar esta estructura.
///
/// ## Example
/// ```swift
/// struct ContentView: View {
///     var body: some View {
///         Image("landscape")
///             .resizable()
///             .aspectRatio(contentMode: .fit)
///             .addPinchZoom() // Aplica el contexto de zoom y panorámica
///     }
/// }
/// ```
struct PinchZoomContext<Content: View>: View {
  /// El contenido (vista) que se envuelve en el contexto.
  var content: Content

  /// Crea un nuevo contexto para aplicar gestos de zoom y panorámica a una vista.
  ///
  /// - Parameter content: El contenido (vista) que se envolverá en el contexto.
  init(@ViewBuilder content: @escaping () -> Content) {
    self.content = content()
  }

  /// El desplazamiento (panorámica) actual de la vista.
  @State var offset: CGPoint = .zero

  /// El valor de escala actual de la vista.
  @State var scale: CGFloat = 0

  /// La posición de la escala (zoom) en la vista.
  @State var scalePosition: CGPoint = .zero

  /// Indica si la vista está en proceso de zoom.
  @SceneStorage("isZooming") var isZooming: Bool = false

  /// El cuerpo de la vista, con el contenido envuelto en el contexto de zoom y panorámica.
  var body: some View {
    content
      .offset(x: offset.x, y: offset.y)
      .overlay(
        GeometryReader { proxy in
          let size = proxy.size
          ZoomGesture(size: size, scale: $scale, offset: $offset, scalePosition: $scalePosition)
        }
      )
      .scaleEffect(1 + (scale < 0 ? 0 : scale), anchor: .init(x: scalePosition.x, y: scalePosition.y))
      .zIndex((scale != 0 || offset != .zero) ? 1000 : 0)
      .onChange(of: scale) { _ in
        isZooming = (scale != 0)
        if scale == -1 {
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            scale = 0
          }
        }
      }
      .onChange(of: offset) { _ in
        isZooming = (offset != .zero)
      }
  }
}
