import Foundation

enum SupportedLanguage: String, CaseIterable {
    case swift, c, cpp, javascript, typescript, python, ruby, go, rust
    
    var fileExtensions: [String] {
        switch self {
        case .swift: return ["swift"]
        case .c: return ["c", "h"]
        case .cpp: return ["cpp", "hpp", "cc", "hh"]
        case .javascript: return ["js", "jsx"]
        case .typescript: return ["ts", "tsx"]
        case .python: return ["py", "pyw"]
        case .ruby: return ["rb"]
        case .go: return ["go"]
        case .rust: return ["rs"]
        }
    }
    
    var commentQuery: String {
        switch self {
        case .swift:
            return """
            (comment) @comment
            (line_comment) @comment
            (multiline_comment) @comment
            """
        case .python:
            return """
            (comment) @comment
            """
        case .c, .cpp:
            return """
            (comment) @comment
            """
        case .javascript, .typescript:
            return """
            (comment) @comment
            """
        case .ruby:
            return """
            (comment) @comment
            """
        case .go:
            return """
            (comment) @comment
            """
        case .rust:
            return """
            (line_comment) @comment
            (block_comment) @comment
            """
        }
    }
} 