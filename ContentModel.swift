import Foundation
import AppKit // Needed for NSOpenPanel if we decide to call it here, or for URL handling.

class ContentModel {

    private var selectedFolderURL: URL?
    private var subfolders: [String] = []
    
    private var fileWatcher: FileWatcher?
    
    func selectFolderURL(url: URL) throws -> [String] {

        self.stopWatchingCurrentFolder()
                
        try self.loadSubfolders(from: url)
        self.selectedFolderURL = url

        self.startWatching(url: url)

        return subfolders
    }

    private func startWatching(url: URL) {
        self.fileWatcher = FileWatcher(url: url) { [weak self] in
            print("File system change detected in \(url.path)")
            do {
                try self?.loadSubfolders(from: url)

            } catch {
                //do nothing
            }
        }
    }
    
    private func stopWatchingCurrentFolder() {
        self.fileWatcher?.stopWatching()
        self.fileWatcher = nil
    }

    private func loadSubfolders(from url: URL) throws {
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [.isDirectoryKey], options: [])
            let newSubfolders = directoryContents.compactMap { itemURL -> String? in
                do {
                    let resourceValues = try itemURL.resourceValues(forKeys: [.isDirectoryKey])
                    if resourceValues.isDirectory == true {
                        return itemURL.lastPathComponent
                    }
                } catch {
                    print("Error checking if item is directory: \(itemURL.path), error: \(error)")
                }
                return nil
            }.sorted()
            
            self.subfolders = newSubfolders
        } catch {
            print("Error loading directory \(url.path) contents: \(error.localizedDescription)")
            self.subfolders = [] // Clear subfolders on error
            throw error
        }
        
    }
}
