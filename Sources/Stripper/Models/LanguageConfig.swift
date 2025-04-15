import Foundation
import SwiftTreeSitter
import SwiftTreeSitterLayer
import TreeSitterSwift
import TreeSitterC
import TreeSitterCPP
import TreeSitterJavaScript
import TreeSitterTypeScript
import TreeSitterPython
import TreeSitterRuby
import TreeSitterGo
import TreeSitterRust

struct LanguageConfig {
    let config: LanguageConfiguration
    let commentQuery: String
    
    init(supportedLanguage: SupportedLanguage) throws {
        // Custom environment variable to override query directory
        let customQueryDir = ProcessInfo.processInfo.environment["STRIPPER_QUERY_DIR"]
        
        // First try with custom paths, then default
        do {
            switch supportedLanguage {
            case .swift:
                self.config = try LanguageConfiguration(tree_sitter_swift(), name: "Swift")
            case .c:
                self.config = try LanguageConfiguration(tree_sitter_c(), name: "C")
            case .cpp:
                self.config = try LanguageConfiguration(tree_sitter_cpp(), name: "CPP")
            case .javascript:
                self.config = try LanguageConfiguration(tree_sitter_javascript(), name: "JavaScript")
            case .typescript:
                self.config = try LanguageConfiguration(tree_sitter_typescript(), name: "TypeScript")
            case .python:
                self.config = try LanguageConfiguration(tree_sitter_python(), name: "Python")
            case .ruby:
                self.config = try LanguageConfiguration(tree_sitter_ruby(), name: "Ruby")
            case .go:
                self.config = try LanguageConfiguration(tree_sitter_go(), name: "Go")
            case .rust:
                self.config = try LanguageConfiguration(tree_sitter_rust(), name: "Rust")
            }
        } catch {
            // If default paths failed, try custom query directory if available
            let queryPath = customQueryDir ?? FileManager.default.homeDirectoryForCurrentUser.appendingPathComponent(".stripper/queries").path
            
            if FileManager.default.fileExists(atPath: queryPath) {
                let langName = supportedLanguage.rawValue
                let queryPath = "\(queryPath)/\(langName)"
                
                switch supportedLanguage {
                case .swift:
                    self.config = try LanguageConfiguration(tree_sitter_swift(), name: "Swift", queriesURL: URL(fileURLWithPath: queryPath))
                case .c:
                    self.config = try LanguageConfiguration(tree_sitter_c(), name: "C", queriesURL: URL(fileURLWithPath: queryPath))
                case .cpp:
                    self.config = try LanguageConfiguration(tree_sitter_cpp(), name: "CPP", queriesURL: URL(fileURLWithPath: queryPath))
                case .javascript:
                    self.config = try LanguageConfiguration(tree_sitter_javascript(), name: "JavaScript", queriesURL: URL(fileURLWithPath: queryPath))
                case .typescript:
                    self.config = try LanguageConfiguration(tree_sitter_typescript(), name: "TypeScript", queriesURL: URL(fileURLWithPath: queryPath))
                case .python:
                    self.config = try LanguageConfiguration(tree_sitter_python(), name: "Python", queriesURL: URL(fileURLWithPath: queryPath))
                case .ruby:
                    self.config = try LanguageConfiguration(tree_sitter_ruby(), name: "Ruby", queriesURL: URL(fileURLWithPath: queryPath))
                case .go:
                    self.config = try LanguageConfiguration(tree_sitter_go(), name: "Go", queriesURL: URL(fileURLWithPath: queryPath))
                case .rust:
                    self.config = try LanguageConfiguration(tree_sitter_rust(), name: "Rust", queriesURL: URL(fileURLWithPath: queryPath))
                }
            } else {
                throw error  
            }
        }
        
        self.commentQuery = supportedLanguage.commentQuery
    }
    
    static func detectLanguage(for filePath: String) -> SupportedLanguage? {
        let fileExtension = (filePath as NSString).pathExtension.lowercased()
        return SupportedLanguage.allCases.first { language in
            language.fileExtensions.contains(fileExtension)
        }
    }
} 