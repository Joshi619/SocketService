//
//  Logger.swift
//  pocService
//
//  Created by Aditya on 08/01/25.
//


import Foundation

class Logger: NSObject {
    
    enum LogType: String, CaseIterable {
        case info = "INFORMATION"
        case warning = "WARNING"
        case debug = "DEBUG"
        case error = "ERROR"
        
        var sort: String {
            switch self {
            case .error:
                return "Err"
            case .warning:
                return "WAR"
            case .debug:
                return "DEB"
            case .info:
                return "INF"
            }
        }
    }
    
    static let shared = Logger()
    
    
    func writeLog(_ logType: LogType,_ message: String, FileName: String = "\(CommonDefine.appName)_log") {
        let fileManager = FileManager.default
        let containerURL = fileManager.homeDirectoryForCurrentUser//containerURL(forSecurityApplicationGroupIdentifier: Constant.groupIdentifier)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        
        let logFileURL = containerURL.appending(path: "Logs")
        #if DEBUG
        print("Log file URL: \(logFileURL)")
        #endif
        let fileName = "\(FileName)_\(dateString).log"
        if !fileManager.fileExists(atPath: logFileURL.path) {
            do {
                try fileManager.createDirectory(atPath: logFileURL.path, withIntermediateDirectories: true)
            } catch {
                #if DEBUG
                print("Failed to create directory: \(error)")
                #endif
            }
        }
        
        let dateFormatterTime = DateFormatter()
        dateFormatterTime.dateFormat = "HH:mm:ss"
        let dateStringTime = dateFormatterTime.string(from: Date())
        let logMessage = "\(logType.sort): \(dateStringTime) - \(message)\n"
        #if DEBUG
        print(logMessage)
        #endif
        if let handle = try? FileHandle(forWritingTo: logFileURL.appending(path: fileName)) {
            handle.seekToEndOfFile()
            if let data = logMessage.data(using: .utf8) {
                handle.write(data)
            }
            handle.closeFile()
        } else {
            do {
                try logMessage.write(to: logFileURL.appending(path: fileName), atomically: true, encoding: .utf8)
            } catch {
                #if DEBUG
                print("Error writing log: \(error)")
                #endif
            }
        }
    }
}
