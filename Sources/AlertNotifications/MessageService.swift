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
import CloudEnvironment

public class MessageService {

    // Make a POST request for a Message.
    public class func post(_ message: Message, usingCredentials credentials: AlertNotificationCredentials, callback: ((Message?, Error?) -> Void)? = nil) throws {
        let bluemixRequest = try CloudRequest(usingCredentials: credentials)
        let errors = [400: "The service reported an invalid request.", 401: "Authorization is invalid.", 415: "Invalid media type for message."]
        let bluemixCallback = MessageService.messageCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.postMessage(message, callback: bluemixCallback)
    }
    
    // Make a GET request for a Message.
    public class func get(shortId id: String, usingCredentials credentials: AlertNotificationCredentials, callback: @escaping (Message?, Error?) -> Void) throws {
        let bluemixRequest = try CloudRequest(usingCredentials: credentials)
        let errors = [401: "Authorization is invalid.", 404: "A message matching this short ID could not be found."]
        let bluemixCallback = MessageService.messageCallbackBuilder(statusResponses: errors, withFinalCallback: callback)
        try bluemixRequest.getMessage(shortId: id, callback: bluemixCallback)
    }
    
    // Create a callback function for when we are expecting a Message object in response.
    private class func messageCallbackBuilder(statusResponses: [Int: String], withFinalCallback callback: ((Message?, Error?) -> Void)? = nil) -> (Data?, Int?, Swift.Error?) -> Void {
        return { (data: Data?, statusCode: Int?, error: Swift.Error?) in
            // Possible error #1: error received.
            if let error = error {
                callback?(nil, error)
                Log.error(error.localizedDescription)
                return
            }
            
            // Possible error #2: no response code from the server.
            guard let statusCode = statusCode else {
                callback?(nil, AlertNotificationError.HTTPError("No status code could be obtained."))
                Log.error("No status code could be obtained.")
                return
            }
            
            // Possible error #3: bad response code from the server.
            if let errMessage = statusResponses[statusCode] {
                callback?(nil, AlertNotificationError.ibmCloudError(errMessage))
                Log.error(errMessage)
                return
            }
            
            if let data = data {
                // Possible error #4: malformed response data.
                guard let messageResponse = Message(data: data) else {
                    let dataString = String(data: data, encoding: .utf8)
                    callback?(nil, AlertNotificationError.HTTPError("Malformed response from server: \(String(describing: dataString))"))
                    Log.error("Malformed response from server.")
                    return
                }
                
                // Perform the callback on the data.
                callback?(messageResponse, nil)
            } else {
                // Possible error #5: no data received.
                if let error = error {
                    callback?(nil, error)
                    Log.error(error.localizedDescription)
                } else {
                    callback?(nil, AlertNotificationError.HTTPError("Payload from server is empty."))
                }
                Log.error("Payload from server is empty.")
                return
            }
        }
    }
}
