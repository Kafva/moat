import SwiftUI

enum AlertType {
    case Error
    case Choice
}

class AlertState: ObservableObject {
    // The published attribute denotes that views watching this
    // observable object should re-render themselves on changes to the
    // given attribute
    @Published var show: Bool = false
    var title: String = ""
    var message: String = ""

    var type: AlertType = AlertType.Error

    /// Unhides an alert and sets the loading state to false
    func makeAlert(
        title: String, err: Error?, isLoading: Binding<Bool>?,
        alertType: AlertType = AlertType.Error
    ) {

        self.title = title
        self.message =
            "\(err?.localizedDescription ?? "No description available")"
        self.type = alertType

        DispatchQueue.main.async {
            // UI changes need to be performed on the main thread
            self.show = true
            isLoading?.wrappedValue = false
        }

    }
}
