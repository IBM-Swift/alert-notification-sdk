//
//  BluemixRequest.swift
//  AlertNotifications
//
//  Created by Jim Avery on 12/5/16.
//
//

import Foundation

import KituraNet

import LoggerAPI

internal class BluemixRequest {
    let USE_KITURA_NET: Bool = false
    
    /*
     * Instance veriables and methods.
     */
    
    // Common variables.
    let baseURL: URL
    let credentials: ServerCredentials
    
    // Initializer.
    init?(usingCredentials credentials: ServerCredentials) {
        self.credentials = credentials
        guard let baseURL = URL(string: "\(credentials.url)/") else {
            Log.error("Invalid URL provided.")
            return nil
        }
        self.baseURL = baseURL
    }
    
    // Convert a Kitura response to a HTTPURLResponse.
    func convertResponse(_ response: ClientResponse?) -> HTTPURLResponse? {
        if response == nil {
            return nil
        }
        
        guard let httpResponse = HTTPURLResponse(url: response!.urlComponents.url!, statusCode: response!.status, httpVersion: "HTTP/\(response!.httpVersionMajor).\(response!.httpVersionMinor)", headerFields: nil) else {
            return nil
        }
        return httpResponse
    }
    
    // Create KituraNet request.
    func createKituraNetRequest(to baseURL: URL, forType type: String, withMethod method: String, forID id: String? = nil, usingCredentials credentials: ServerCredentials, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) throws -> ClientRequest {
        guard let apiURL = URL(string: "\(type)s/v1/", relativeTo: self.baseURL) else {
            throw AlertNotificationError.CredentialsError("Invalid URL provided.")
        }
        let requestURL: URL? = id != nil ? URL(string: id!, relativeTo: apiURL) : apiURL
        if requestURL == nil {
            throw AlertNotificationError.AlertError("Invalid alert ID provided to \(method) request.")
        }
        
        guard let urlComponents = URLComponents(string: requestURL!.absoluteString), let host = urlComponents.host, let schema = urlComponents.scheme else {
            throw AlertNotificationError.CredentialsError("Invalid URL provided.")
        }
        var headers = ["Authorization": "Basic \(credentials.authString)"]
        if method == "POST" {
            headers["Content-Type"] = "application/json; charset=utf-8"
        }
        
        let clientCallback: ClientRequest.Callback = { (response: ClientResponse?) in
            let httpResponse = self.convertResponse(response)
            do {
                let dataString = try response?.readString()
                let responseData = dataString != nil ? dataString!.data(using: String.Encoding.utf8) : nil
                callback(responseData, httpResponse, nil)
            } catch {
                Log.error(error.localizedDescription)
                callback(nil, httpResponse, error)
            }
        }
        
        let options: [ClientRequest.Options] = [.method(method), .hostname(host), .path(urlComponents.path), .schema(schema), .headers(headers)]
        return HTTP.request(options, callback: clientCallback)
    }
    
    // Submit URLSession request.
    func sendRequest(req: URLRequest, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) {
        let session: URLSession = createSession()
        let reqTask = session.dataTask(with: req, completionHandler: callback)
        reqTask.resume()
        session.finishTasksAndInvalidate()
    }
    
    /*
     * Alert requests.
     */
    
    func postAlert(_ alert: Alert, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, forType: "alert", withMethod: "POST", usingCredentials: credentials, callback: callback)
            
            let alertJSON = try alert.toJSONData()
            req.write(from: alertJSON!)
            req.end()
        } else {
            guard let apiURL = URL(string: "alerts/v1/", relativeTo: self.baseURL) else {
                throw AlertNotificationError.CredentialsError("Invalid URL provided.")
            }
            var request: URLRequest = URLRequest(url: apiURL)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            let alertJSON = try alert.toJSONData()
            request.httpBody = alertJSON
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    func getAlert(shortId id: String, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, forType: "alert", withMethod: "GET", forID: id, usingCredentials: credentials, callback: callback)
            req.end()
        } else {
            guard let apiURL = URL(string: "alerts/v1/", relativeTo: self.baseURL) else {
                throw AlertNotificationError.CredentialsError("Invalid URL provided.")
            }
            guard let fullURL = URL(string: id, relativeTo: apiURL) else {
                throw AlertNotificationError.AlertError("Invalid alert ID provided to GET request.")
            }
            var request: URLRequest = URLRequest(url: fullURL)
            request.httpMethod = "GET"
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    func deleteAlert(shortId id: String, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, forType: "alert", withMethod: "DELETE", forID: id, usingCredentials: credentials, callback: callback)
            req.end()
        } else {
            guard let apiURL = URL(string: "alerts/v1/", relativeTo: self.baseURL) else {
                throw AlertNotificationError.CredentialsError("Invalid URL provided.")
            }
            guard let fullURL: URL = URL(string: id, relativeTo: apiURL) else {
                throw AlertNotificationError.AlertError("Invalid alert ID provided to DELETE request.")
            }
            var request: URLRequest = URLRequest(url: fullURL)
            request.httpMethod = "DELETE"
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    /*
     * Message requests.
     */
    
    func postMessage(_ message: Message, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, forType: "message", withMethod: "POST", usingCredentials: credentials, callback: callback)
            
            let messageJSON = try message.toJSONData()
            req.write(from: messageJSON!)
            req.end()
        } else {
            guard let apiURL = URL(string: "messages/v1/", relativeTo: self.baseURL) else {
                throw AlertNotificationError.CredentialsError("Invalid URL provided.")
            }
            var request: URLRequest = URLRequest(url: apiURL)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            let messageJSON = try message.toJSONData()
            request.httpBody = messageJSON
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    func getMessage(shortId id: String, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, forType: "message", withMethod: "GET", forID: id, usingCredentials: credentials, callback: callback)
            req.end()
        } else {
            guard let apiURL = URL(string: "messages/v1/", relativeTo: self.baseURL) else {
                throw AlertNotificationError.CredentialsError("Invalid URL provided.")
            }
            guard let fullURL = URL(string: id, relativeTo: apiURL) else {
                throw AlertNotificationError.MessageError("Invalid message ID provided to GET request.")
            }
            var request: URLRequest = URLRequest(url: fullURL)
            request.httpMethod = "GET"
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            self.sendRequest(req: request, callback: callback)
        }
    }
}
