import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {

    @Published var selectedFolderURL: URL?
    @Published var subfolders: [String] = []

    var contentModel: ContentModel

    init() {
        self.contentModel = AppContext.shared.contentModel
    }

    // This method will be called by the ViewModel
    func selectFolder() {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.canCreateDirectories = false
        openPanel.prompt = "Select Folder"
        openPanel.title = "Choose a folder to monitor"

        // NSOpenPanel's runModal must be called on the main thread.
        DispatchQueue.main.async {
            if openPanel.runModal() == .OK {
                guard let selectedURL = openPanel.url else { return }
                
                do {
                    self.subfolders = try self.contentModel.selectFolderURL(url: selectedURL)
                    self.selectedFolderURL = selectedURL
                } catch {
                    //Do nothing for now. Probabaly need to display error messages in the UI

                }
            }
        }
    }
}
