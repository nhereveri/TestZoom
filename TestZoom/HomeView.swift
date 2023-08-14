import SwiftUI

struct HomeView: View {
  var body: some View {
    ScrollView(.vertical, showsIndicators: false) {
      VStack(spacing: 18) {
        ForEach(1...5, id: \.self) {index in
          Image("Post\(index)")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .cornerRadius(15)
            .addPinchZoom()
        }
      }
      .padding()
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
