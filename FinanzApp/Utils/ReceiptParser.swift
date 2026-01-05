import Vision
import UIKit

struct ParsedReceipt {
    var amount: Double?
    var date: Date?
    var merchant: String?
    var fullText: String
}

class ReceiptParser {
    
    static func parseReceipt(from image: UIImage, completion: @escaping (ParsedReceipt) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(ParsedReceipt(fullText: "Error: No se pudo procesar la imagen"))
            return
        }
        
        let request = VNRecognizeTextRequest { request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  error == nil else {
                completion(ParsedReceipt(fullText: "Error al leer texto"))
                return
            }
            
            let recognizedText = observations.compactMap { observation in
                observation.topCandidates(1).first?.string
            }.joined(separator: "\n")
            
            print("📄 Texto reconocido:\n\(recognizedText)")
            
            let amount = extractAmount(from: recognizedText)
            let date = extractDate(from: recognizedText)
            let merchant = extractMerchant(from: recognizedText)
            
            let parsed = ParsedReceipt(
                amount: amount,
                date: date,
                merchant: merchant,
                fullText: recognizedText
            )
            
            DispatchQueue.main.async {
                completion(parsed)
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }
    
    private static func extractAmount(from text: String) -> Double? {
        let patterns = [
            "(?:total|subtotal|importe|amount)[:\\s]*[€$£¥]?\\s*(\\d+[.,]\\d{2})",
            "(?:USD|EUR|GBP)[\\$€£]?\\s*(\\d+[.,]\\d{2})",
            "^[€$£¥]\\s*(\\d+[.,]\\d{2})",
            "(\\d+[.,]\\d{2})\\s*[€$£¥]",
            "(\\d+[.,]\\d{2})"
        ]
        
        var amounts: [Double] = []
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let nsString = text as NSString
                let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
                
                for match in matches {
                    if match.numberOfRanges > 1 {
                        let amountString = nsString.substring(with: match.range(at: 1))
                        let cleanAmount = amountString.replacingOccurrences(of: ",", with: ".")
                        if let amount = Double(cleanAmount) {
                            amounts.append(amount)
                        }
                    }
                }
            }
        }
        
        return amounts.max()
    }
    
    private static func extractDate(from text: String) -> Date? {
        let patterns = [
            "(\\d{1,2})[-/](\\d{1,2})[-/](\\d{4})",
            "(\\d{1,2})[-/](\\d{1,2})[-/](\\d{2})"
        ]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern) {
                let nsString = text as NSString
                if let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: nsString.length)) {
                    let dateString = nsString.substring(with: match.range)
                    if let date = dateFormatter.date(from: dateString) {
                        return date
                    }
                }
            }
        }
        
        return Date()
    }
    
    private static func extractMerchant(from text: String) -> String? {
        let lines = text.components(separatedBy: "\n")
        
        for line in lines.prefix(5) {
            let cleaned = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if cleaned.count > 3 && !cleaned.contains(where: { "0123456789".contains($0) }) {
                return cleaned
            }
        }
        
        return nil
    }
}
