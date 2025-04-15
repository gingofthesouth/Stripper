import Foundation
import SwiftTreeSitter
import SwiftTreeSitterLayer
import Rainbow

// Process a single file for comment removal
func processFile(at filePath: String, interactive: Bool, contextLines: Int) throws {
    // Detect the language based on file extension
    guard let language = LanguageConfig.detectLanguage(for: filePath) else {
        throw StripperError.unsupportedFileType
    }
    
    let config = try LanguageConfig(supportedLanguage: language)
    
    // Read the file content
    let content = try String(contentsOfFile: filePath, encoding: .utf8)
    
    var matches = [NamedRange]()
    let nsContent = content as NSString
    
    do {
        // First try: Parse with tree-sitter
        let parser = Parser()
        try parser.setLanguage(config.config.language)
        
        guard let tree = parser.parse(content) else {
            throw StripperError.parsingFailed
        }
        
        // Try to find comments using the language specific query
        let queryString = config.commentQuery
        guard let queryData = queryString.data(using: .utf8) else {
            throw StripperError.queryCreationFailed
        }
        
        let query = try Query(language: config.config.language, data: queryData)
        let cursor = query.execute(in: tree)
        
        // Collect matches using tree-sitter query
        while let match = cursor.next() {
            for capture in match.captures where capture.name == "comment" {
                let node = capture.node
                
                // Get the node's text using its byte range
                let range = node.range
                
                // Ensure the range is valid
                if range.location >= 0 && range.length > 0 && range.location + range.length <= nsContent.length {
                    matches.append(NamedRange(name: "comment", range: range))
                }
            }
        }
    } catch {
        print("⚠️ Tree-sitter query error: \(error.localizedDescription)".yellow)
        
        // Fallback to regex for Swift files
        if language == .swift {
            print("🔄 Falling back to regex-based comment detection for Swift files...".yellow)
            matches = findSwiftCommentsWithRegex(in: content)
        } else {
            // For other languages, provide error details
            if error.localizedDescription.contains("nodeType") {
                let codeString = error.localizedDescription
                let code = Int(codeString.replacingOccurrences(of: "nodeType(", with: "").replacingOccurrences(of: ")", with: "")) ?? 0
                throw StripperError.nodeTypeError(code)
            }
            
            throw error
        }
    }
    
    if matches.isEmpty {
        print("No comments found in file.".yellow)
        return
    }
    
    // Sort matches by location for consistent processing
    matches.sort { $0.range.location < $1.range.location }
    
    if interactive {
        displayCommentSummary(matches: matches, content: content)
        print("\nWould you like to proceed with comment removal? (y/n): ".yellow, terminator: "")
        guard readLine()?.lowercased() == "y" else {
            print("Operation cancelled.".yellow)
            return
        }
    }
    
    var adjustedContent = content
    
    // Process comments in reverse order to avoid line number changes affecting subsequent comments
    for (index, match) in matches.enumerated().reversed() {
        let commentRange = match.range
        let lineNumber = content.lineNumber(for: commentRange.location)
        
        if interactive {
            print("\nComment \(matches.count - index)/\(matches.count):".yellow)
            
            // Display code context (3 lines before and after)
            // Calculate context range
            let lines = content.components(separatedBy: .newlines)
            let currentLine = lineNumber - 1 // Convert to 0-based indexing
            let startLine = max(0, currentLine - contextLines)
            let endLine = min(lines.count - 1, currentLine + contextLines)
            
            // Create line number ranges for the context
            let contextStartOffset = (content as NSString).lineRange(for: NSRange(location: 0, length: 0)).location
            var lineOffsets: [Int] = []
            var currentOffset = contextStartOffset
            
            // Calculate line offsets for mapping
            for i in 0..<lines.count {
                lineOffsets.append(currentOffset)
                currentOffset += (lines[i] as NSString).length + 1 // +1 for newline
                if currentOffset > (content as NSString).length {
                    break
                }
            }
            
            // Find all comments that fall within the context range
            let contextComments = matches.filter { commentMatch in
                let commentLine = content.lineNumber(for: commentMatch.range.location) - 1 // 0-based
                return commentLine >= startLine && commentLine <= endLine
            }
            
            // Print context with line numbers and highlighting for the comment line
            print("\nContext:".cyan)
            for i in startLine...endLine {
                let lineText = lines[i]
                
                // Find actual comment line by checking if this line contains the comment
                let isCurrentCommentLine = i == currentLine
                let linePrefix = isCurrentCommentLine ? "→ ".yellow.bold : "  "
                
                let lineStartOffset = lineOffsets[i]
                let lineEndOffset = i < lineOffsets.count - 1 ? lineOffsets[i + 1] - 1 : (content as NSString).length
                
                // Apply syntax highlighting to line, handling all comments
                var highlightedLine = lineText
                
                // First check if line contains any comments and extract their ranges within this line
                var commentsInLine: [(NSRange, Bool)] = [] // (range, isCurrentComment)
                
                for commentMatch in contextComments {
                    // Calculate if comment intersects with this line
                    let commentStartOffset = commentMatch.range.location
                    let commentEndOffset = commentMatch.range.location + commentMatch.range.length
                    
                    // Check if comment intersects with current line
                    if commentStartOffset <= lineEndOffset && commentEndOffset >= lineStartOffset {
                        // Calculate the comment range within this line
                        let commentStartInLine = max(0, commentStartOffset - lineStartOffset)
                        let commentEndInLine = min(lineText.count, commentEndOffset - lineStartOffset)
                        
                        if commentStartInLine < lineText.count && commentEndInLine > 0 {
                            let rangeInLine = NSRange(location: commentStartInLine, length: commentEndInLine - commentStartInLine)
                            commentsInLine.append((rangeInLine, commentMatch.range == match.range))
                        }
                    }
                }
                
                // Sort comments by location in reverse order to avoid range invalidation
                commentsInLine.sort { $0.0.location > $1.0.location }
                
                // Apply highlighting to non-comment parts of the line
                if commentsInLine.isEmpty {
                    // No comments on this line, apply full syntax highlighting
                    highlightedLine = applySyntaxHighlighting(lineText, language: language)
                } else {
                    // Line has comments, apply syntax highlighting to parts between comments
                    let nsLine = lineText as NSString
                    var result = lineText
                    
                    for (commentRange, isCurrentComment) in commentsInLine {
                        let commentText = nsLine.substring(with: commentRange)
                        let highlightedComment = isCurrentComment ? commentText.yellow.bold : commentText.yellow
                        
                        // Replace the comment in the result
                        result = (result as NSString).replacingCharacters(in: commentRange, with: highlightedComment)
                    }
                    
                    // Now we need to find all non-comment sections and highlight them
                    var lastCommentEnd = 0
                    var resultNS = result as NSString
                    
                    for (commentRange, _) in commentsInLine.sorted(by: { $0.0.location < $1.0.location }) {
                        if commentRange.location > lastCommentEnd {
                            // There's code before this comment
                            let codeRange = NSRange(location: lastCommentEnd, length: commentRange.location - lastCommentEnd)
                            let codeText = nsLine.substring(with: codeRange)
                            let highlightedCode = applySyntaxHighlighting(codeText, language: language)
                            
                            // Need to calculate new range due to potential expansions from highlighting
                            let newCodeRange = NSRange(location: lastCommentEnd, length: codeRange.length)
                            resultNS = (resultNS.replacingCharacters(in: newCodeRange, with: highlightedCode) as NSString)
                        }
                        lastCommentEnd = NSMaxRange(commentRange)
                    }
                    
                    // Handle code after the last comment
                    if lastCommentEnd < nsLine.length {
                        let codeRange = NSRange(location: lastCommentEnd, length: nsLine.length - lastCommentEnd)
                        let codeText = nsLine.substring(with: codeRange)
                        let highlightedCode = applySyntaxHighlighting(codeText, language: language)
                        
                        // Need to calculate new range due to potential expansions from highlighting
                        let newCodeRange = NSRange(location: lastCommentEnd, length: codeRange.length)
                        resultNS = (resultNS.replacingCharacters(in: newCodeRange, with: highlightedCode) as NSString)
                    }
                    
                    highlightedLine = resultNS as String
                }
                
                print("\(linePrefix)\(i + 1): \(highlightedLine)")
            }
            
            print("\nRemove this comment? (y/n): ".yellow, terminator: "")
            
            guard readLine()?.lowercased() == "y" else {
                continue
            }
        }
        
        if isLineOnlyWhitespaceAndComment(in: adjustedContent, commentRange: commentRange) {
            let lineRange = getLineRange(in: adjustedContent, containing: commentRange)
            adjustedContent = (adjustedContent as NSString).replacingCharacters(in: lineRange, with: "")
        } else {
            adjustedContent = (adjustedContent as NSString).replacingCharacters(in: commentRange, with: "")
        }
    }
    
    try adjustedContent.write(toFile: filePath, atomically: true, encoding: .utf8)
    print("\nComments have been removed successfully.".green)
}

// Add a function to recursively process directories
func processDirectory(at directoryPath: String, interactive: Bool, contextLines: Int) throws {
    let fileManager = FileManager.default
    
    // Get all items in directory
    let directoryURL = URL(fileURLWithPath: directoryPath)
    let contents = try fileManager.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: [.isDirectoryKey], options: [.skipsHiddenFiles])
    
    var processedFiles = 0
    var failedFiles = 0
    
    for fileURL in contents {
        let isDirectory = try fileURL.resourceValues(forKeys: [.isDirectoryKey]).isDirectory ?? false
        
        if isDirectory {
            // Recursively process subdirectories
            try processDirectory(at: fileURL.path, interactive: interactive, contextLines: contextLines)
        } else {
            // Process files if a supported language
            if LanguageConfig.detectLanguage(for: fileURL.path) != nil {
                print("\nProcessing file: \(fileURL.lastPathComponent)".cyan)
                do {
                    try processFile(at: fileURL.path, interactive: interactive, contextLines: contextLines)
                    processedFiles += 1
                } catch {
                    print("❌ Error processing file \(fileURL.lastPathComponent): \(error.localizedDescription)".red)
                    failedFiles += 1
                }
            }
        }
    }
    
    print("\nDirectory summary for \(directoryPath):".cyan)
    print("✅ Processed \(processedFiles) files".green)
    if failedFiles > 0 {
        print("❌ Failed to process \(failedFiles) files".red)
    }
} 