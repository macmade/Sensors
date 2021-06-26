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

public class Preferences: NSObject
{
    @objc public enum GraphStyle: Int
    {
        case gradient
        case line
        case fill
        case bars
    }
    
    @objc public dynamic var lastStart: Date?
    {
        get
        {
            UserDefaults.standard.object( forKey: "LastStart" ) as? Date
        }
        
        set( value )
        {
            self.willChangeValue( for: \.graphStyle )
            UserDefaults.standard.set( value, forKey: "LastStart" )
            self.didChangeValue( for: \.graphStyle )
        }
    }
    
    @objc public dynamic var graphStyle: GraphStyle
    {
        get
        {
            GraphStyle( rawValue: UserDefaults.standard.integer( forKey: "GraphStyle" ) ) ?? .gradient
        }
        
        set( value )
        {
            self.willChangeValue( for: \.graphStyle )
            UserDefaults.standard.set( value.rawValue, forKey: "GraphStyle" )
            self.didChangeValue( for: \.graphStyle )
        }
    }
    
    public static let shared = Preferences()
    
    private override init()
    {}
}
