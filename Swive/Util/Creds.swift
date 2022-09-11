import KeychainAccess

func setCreds(){
  let keychain = Keychain(service: "com..Swive")
  keychain["creds"] = "test"
}

func getCreds() -> String {
  let keychain = Keychain(service: "com..Swive")
  return keychain["creds"] ?? ""
}
