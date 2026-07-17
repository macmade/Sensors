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

public class SensorGraphView: NSView
{
    @objc
    public enum GraphStyle: Int
    {
        case gradient
        case line
        case fill
        case bars
    }

    @objc public dynamic var sensor: SensorHistoryData?
    {
        didSet
        {
            self.needsDisplay = true
        }
    }

    public override init( frame: NSRect )
    {
        super.init( frame: frame )
        self.observeGraphStyleDefault()
    }

    required init?( coder: NSCoder )
    {
        super.init( coder: coder )
        self.observeGraphStyleDefault()
    }

    deinit
    {
        UserDefaults.standard.removeObserver( self, forKeyPath: DefaultsKeys.graphStyle )
    }

    private func observeGraphStyleDefault()
    {
        UserDefaults.standard.addObserver( self, forKeyPath: DefaultsKeys.graphStyle, options: [], context: nil )
    }

    public override func observeValue( forKeyPath keyPath: String?, of object: Any?, change: [ NSKeyValueChangeKey: Any ]?, context: UnsafeMutableRawPointer? )
    {
        guard keyPath == DefaultsKeys.graphStyle
        else
        {
            super.observeValue( forKeyPath: keyPath, of: object, change: change, context: context )

            return
        }

        self.needsDisplay = true
    }

    public override func draw( _ rect: NSRect )
    {
        let rect = self.bounds

        guard rect.size.width > 0, rect.size.height > 0
        else
        {
            return
        }

        let style = GraphStyle( rawValue: UserDefaults.standard.integer( forKey: DefaultsKeys.graphStyle ) ) ?? .gradient

        self.drawBorder( in: rect, style: style )
        self.drawBackground( in: rect, style: style )

        guard let sensor = self.sensor, sensor.values.count >= 2
        else
        {
            return
        }

        let values       = sensor.values.map { CGFloat( $0.doubleValue ) }
        var min: CGFloat = values.min() ?? 0
        var max: CGFloat = values.max() ?? 0

        if sensor.kind == .thermal, min >= 0, max <= 120
        {
            min = 0
            max = 120
        }

        if style == .bars
        {
            self.drawBars(
                in:     rect,
                values: values,
                min:    min,
                max:    max,
                color:  Colors.color( for: sensor.kind )
            )
        }
        else
        {
            self.drawGraph(
                in:     rect.insetBy( dx: 10, dy: 10 ),
                kind:   sensor.kind,
                values: values,
                min:    min,
                max:    max,
                color:  Colors.color( for: sensor.kind ),
                style:  style
            )
        }
    }

    private func drawBorder( in rect: NSRect, style: GraphStyle )
    {
        if style == .bars
        {
            return
        }

        let border       = NSBezierPath( roundedRect: rect.insetBy( dx: 1, dy: 1 ), xRadius: 10, yRadius: 10 )
        border.lineWidth = 1

        NSColor.gray.setStroke()
        border.stroke()
    }

    private func drawBackground( in rect: NSRect, style: GraphStyle )
    {
        if style == .bars
        {
            let c = 15
            let h = rect.size.height / CGFloat( c )
            let n = Self.columnCount( width: rect.size.width, cellSize: h )

            for i in 0 ..< n
            {
                for j in 0 ..< c
                {
                    let square = NSRect( x: rect.origin.x + h * CGFloat( i ), y: rect.origin.y + h * CGFloat( j ), width: h, height: h ).insetBy( dx: 1, dy: 1 )

                    NSColor.gray.withAlphaComponent( 0.2 ).setFill()
                    square.fill()
                }
            }
        }
        else
        {
            let border = NSBezierPath( roundedRect: rect.insetBy( dx: 1, dy: 1 ), xRadius: 10, yRadius: 10 )

            NSColor.gray.withAlphaComponent( 0.2 ).setFill()
            border.fill()
        }
    }

    private func drawGraph( in rect: NSRect, kind: SensorHistoryData.Kind, values: [ CGFloat ], min: CGFloat, max: CGFloat, color: NSColor, style: GraphStyle )
    {
        let p1       = NSBezierPath()
        let p2       = NSBezierPath()
        p1.lineWidth = 1
        p2.lineWidth = 0

        if min == max, kind != .thermal
        {
            p1.move( to: NSPoint( x: rect.origin.x, y: rect.origin.y + rect.size.height / 2 ) )
            p1.line( to: NSPoint( x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height / 2 ) )
            p2.move( to: NSPoint( x: rect.origin.x, y: rect.origin.y + rect.size.height / 2 ) )
            p2.line( to: NSPoint( x: rect.origin.x + rect.size.width, y: rect.origin.y + rect.size.height / 2 ) )
        }
        else
        {
            for i in 0 ..< values.count
            {
                let value = values[ i ]
                let dx    = rect.size.width / CGFloat( values.count - 1 )
                let x     = rect.origin.x + CGFloat( i ) * dx
                let v     = ( value - min ) / ( max - min )
                let y     = rect.origin.y + v * rect.size.height

                if x.isNaN || y.isNaN
                {
                    return
                }

                if i == 0
                {
                    p1.move( to: NSPoint( x: x, y: y ) )
                    p2.move( to: NSPoint( x: x, y: y ) )
                }
                else
                {
                    p1.line( to: NSPoint( x: x, y: y ) )
                    p2.line( to: NSPoint( x: x, y: y ) )
                }
            }
        }

        p2.line( to: NSPoint( x: rect.origin.x + rect.size.width, y: rect.origin.y - 3 ) )
        p2.line( to: NSPoint( x: rect.origin.x, y: rect.origin.y - 3 ) )
        p2.close()

        if style == .gradient
        {
            let gradient = NSGradient( colors: [ color.withAlphaComponent( 0.25 ), color.withAlphaComponent( 0 ) ] )

            gradient?.draw( in: p2, angle: -90 )
        }
        else if style == .fill
        {
            color.setFill()
            p2.fill()
        }

        color.setStroke()
        p1.stroke()
    }

    private func drawBars( in rect: NSRect, values: [ CGFloat ], min: CGFloat, max: CGFloat, color: NSColor )
    {
        let c = 15
        let h = rect.size.height / CGFloat( c )
        let n = Self.columnCount( width: rect.size.width, cellSize: h )

        let values = Array( values.suffix( n ) )

        for i in 0 ..< n
        {
            if i >= values.count
            {
                return
            }

            let v = values[ i ]
            let p = Self.fillFraction( value: v, min: min, max: max )

            for j in 0 ..< c
            {
                if CGFloat( j ) / CGFloat( c ) > p
                {
                    break
                }

                let square = NSRect( x: rect.origin.x + h * CGFloat( i ), y: rect.origin.y + h * CGFloat( j ), width: h, height: h ).insetBy( dx: 1, dy: 1 )

                color.setFill()
                square.fill()
            }
        }
    }

    static func fillFraction( value: CGFloat, min: CGFloat, max: CGFloat ) -> CGFloat
    {
        min == max ? 0 : ( value - min ) / ( max - min )
    }

    static func columnCount( width: CGFloat, cellSize: CGFloat ) -> Int
    {
        guard width.isFinite, cellSize.isFinite, cellSize > 0
        else
        {
            return 0
        }

        let count = width / cellSize

        guard count.isFinite, count > 0
        else
        {
            return 0
        }

        return Int( count )
    }
}
