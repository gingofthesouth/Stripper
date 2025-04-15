import Foundation
import Rainbow

// Display a summary of all comments found in the file
func displayCommentSummary(matches: [NamedRange], content: String) {
    print("\n=== Comment Summary ===".cyan.bold)
    print("Total comments found: \(matches.count)".bold)
    print(String(repeating: "─", count: 50))
    
    for (index, match) in matches.enumerated() {
        let lineNumber = content.lineNumber(for: match.range.location)
        let commentText = (content as NSString).substring(with: match.range)
        let trimmedComment = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("#\(index + 1) [Line \(lineNumber)]: \(trimmedComment)".yellow)
    }
    
    print(String(repeating: "─", count: 50) + "\n")
}

// A fallback function for finding Swift comments using regex
func findSwiftCommentsWithRegex(in content: String) -> [NamedRange] {
    var matches = [NamedRange]()
    let nsContent = content as NSString
    
    // Regex patterns for Swift comments
    let patterns = [
        // Single line comments
        try? NSRegularExpression(pattern: "//.*$", options: [.anchorsMatchLines]),
        // Multi-line comments
        try? NSRegularExpression(pattern: "/\\*[\\s\\S]*?\\*/", options: [])
    ]
    
    for pattern in patterns.compactMap({ $0 }) {
        let range = NSRange(location: 0, length: nsContent.length)
        let matches1 = pattern.matches(in: content, options: [], range: range)
        
        for match in matches1 {
            matches.append(NamedRange(name: "comment", range: match.range))
        }
    }
    
    return matches
}

// Check if a line contains only whitespace and comment
func isLineOnlyWhitespaceAndComment(in content: String, commentRange: NSRange) -> Bool {
    let lineRange = getLineRange(in: content, containing: commentRange)
    let beforeComment = (content as NSString).substring(with: NSRange(location: lineRange.location, length: commentRange.location - lineRange.location))
    return beforeComment.trimmingCharacters(in: .whitespaces).isEmpty
}

// Get the range of the entire line containing a comment
func getLineRange(in content: String, containing range: NSRange) -> NSRange {
    let string = content as NSString
    let start = string.lineRange(for: NSRange(location: range.location, length: 0))
    let end = string.lineRange(for: NSRange(location: NSMaxRange(range), length: 0))
    return NSRange(location: start.location, length: NSMaxRange(end) - start.location)
}

// Helper function to get highlight queries for different languages
func getHighlightQueryForLanguage(_ language: SupportedLanguage) -> String {
    switch language {
    case .swift:
        return """
        ; Basic Comments - simplified pattern
        (comment) @comment
        
        ; Keywords
        "class" @keyword
        "struct" @keyword
        "enum" @keyword
        "protocol" @keyword
        "extension" @keyword
        "func" @keyword
        "var" @keyword
        "let" @keyword
        "if" @keyword
        "else" @keyword
        "guard" @keyword
        "return" @keyword
        "while" @keyword
        "for" @keyword
        "in" @keyword
        "import" @keyword
        """
    case .c, .cpp:
        return """
        ; Comments
        (comment) @comment
        
        ; Keywords
        [
          "if"
          "else"
          "switch"
          "case"
          "default"
          "break"
          "return"
          "for"
          "while"
          "do"
          "continue"
          "typedef"
          "struct"
          "enum"
          "union"
        ] @keyword
        """
    case .javascript, .typescript:
        return """
        ; Comments
        (comment) @comment
        
        ; Keywords
        [
          "if"
          "else"
          "switch"
          "case"
          "default"
          "break"
          "return"
          "for"
          "while"
          "do"
          "continue"
          "function"
          "class"
          "const"
          "let"
          "var"
        ] @keyword
        """
    case .python:
        return """
        ; Comments
        (comment) @comment
        
        ; Keywords
        [
          "if"
          "elif"
          "else"
          "def"
          "class"
          "return"
          "import"
          "from"
          "as"
          "try"
          "except"
          "finally"
          "raise"
          "with"
        ] @keyword
        """
    case .ruby:
        return """
        ; Comments
        (comment) @comment
        
        ; Keywords
        [
          "if"
          "elsif"
          "else"
          "unless"
          "class"
          "module"
          "def"
          "end"
          "return"
          "begin"
          "rescue"
          "ensure"
        ] @keyword
        """
    case .go:
        return """
        ; Comments
        (comment) @comment
        
        ; Keywords
        [
          "if"
          "else"
          "switch"
          "case"
          "default"
          "break"
          "return"
          "for"
          "func"
          "type"
          "struct"
          "interface"
          "package"
          "import"
          "var"
          "const"
        ] @keyword
        """
    case .rust:
        return """
        ; Comments
        (line_comment) @comment
        (block_comment) @comment
        
        ; Keywords
        [
          "if"
          "else"
          "match"
          "fn"
          "struct"
          "enum"
          "impl"
          "trait"
          "pub"
          "let"
          "mut"
          "return"
          "use"
          "mod"
        ] @keyword
        """
    }
} 