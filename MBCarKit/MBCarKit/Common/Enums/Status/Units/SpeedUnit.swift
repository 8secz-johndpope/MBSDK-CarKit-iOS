//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

/// State for speed unit
public enum SpeedUnit: Int, Codable, CaseIterable {
	
	/// km/h
	case kmPerHour = 1
	
	/// mph
	case mPerHour = 2

    func mapToString() -> String {
        switch self {
        case .kmPerHour: return "KMH"
        case .mPerHour:  return "MPH"
        }
    }
}
