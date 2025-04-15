import Foundation
import Rainbow

func applySyntaxHighlighting(_ code: String, language: SupportedLanguage) -> String {
    var result = code
    
    // Define patterns for different languages
    var patterns: [(NSRegularExpression, (String) -> String)] = []
    
    switch language {
    case .swift:
        patterns = [
            (try! NSRegularExpression(pattern: "\\b(class|struct|enum|protocol|extension|func|var|let|if|else|guard|return|while|for|in|import|switch|case|default|break|continue|where|self|throw|throws|try|catch)\\b", options: []), { $0.cyan }),
            (try! NSRegularExpression(pattern: "\\b[A-Z][A-Za-z0-9_]*\\b", options: []), { $0.green }),
            (try! NSRegularExpression(pattern: "\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"", options: []), { $0.red }),
            (try! NSRegularExpression(pattern: "\\b[0-9]+\\b", options: []), { $0.blue }),
        ]
    case .c, .cpp:
        patterns = [
            (try! NSRegularExpression(pattern: "\\b(if|else|switch|case|default|break|return|for|while|do|continue|typedef|struct|enum|union|void|int|char|float|double|long|unsigned|const|static)\\b", options: []), { $0.cyan }),
            (try! NSRegularExpression(pattern: "\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"", options: []), { $0.red }),
            (try! NSRegularExpression(pattern: "\\b[0-9]+\\b", options: []), { $0.blue }),
        ]
    case .javascript, .typescript:
        patterns = [
            (try! NSRegularExpression(pattern: "\\b(var|let|const|function|class|if|else|switch|case|default|break|return|for|while|do|continue|new|this|typeof|instanceof|try|catch|finally|throw|throws|async|await|import|export|from)\\b", options: []), { $0.cyan }),
            (try! NSRegularExpression(pattern: "(\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"|'[^'\\\\]*(\\\\.[^'\\\\]*)*'|`[^`\\\\]*(\\\\.[^`\\\\]*)*`)", options: []), { $0.red }),
            (try! NSRegularExpression(pattern: "\\b[0-9]+\\b", options: []), { $0.blue }),
        ]
    case .python:
        patterns = [
            (try! NSRegularExpression(pattern: "\\b(def|class|if|elif|else|for|while|break|continue|return|import|from|as|try|except|finally|raise|with|in|is|not|and|or|True|False|None)\\b", options: []), { $0.cyan }),
            (try! NSRegularExpression(pattern: "(\"\"\"[^\"]*\"\"\"|'''[^']*'''|\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"|'[^'\\\\]*(\\\\.[^'\\\\]*)*')", options: []), { $0.red }),
            (try! NSRegularExpression(pattern: "\\b[0-9]+\\b", options: []), { $0.blue }),
        ]
    case .ruby:
        patterns = [
            (try! NSRegularExpression(pattern: "\\b(def|class|module|if|elsif|else|unless|case|when|while|until|for|break|next|return|begin|rescue|ensure|end|do|yield)\\b", options: []), { $0.cyan }),
            (try! NSRegularExpression(pattern: "(\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"|'[^'\\\\]*(\\\\.[^'\\\\]*)*')", options: []), { $0.red }),
            (try! NSRegularExpression(pattern: ":[a-zA-Z_][a-zA-Z0-9_]*", options: []), { $0.magenta }),
            (try! NSRegularExpression(pattern: "\\b[0-9]+\\b", options: []), { $0.blue }),
        ]
    case .go:
        patterns = [
            (try! NSRegularExpression(pattern: "\\b(func|var|const|type|struct|interface|map|if|else|switch|case|default|for|range|break|continue|return|go|defer|package|import)\\b", options: []), { $0.cyan }),
            (try! NSRegularExpression(pattern: "\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"", options: []), { $0.red }),
            (try! NSRegularExpression(pattern: "\\b[0-9]+\\b", options: []), { $0.blue }),
        ]
    case .rust:
        patterns = [
            (try! NSRegularExpression(pattern: "\\b(fn|struct|enum|impl|trait|pub|let|mut|if|else|match|while|for|in|return|break|continue|loop|use|mod|as|where|unsafe|extern|move|ref|self|Self)\\b", options: []), { $0.cyan }),
            (try! NSRegularExpression(pattern: "\"[^\"\\\\]*(\\\\.[^\"\\\\]*)*\"", options: []), { $0.red }),
            (try! NSRegularExpression(pattern: "'[a-zA-Z_][a-zA-Z0-9_]*", options: []), { $0.magenta }),
            (try! NSRegularExpression(pattern: "\\b[0-9]+\\b", options: []), { $0.blue }),
        ]
    }
    
    // Apply each pattern in reverse order to avoid range issues
    for (pattern, colorize) in patterns.reversed() {
        let range = NSRange(location: 0, length: (result as NSString).length)
        let matches = pattern.matches(in: result, options: [], range: range)
        
        for match in matches.reversed() {
            let matchedText = (result as NSString).substring(with: match.range)
            let colorized = colorize(matchedText)
            result = (result as NSString).replacingCharacters(in: match.range, with: colorized)
        }
    }
    
    return result
} 