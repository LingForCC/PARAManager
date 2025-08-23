import Foundation
import AppKit // Needed for NSOpenPanel if we decide to call it here, or for URL handling.

extension Notification.Name {
    static let subfoldersUpdated = Notification.Name("subfoldersUpdated")
    static let archiveCompleted = Notification.Name("archiveCompleted")
}

class ProjectsModel {

    private var selectedFolderURL: URL?
    private var archivingFolderURL: URL?
    private var subfolders: [URL] = []
    
    private var fileWatcher: FileWatcher?
    
    private let selectedFolderURLKey = "SelectedFolderURL"
    private let archivingFolderURLKey = "ArchivingFolderURL"
    
    init() {
        loadSelectedFolderFromUserDefaults()
        loadArchivingFolderFromUserDefaults()
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
    
    // MARK: - Archiving Functionality
    
    func setArchivingFolderURL(url: URL) {
        self.archivingFolderURL = url
        saveArchivingFolderToUserDefaults()
    }
    
    func getArchivingFolderURL() -> URL? {
        return archivingFolderURL
    }
    
    func archiveSubfolder(at index: Int) throws {
        guard let archivingFolderURL = archivingFolderURL else {
            throw ArchiveError.archivingFolderNotSet
        }
        
        guard index >= 0 && index < subfolders.count else {
            throw ArchiveError.invalidIndex
        }
        
        let subfolderToArchive = subfolders[index]
        let destinationURL = archivingFolderURL.appendingPathComponent(subfolderToArchive.lastPathComponent)
        
        // Check if destination already exists
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            throw ArchiveError.destinationAlreadyExists(destinationURL.lastPathComponent)
        }
        
        do {
            try FileManager.default.moveItem(at: subfolderToArchive, to: destinationURL)
            
            // Refresh subfolders list
            if let selectedFolderURL = selectedFolderURL {
                try loadSubfolders(from: selectedFolderURL)
                NotificationCenter.default.post(name: .subfoldersUpdated, object: nil)
            }
            
            NotificationCenter.default.post(name: .archiveCompleted, object: subfolderToArchive)
        } catch {
            print("Error archiving folder: \(error.localizedDescription)")
            throw error
        }
    }
    
    private func loadArchivingFolderFromUserDefaults() {
        guard let urlString = UserDefaults.standard.string(forKey: archivingFolderURLKey),
              let url = URL(string: urlString) else {
            return
        }
        
        if FileManager.default.fileExists(atPath: url.path) {
            self.archivingFolderURL = url
        } else {
            UserDefaults.standard.removeObject(forKey: archivingFolderURLKey)
        }
    }
    
    private func saveArchivingFolderToUserDefaults() {
        guard let url = archivingFolderURL else {
            UserDefaults.standard.removeObject(forKey: archivingFolderURLKey)
            return
        }
       
        UserDefaults.standard.set(url.absoluteString, forKey: archivingFolderURLKey)
    }
}

enum ArchiveError: Error {
    case archivingFolderNotSet
    case invalidIndex
    case destinationAlreadyExists(String)
    
    var localizedDescription: String {
        switch self {
        case .archivingFolderNotSet:
            return "Archiving folder is not selected"
        case .invalidIndex:
            return "Invalid subfolder index"
        case .destinationAlreadyExists(let folderName):
            return "Destination folder '\(folderName)' already exists in archiving location"
        }
    }
}
