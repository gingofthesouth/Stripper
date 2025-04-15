import Foundation
import ArgumentParser
import SwiftTreeSitter
import SwiftTreeSitterLayer
import Rainbow

struct Stripper: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "stripper",
        abstract: "A tool to strip comments from source code files.",
        version: "1.0.0"
    )
    
    @Argument(help: "Path to the file or directory to process")
    var path: String
    
    @Flag(name: .shortAndLong, help: "Run in non-interactive mode")
    var nonInteractive = false
    
    @Option(name: .long, help: "Number of context lines to display before and after each comment (default: 3)")
    var contextLines: Int = 3
    
    mutating func run() throws {
        let fileManager = FileManager.default
        var isDirectory: ObjCBool = false
        
        // Check if path exists
        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
            throw StripperError.fileAccessError(path)
        }
        
        do {
            if isDirectory.boolValue {
                // Process directory
                print("Processing directory: \(path)".cyan)
                try processDirectory(at: path, interactive: !nonInteractive, contextLines: contextLines)
            } else {
                // Process single file
                try processFile(at: path, interactive: !nonInteractive, contextLines: contextLines)
            }
        } catch let error as NSError where error.localizedDescription.contains("nodeType") {
            // Handle nodeType errors by recreating query files
            let codeString = error.localizedDescription
            let code = Int(codeString.replacingOccurrences(of: "nodeType(", with: "").replacingOccurrences(of: ")", with: "")) ?? 0
            
            print("⚠️ Node type error detected (\(code)). Recreating query files...".yellow)
            
            // Force recreation of query files
            let fileManager = FileManager.default
            let queryDir = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".stripper/queries").path
            
            do {
                // Remove existing query dir if it exists
                if fileManager.fileExists(atPath: queryDir) {
                    try fileManager.removeItem(atPath: queryDir)
                    print("🧹 Removed existing query directory".yellow)
                }
                
                // Create fresh query files
                if createQueryFiles() {
                    // Try again with the newly created queries
                    print("🔄 Retrying...".yellow)
                    if isDirectory.boolValue {
                        try processDirectory(at: path, interactive: !nonInteractive, contextLines: contextLines)
                    } else {
                        try processFile(at: path, interactive: !nonInteractive, contextLines: contextLines)
                    }
                } else {
                    throw StripperError.nodeTypeError(code)
                }
            } catch {
                print("❌ Error recreating query files: \(error.localizedDescription)".red)
                throw StripperError.nodeTypeError(code)
            }
        } catch StripperError.queryCreationFailed {
            // If query creation failed, try to recreate query files
            print("⚠️ Failed to create query. Recreating query files...".yellow)
            
            // Force recreation of query files
            let fileManager = FileManager.default
            let queryDir = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".stripper/queries").path
            
            do {
                // Remove existing query dir if it exists
                if fileManager.fileExists(atPath: queryDir) {
                    try fileManager.removeItem(atPath: queryDir)
                    print("🧹 Removed existing query directory".yellow)
                }
                
                // Create fresh query files
                if createQueryFiles() {
                    // Try again with the newly created queries
                    print("🔄 Retrying...".yellow)
                    if isDirectory.boolValue {
                        try processDirectory(at: path, interactive: !nonInteractive, contextLines: contextLines)
                    } else {
                        try processFile(at: path, interactive: !nonInteractive, contextLines: contextLines)
                    }
                } else {
                    throw StripperError.queryCreationFailed
                }
            } catch {
                print("❌ Error recreating query files: \(error.localizedDescription)".red)
                throw StripperError.queryCreationFailed
            }
        } catch let error as NSError where error.domain == "TSLanguageConfigurationErrorDomain" {
            let errorMessage = error.userInfo["NSLocalizedDescription"] as? String ?? error.localizedDescription
            if errorMessage.contains("queries") {
                print("⚠️ Query directory not found. Creating query files...".yellow)
                
                if createQueryFiles() {
                    // Try again with the newly created queries
                    if isDirectory.boolValue {
                        try processDirectory(at: path, interactive: !nonInteractive, contextLines: contextLines)
                    } else {
                        try processFile(at: path, interactive: !nonInteractive, contextLines: contextLines)
                    }
                } else {
                    let homeDir = FileManager.default.homeDirectoryForCurrentUser.path
                    let queryDir = "\(homeDir)/.stripper/queries"
                    throw StripperError.queryDirectoryNotReadable("Failed to create query directory at \(queryDir). Try running 'make setup-queries' manually.")
                }
            } else {
                throw error
            }
        }
    }
}

Stripper.main()