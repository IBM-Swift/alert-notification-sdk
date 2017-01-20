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
import SwiftyJSON
import CloudFoundryEnv

public struct Configuration {
    let configurationFile: String
    let appEnv: AppEnv
    
    public enum ConfigError: Error {
        case Error(String)
    }
    
    public init(withFile configFile: String) throws {
        configurationFile = configFile
        let path = Configuration.getAbsolutePath(relativePath: "/\(configurationFile)", useFallback: false)
        
        guard let finalPath = path else {
            Log.warning("Could not find '\(configFile)'.")
            appEnv = try CloudFoundryEnv.getAppEnv()
            return
        }
        
        let url = URL(fileURLWithPath: finalPath)
        let configData = try Data(contentsOf: url)
        let configJson = JSON(data: configData)
        guard configJson.type == .dictionary, let configDict = configJson.object as? [String: Any] else {
            Log.error("Invalid format for configuration file.")
            throw ConfigError.Error("Invalid format for configuration file.")
        }
        appEnv = try CloudFoundryEnv.getAppEnv(options: configDict)
        Log.info("Using configuration values from '\(configurationFile)'.")
    }
    
    public func getCredentials(forService service: String) -> [String: Any]? {
        return appEnv.getService(spec: service)?.credentials
    }
    
    public func getPort() -> Int {
        return appEnv.port
    }
    
    private static func getAbsolutePath(relativePath: String, useFallback: Bool) -> String? {
        let initialPath = #file
        let fileManager = FileManager.default
        
        // We need to search for the root directory of the package
        // by searching for Package.swift.
        let components = initialPath.characters.split(separator: "/").map(String.init)
        var rootPath = initialPath
        var filePath = ""
        for index in stride(from: components.count-1, through: 0, by: -1) {
            let subArray = components[0...index]
            rootPath = "/" + subArray.joined(separator: "/")
            if fileManager.fileExists(atPath: rootPath + "/Package.swift") {
                filePath = rootPath + "/" + relativePath
                break
            }
        }
        if filePath == "" {
            return nil
        }
        
        if fileManager.fileExists(atPath: filePath) {
            return filePath
        } else if useFallback {
            let currentPath = fileManager.currentDirectoryPath
            filePath = currentPath + relativePath
            if fileManager.fileExists(atPath: filePath) {
                return filePath
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
