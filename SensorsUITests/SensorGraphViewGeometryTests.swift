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
@testable import SensorsUI

final class SensorGraphViewGeometryTests: XCTestCase
{
    // MARK: - columnCount

    func testColumnCountZeroOrNegativeSizeReturnsZero()
    {
        XCTAssertEqual( SensorGraphView.columnCount( width:    0, cellSize:  10 ), 0 )
        XCTAssertEqual( SensorGraphView.columnCount( width:  100, cellSize:   0 ), 0 )
        XCTAssertEqual( SensorGraphView.columnCount( width: -100, cellSize:  10 ), 0 )
        XCTAssertEqual( SensorGraphView.columnCount( width:  100, cellSize: -10 ), 0 )
    }

    func testColumnCountNonFiniteReturnsZero()
    {
        XCTAssertEqual( SensorGraphView.columnCount( width: .nan,      cellSize: 10 ),   0 )
        XCTAssertEqual( SensorGraphView.columnCount( width: .infinity, cellSize: 10 ),   0 )
        XCTAssertEqual( SensorGraphView.columnCount( width: 100,       cellSize: .nan ), 0 )
    }

    func testColumnCountNormalTruncatesTowardZero()
    {
        XCTAssertEqual( SensorGraphView.columnCount( width: 100, cellSize: 10 ), 10 )
        XCTAssertEqual( SensorGraphView.columnCount( width: 105, cellSize: 10 ), 10 )
        XCTAssertEqual( SensorGraphView.columnCount( width:   9, cellSize: 10 ),  0 )
    }

    // MARK: - fillFraction

    func testFillFractionFlatSensorIsZero()
    {
        XCTAssertEqual( SensorGraphView.fillFraction( value: 42, min: 42, max: 42 ), 0, accuracy: 0.0001 )
    }

    func testFillFractionNormalRangeMapsProportionally()
    {
        XCTAssertEqual( SensorGraphView.fillFraction( value:  0, min: 0, max: 10 ), 0.0, accuracy: 0.0001 )
        XCTAssertEqual( SensorGraphView.fillFraction( value:  5, min: 0, max: 10 ), 0.5, accuracy: 0.0001 )
        XCTAssertEqual( SensorGraphView.fillFraction( value: 10, min: 0, max: 10 ), 1.0, accuracy: 0.0001 )
    }
}
