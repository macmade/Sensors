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

@import IOKit;
@import CoreFoundation;

#import <IOKit/hidsystem/IOHIDEventSystemClient.h>
#import <IOKit/hidsystem/IOHIDServiceClient.h>

/* @see https://opensource.apple.com/source/IOHIDFamily/ */

typedef NS_ENUM( int64_t, HIDPage )
{
    HIDPageAppleVendor                   = 0xFF00,
    HIDPageAppleVendorKeyboard           = 0xFF01,
    HIDPageAppleVendorMouse              = 0xFF02,
    HIDPageAppleVendorAccelerometer      = 0xFF03,
    HIDPageAppleVendorAmbientLightSensor = 0xFF04,
    HIDPageAppleVendorTemperatureSensor  = 0xFF05,
    HIDPageAppleVendorHeadset            = 0xFF07,
    HIDPageAppleVendorPowerSensor        = 0xFF08,
    HIDPageAppleVendorSmartCover         = 0xFF09,
    HIDPageAppleVendorPlatinum           = 0xFF0A,
    HIDPageAppleVendorLisa               = 0xFF0B,
    HIDPageAppleVendorMotion             = 0xFF0C,
    HIDPageAppleVendorBattery            = 0xFF0D,
    HIDPageAppleVendorIRRemote           = 0xFF0E,
    HIDPageAppleVendorDebug              = 0xFF0F,
    HIDPageAppleVendorFilteredEvent      = 0xFF50,
    HIDPageAppleVendorMultitouch         = 0xFF60,
    HIDPageAppleVendorDisplay            = 0xFF92,
    HIDPageAppleVendorTopCase            = 0x00FF
};

typedef NS_ENUM( int64_t, HIDUsageAppleVendor )
{
    HIDUsageAppleVendorTopCase            = 0x01,
    HIDUsageAppleVendorDisplay            = 0x02,
    HIDUsageAppleVendorAccelerometer      = 0x03,
    HIDUsageAppleVendorAmbientLightSensor = 0x04,
    HIDUsageAppleVendorTemperatureSensor  = 0x05,
    HIDUsageAppleVendorKeyboard           = 0x06,
    HIDUsageAppleVendorHeadset            = 0x07,
    HIDUsageAppleVendorProximitySensor    = 0x08,
    HIDUsageAppleVendorGyro               = 0x09,
    HIDUsageAppleVendorCompass            = 0x0A,
    HIDUsageAppleVendorDeviceManagement   = 0x0B,
    HIDUsageAppleVendorTrackpad           = 0x0C,
    HIDUsageAppleVendorTopCaseReserved    = 0x0D,
    HIDUsageAppleVendorMotion             = 0x0E,
    HIDUsageAppleVendorKeyboardBacklight  = 0x0F,
    HIDUsageAppleVendorDeviceMotionLite   = 0x10,
    HIDUsageAppleVendorForce              = 0x11,
    HIDUsageAppleVendorBluetoothRadio     = 0x12,
    HIDUsageAppleVendorOrb                = 0x13,
    HIDUsageAppleVendorAccessoryBattery   = 0x14
};

typedef NS_ENUM( int64_t, HIDUsageAppleVendorPowerSensor )
{
    HIDUsageAppleVendorPowerSensorPower   = 0x1,
    HIDUsageAppleVendorPowerSensorCurrent = 0x2,
    HIDUsageAppleVendorPowerSensorVoltage = 0x3
};

typedef NS_ENUM( int64_t, HIDEvent )
{
    IOHIDEventTypeNULL                  = 0x00,
    IOHIDEventTypeVendorDefined         = 0x01,
    IOHIDEventTypeButton                = 0x02,
    IOHIDEventTypeKeyboard              = 0x03,
    IOHIDEventTypeTranslation           = 0x04,
    IOHIDEventTypeRotation              = 0x05,
    IOHIDEventTypeScroll                = 0x06,
    IOHIDEventTypeScale                 = 0x07,
    IOHIDEventTypeZoom                  = 0x08,
    IOHIDEventTypeVelocity              = 0x09,
    IOHIDEventTypeOrientation           = 0x0A,
    IOHIDEventTypeDigitizer             = 0x0B,
    IOHIDEventTypeAmbientLightSensor    = 0x0C,
    IOHIDEventTypeAccelerometer         = 0x0D,
    IOHIDEventTypeProximity             = 0x0E,
    IOHIDEventTypeTemperature           = 0x0F,
    IOHIDEventTypeNavigationSwipe       = 0x10,
    IOHIDEventTypeSwipe                 = IOHIDEventTypeNavigationSwipe,
    IOHIDEventTypeMouse                 = 0x11,
    IOHIDEventTypeProgress              = 0x12,
    IOHIDEventTypeCount                 = 0x13,
    IOHIDEventTypeGyro                  = 0x14,
    IOHIDEventTypeCompass               = 0x15,
    IOHIDEventTypeZoomToggle            = 0x16,
    IOHIDEventTypeDockSwipe             = 0x17,
    IOHIDEventTypeSymbolicHotKey        = 0x18,
    IOHIDEventTypePower                 = 0x19,
    IOHIDEventTypeBrightness            = 0x1A,
    IOHIDEventTypeFluidTouchGesture     = 0x1B,
    IOHIDEventTypeBoundaryScroll        = 0x1C,
    IOHIDEventTypeReset                 = 0x1D
};

extern IOHIDEventSystemClientRef IOHIDEventSystemClientCreate( CFAllocatorRef );
extern void                      IOHIDEventSystemClientSetMatching( IOHIDEventSystemClientRef, CFDictionaryRef );
extern CFTypeRef                 IOHIDServiceClientCopyEvent( IOHIDServiceClientRef, HIDEvent, int64_t, int64_t );
extern double                    IOHIDEventGetFloatValue( CFTypeRef, int64_t );
