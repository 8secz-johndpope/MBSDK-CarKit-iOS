//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

/// Representation of weekly profile configuration. You must use this struct for the WeeklyProfileConfigureV2 command.
/// Therefore there is no public initializer. The timeProfile array depends on the current state of the configuration in the vehicle.
public struct WeeklyProfileModel {
	
	/// Determines whether a single time profile entry is activatable
	public let singleEntriesActivatable: Bool
	
	/// Maximum number of weekly time profile slots
	public let maxSlots: Int
	
	/// Maximum number of time profiles
	public let maxTimeProfiles: Int
	
	/// Current number of time profile slots
	public let currentSlots: Int
	
	/// Current number of time profiles
	public let currentTimeProfiles: Int
	
	/// All internally tracked time profiles. This also includes profiles that are marked as to be removed.
	internal let allTimeProfiles: [TimeProfile]
	
	/// Current number of time profiles. This excludes profiles that were marked as to be removed.
	public var timeProfiles: [TimeProfile] {
		return self.allTimeProfiles.filter { !$0.toBeRemoved }
	}
	
	
	// MARK: - Init
	
	internal init(singleEntriesActivatable: Bool, maxSlots: Int, maxTimeProfiles: Int, currentSlots: Int, currentTimeProfiles: Int, allTimeProfiles: [TimeProfile]) {
		
		self.singleEntriesActivatable = singleEntriesActivatable
		self.maxSlots = maxSlots
		self.maxTimeProfiles = maxTimeProfiles
		self.currentSlots = currentSlots
		self.currentTimeProfiles = currentTimeProfiles
		self.allTimeProfiles = allTimeProfiles
	}
	
	
	// MARK: - Public
	
	
	/// Adds a new time profile entry to the internal list of the WeeklyProfileModel
	public func addTimeProfile(timeProfile: TimeProfile) -> WeeklyProfileModel {

		var newTimeProfiles = self.allTimeProfiles
		newTimeProfiles.append(timeProfile)
		
		return WeeklyProfileModel(
			singleEntriesActivatable: self.singleEntriesActivatable,
			maxSlots: self.maxSlots,
			maxTimeProfiles: self.maxTimeProfiles,
			currentSlots: self.currentSlots,
			currentTimeProfiles: self.currentTimeProfiles,
			allTimeProfiles: newTimeProfiles
		)
	}
	
	// Updates the time profile at the given index with the provided time profile. If the
	// index is out of range this method will return nil. If you want to update an existing
	// time profile make sure to use the struct that is already exising in the WeeklyProfileModel.
	public func updateTimeProfile(index: Int, timeProfile: TimeProfile) -> WeeklyProfileModel? {

		guard let oldTimeProfile = self.timeProfiles.item(at: index) else {
			return nil
		}
		
		guard oldTimeProfile.identifier == timeProfile.identifier else {
			return nil
		}
		
		guard let fullIndex = mapFilteredIndexToFullIndex(index) else {
			return nil
		}
		
		var newTimeProfiles = self.allTimeProfiles
		newTimeProfiles[fullIndex] = timeProfile
		
		return WeeklyProfileModel(
			singleEntriesActivatable: self.singleEntriesActivatable,
			maxSlots: self.maxSlots,
			maxTimeProfiles: self.maxTimeProfiles,
			currentSlots: self.currentSlots,
			currentTimeProfiles: self.currentTimeProfiles,
			allTimeProfiles: newTimeProfiles
		)
	}
	
	/// Returns a new weekly profile configuration that has the given time profiles marked as "to be removed". The marking
	/// happens based on the identifier so time profiles that were added manually beforehand cannot be removed,
	/// because for those the identifier is nil. If a given ID is not in the set of time profiles, nothing happens.
	public func removeTimeProfile(index: Int) -> WeeklyProfileModel? {
		
		guard let fullIndex = mapFilteredIndexToFullIndex(index) else {
			return nil
		}
		
		var newTimeProfiles = self.allTimeProfiles
		newTimeProfiles[fullIndex].toBeRemoved = true
		
		return WeeklyProfileModel(
			singleEntriesActivatable: self.singleEntriesActivatable,
			maxSlots: self.maxSlots,
			maxTimeProfiles: self.maxTimeProfiles,
			currentSlots: self.currentSlots,
			currentTimeProfiles: self.currentTimeProfiles,
			allTimeProfiles: newTimeProfiles
		)
	}
	
	// MARK: - Helper
	
	/// This function maps an index of the timeProfiles field to the corresponding index of the allTimeProfiles field.
	/// SDK developers will only operate on the filtered list so we need to map their index to the complete list.
	private func mapFilteredIndexToFullIndex(_ filteredIndex: Int) -> Int? {
		
		var tmpFilteredIndex = -1
		for fullIndex in 0..<self.allTimeProfiles.count {
			
			if !self.allTimeProfiles[fullIndex].toBeRemoved {
				tmpFilteredIndex += 1
			}
			
			if tmpFilteredIndex == filteredIndex {
				return fullIndex
			}
		}
		
		return nil
	}
}


// MARK: - TimeProfile

public struct TimeProfile {
	
	/// a unique identifier of this time profile entry
	internal let identifier: Int?
	
	/// Hour after midnight range [0, 23]
	public var hour: Int
	
	/// Minute after full hour range [0, 59]
	public var minute: Int
	
	/// Whether this profile entry is active or not
	public var active: Bool
	
	/// Days for which the above time should be applied
	public var days: Set<Day>
	
	/// Indicates whether this time profile should be removed with the next WeeklyProfileConfigureV2 command
	internal var toBeRemoved: Bool = false
	
	// MARK: - Init
	
	public init(hour: Int, minute: Int, active: Bool, days: Set<Day>) {
		
		self.hour = hour
		self.minute = minute
		self.active = active
		self.days = days
		self.identifier = nil
	}
	
	internal init(identifier: Int, hour: Int, minute: Int, active: Bool, days: Set<Day>, toBeRemoved: Bool = false) {
		
		self.hour = hour
		self.minute = minute
		self.active = active
		self.days = days
		self.identifier = identifier
		self.toBeRemoved = toBeRemoved
	}
}
