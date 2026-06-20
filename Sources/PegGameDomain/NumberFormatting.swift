import Foundation

/// Compact display of the large numbers idle games accumulate: `1.23K`, `4.5M`,
/// `7.89B`… Pure and locale-independent (uses `.` decimal) so it is trivially
/// testable and stable across devices.
public enum NumberFormatting {
    private static let suffixes = ["", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]

    /// Formats `value` compactly. Values below 1000 show as whole numbers;
    /// larger values show up to two decimals with a magnitude suffix.
    public static func compact(_ value: Double) -> String {
        guard value.isFinite else { return "∞" }
        let sign = value < 0 ? "-" : ""
        var magnitude = abs(value)

        if magnitude < 1000 {
            return sign + String(Int(magnitude.rounded(.down)))
        }

        var tier = 0
        while magnitude >= 1000 && tier < suffixes.count - 1 {
            magnitude /= 1000
            tier += 1
        }

        // Trim trailing zeros: 1.20K -> 1.2K, 1.00K -> 1K.
        let rounded = (magnitude * 100).rounded(.down) / 100
        var text = String(format: "%.2f", rounded)
        while text.contains(".") && (text.hasSuffix("0") || text.hasSuffix(".")) {
            text.removeLast()
        }
        return sign + text + suffixes[tier]
    }
}
