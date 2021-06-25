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
#import "IOHID.h"

NS_ASSUME_NONNULL_BEGIN

@interface Sensors()

@property( nonatomic, readwrite, strong ) NSMutableDictionary< NSString *, SensorData * > * sensors;

- ( void )run __attribute__( ( noreturn ) );
- ( void )readSensors: ( NSTimer * )timer;
- ( void )readSensors: ( SensorDataKind )kind page: ( IOHIDPage )page usage: ( NSInteger )usage event: ( IOHIDEvent )eventType client: ( IOHIDEventSystemClientRef )client;
- ( void )addSensorData: ( double )value name: ( NSString * )name kind: ( SensorDataKind )kind properties: ( nullable NSDictionary * )properties;

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
                [ self run ];
            }
        );
    }
    
    return self;
}

- ( void )run
{
    IOHIDEventSystemClientRef client = IOHIDEventSystemClientCreate( kCFAllocatorDefault );
    NSDictionary            * info   = @{ @"Client" : [ NSValue valueWithPointer: client ] };
    
    [ NSTimer scheduledTimerWithTimeInterval: 2 target: self selector: @selector( readSensors: ) userInfo: info repeats: YES ];
    
    while( YES )
    {
        [ [ NSRunLoop currentRunLoop ] runUntilDate: [ NSDate dateWithTimeIntervalSinceNow: 5 ] ];
    }
}

- ( void )readSensors: ( NSTimer * )timer
{
    IOHIDEventSystemClientRef client = ( ( NSValue * )( timer.userInfo[ @"Client" ] ) ).pointerValue;
    
    if( client != nil )
    {
        [ self readSensors: SensorDataKindThermal page: IOHIDPageAppleVendor            usage: IOHIDUsageAppleVendorTemperatureSensor  event: IOHIDEventTypeTemperature client: client ];
        [ self readSensors: SensorDataKindPower   page: IOHIDPageAppleVendorPowerSensor usage: IOHIDUsageAppleVendorPowerSensorPower   event: IOHIDEventTypePower       client: client ];
        [ self readSensors: SensorDataKindVoltage page: IOHIDPageAppleVendorPowerSensor usage: IOHIDUsageAppleVendorPowerSensorVoltage event: IOHIDEventTypePower       client: client ];
        [ self readSensors: SensorDataKindCurrent page: IOHIDPageAppleVendorPowerSensor usage: IOHIDUsageAppleVendorPowerSensorCurrent event: IOHIDEventTypePower       client: client ];
        
        self.data = self.sensors.allValues;
    }
}

- ( void )readSensors: ( SensorDataKind )kind page: ( IOHIDPage )page usage: ( NSInteger )usage event: ( IOHIDEvent )eventType client: ( IOHIDEventSystemClientRef )client
{
    NSDictionary * filter =
    @{
        @"PrimaryUsagePage" : [ NSNumber numberWithLongLong: page ],
        @"PrimaryUsage"     : [ NSNumber numberWithLongLong: usage ]
    };
    
    IOHIDEventSystemClientSetMatching( client, ( __bridge CFDictionaryRef )filter );
    
    {
        NSArray * services = CFBridgingRelease( IOHIDEventSystemClientCopyServices( client ) );
        
        for( id o in services )
        {
            IOHIDServiceClientRef service    = ( __bridge IOHIDServiceClientRef )o;
            CFTypeRef             event      = IOHIDServiceClientCopyEvent( service, eventType, 0, 0 );
            NSString            * name       = CFBridgingRelease( IOHIDServiceClientCopyProperty( service, CFSTR( "Product" ) ) );
            NSArray             * keys       = @[ @"IOClass", @"IOProviderClass", @"IONameMatch", @"Product", @"DeviceUsagePairs" ];
            NSDictionary        * properties = CFBridgingRelease( IOHIDServiceClientCopyProperties( service, ( __bridge CFArrayRef )keys ) );
            
            if( name != nil && event != nil )
            {
                [ self addSensorData: IOHIDEventGetFloatValue( event, eventType << 16 ) name: name kind: kind properties: properties ];
            }
            
            if( event != nil )
            {
                CFRelease( event );
            }
        }
    }
}

- ( void )addSensorData: ( double )value name: ( NSString * )name kind: ( SensorDataKind )kind properties: ( nullable NSDictionary * )properties
{
    NSString   * key  = [ NSString stringWithFormat: @"%llu.%@", ( uint64_t )kind, name ];
    SensorData * data = [ self.sensors objectForKey: key ];
    
    if( data == nil )
    {
        data = [ [ SensorData alloc ] initWithKind: kind name: name properties: properties ];
        
        [ self.sensors setObject: data forKey: key ];
    }
    
    [ data addValue: value ];
}

@end
