import Foundation
import AppKit // Needed for NSOpenPanel if we decide to call it here, or for URL handling.

extension Notification.Name {
    static let subfoldersUpdated = Notification.Name("subfoldersUpdated")
}

class ProjectsModel {

    private var selectedFolderURL: URL?
    private var subfolders: [URL] = []
    
    private var fileWatcher: FileWatcher?
    
    private let selectedFolderURLKey = "SelectedFolderURL"
    
    init() {
        loadSelectedFolderFromUserDefaults()
    }
    
    func selectFolderURL(url: URL) throws {

        try selectFolder(url: url)
        
        saveSelectedFolderToUserDefaults()

    }

    private func selectFolder(url: URL) throws {

        self.stopWatchingCurrentFolder()
                
        try self.loadSubfolders(from: url)
        self.selectedFolderURL = url

        self.startWatching(url: url)
    }

    private func startWatching(url: URL) {
        self.fileWatcher = FileWatcher(url: url) { [weak self] in
            do {
                try self?.loadSubfolders(from: url)

                NotificationCenter.default.post(name: .subfoldersUpdated, object: nil)
            } catch {
                //do nothing
            }
        }
    }
    
    private func stopWatchingCurrentFolder() {
        self.fileWatcher?.stopWatching()
        self.fileWatcher = nil
    }
    
    func getSubfolders() -> [URL] {
        return subfolders
    }
    
    func getSelectedFolderURL() -> URL? {
        return selectedFolderURL
    }

    private func loadSubfolders(from url: URL) throws {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [])
            let newSubfolders = directoryContents.compactMap { itemURL -> URL? in
                do {
                    let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey])
                    if resourceValues.isDirectory == true {
                        return itemURL
                    }
                } catch {
                    print("Error checking if item is directory: \(itemURL.path), error: \(error)")
                }
                return nil
            }.sorted { $0.lastPathComponent < $1.lastPathComponent }
            
            self.subfolders = newSubfolders
        } catch {
            print("Error loading directory \(url.path) contents: \(error.localizedDescription)")
            self.subfolders = [] // Clear subfolders on error
            throw error
        }
    }
    
    private func loadSelectedFolderFromUserDefaults() {
        guard let urlString = UserDefaults.standard.string(forKey: selectedFolderURLKey),
              let url = URL(string: urlString) else {
            return
        }
        
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try selectFolder(url: url)
            } catch {
                print("Error loading saved folder: \(error.localizedDescription)")
                // Remove the invalid URL from UserDefaults
                UserDefaults.standard.removeObject(forKey: selectedFolderURLKey)
            }
        } else {
            UserDefaults.standard.removeObject(forKey: selectedFolderURLKey)
        }
    }
    
    private func saveSelectedFolderToUserDefaults() {
        guard let url = selectedFolderURL else {
            UserDefaults.standard.removeObject(forKey: selectedFolderURLKey)
            return
        }
       
        UserDefaults.standard.set(url.absoluteString, forKey: selectedFolderURLKey)
    }
}
