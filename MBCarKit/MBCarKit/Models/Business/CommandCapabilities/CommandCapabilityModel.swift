//
//  Copyright © 2019 MBition GmbH. All rights reserved.
//

import Foundation

public struct CommandCapabilityModel {
	
	public let additionalInformation: [String]
	public let commandName: CommandName
	public let isAvailable: Bool
	public let parameters: [CommandParameterModel]
}
