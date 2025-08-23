
class AppContext {
    // Singleton instance
    static let shared = AppContext()

    let contentModel: ContentModel
    
    // Private initializer to prevent direct instantiation
    private init() {
        // Initialize any properties here
        self.contentModel = ContentModel()
    }
    
    // Add any shared properties or methods here
}
