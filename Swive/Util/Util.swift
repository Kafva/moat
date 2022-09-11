import KeychainAccess
import SwiftUI

func setCreds(){
  let keychain = Keychain(service: "com..Swive")
  keychain["creds"] = "test"
}

func getCreds() -> String {
  let keychain = Keychain(service: "com..Swive")
  return keychain["creds"] ?? ""
}

func setViewTransparency() {
  // https://stackoverflow.com/questions/57128547/swiftui-list-color-background
  UITableView.appearance().backgroundColor = .clear
  UITableViewCell.appearance().backgroundColor = .clear
  UIButton.appearance().backgroundColor = .clear

  // https://stackoverflow.com/a/58974331/9033629 
  UINavigationBar.appearance().barTintColor = .clear
  UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
  
  // https://stackoverflow.com/a/26390278/9033629
  UINavigationBar.appearance().shadowImage = UIImage()
}