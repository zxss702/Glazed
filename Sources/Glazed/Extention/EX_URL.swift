//
//  EX_URL.swift
//  noteE
//
//  Created by 张旭晟 on 2023/1/14.
//

import Foundation

extension URL{
    init(){
        self.init(fileURLWithPath: "")
    }
    
    func isDirectory() -> Bool {
        var directoryExists = ObjCBool(false)
        let fileExists = FileManager.default.fileExists(atPath: self.path, isDirectory: &directoryExists)
        return fileExists && directoryExists.boolValue
    }
    
    func append(path: String) -> Self {
        return self.appendingPathComponent(path)
    }
}
