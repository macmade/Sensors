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

#import "Sensors.h"
#import "Sensors-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface Sensors()

@property( atomic, readwrite, strong ) NSMutableDictionary< NSString *, SensorData * > * sensors;

- ( void )readSensors: ( NSTimer * )timer;

@end

NS_ASSUME_NONNULL_END

@implementation Sensors

+ ( instancetype )shared
{
    static dispatch_once_t once;
    static Sensors       * instance;
    
    dispatch_once
    (
        &once,
        ^( void )
        {
            instance = [ Sensors new ];
        }
    );
    
    return instance;
}

- ( instancetype )init
{
    if( ( self = [ super init ] ) )
    {
        self.sensors = [ NSMutableDictionary new ];
        self.data    = [ NSArray new ];
        
        dispatch_async
        (
            dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0 ),
            ^( void )
            {
                [ NSTimer scheduledTimerWithTimeInterval: 1 target:self selector: @selector( readSensors: ) userInfo: nil repeats: YES ];
                
                while( YES )
                {
                    [ [ NSRunLoop currentRunLoop ] runUntilDate: [ NSDate dateWithTimeIntervalSinceNow: 1 ] ];
                }
            }
        );
    }
    
    return self;
}

- ( void )readSensors: ( NSTimer * )timer
{
    ( void )timer;
}

@end
