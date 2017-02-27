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

import KituraNet

import LoggerAPI

class BluemixRequest {
    #if os(macOS)
    let USE_KITURA_NET: Bool = false
    #else
    let USE_KITURA_NET: Bool = true
    #endif
    
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
    
    // Create a URL for a KituraNet request.
    func createKituraNetURL(to baseURL: URL, forType type: String, withMethod method: String, withID id: String?) throws -> URL {
        guard let apiURL = URL(string: "\(type)s/v1/", relativeTo: self.baseURL) else {
            throw AlertNotificationError.credentialsError("Invalid URL provided.")
        }
        var requestURL: URL? = apiURL
        if let id = id {
            requestURL = URL(string: id, relativeTo: apiURL)
        }
        guard let finalURL = requestURL else {
            throw AlertNotificationError.alertError("Invalid alert ID provided to \(method) request.")
        }
        
        return finalURL
    }
    
    // Create KituraNet request.
    func createKituraNetRequest(to baseURL: URL, forType type: String, withMethod method: String, forID id: String? = nil, usingCredentials credentials: ServiceCredentials, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) throws -> ClientRequest {
        let requestURL = try createKituraNetURL(to: baseURL, forType: type, withMethod: method, withID: id)
        
        guard let urlComponents = URLComponents(string: requestURL.absoluteString), let host = urlComponents.host, let schema = urlComponents.scheme else {
            throw AlertNotificationError.credentialsError("Invalid URL provided.")
        }
        var headers = ["Authorization": "Basic \(credentials.authString)"]
        if method == "POST" {
            headers["Content-Type"] = "application/json; charset=utf-8"
        }
        
        let clientCallback: ClientRequest.Callback = { (response: ClientResponse?) in
            do {
                let dataString = try response?.readString()
                let responseData = dataString?.data(using: String.Encoding.utf8)
                callback(responseData, response?.httpStatusCode.rawValue, nil)
            } catch {
                Log.error(error.localizedDescription)
                callback(nil, response?.httpStatusCode.rawValue, error)
            }
        }
        
        let options: [ClientRequest.Options] = [.method(method), .hostname(host), .path(urlComponents.path), .schema(schema), .headers(headers)]
        return HTTP.request(options, callback: clientCallback)
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
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, forType: "alert", withMethod: "POST", usingCredentials: credentials, callback: callback)
            
            guard let alertJSON = try alert.toJSONData() else {
                throw AlertNotificationError.alertError("Error forming POST request to server: could not convert alert object to JSON.")
            }
            req.write(from: alertJSON)
            req.end()
        } else {
            guard let apiURL = URL(string: "alerts/v1/", relativeTo: self.baseURL) else {
                throw AlertNotificationError.credentialsError("Invalid URL provided.")
            }
            var request: URLRequest = URLRequest(url: apiURL)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            let alertJSON = try alert.toJSONData()
            request.httpBody = alertJSON
            
            SharedSession.sendRequest(req: request, callback: urlResponseCallbackWrapper(callback: callback))
        }
    }
    
    func getAlert(shortId id: String, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, forType: "alert", withMethod: "GET", forID: id, usingCredentials: credentials, callback: callback)
            req.end()
        } else {
            guard let apiURL = URL(string: "alerts/v1/", relativeTo: self.baseURL) else {
                throw AlertNotificationError.credentialsError("Invalid URL provided.")
            }
            guard let fullURL = URL(string: id, relativeTo: apiURL) else {
                throw AlertNotificationError.alertError("Invalid alert ID provided to GET request.")
            }
            var request: URLRequest = URLRequest(url: fullURL)
            request.httpMethod = "GET"
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            SharedSession.sendRequest(req: request, callback: urlResponseCallbackWrapper(callback: callback))
        }
    }
    
    func deleteAlert(shortId id: String, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, forType: "alert", withMethod: "DELETE", forID: id, usingCredentials: credentials, callback: callback)
            req.end()
        } else {
            guard let apiURL = URL(string: "alerts/v1/", relativeTo: self.baseURL) else {
                throw AlertNotificationError.credentialsError("Invalid URL provided.")
            }
            guard let fullURL: URL = URL(string: id, relativeTo: apiURL) else {
                throw AlertNotificationError.alertError("Invalid alert ID provided to DELETE request.")
            }
            var request: URLRequest = URLRequest(url: fullURL)
            request.httpMethod = "DELETE"
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            SharedSession.sendRequest(req: request, callback: urlResponseCallbackWrapper(callback: callback))
        }
    }
    
    /*
     * Message requests.
     */
    
    func postMessage(_ message: Message, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, forType: "message", withMethod: "POST", usingCredentials: credentials, callback: callback)
            
            guard let messageJSON = try message.toJSONData() else {
                throw AlertNotificationError.messageError("Error forming POST request to server: could not convert message object to JSON.")
            }
            req.write(from: messageJSON)
            req.end()
        } else {
            guard let apiURL = URL(string: "messages/v1/", relativeTo: self.baseURL) else {
                throw AlertNotificationError.credentialsError("Invalid URL provided.")
            }
            var request: URLRequest = URLRequest(url: apiURL)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            let messageJSON = try message.toJSONData()
            request.httpBody = messageJSON
            
            SharedSession.sendRequest(req: request, callback: urlResponseCallbackWrapper(callback: callback))
        }
    }
    
    func getMessage(shortId id: String, callback: @escaping (Data?, Int?, Swift.Error?) -> Void) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, forType: "message", withMethod: "GET", forID: id, usingCredentials: credentials, callback: callback)
            req.end()
        } else {
            guard let apiURL = URL(string: "messages/v1/", relativeTo: self.baseURL) else {
                throw AlertNotificationError.credentialsError("Invalid URL provided.")
            }
            guard let fullURL = URL(string: id, relativeTo: apiURL) else {
                throw AlertNotificationError.messageError("Invalid message ID provided to GET request.")
            }
            var request: URLRequest = URLRequest(url: fullURL)
            request.httpMethod = "GET"
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            SharedSession.sendRequest(req: request, callback: urlResponseCallbackWrapper(callback: callback))
        }
    }
}
