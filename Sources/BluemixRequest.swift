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

class BluemixRequest {
    let USE_KITURA_NET: Bool = false
    
    /*
     * Instance veriables and methods.
     */
    
    // Common variables.
    let type: RequestType
    let baseURL: URL
    let credentials: ServerCredentials
    
    // Initializer.
    init?(type: RequestType, usingCredentials credentials: ServerCredentials) {
        self.type = type
        self.credentials = credentials
        
        guard let baseURL = URL(string: "\(credentials.url)/\(type.rawValue.lowercased())s/v1/") else {
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
    func createKituraNetRequest(to baseURL: URL, withMethod method: String, forID id: String? = nil, usingCredentials credentials: ServerCredentials, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) throws -> ClientRequest {
        let requestURL: URL? = id != nil ? URL(string: id!, relativeTo: baseURL) : baseURL
        if requestURL == nil {
            throw AlertNotificationError.AlertError("Invalid alert ID provided to \(method) request.")
        }
        
        guard let urlComponents = URLComponents(string: requestURL!.absoluteString), let host = urlComponents.host, let schema = urlComponents.scheme else {
            throw AlertNotificationError.AlertError("Invalid URL provided.")
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
                if callback != nil {
                    callback!(responseData, httpResponse, nil)
                }
            } catch {
                Log.error(error.localizedDescription)
                if callback != nil {
                    callback!(nil, httpResponse, error)
                }
            }
        }
        
        let options: [ClientRequest.Options] = [.method(method), .hostname(host), .path(urlComponents.path), .schema(schema), .headers(headers)]
        return HTTP.request(options, callback: clientCallback)
    }
    
    // Submit URLSession request.
    func sendRequest(req: URLRequest, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) {
        let session: URLSession = createSession()
        let reqTask = session.dataTask(with: req) { (data, response, error) in
            if callback != nil {
                callback!(data, response, error)
            }
        }
        reqTask.resume()
        session.finishTasksAndInvalidate()
    }
    
    /*
     * Alert requests.
     */
    
    func postAlert(_ alert: Alert, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, withMethod: "POST", usingCredentials: credentials, callback: callback)
            
            let alertBody = try alert.postBody()
            req.write(from: alertBody!)
            req.end()
        } else {
            var request: URLRequest = URLRequest(url: self.baseURL)
            request.httpMethod = "POST"
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            let alertBody = try alert.postBody()
            request.httpBody = alertBody
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    func getAlert(shortId id: String, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, withMethod: "GET", forID: id, usingCredentials: credentials, callback: callback)
            req.end()
        } else {
            guard let fullUrl: URL = URL(string: id, relativeTo: self.baseURL) else {
                throw AlertNotificationError.AlertError("Invalid alert ID provided to GET request.")
            }
            var request: URLRequest = URLRequest(url: fullUrl)
            request.httpMethod = "GET"
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    func deleteAlert(shortId id: String, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) throws {
        if self.USE_KITURA_NET {
            let req: ClientRequest = try self.createKituraNetRequest(to: self.baseURL, withMethod: "DELETE", forID: id, usingCredentials: credentials, callback: callback)
            req.end()
        } else {
            guard let fullUrl: URL = URL(string: id, relativeTo: self.baseURL) else {
                throw AlertNotificationError.AlertError("Invalid alert ID provided to DELETE request.")
            }
            var request: URLRequest = URLRequest(url: fullUrl)
            request.httpMethod = "DELETE"
            request.setValue("Basic \(credentials.authString)", forHTTPHeaderField: "Authorization")
            
            self.sendRequest(req: request, callback: callback)
        }
    }
    
    /*
     * Message requests.
     */
    
    func postMessage(message: Message, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) throws {
        if self.USE_KITURA_NET {
            
        } else {
            
        }
    }
    
    func getMessage(shortId id: String, callback: ((Data?, URLResponse?, Swift.Error?) -> Void)? = nil) throws {
        if self.USE_KITURA_NET {
            
        } else {
            
        }
    }
}
