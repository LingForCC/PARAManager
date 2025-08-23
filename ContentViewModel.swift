import Foundation
import SwiftUI

class ContentViewModel: ObservableObject {
    @Published var model: ContentModel
    
    init() {
        self.model = ContentModel()
    }
    
    func updateMessage(newMessage: String) {
        model = ContentModel(message: newMessage)
    }
}
