# PARAManage

A SwiftUI application to manage files on local file system organized based on PARA method from Tiago Forte.

## Features

- **Project Folder Monitoring**: Select and monitor a projects directory in real-time
- **Automatic Detection**: Automatically detects subfolders and updates the list when changes occur
- **Easy Archiving**: Archive completed projects to a designated archiving folder with a single click
- **Native macOS Experience**: Built with SwiftUI for a seamless macOS experience
- **Persistent Settings**: Remembers your selected folders between app launches
- **File System Integration**: Direct integration with Finder for opening project folders

## Screenshots

*[Screenshots would be added here]*

## System Requirements

- **macOS**: 14.0 or later
- **Swift**: 5.9 or later
- **Xcode Command Line Tools** (for building from source)

## Installation

### Option 1: Download Pre-built App

1. Download the latest DMG file from the [Releases](https://github.com/yourusername/PARAManager/releases) page
2. Mount the DMG file
3. Drag PARAManager to your Applications folder
4. Launch the app

### Option 2: Build from Source

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/PARAManager.git
   cd PARAManager
   ```

2. Build the project:
   ```bash
   swift build -c release
   ```

3. Run the app:
   ```bash
   .build/release/PARAManager
   ```

### Option 3: Create DMG Package

Use the included build script to create a distributable DMG:

```bash
./build-dmg.sh
```

For detailed packaging instructions, see [Packaging.md](Packaging.md).

## Usage

### Getting Started

1. **Launch PARAManager**
2. **Select Projects Folder**: Click "Select Projects Folder" to choose the directory containing your projects
3. **Select Archiving Folder**: Click "Select Archiving Folder" to choose where completed projects will be archived
4. **Monitor Projects**: The app will automatically display all subfolders in your projects directory
5. **Archive Projects**: Click "Archive" next to any project to move it to your archiving folder

### Features in Detail

#### Real-time Monitoring
- PARAManager automatically watches your selected projects folder
- New projects are detected immediately when added
- The interface updates in real-time without manual refresh

#### Project Management
- **Open**: Click "Open" to open a project folder directly in Finder
- **Archive**: Click "Archive" to move a project to your designated archiving location
- **Automatic Updates**: The project list updates automatically when files change

#### Persistent Settings
- Your selected folders are remembered between app launches
- No need to reconfigure the app each time you use it

## Development

### Project Structure

```
PARAManager/
├── PARAManagerApp.swift          # Main app entry point
├── AppContext.swift              # Shared app context
├── Models/
│   └── ProjectsModel.swift       # Core business logic
├── ViewModels/
│   └── ProjectsViewModel.swift   # UI state management
├── Views/
│   └── ProjectsView.swift        # Main UI components
├── Utils/
│   └── FileWatcher.swift         # File system monitoring
├── Package.swift                 # Swift Package Manager configuration
├── Info.plist                   # App metadata
├── Entitlements.plist           # App permissions
└── build-dmg.sh                 # Build and packaging script
```

### Architecture

PARAManager follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Model** (`ProjectsModel`): Handles file system operations, folder monitoring, and archiving logic
- **View** (`ProjectsView`): SwiftUI interface for user interaction
- **ViewModel** (`ProjectsViewModel`): Manages UI state and coordinates between Model and View

### Key Components

#### FileWatcher
- Monitors directory changes using macOS file system events
- Automatically updates the project list when changes occur
- Efficient resource management with proper cleanup

#### ProjectsModel
- Core business logic for folder management
- Handles archiving operations with error handling
- Persistent storage using UserDefaults

#### ProjectsViewModel
- Manages UI state and user interactions
- Coordinates with the Model layer
- Handles file picker dialogs and user feedback

### Building and Testing

#### Prerequisites
```bash
# Install Xcode Command Line Tools
xcode-select --install

# Verify Swift version
swift --version
```

#### Development Build
```bash
# Build in debug mode
swift build

# Run the app
swift run
```

#### Release Build
```bash
# Build optimized release version
swift build -c release

# Run release version
.build/release/PARAManager
```

### Code Signing and Distribution

For distribution, you'll need:
- Apple Developer Program membership
- Developer ID Application certificate
- Proper code signing and notarization

See [Packaging.md](Packaging.md) for detailed instructions.

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow Swift style guidelines
- Add tests for new features
- Update documentation as needed
- Ensure code signing works before submitting PRs

## Troubleshooting

### Common Issues

#### App Won't Launch
- Ensure you're running macOS 14.0 or later
- Check that the app has necessary permissions
- Try building from source to see detailed error messages

#### Folder Monitoring Not Working
- Verify the selected folder exists and is accessible
- Check that the app has permission to access the folder
- Restart the app if folder permissions have changed

#### Archiving Fails
- Ensure the archiving folder is selected
- Check that you have write permissions to the archiving location
- Verify the destination doesn't already contain a folder with the same name

#### Build Errors
- Ensure Xcode Command Line Tools are installed
- Check Swift version compatibility
- Verify all dependencies are properly resolved

### Debug Mode

To run in debug mode with additional logging:

```bash
swift build
swift run
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Built with SwiftUI and Swift
- Uses native macOS file system APIs
- Inspired by the need for better project organization tools

## Support

- **Issues**: Report bugs and feature requests on [GitHub Issues](https://github.com/yourusername/PARAManager/issues)
- **Discussions**: Join the conversation on [GitHub Discussions](https://github.com/yourusername/PARAManager/discussions)
- **Documentation**: Check the [Packaging.md](Packaging.md) for build and distribution details

---

**PARAManager** - Simplify your project management workflow on macOS.
