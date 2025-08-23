import Foundation

class FileWatcher: NSObject {
    private var fileDescriptor: Int32 = -1
    private var dispatchSource: DispatchSourceFileSystemObject?
    private let url: URL
    private var onChange: (() -> Void)?

    init(url: URL, onChange: @escaping () -> Void) {
        self.url = url
        self.onChange = onChange
        super.init()
        startWatching()
    }

    deinit {
        stopWatching()
    }

    private func startWatching() {
        // Open a file descriptor for the directory we want to monitor
        fileDescriptor = open(url.path, O_EVTONLY)
        guard fileDescriptor != -1 else {
            print("Error: Failed to open file descriptor for \(url.path)")
            return
        }

        // Create a dispatch source to monitor the file descriptor
        dispatchSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: .write, queue: .main)

        // Set the event handler
        dispatchSource?.setEventHandler { [weak self] in
            self?.onChange?()
        }

        // Set the cancellation handler to clean up
        dispatchSource?.setCancelHandler { [weak self] in
            guard let self = self else { return }
            if self.fileDescriptor != -1 {
                close(self.fileDescriptor)
                self.fileDescriptor = -1
            }
            self.dispatchSource = nil
        }

        // Resume the dispatch source
        dispatchSource?.resume()
    }

    func stopWatching() { // Changed private to internal (default)
        dispatchSource?.cancel()
        // The cancellation handler will close the file descriptor and nil out the dispatchSource
    }
}
