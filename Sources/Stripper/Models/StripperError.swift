import Foundation

enum StripperError: Error, LocalizedError {
    case parsingFailed
    case queryCreationFailed
    case languageInitFailed
    case fileAccessError(String)
    case fileWriteError(String)
    case unsupportedFileType
    case invalidRange(String)
    case queryDirectoryNotReadable(String)
    case nodeTypeError(Int)
    
    var errorDescription: String? {
        switch self {
        case .parsingFailed:
            return "Failed to parse the source code. The file might be corrupted or contain invalid syntax."
        case .queryCreationFailed:
            return "Failed to create comment query. This might be due to an unsupported language configuration."
        case .languageInitFailed:
            return "Failed to initialize language parser. Please ensure the language is properly supported."
        case .fileAccessError(let path):
            return "Failed to access file at path: \(path)"
        case .fileWriteError(let path):
            return "Failed to write changes to file at path: \(path)"
        case .unsupportedFileType:
            return "Unsupported file type"
        case .invalidRange(let details):
            return "Invalid range encountered: \(details)"
        case .queryDirectoryNotReadable(let path):
            return "Query directory not readable at: \(path)\nPlease run 'make setup-queries' to create the necessary query files."
        case .nodeTypeError(let code):
            return "Unexpected node type error (\(code)). Try refreshing query files with 'make reset-queries'."
        }
    }
} 