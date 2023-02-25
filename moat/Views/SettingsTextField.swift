import SwiftUI

struct SettingsTextView: View {

    let screenWidth: CGFloat
    var text: String
    var default_text: String = ""

    var setting_key: String
    @Binding var setting_value: String

    var body: some View {
        HStack {
            Text(text)
                .lineLimit(1)
                .frame(width: self.screenWidth * 0.3, alignment: .leading)

            TextField(
                default_text, text: $setting_value,
                onEditingChanged: { started in
                    if !started {
                        // `onEditingChanged` is triggered upon entering and leaving a textfield
                        // using `onCommit` misses changes that are made without hiting <ENTER>
                        UserDefaults.standard.setValue(
                            setting_value, forKey: setting_key)
                    }
                }
            )
            .customStyle(width: self.screenWidth * 0.5)
            .autocapitalization(.none)
        }
    }
}
