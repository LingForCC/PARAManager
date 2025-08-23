import Foundation
import SwiftUI

class ProjectsViewModel: ObservableObject {

    @Published var selectedFolderURL: URL?
    @Published var subfolders: [String] = []

    var projectsModel: ProjectsModel

    init() {
        self.projectsModel = AppContext.shared.projectsModel
        setupNotificationObserver()
        syncWithModel()
    }
    
    private func syncWithModel() {
        // Get the current subfolders from the model
        self.subfolders = projectsModel.getSubfolders()
        
        // Get the selected folder URL from the model
        self.selectedFolderURL = projectsModel.getSelectedFolderURL()
    }
    
    private func setupNotificationObserver() {
        NotificationCenter.default.addObserver(
            forName: .subfoldersUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSubfoldersUpdated()
        }
    }
    
    private func handleSubfoldersUpdated() {
        self.subfolders = projectsModel.getSubfolders()
    }

    func selectFolder() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.prompt = "Select Folder"
        openPanel.title = "Choose a folder to monitor"

        DispatchQueue.main.async {
            if openPanel.runModal() == .OK {
                guard let selectedURL = openPanel.url else { return }
                
                do {
                    try self.projectsModel.selectFolderURL(url: selectedURL)
                    self.selectedFolderURL = self.projectsModel.getSelectedFolderURL()
                    self.subfolders = self.projectsModel.getSubfolders()
                } catch {
                    //Do nothing for now. Probabaly need to display error messages in the UI
                    print("Error selecting folder: \(error)")
                }
                
                // Ensure main window regains focus after NSOpenPanel closes
                DispatchQueue.main.async {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            } else {
                // User cancelled, still ensure main window regains focus
                DispatchQueue.main.async {
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            }
        }
    }
}
