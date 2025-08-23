import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.model.message)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Button("Change Message") {
                viewModel.updateMessage(newMessage: "Hello MVVM!")
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ContentViewModel())
    }
}
