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

class SharedSession {
    private static let sharedInstance: URLSession = URLSession(configuration: URLSessionConfiguration.`default`)
    
    // Make a URLRequest using the static shared URLSession object.
    class func sendRequest(req: URLRequest, callback: @escaping (Data?, URLResponse?, Swift.Error?) -> Void) {
        let reqTask = SharedSession.sharedInstance.dataTask(with: req, completionHandler: callback)
        reqTask.resume()
    }
}
