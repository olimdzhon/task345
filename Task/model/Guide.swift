//
//  Guide.swift
//  Task
//
//  Created by developer on 9/1/20.
//  Copyright © 2020 developer. All rights reserved.
//

import Foundation
struct Guide: Codable {
    let icon: String
    let objType: String
    let name: String
    let endDate: String
    let loginRequired: Bool
    var venue: Venue
    let startDate: String
    let url: String
}
