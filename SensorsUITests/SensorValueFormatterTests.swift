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

import XCTest
import SensorsKit
@testable import SensorsUI

final class SensorValueFormatterTests: XCTestCase
{
    private let en = Locale( identifier: "en_US" )
    private let fr = Locale( identifier: "fr_FR" )

    func testNilValueReturnsPlaceholder()
    {
        XCTAssertEqual( SensorValueFormatter.string( for: nil, kind: .thermal, locale: self.en ), "--" )
    }

    func testNonFiniteValueReturnsPlaceholder()
    {
        XCTAssertEqual( SensorValueFormatter.string( for: NSNumber( value: Double.nan ),      kind: .thermal, locale: self.en ), "--" )
        XCTAssertEqual( SensorValueFormatter.string( for: NSNumber( value: Double.infinity ), kind: .voltage, locale: self.en ), "--" )
    }

    func testFanSpeedFormatsAsWholeNumber()
    {
        XCTAssertEqual( SensorValueFormatter.string( for: 2100,   kind: .rpm, locale: self.en ), "2100" )
        XCTAssertEqual( SensorValueFormatter.string( for: 2100.7, kind: .rpm, locale: self.en ), "2101" )
    }

    func testOtherKindsFormatWithTwoFractionalDigits()
    {
        XCTAssertEqual( SensorValueFormatter.string( for: 45.256, kind: .thermal,      locale: self.en ), "45.26" )
        XCTAssertEqual( SensorValueFormatter.string( for: 12.3,   kind: .voltage,      locale: self.en ), "12.30" )
        XCTAssertEqual( SensorValueFormatter.string( for: 1.2,    kind: .current,      locale: self.en ), "1.20" )
        XCTAssertEqual( SensorValueFormatter.string( for: 350,    kind: .ambientLight, locale: self.en ), "350.00" )
    }

    func testLocaleDecimalSeparatorIsApplied()
    {
        XCTAssertEqual( SensorValueFormatter.string( for: 45.25, kind: .thermal, locale: self.fr ), "45,25" )
    }

    func testNoThousandsGroupingSeparator()
    {
        XCTAssertEqual( SensorValueFormatter.string( for: 12345, kind: .rpm, locale: self.en ), "12345" )
    }
}
