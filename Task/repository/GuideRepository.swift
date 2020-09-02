//
//  GuideRepository.swift
//  Task
//
//  Created by developer on 9/1/20.
//  Copyright © 2020 developer. All rights reserved.
//

import Foundation
import Alamofire
import PromiseKit

class GuideRepository {
    func load() -> Promise<LoadedData> {
        let url = "https://guidebook.com/service/v2/upcomingGuides/"
        return Promise {seal in
            var request = URLRequest(url: URL(string: url)!)
            request.timeoutInterval = 30.0
            AF.request(request).validate().responseData { response in
                switch response.result {
                case .success(let data):
                    debugPrint("alamofire request data \(data)")
                    
                    do {
                        let decoder = JSONDecoder()
                        let guides = try decoder.decode(LoadedData.self, from: data)
                        seal.fulfill(guides)
                    } catch let error {
                        seal.reject(error)
                    }
                    
                case .failure(let error):
                    seal.reject(error)
                }
            }
        }
    }
}
