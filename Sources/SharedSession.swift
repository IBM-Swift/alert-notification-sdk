//
//  SharedSession.swift
//  AlertNotifications
//
//  Created by Jim Avery on 12/22/16.
//
//

import Foundation

class SharedSession {
    private static let sharedInstance: URLSession = URLSession(configuration: URLSessionConfiguration.`default`)
    
    class func sendRequest(req: URLRequest, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) {
        let reqTask = SharedSession.sharedInstance.dataTask(with: req, completionHandler: callback)
        reqTask.resume()
    }
}
