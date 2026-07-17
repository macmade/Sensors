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

public class SensorsWindowController: NSWindowController
{
    @objc private dynamic var sensors = Sensors()

    @objc private dynamic var showTemperature = UserDefaults.standard.object( forKey: DefaultsKeys.showTemperature ) as? Bool ?? true
    {
        didSet
        {
            self.updateFilters()
            UserDefaults.standard.set( self.showTemperature, forKey: DefaultsKeys.showTemperature )
        }
    }

    @objc private dynamic var showVoltage =  UserDefaults.standard.object( forKey: DefaultsKeys.showVoltage ) as? Bool ?? true
    {
        didSet
        {
            self.updateFilters()
            UserDefaults.standard.set( self.showVoltage, forKey: DefaultsKeys.showVoltage )
        }
    }

    @objc private dynamic var showCurrent =  UserDefaults.standard.object( forKey: DefaultsKeys.showCurrent ) as? Bool ?? true
    {
        didSet
        {
            self.updateFilters()
            UserDefaults.standard.set( self.showCurrent, forKey: DefaultsKeys.showCurrent )
        }
    }

    @objc private dynamic var showAmbientLight =  UserDefaults.standard.object( forKey: DefaultsKeys.showAmbientLight ) as? Bool ?? true
    {
        didSet
        {
            self.updateFilters()
            UserDefaults.standard.set( self.showAmbientLight, forKey: DefaultsKeys.showAmbientLight )
        }
    }

    @objc private dynamic var showFanSpeed =  UserDefaults.standard.object( forKey: DefaultsKeys.showFanSpeed ) as? Bool ?? true
    {
        didSet
        {
            self.updateFilters()
            UserDefaults.standard.set( self.showFanSpeed, forKey: DefaultsKeys.showFanSpeed )
        }
    }

    @objc private dynamic var showIOHID =  UserDefaults.standard.object( forKey: DefaultsKeys.showIOHID ) as? Bool ?? true
    {
        didSet
        {
            self.updateFilters()
            UserDefaults.standard.set( self.showIOHID, forKey: DefaultsKeys.showIOHID )
        }
    }

    @objc private dynamic var showSMC =  UserDefaults.standard.object( forKey: DefaultsKeys.showSMC ) as? Bool ?? true
    {
        didSet
        {
            self.updateFilters()
            UserDefaults.standard.set( self.showSMC, forKey: DefaultsKeys.showSMC )
        }
    }

    @objc private dynamic var sorting =  UserDefaults.standard.integer( forKey: DefaultsKeys.sorting )
    {
        didSet
        {
            self.updateFilters()
            UserDefaults.standard.set( self.sorting, forKey: DefaultsKeys.sorting )
        }
    }

    @objc private dynamic var searchText: String?
    {
        didSet { self.updateFilters() }
    }

    @objc private dynamic var graphStyle = UserDefaults.standard.integer( forKey: DefaultsKeys.graphStyle )
    {
        didSet
        {
            UserDefaults.standard.set( self.graphStyle, forKey: DefaultsKeys.graphStyle )
        }
    }

    @IBOutlet private var collectionView:  NSCollectionView!
    @IBOutlet private var arrayController: NSArrayController!

    public override var windowNibName: NSNib.Name?
    {
        "SensorsWindowController"
    }

    public override func windowDidLoad()
    {
        super.windowDidLoad()

        self.arrayController.sortDescriptors = [ NSSortDescriptor( key: "name", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) ) ]

        self.updateFilters()
    }

    public func stop( completion: ( () -> Void )? )
    {
        self.sensors.stop( completion: completion )
    }

    private func updateFilters()
    {
        let descriptors =
            [
                NSSortDescriptor( key: "name", ascending: true, selector: #selector( NSString.localizedCaseInsensitiveCompare( _: ) ) ),
                NSSortDescriptor( key: "last", ascending: false ),
            ]

        self.arrayController.sortDescriptors = self.sorting == 1 ? descriptors.reversed() : descriptors
        self.arrayController.filterPredicate = self.filterPredicate
    }

    /// The predicates removing the sensor kinds and sources currently filtered
    /// out, and restricting the results to the active search term.
    ///
    /// Shared by the array controller's `filterPredicate` and by
    /// ``visibleSensors`` so both apply the exact same filtering rules.
    private func filterPredicates() -> [ NSPredicate ]
    {
        var predicates = [ NSPredicate ]()

        if self.showTemperature == false
        {
            predicates.append( NSPredicate { o, i in ( o as? SensorHistoryData )?.kind != .thermal } )
        }

        if self.showVoltage == false
        {
            predicates.append( NSPredicate { o, i in ( o as? SensorHistoryData )?.kind != .voltage } )
        }

        if self.showCurrent == false
        {
            predicates.append( NSPredicate { o, i in ( o as? SensorHistoryData )?.kind != .current } )
        }

        if self.showAmbientLight == false
        {
            predicates.append( NSPredicate { o, i in ( o as? SensorHistoryData )?.kind != .ambientLight } )
        }

        if self.showFanSpeed == false
        {
            predicates.append( NSPredicate { o, i in ( o as? SensorHistoryData )?.kind != .rpm } )
        }

        if self.showIOHID == false
        {
            predicates.append( NSPredicate { o, i in ( o as? SensorHistoryData )?.source != .hid } )
        }

        if self.showSMC == false
        {
            predicates.append( NSPredicate { o, i in ( o as? SensorHistoryData )?.source != .smc } )
        }

        if let search = self.searchText, search.count > 0
        {
            predicates.append( NSPredicate( format: "name contains[c] %@", search ) )
        }

        return predicates
    }

    /// The compound predicate applied to the sensor list, or `nil` when no
    /// filter or search is active.
    private var filterPredicate: NSPredicate?
    {
        let predicates = self.filterPredicates()

        return predicates.isEmpty ? nil : NSCompoundPredicate( andPredicateWithSubpredicates: predicates )
    }

    /// The sensors currently passing the active filters and search — the ones
    /// actually shown in the collection view.
    private var visibleSensors: [ SensorHistoryData ]
    {
        guard let predicate = self.filterPredicate
        else
        {
            return self.sensors.data
        }

        return self.sensors.data.filter { predicate.evaluate( with: $0 ) }
    }

    /// Whether at least one sensor passes the active filters and search, so the
    /// collection view has something to display.
    @objc private dynamic var hasVisibleSensors: Bool
    {
        self.visibleSensors.isEmpty == false
    }

    /// Whether the "no results" message should be hidden.
    ///
    /// The message is shown only when sensor data exists but the active filters
    /// or search hide all of it; the empty-hardware and loading states are
    /// handled by the separate icon placeholder instead.
    @objc private dynamic var noResultsHidden: Bool
    {
        self.sensors.data.isEmpty || self.visibleSensors.isEmpty == false
    }

    /// The context-specific message shown when the filters or search hide every
    /// available sensor.
    @objc private dynamic var noResultsMessage: String
    {
        let anyKindEnabled   = self.showTemperature || self.showVoltage || self.showCurrent || self.showAmbientLight || self.showFanSpeed
        let anySourceEnabled = self.showIOHID || self.showSMC

        if anyKindEnabled == false || anySourceEnabled == false
        {
            return "No sensor types are selected."
        }

        if let search = self.searchText, search.isEmpty == false
        {
            return "No sensors match “\( search )”."
        }

        return "No sensors to display."
    }

    /// Key paths whose changes invalidate the empty-state properties.
    private static let emptyStateKeyPaths: Set<String> =
        [
            "sensors.data",
            "showTemperature",
            "showVoltage",
            "showCurrent",
            "showAmbientLight",
            "showFanSpeed",
            "showIOHID",
            "showSMC",
            "searchText",
        ]

    /// Key paths whose changes invalidate `hasVisibleSensors`.
    @objc private class func keyPathsForValuesAffectingHasVisibleSensors() -> Set<String>
    {
        SensorsWindowController.emptyStateKeyPaths
    }

    /// Key paths whose changes invalidate `noResultsHidden`.
    @objc private class func keyPathsForValuesAffectingNoResultsHidden() -> Set<String>
    {
        SensorsWindowController.emptyStateKeyPaths
    }

    /// Key paths whose changes invalidate `noResultsMessage`.
    @objc private class func keyPathsForValuesAffectingNoResultsMessage() -> Set<String>
    {
        SensorsWindowController.emptyStateKeyPaths
    }
}

extension SensorsWindowController: NSCollectionViewDataSource
{
    public func numberOfSections( in collectionView: NSCollectionView ) -> Int
    {
        1
    }

    public func collectionView( _ collectionView: NSCollectionView, numberOfItemsInSection section: Int ) -> Int
    {
        ( self.arrayController.arrangedObjects as? [ SensorHistoryData ] )?.count ?? 0
    }

    public func collectionView( _ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath ) -> NSCollectionViewItem
    {
        let item = collectionView.makeItem( withIdentifier: NSUserInterfaceItemIdentifier( rawValue: "SensorItem" ), for: indexPath )

        if let item = item as? SensorItem, let sensors = self.arrayController.arrangedObjects as? [ SensorHistoryData ]
        {
            if sensors.count > indexPath.item
            {
                item.sensor = sensors[ indexPath.item ]
            }
        }

        return item
    }
}
