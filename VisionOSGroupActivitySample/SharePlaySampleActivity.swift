//
//  ShowAlertSharePlayActivity.swift
//  VisionOSGroupActivitySample
//
//  Created by Sadao Tokuyama on 3/13/24.
//

import Foundation
import GroupActivities

struct SharePlaySampleActivity: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = NSLocalizedString("Share Play Sample", comment: "This is a Share Play Sample.")
        metadata.type = .generic
        return metadata
    }
}
