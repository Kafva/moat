import SwiftUI

class ApiWrapper<T: Codable> {
    private func getServerConfig(alert: AlertState, isLoading: Binding<Bool>?)
        -> (String, String)?
    {
        guard
            let serverLocation = UserDefaults.standard.string(
                forKey: "serverLocation")
        else {
            alert.makeAlert(
                title: ServerConnectionErrorTitle.incomplete,
                err: ServerConnectionError.noServerLocation,
                isLoading: isLoading
            )
            return nil
        }

        guard
            let serverPort = UserDefaults.standard.string(forKey: "serverPort")
        else {
            alert.makeAlert(
                title: ServerConnectionErrorTitle.incomplete,
                err: ServerConnectionError.noServerPort,
                isLoading: isLoading
            )
            return nil
        }
        let serverKey = getCreds()

        if serverKey == "" {
            alert.makeAlert(
                title: ServerConnectionErrorTitle.incomplete,
                err: ServerConnectionError.noServerKey,
                isLoading: isLoading
            )
            return nil
        }

        return ("\(serverLocation):\(serverPort)", serverKey)
    }

    private func makeBaseRequest(api_url: String, serverKey: String)
        -> URLRequest?
    {

        guard let url = URL(string: api_url) else { return nil }
        var req = URLRequest(url: url, timeoutInterval: SERVER_REQUEST_TIMEOUT)
        req.addValue(serverKey, forHTTPHeaderField: "x-creds")
        return req
    }

    private func sendRequest(
        req: URLRequest, alert: AlertState, isLoading: Binding<Bool>?,
        callback: @escaping (Data) -> Void
    ) {

        URLSession.shared.dataTask(with: req) { data, res, err in
            // Create a background task to fetch data from the server
            if (res as? HTTPURLResponse)?.statusCode == 401 {
                alert.makeAlert(
                    title: ServerConnectionErrorTitle.unauthorized,
                    err: ServerConnectionError.invalidKey,
                    isLoading: isLoading
                )
            } else {
                if data != nil {
                    callback(data!)
                } else {
                    alert.makeAlert(
                        title: ServerConnectionErrorTitle.internalFailure, err: err,
                        isLoading: isLoading
                    )
                }
            }
        }
        .resume()  // Execute the task immediatelly
    }

    /// Makes the server issue `newsboat -r` to update the cache.db and
    /// invokes a request to `/feeds` afterwards
    func reloadFeeds(
        rows: ObservableArray<T>, alert: AlertState, isLoading: Binding<Bool>,
        isReloading: Binding<Bool>
    ) {

        guard
            let (serverLocation, serverKey) =
                self.getServerConfig(alert: alert, isLoading: isLoading)
        else { return }

        guard
            var req = self.makeBaseRequest(
                api_url: "https://\(serverLocation)/reload",
                serverKey: serverKey)
        else { return }

        req.httpMethod = "PATCH"

        self.sendRequest(
            req: req, alert: alert, isLoading: isLoading,
            callback: { data in
                do {
                    let decoded = try JSONDecoder().decode(
                        ServerResponse.self, from: data)
                    if decoded.success {
                        // The `FeedsView` implicitly calls `loadRows` .onAppear but since the view will
                        // already have presented itself when we reach this block we need to manuallly invoke it
                        isReloading.wrappedValue = false
                        self.loadRows(
                            rows: rows, alert: alert, isLoading: isLoading)
                    } else {
                        alert.makeAlert(
                            title: ServerConnectionErrorTitle.internalFailure,
                            err: ServerConnectionError.feedReloadFailure,
                            isLoading: isLoading
                        )
                    }
                } catch {
                    alert.makeAlert(
                        title: ServerConnectionErrorTitle.decoding,
                        err: error,
                        isLoading: isLoading
                    )
                }
            })
    }

    /// Fetch a list of all feeds or all items for a perticular feed
    /// The arbitrary type needs to implemennt the codable protocol
    func loadRows(
        rows: ObservableArray<T>, alert: AlertState, isLoading: Binding<Bool>,
        rssurl: String = ""
    ) {

        guard
            let (serverLocation, serverKey) =
                self.getServerConfig(alert: alert, isLoading: isLoading)
        else { return }

        var api_url = "https://\(serverLocation)/feeds"

        if T.self is RssItem.Type {
            api_url = "https://\(serverLocation)/items/\(rssurl.toBase64())"
        }

        guard
            let req = self.makeBaseRequest(
                api_url: api_url, serverKey: serverKey)
        else { return }

        self.sendRequest(
            req: req, alert: alert, isLoading: isLoading,
            callback: { data in
                do {
                    print("data:", data)
                    let decoded = try JSONDecoder().decode([T].self, from: data)
                    print("decoded:", decoded)

                    // If the response data was successfully decoded dispatch an update in the
                    // main thread (all UI updates should be done in the main thread)
                    // to update the state in the view
                    DispatchQueue.main.async {
                        rows.arr = decoded
                        isLoading.wrappedValue = false
                    }
                } catch {
                    alert.makeAlert(
                        title: ServerConnectionErrorTitle.decoding,
                        err: error,
                        isLoading: isLoading
                    )
                }
            })
    }

    func setAllItemsAsRead(
        unread_count: Binding<Int>, rssurl: String, alert: AlertState
    ) {

        guard
            let (serverLocation, serverKey) =
                self.getServerConfig(alert: alert, isLoading: nil)
        else { return }

        var req = self.makeBaseRequest(
            api_url: "https://\(serverLocation)/update",
            serverKey: serverKey
        )!

        // Add POST data
        req.httpMethod = "POST"
        req.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type")
        req.httpBody = "feedurl=\(rssurl.toBase64())&unread=false".data(
            using: .ascii)

        self.sendRequest(
            req: req,
            alert: alert,
            isLoading: nil,
            callback: { data in
                do {
                    let decoded = try JSONDecoder().decode(
                        ServerResponse.self, from: data)

                    // If the response data was successfully decoded dispatch an update in the
                    // main thread (all UI updates should be done in the main thread)
                    // to update the state in the view
                    DispatchQueue.main.async {
                        if !decoded.success {
                            alert.makeAlert(
                                title: ServerConnectionErrorTitle.badRequest,
                                err: ServerConnectionError.unexpected(
                                    code: 400),
                                isLoading: nil
                            )
                        } else {
                            // Update the binding to the unread_count value for the
                            // RssFeedRow in question
                            unread_count.wrappedValue = 0
                        }
                    }
                } catch {
                    alert.makeAlert(
                        title: ServerConnectionErrorTitle.decoding,
                        err: error,
                        isLoading: nil
                    )
                }

            }
        )
    }

    func setUnreadStatus(
        unread_count: Binding<Int>, unread_binding: Binding<Bool>,
        rssurl: String, video_id: Int, alert: AlertState
    ) {

        guard
            let (serverLocation, serverKey) =
                self.getServerConfig(alert: alert, isLoading: nil)
        else { return }

        var req = self.makeBaseRequest(
            api_url: "https://\(serverLocation)/update",
            serverKey: serverKey
        )!

        // The value for the unread parameter will be the opposite of the current value
        let unread = !unread_binding.wrappedValue ? "true" : "false"

        // Add POST data
        req.httpMethod = "POST"
        req.setValue(
            "application/x-www-form-urlencoded",
            forHTTPHeaderField: "Content-Type")
        req.httpBody = "id=\(video_id)&unread=\(unread)".data(using: .ascii)

        self.sendRequest(
            req: req,
            alert: alert,
            isLoading: nil,
            callback: { data in
                do {
                    let decoded = try JSONDecoder().decode(
                        ServerResponse.self, from: data)

                    DispatchQueue.main.async {
                        if !decoded.success {
                            alert.makeAlert(
                                title: ServerConnectionErrorTitle.badRequest,
                                err: ServerConnectionError.unexpected(
                                    code: 400),
                                isLoading: nil
                            )
                        } else {
                            // Update the binding to the unread_count value in the FeedsView
                            // and toggle the boolean value for the ItemsView
                            unread_count.wrappedValue +=
                                unread_binding.wrappedValue ? -1 : 1
                            unread_binding.wrappedValue = !unread_binding
                                .wrappedValue
                        }
                    }
                } catch {
                    alert.makeAlert(
                        title: ServerConnectionErrorTitle.decoding,
                        err: error,
                        isLoading: nil
                    )
                }
            }
        )
    }
}
