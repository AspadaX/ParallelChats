//
//  Settings.swift
//  Parallel Chats
//
//  Created by Xinyu Bao on 2024/8/19.
//

import SwiftUI
import Combine

struct SettingsView: View {
    
    @ObservedObject var configurationManager: ConfigurationManager
    
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "apiKey") ?? ""
    @State private var endPoint: String = UserDefaults.standard.string(forKey: "endPoint") ?? "localhost"
    @State private var modelName: String = UserDefaults.standard.string(forKey: "modelName") ?? ""
    @State private var port: Int = UserDefaults.standard.integer(forKey: "port")
    @State private var scheme: String = UserDefaults.standard.string(forKey: "scheme") ?? "http"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Settings")
                .font(.headline)
            TextField("API Key", text: $apiKey)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.bottom, 10)
            TextField("API Endpont", text: $endPoint)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Port", text: Binding(
                    get: { String(port) },
                    set: { port = Int($0) ?? 0 }
                )
            )
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Scheme", text: $scheme)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Divider()
            
            TextField("Model", text: $modelName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button(action: {
                saveSettings()
                configurationManager.updateConfiguration()
            }) {
                Text("Save")
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(2.0)
            }
            
            Spacer()
        }
            .padding()
            .frame(width: 300, height: 300)
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(apiKey, forKey: "apiKey")
        UserDefaults.standard.set(endPoint, forKey: "endPoint")
        UserDefaults.standard.set(port, forKey: "port")
        UserDefaults.standard.set(scheme, forKey: "scheme")
        UserDefaults.standard.set(modelName, forKey: "modelName")
        print("Settings saved!")
    }
}
