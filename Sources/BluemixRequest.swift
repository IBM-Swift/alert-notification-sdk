/**
 * Copyright IBM Corporation 2016,2017
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import Foundation

import LoggerAPI

class BluemixRequest {
    /*
     * Instance veriables and methods.
     */
    
    // Common variables.
    let baseURL: URL
    let credentials: ServiceCredentials
    
    // Initializer.
    init(usingCredentials credentials: ServiceCredentials) throws {
        self.credentials = credentials
        guard let baseURL = URL(string: "\(credentials.url)/") else {
            throw AlertNotificationError.credentialsError("Invalid URL provided.")
        }
        self.baseURL = baseURL
    }
    
    // Create a URLRequest object with some basic initialization done.
    func createRequest(forURL url: URL, withMethod method: String) -> URLRequest {
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    // A callback wrapper that extracts a status code from a URLResponse, then calls the callback.
    func urlResponseCallbackWrapper(callback: @escaping (Data?, Int?, Swift.Error?) -> Void) -> (Data?, URLResponse?, Swift.Error?) -> Void {
        return {(data: Data?, response: URLResponse?, error: Swift.Error?) in
            guard let httpResponse = response as? HTTPURLResponse else {
                callback(data, nil, error)
                return
            }
            callback(data, httpResponse.statusCode, error)
        }
    }
    
    /*
     * Alert requests.
     */
    
    func postAlert(_ alert: Alert, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) throws {
        guard let apiURL = URL(string: "alerts/v1/", relativeTo: self.baseURL) else {
            throw AlertNotificationError.credentialsError("Invalid URL provided.")
        }
        var request: URLRequest = createRequest(forURL: apiURL, withMethod: "POST")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
        let alertJSON = try alert.toJSONData()
        request.httpBody = alertJSON
            
        SharedSession.sendRequest(req: request, callback: urlResponseCallbackWrapper(callback: callback))
    }
    
    func getAlert(shortId id: String, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) throws {
        guard let apiURL = URL(string: "alerts/v1/", relativeTo: self.baseURL) else {
            throw AlertNotificationError.credentialsError("Invalid URL provided.")
        }
        guard let fullURL = URL(string: id, relativeTo: apiURL) else {
            throw AlertNotificationError.alertError("Invalid alert ID provided to GET request.")
        }
        let request: URLRequest = createRequest(forURL: fullURL, withMethod: "GET")
            
        SharedSession.sendRequest(req: request, callback: urlResponseCallbackWrapper(callback: callback))
    }
    
    func deleteAlert(shortId id: String, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) throws {
        guard let apiURL = URL(string: "alerts/v1/", relativeTo: self.baseURL) else {
            throw AlertNotificationError.credentialsError("Invalid URL provided.")
        }
        guard let fullURL: URL = URL(string: id, relativeTo: apiURL) else {
            throw AlertNotificationError.alertError("Invalid alert ID provided to DELETE request.")
        }
        let request: URLRequest = createRequest(forURL: fullURL, withMethod: "DELETE")
            
        SharedSession.sendRequest(req: request, callback: urlResponseCallbackWrapper(callback: callback))
    }
    
    /*
     * Message requests.
     */
    
    func postMessage(_ message: Message, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) throws {
        guard let apiURL = URL(string: "messages/v1/", relativeTo: self.baseURL) else {
            throw AlertNotificationError.credentialsError("Invalid URL provided.")
        }
        var request: URLRequest = createRequest(forURL: apiURL, withMethod: "POST")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            
        let messageJSON = try message.toJSONData()
        request.httpBody = messageJSON
            
        SharedSession.sendRequest(req: request, callback: urlResponseCallbackWrapper(callback: callback))
    }
    
    func getMessage(shortId id: String, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) throws {
        guard let apiURL = URL(string: "messages/v1/", relativeTo: self.baseURL) else {
            throw AlertNotificationError.credentialsError("Invalid URL provided.")
        }
        guard let fullURL = URL(string: id, relativeTo: apiURL) else {
            throw AlertNotificationError.messageError("Invalid message ID provided to GET request.")
        }
        let request: URLRequest = createRequest(forURL: fullURL, withMethod: "GET")
            
        SharedSession.sendRequest(req: request, callback: urlResponseCallbackWrapper(callback: callback))
    }
}
