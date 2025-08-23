import SwiftUI

struct ProjectsView: View {

    @StateObject var projectsViewModel = ProjectsViewModel()
    
    // We still need the ViewModel to trigger actions, or we can call model methods directly.
    // For this refactoring, let's assume the view might trigger model actions directly
    // or through a ViewModel that's also an environment object.
    // To keep it simple and demonstrate the model's capability, we'll call model methods directly.
    // If we still wanted to use the ViewModel as a pure intermediary,
    // we'd also inject it and call viewModel.model.updateMessage etc.
    // Let's stick to observing the model and calling its methods for now.

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

            Button("Pick Folder") {
                projectsViewModel.selectFolder()
            }
            .padding()
            .background(Color.green)
            .foregroundColor(.white)
            .cornerRadius(10)

            if let selectedFolderURL = projectsViewModel.selectedFolderURL {
                Text("Selected Folder: \(selectedFolderURL.path)")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if projectsViewModel.subfolders.isEmpty {
                    Text("No subfolders found.")
                        .foregroundColor(.gray)
                } else {
                    List(projectsViewModel.subfolders, id: \.self) { subfolder in
                        Text(subfolder)
                    }
                    .frame(minHeight: 150) // Give the list some default height
                }
            } else {
                Text("No folder selected.")
                    .foregroundColor(.gray)
            }
            
            Spacer() // Pushes content to the top
        }
        .padding()
    }
}
