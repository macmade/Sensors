/*******************************************************************************
 * The MIT License (MIT)
 * 
 * Copyright (c) 2021 Jean-David Gadina - www.xs-labs.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 ******************************************************************************/

import Foundation

@objc class SensorData: NSObject, Synchronizable
{
    @objc public enum Kind: Int
    {
        case thermal
        case voltage
        case current
    }
    
    @objc public private( set ) dynamic var kind: Kind
    @objc public private( set ) dynamic var name: String
    
    private var data: [ Double ] = []
    
    @objc public dynamic var values: [ NSNumber ]
    {
        return self.synchronized
        {
            return self.data.map { NSNumber( floatLiteral: $0 ) }
        }
    }
    
    @objc public dynamic var min: NSNumber?
    {
        return self.synchronized
        {
            guard let max = self.data.min() else
            {
                return nil
            }
            
            return NSNumber( floatLiteral: max )
        }
    }
    
    @objc public dynamic var max: NSNumber?
    {
        return self.synchronized
        {
            guard let min = self.data.max() else
            {
                return nil
            }
            
            return NSNumber( floatLiteral: min )
        }
    }
    
    public init( kind: Kind, name: String )
    {
        self.kind = kind
        self.name = name
    }
    
    public func add( value: Double )
    {
        self.synchronized
        {
            self.willChangeValue( for: \.values )
            self.willChangeValue( for: \.min )
            self.willChangeValue( for: \.max )
            self.data.append( value )
            self.didChangeValue( for: \.values )
            self.didChangeValue( for: \.min )
            self.didChangeValue( for: \.max )
        }
    }
}
