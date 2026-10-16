import Foundation

public final class MathCalculator {
    public static let shared = MathCalculator()

    public func evaluateExpressionInText(_ text: String) -> String? {
        let pattern = #"(?:^|\s)([0-9+\-*/().^% ]+=[?]?|[0-9+\-*/().^% ]+[+\-*/][0-9+\-*/().^% ]+)$"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range) else { return nil }

        guard let matchRange = Range(match.range(at: 1), in: text) else { return nil }
        var exprStr = String(text[matchRange])
        exprStr = exprStr.replacingOccurrences(of: "=", with: "").trimmingCharacters(in: .whitespaces)

        guard let result = calculate(exprStr) else { return nil }
        return result
    }

    public func calculate(_ expression: String) -> String? {
        let cleaned = expression
            .replacingOccurrences(of: "×", with: "*")
            .replacingOccurrences(of: "÷", with: "/")
            .trimmingCharacters(in: .whitespaces)

        let validChars = CharacterSet(charactersIn: "0123456789+-*/().% ")
        guard CharacterSet(charactersIn: cleaned).isSubset(of: validChars), cleaned.count >= 3 else {
            return nil
        }

        let exp = NSExpression(format: cleaned)
        guard let value = exp.expressionValue(with: nil, context: nil) as? NSNumber else {
            return nil
        }

        let doubleVal = value.doubleValue
        if doubleVal.isNaN || doubleVal.isInfinite { return nil }
        if floor(doubleVal) == doubleVal && abs(doubleVal) < 1e12 {
            return String(Int64(doubleVal))
        } else {
            return String(format: "%.4g", doubleVal)
        }
    }
}
