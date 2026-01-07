import Vision
import UIKit

struct ParsedReceipt {
    var amount: Double?
    var date: Date?
    var merchant: String?
    var fullText: String = ""
    var detectedBTWRate: Double?
}

class ReceiptParser {
    
    static func parseReceipt(from image: UIImage, completion: @escaping (ParsedReceipt) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(ParsedReceipt())
            return
        }
        
        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                completion(ParsedReceipt())
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }
            
            let fullText = recognizedStrings.joined(separator: "\n")
            var parsed = ParsedReceipt()
            parsed.fullText = fullText
            
            parsed.merchant = extractMerchant(from: recognizedStrings)
            parsed.date = extractDate(from: recognizedStrings)
            parsed.amount = extractAmount(from: recognizedStrings)
            parsed.detectedBTWRate = detectBTWRate(from: recognizedStrings)
            
            completion(parsed)
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? requestHandler.perform([request])
        }
    }
    
    // MARK: - Extract Merchant
    private static func extractMerchant(from lines: [String]) -> String? {
        let merchants = ["albert heijn", "ah", "jumbo", "lidl", "aldi"]
        
        for line in lines.prefix(5) {
            let lower = line.lowercased()
            for merchant in merchants {
                if lower.contains(merchant) {
                    return line.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        }
        
        return lines.first
    }
    
    // MARK: - Extract Date
    private static func extractDate(from lines: [String]) -> Date? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "nl_NL")
        let formats = ["dd-MM-yyyy", "dd/MM/yyyy", "dd-MM-yy"]
        
        for line in lines {
            for format in formats {
                formatter.dateFormat = format
                if let date = formatter.date(from: line.trimmingCharacters(in: .whitespaces)) {
                    return date
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Extract Amount
    private static func extractAmount(from lines: [String]) -> Double? {
        // Priority 1: TE BETALEN (most important - final amount to pay)
        for line in lines.reversed() {
            let lower = line.lowercased().replacingOccurrences(of: " ", with: "")
            if lower.contains("tebetalen") || lower.contains("apagar") {
                if let amount = extractNumber(from: line), amount < 500 {
                    return amount
                }
            }
        }
        
        // Priority 2: TOTAAL (but not SUBTOTAAL)
        for line in lines.reversed() {
            let lower = line.lowercased()
            if lower.contains("totaal") && !lower.contains("subtotaal") {
                if let amount = extractNumber(from: line), amount < 500 {
                    return amount
                }
            }
        }
        
        // Priority 3: TOTAL
        for line in lines.reversed() {
            let lower = line.lowercased()
            if lower.contains("total") && !lower.contains("subtotal") {
                if let amount = extractNumber(from: line), amount < 500 {
                    return amount
                }
            }
        }
        
        // Fallback: reasonable numbers only
        let amounts = lines.compactMap { extractNumber(from: $0) }
        let filtered = amounts.filter { $0 > 0.50 && $0 < 200 }
        return filtered.max()
    }
    
    // MARK: - Extract Number
    private static func extractNumber(from text: String) -> Double? {
        var cleaned = text
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: "EUR", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        // Handle European format
        if cleaned.contains(",") && !cleaned.contains(".") {
            cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
        } else if cleaned.contains(".") && cleaned.contains(",") {
            cleaned = cleaned.replacingOccurrences(of: ".", with: "")
            cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
        }
        
        // Extract all numbers
        let pattern = "[0-9]+\\.?[0-9]{0,2}"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let range = NSRange(cleaned.startIndex..., in: cleaned)
            let matches = regex.matches(in: cleaned, range: range)
            
            // Get last number (usually the amount)
            if let lastMatch = matches.last {
                if let swiftRange = Range(lastMatch.range, in: cleaned) {
                    let numString = String(cleaned[swiftRange])
                    return Double(numString)
                }
            }
        }
        
        return nil
    }
    
    // MARK: - Detect BTW Rate
    private static func detectBTWRate(from lines: [String]) -> Double? {
        // Count B markers
        var bCount = 0
        for line in lines {
            if line.hasSuffix(" B") || line.hasSuffix("B") || line.contains(" B ") {
                bCount += 1
            }
        }
        
        if bCount >= 2 {
            return 0.09
        }
        
        let fullText = lines.joined(separator: " ").lowercased()
        if fullText.contains("21%") {
            return 0.21
        }
        if fullText.contains("9%") {
            return 0.09
        }
        
        return nil
    }
}
