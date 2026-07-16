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

/// The `UserDefaults` keys backing the sensors window's persisted preferences.
///
/// Centralizing the raw key strings here keeps every reader and writer in sync
/// and avoids duplicating string literals across the UI.
public class DefaultsKeys
{
    /// Whether temperature sensors are shown.
    public static let showTemperature  = "sensorsWindowShowTemperature"

    /// Whether voltage sensors are shown.
    public static let showVoltage      = "sensorsWindowShowVoltage"

    /// Whether current sensors are shown.
    public static let showCurrent      = "sensorsWindowShowCurrent"

    /// Whether ambient light sensors are shown.
    public static let showAmbientLight = "sensorsWindowShowAmbientLight"

    /// Whether fan speed sensors are shown.
    public static let showFanSpeed     = "sensorsWindowShowFanSpeed"

    /// Whether IOHID sensors are shown.
    public static let showIOHID        = "sensorsWindowShowIOHID"

    /// Whether SMC sensors are shown.
    public static let showSMC          = "sensorsWindowShowSMC"

    /// The selected sorting mode.
    public static let sorting          = "sensorsWindowSorting"

    /// The selected graph style (raw value of `SensorGraphView.GraphStyle`).
    public static let graphStyle       = "sensorsWindowGraphStyle"

    /// Prevents instantiation — this type is a namespace of key constants only.
    private init()
    {}
}
