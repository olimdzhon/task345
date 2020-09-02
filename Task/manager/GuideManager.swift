//
//  GuideManager.swift
//  Task
//
//  Created by developer on 9/1/20.
//  Copyright © 2020 developer. All rights reserved.
//

import Foundation
import CoreStore
import PromiseKit

class GuideManager {
    
    static let shared = GuideManager()
    
    private init(){}
    
    func add(_ guide: Guide) -> Promise<Void> {
        return Promise { seal in
            dataStack.perform(
                    asynchronous: { (transaction) -> Void in
                        let guides = try transaction.fetchAll(From<GuidesEntity>())
                        let sameGuide = guides.filter{$0.name == guide.name}.first
                        if (sameGuide == nil) {
                            let newGuide = transaction.create(Into<GuidesEntity>())
                            newGuide.icon = guide.icon
                            newGuide.objType = guide.objType
                            newGuide.name = guide.name
                            newGuide.endDate = guide.endDate
                            newGuide.loginRequired = guide.loginRequired
                            newGuide.startDate = guide.startDate
                            newGuide.url = guide.url
                        }
                },
                    success: { _ in
                        seal.fulfill_()
                },
                    failure: { (error) -> Void in
                        seal.reject(error)
                }
            )
        }
    }
}
