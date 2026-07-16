/*******************************************************************************
 * The MIT License (MIT)
 *
 * Copyright (c) 2023, Jean-David Gadina - www.xs-labs.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the Software), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED AS IS, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation
import SensorsKit

/// Formats sensor readings for display, applying per-kind precision and the
/// user's locale.
///
/// Fan speed (RPM) is shown as a whole number; every other kind is shown with
/// two fractional digits. A missing (`nil`) or non-finite value formats as
/// `"--"`. The logic is pure and side-effect free so it can be unit-tested in
/// isolation.
public class SensorValueFormatter
{
    /// Returns a localized, per-kind formatted string for the given value.
    ///
    /// - Parameters:
    ///   - value:  The numeric reading to format, or `nil`/non-finite for a
    ///             missing or invalid value.
    ///   - kind:   The sensor kind, used to pick the fractional precision.
    ///   - locale: The locale whose decimal separator is applied. Defaults to
    ///             the current locale.
    /// - Returns: The formatted value, or `"--"` when `value` is `nil`,
    ///            non-finite, or cannot be formatted.
    public static func string( for value: NSNumber?, kind: SensorHistoryData.Kind?, locale: Locale = .current ) -> String
    {
        guard let value = value, value.doubleValue.isFinite
        else
        {
            return "--"
        }

        let digits                      = self.fractionDigits( for: kind )
        let formatter                   = NumberFormatter()
        formatter.numberStyle           = .decimal
        formatter.locale                = locale
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = digits
        formatter.maximumFractionDigits = digits

        return formatter.string( from: value ) ?? "--"
    }

    /// The number of fractional digits to display for a given sensor kind.
    ///
    /// - Parameter kind: The sensor kind, or `nil` when unknown.
    /// - Returns: `0` for fan speed (RPM), `2` for every other kind.
    private static func fractionDigits( for kind: SensorHistoryData.Kind? ) -> Int
    {
        switch kind
        {
            case .rpm?: return 0
            default:    return 2
        }
    }

    /// Prevents instantiation — this type is a namespace of formatting logic only.
    private init()
    {}
}
