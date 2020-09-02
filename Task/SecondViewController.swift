//
//  SecondViewController.swift
//  Task
//
//  Created by developer on 9/1/20.
//  Copyright © 2020 developer. All rights reserved.
//

import UIKit
import WebKit

class SecondViewController: UIViewController {
    
    var guide: Guide? = nil
    var webView: WKWebView!
    var jsonString = String()
    
    override func loadView() {
           super.loadView()
          let contentController = WKUserContentController()
                  let config = WKWebViewConfiguration()
                  config.userContentController = contentController
                  self.webView = WKWebView( frame: self.view.bounds, configuration: config)
           
           self.view.addSubview(self.webView)
    }
           
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.navigationDelegate = self
        webView.load(request)
        
    }
    
    func createJsonForJavaScript(for data: [String : Any]) -> String {
        var jsonString : String?
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: .prettyPrinted)
            // here "jsonData" is the dictionary encoded in JSON data
            
            jsonString = String(data: jsonData, encoding: .utf8)!
            jsonString = jsonString?.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\\", with: "")
            
        } catch {
            print(error.localizedDescription)
        }
        print(jsonString!)
        return jsonString!
    }
    
    func createJsonToPass(icon : String , objType : String = "" , name : String = "", endDate : String = "", loginRequired : Bool = false, startDate : String = "", url : String = "") {
        
        let data = ["icon": icon ,"objType": objType , "name": name, "endDate": endDate, "loginRequired": loginRequired, "startDate": startDate, "url": url] as [String : Any]
        self.jsonString = createJsonForJavaScript(for: data)
        
    }
    
}

extension SecondViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let guide = self.guide else {
            print("guide equals nil")
            return
        }
        self.createJsonToPass(icon: guide.icon, objType: guide.objType, name: guide.name, endDate: guide.endDate, loginRequired: guide.loginRequired, startDate: guide.startDate, url: guide.url )
        self.webView.evaluateJavaScript("fillDetails('\(self.jsonString)')") { (any, error) in
            print("Error : \(error)")
        }
    }
}

