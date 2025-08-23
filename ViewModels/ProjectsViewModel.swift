import Foundation
import SwiftUI

class ProjectsViewModel: ObservableObject {

    @Published var selectedFolderURL: URL?
    @Published var archivingFolderURL: URL?
    @Published var subfolders: [URL] = []

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
        
        // Get the archiving folder URL from the model
        self.archivingFolderURL = projectsModel.getArchivingFolderURL()
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
    
    // MARK: - Archiving Functionality
    
    func selectArchivingFolder() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.prompt = "Select Archiving Folder"
        openPanel.title = "Choose a folder for archiving projects"

        DispatchQueue.main.async {
            if openPanel.runModal() == .OK {
                guard let selectedURL = openPanel.url else { return }
                
                self.projectsModel.setArchivingFolderURL(url: selectedURL)
                self.archivingFolderURL = self.projectsModel.getArchivingFolderURL()
                
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
    
    func archiveSubfolder(at index: Int) {
        do {
            try projectsModel.archiveSubfolder(at: index)
        } catch {
            print("Error archiving subfolder: \(error.localizedDescription)")
            // TODO: Show error to user in UI
        }
    }
}
