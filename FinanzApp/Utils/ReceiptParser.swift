import UIKit
import Vision

struct ReceiptResult {
    var amount: Double?
    var merchant: String?
    var date: Date?
    var suggestedCategory: String?
}

class ReceiptParser {
    static func extractText(from image: UIImage, completion: @escaping (ReceiptResult) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(ReceiptResult())
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard error == nil else {
                completion(ReceiptResult())
                return
            }
            
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(ReceiptResult())
                return
            }
            
            var result = ReceiptResult()
            var allText: [String] = []
            
            for observation in observations {
                guard let topCandidate = observation.topCandidates(1).first else { continue }
                allText.append(topCandidate.string)
            }
            
            // Extract amount
            result.amount = extractAmount(from: allText)
            
            // Extract merchant name
            result.merchant = extractMerchant(from: allText)
            
            // Suggest category
            result.suggestedCategory = suggestCategory(from: allText)
            
            completion(result)
        }
        
        request.recognitionLevel = .accurate
        request.recognitionLanguages = ["nl-NL", "en-US"]
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Failed to perform OCR: \(error)")
                completion(ReceiptResult())
            }
        }
    }
    
    private static func extractAmount(from lines: [String]) -> Double? {
        let totalKeywords = ["totaal", "total", "bedrag", "te betalen", "subtotal", "sum"]
        
        for (index, line) in lines.enumerated() {
            let lowercased = line.lowercased()
            
            if totalKeywords.contains(where: { lowercased.contains($0) }) {
                for i in index..<min(index + 3, lines.count) {
                    if let amount = extractNumber(from: lines[i]) {
                        return amount
                    }
                }
            }
        }
        
        var amounts: [Double] = []
        for line in lines {
            if let amount = extractNumber(from: line) {
                amounts.append(amount)
            }
        }
        
        return amounts.max()
    }
    
    private static func extractNumber(from text: String) -> Double? {
        var cleaned = text
            .replacingOccurrences(of: "€", with: "")
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: " ", with: "")
            .trimmingCharacters(in: .whitespaces)
        
        cleaned = cleaned.replacingOccurrences(of: ",", with: ".")
        
        let pattern = "\\d+\\.?\\d{0,2}"
        if let range = cleaned.range(of: pattern, options: .regularExpression) {
            let numberString = String(cleaned[range])
            return Double(numberString)
        }
        
        return nil
    }
    
    private static func extractMerchant(from lines: [String]) -> String? {
        for line in lines.prefix(5) {
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.count > 3 && !trimmed.contains(where: { $0.isNumber }) {
                return trimmed
            }
        }
        return nil
    }
    
    private static func suggestCategory(from lines: [String]) -> String? {
        let allText = lines.joined(separator: " ").lowercased()
        
        let categoryMap: [String: [String]] = [
            "Groceries": ["albert heijn", "jumbo", "lidl", "aldi", "plus", "supermarkt", "grocery"],
            "Transport": ["ns", "train", "taxi", "uber", "ov", "benzine", "shell", "parking"],
            "Healthcare": ["apotheek", "pharmacy", "dokter", "hospital", "ziekenhuis", "tandarts"],
            "Entertainment": ["cinema", "bioscoop", "netflix", "spotify", "museum"],
            "Clothing": ["h&m", "zara", "fashion", "kleding"],
            "Travel": ["hotel", "booking", "airbnb", "airline", "vliegtuig"]
        ]
        
        for (category, keywords) in categoryMap {
            for keyword in keywords {
                if allText.contains(keyword) {
                    return category
                }
            }
        }
        
        return "Other"
    }
}
