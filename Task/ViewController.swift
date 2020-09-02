//
//  ViewController.swift
//  Task
//
//  Created by developer on 9/1/20.
//  Copyright © 2020 developer. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ViewController: UIViewController {
    
    private var guides: [Guide] = []
    private var maxItems: Int = 3
    private var lastContentOffset: CGFloat = 0
    @IBOutlet weak var guidesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guidesTableView.delegate = self
        guidesTableView.dataSource = self
        
        GuideRepository().load()
            .done{loadedData in
                self.guides = loadedData.data
                self.guidesTableView.reloadData()
        }
        .catch{error in
            print("guides load error \(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "guideDetails" {
            if let indexPath = self.guidesTableView.indexPathForSelectedRow {
                let controller = segue.destination as! SecondViewController
                controller.guide = guides[indexPath.row]
            }
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guides.isEmpty ? guides.count : maxItems
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.register(UINib.init(nibName: GuidesTableViewCell.cellId, bundle: nil), forCellReuseIdentifier: GuidesTableViewCell.cellId)
        let cell = tableView.dequeueReusableCell(withIdentifier: GuidesTableViewCell.cellId, for: indexPath) as! GuidesTableViewCell
        
        let guide = guides[indexPath.row]
        
        GuideManager.shared.add( guide)
            .done{_ in
                print("add successfully to CoreData")
        }.catch{ error in
            print(error.localizedDescription)
        }
        
        cell.guidesName.text = guide.name
        cell.guidesEndTime.text = guide.endDate
        
        // displaying image
        AF.request(guide.icon).responseImage{ response in
            debugPrint(response)
            
            if let image = response.data {
                cell.guidesImage.image = UIImage(data: image)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "guideDetails", sender: self)
    }
}

extension ViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.maxItems = self.maxItems + 3
        if self.maxItems > guides.count {
            self.maxItems = guides.count
        }
        self.guidesTableView.reloadData()
    }
}

