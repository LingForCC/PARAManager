
class AppContext {
    // Singleton instance
    static let shared = AppContext()

    let projectsModel: ProjectsModel
    
    // Private initializer to prevent direct instantiation
    private init() {
        // Initialize any properties here
        self.projectsModel = ProjectsModel()
    }
    
    // Add any shared properties or methods here
}
