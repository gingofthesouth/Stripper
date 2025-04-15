import Foundation

// Function to create query files for all supported languages
func createQueryFiles() -> Bool {
    let fileManager = FileManager.default
    let queryDir = fileManager.homeDirectoryForCurrentUser.appendingPathComponent(".stripper/queries").path
    
    // Create directories for each language
    let languageDirectories = SupportedLanguage.allCases.map { "\(queryDir)/\($0.rawValue)" }
    
    // Create parent directory
    do {
        try fileManager.createDirectory(atPath: queryDir, withIntermediateDirectories: true)
        
        // Create language subdirectories and query files
        for (language, directory) in zip(SupportedLanguage.allCases, languageDirectories) {
            try fileManager.createDirectory(atPath: directory, withIntermediateDirectories: true)
            
            // Create query files with proper content for each language
            let highlightPath = "\(directory)/highlights.scm"
            
            // Write the appropriate query content for each language
            let highlightQuery = getHighlightQueryForLanguage(language)
            try highlightQuery.write(toFile: highlightPath, atomically: true, encoding: .utf8)
            
            // Also create a comments.scm file specifically for comment queries
            let commentsPath = "\(directory)/comments.scm"
            try language.commentQuery.write(toFile: commentsPath, atomically: true, encoding: .utf8)
        }
        
        print("✅ Created query files at \(queryDir)".green)
        return true
    } catch {
        print("⚠️ Failed to create query directories: \(error.localizedDescription)".red)
        return false
    }
} 