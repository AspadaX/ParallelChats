//
//  ConfigurationManager.swift
//  Parallel Chats
//
//  Created by Xinyu Bao on 2024/8/19.
//

import SwiftUI
import OpenAI
import Combine

class ConfigurationManager: ObservableObject {
    @Published var configuration: OpenAI.Configuration
    
    init() {
        self.configuration = Self.getConfiguration()
    }
    
    func updateConfiguration() {
        self.configuration = Self.getConfiguration()
    }
    
    static func getConfiguration() -> OpenAI.Configuration {
        let token = UserDefaults.standard.string(forKey: "apiKey") ?? ""
        let host = UserDefaults.standard.string(forKey: "endPoint") ?? "localhost"
        var port = UserDefaults.standard.integer(forKey: "port")
        let scheme = UserDefaults.standard.string(forKey: "scheme") ?? "http"
        
        if port == 0 {
            port = 443
        }
        
        return OpenAI.Configuration(
            token: token,
            host: host,
            port: port,
            scheme: scheme
        )
    }
}
