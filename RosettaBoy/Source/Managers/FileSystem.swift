//
//  FileManager.swift
//  RosettaBoy
//
//  Created by Wender on 23/05/24.
//

import Foundation

struct FileSystem {
    
    private func copyResourcesToDocuments() {
        let resources = Bundle.main.paths(forResourcesOfType: "gb", inDirectory: nil)
        
        guard let destiny = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first else {
            fatalError("documents not found")
        }
        
        for resource in resources {
            let destinyFile = "\(destiny)/" + URL(string: resource)!.lastPathComponent
            
            if !FileManager.default.fileExists(atPath: destinyFile, isDirectory: nil) {
                do {
                    try FileManager.default.copyItem(atPath: resource, toPath: destinyFile)
                    print("copied \(resource)")
                } catch let e {
                    print(e)
                }
            } else {
                print("copy skipped. File already exists \(resource)")
            }
          
        }
    }
    
    func readBundleItem(named: String) -> String? {
        let resources = Bundle.main.paths(forResourcesOfType: nil, inDirectory: nil)
        return resources.first { $0.hasSuffix(named) }
    }
    
    func readItem(at: URL) -> Data {
        let handle = try! FileHandle(forReadingFrom: at) // TODO: proper nullable management
        let bytes = handle.readDataToEndOfFile()
        
        try! handle.close()
        
        return bytes
        
    }
}
