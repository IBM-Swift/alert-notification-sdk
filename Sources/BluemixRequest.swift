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
    let USE_KITURA_NET: Bool = true
    
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
    
    // Convert a Kitura response to a HTTPURLResponse.
    func convertResponse(_ response: ClientResponse?) -> HTTPURLResponse? {
        guard let responseURL = response?.urlComponents.url, let responseStatus = response?.status, let httpResponse = HTTPURLResponse(url: responseURL, statusCode: responseStatus, httpVersion: "HTTP/\(response?.httpVersionMajor).\(response?.httpVersionMinor)", headerFields: nil) else {
            return nil
        }
        return httpResponse
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
    func createKituraNetRequest(to baseURL: URL, forType type: String, withMethod method: String, forID id: String? = nil, usingCredentials credentials: ServiceCredentials, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) throws -> ClientRequest {
        let requestURL = try createKituraNetURL(to: baseURL, forType: type, withMethod: method, withID: id)
        
        guard let urlComponents = URLComponents(string: requestURL.absoluteString), let host = urlComponents.host, let schema = urlComponents.scheme else {
            throw AlertNotificationError.credentialsError("Invalid URL provided.")
        }
        var headers = ["Authorization": "Basic \(credentials.authString)"]
        if method == "POST" {
            headers["Content-Type"] = "application/json; charset=utf-8"
        }
        
        let clientCallback: ClientRequest.Callback = { (response: ClientResponse?) in
            let httpResponse = self.convertResponse(response)
            do {
                let dataString = try response?.readString()
                let responseData = dataString?.data(using: String.Encoding.utf8)
                callback(responseData, httpResponse, nil)
            } catch {
                Log.error(error.localizedDescription)
                callback(nil, httpResponse, error)
            }
        }
        
        let options: [ClientRequest.Options] = [.method(method), .hostname(host), .path(urlComponents.path), .schema(schema), .headers(headers)]
        return HTTP.request(options, callback: clientCallback)
    }
    
    // Create a URLSession for a request.
    func createSession() -> URLSession {
        let basicConfig = URLSessionConfiguration.`default`
        return URLSession(configuration: basicConfig)
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
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    func getAlert(shortId id: String, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) throws {
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
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    func deleteAlert(shortId id: String, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) throws {
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
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    /*
     * Message requests.
     */
    
    func postMessage(_ message: Message, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) throws {
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
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    func getMessage(shortId id: String, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) throws {
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
            
            self.sendRequest(req: request, callback: callback)
        }
    }
}
