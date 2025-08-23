import SwiftUI
import AppKit

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
            HStack {
                Button("Select Projects Folder") {
                    projectsViewModel.selectFolder()
                }
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)

                Button("Select Archiving Folder") {
                    projectsViewModel.selectArchivingFolder()
                }
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            if let selectedFolderURL = projectsViewModel.selectedFolderURL {
                Text("Projects Folder: \(selectedFolderURL.path)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }   else {
                Text("No projects folder selected.")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            
            if let archivingFolderURL = projectsViewModel.archivingFolderURL {
                Text("Archiving Folder: \(archivingFolderURL.path)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("No archiving folder selected.")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
            
            if projectsViewModel.subfolders.isEmpty {
                Text("No subfolders found.")
                    .foregroundColor(.gray)
            } else {
                List(projectsViewModel.subfolders.indices, id: \.self) { index in
                    let subfolder = projectsViewModel.subfolders[index]
                    HStack {
                        Text(subfolder.lastPathComponent)
                        Spacer()
                        HStack(spacing: 8) {
                            Button("Open") {
                                NSWorkspace.shared.open(subfolder)
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Archive") {
                                projectsViewModel.archiveSubfolder(at: index)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                            .disabled(projectsViewModel.archivingFolderURL == nil)
                        }
                    }
                }
                .frame(minHeight: 150) // Give the list some default height
            }

            
            Spacer() // Pushes content to the top
        }
        .padding()
    }
}
