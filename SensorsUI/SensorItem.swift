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

import Cocoa
import SensorsKit

public class SensorItem: NSCollectionViewItem
{
    @objc public dynamic var sensor: SensorHistoryData?
    {
        didSet
        {
            self.graph.sensor = self.sensor
        }
    }

    /// The current reading, formatted per-kind and localized (or `"--"`).
    @objc public dynamic var formattedLast: String
    {
        SensorValueFormatter.string( for: self.sensor?.last, kind: self.sensor?.kind )
    }

    /// The minimum reading, formatted per-kind and localized (or `"--"`).
    @objc public dynamic var formattedMin: String
    {
        SensorValueFormatter.string( for: self.sensor?.min, kind: self.sensor?.kind )
    }

    /// The maximum reading, formatted per-kind and localized (or `"--"`).
    @objc public dynamic var formattedMax: String
    {
        SensorValueFormatter.string( for: self.sensor?.max, kind: self.sensor?.kind )
    }

    /// Key paths whose changes invalidate `formattedLast`.
    @objc private class func keyPathsForValuesAffectingFormattedLast() -> Set<String>
    {
        [ "sensor.last", "sensor.kind" ]
    }

    /// Key paths whose changes invalidate `formattedMin`.
    @objc private class func keyPathsForValuesAffectingFormattedMin() -> Set<String>
    {
        [ "sensor.min", "sensor.kind" ]
    }

    /// Key paths whose changes invalidate `formattedMax`.
    @objc private class func keyPathsForValuesAffectingFormattedMax() -> Set<String>
    {
        [ "sensor.max", "sensor.kind" ]
    }

    private var graph = SensorGraphView()

    @IBOutlet private var graphContainer: NSView!

    public override func viewDidLoad()
    {
        super.viewDidLoad()

        self.graph.translatesAutoresizingMaskIntoConstraints = false
        self.graph.frame                                     = self.graphContainer.bounds

        self.graphContainer.addSubview( self.graph )
        self.graphContainer.addConstraint( NSLayoutConstraint( item: self.graph, attribute: .width,   relatedBy: .equal, toItem: self.graphContainer, attribute: .width,   multiplier: 1, constant: 0 ) )
        self.graphContainer.addConstraint( NSLayoutConstraint( item: self.graph, attribute: .height,  relatedBy: .equal, toItem: self.graphContainer, attribute: .height,  multiplier: 1, constant: 0 ) )
        self.graphContainer.addConstraint( NSLayoutConstraint( item: self.graph, attribute: .centerX, relatedBy: .equal, toItem: self.graphContainer, attribute: .centerX, multiplier: 1, constant: 0 ) )
        self.graphContainer.addConstraint( NSLayoutConstraint( item: self.graph, attribute: .centerY, relatedBy: .equal, toItem: self.graphContainer, attribute: .centerY, multiplier: 1, constant: 0 ) )
    }
}
