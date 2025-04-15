import Foundation

extension String {
    func lineNumber(for location: Int) -> Int {
        let string = self as NSString
        var lineNumber = 1
        var currentLocation = 0
        
        // For each line, calculate its range and see if the location falls within it
        while currentLocation < string.length && currentLocation <= location {
            let lineRange = string.lineRange(for: NSRange(location: currentLocation, length: 0))
            
            // If location is within this line range, return this line number
            if location < NSMaxRange(lineRange) {
                return lineNumber
            }
            
            currentLocation = NSMaxRange(lineRange)
            lineNumber += 1
        }
        
        return max(1, lineNumber - 1) // Return the last line number if we've gone past the end
    }
} 