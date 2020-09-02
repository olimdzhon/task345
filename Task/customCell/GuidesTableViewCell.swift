//
//  GuidesTableViewCell.swift
//  Task
//
//  Created by developer on 9/1/20.
//  Copyright © 2020 developer. All rights reserved.
//

import UIKit

class GuidesTableViewCell: UITableViewCell {
    static let cellId = "GuidesTableViewCell"
    
    @IBOutlet weak var guidesImage: UIImageView!
    @IBOutlet weak var guidesName: UILabel!
    @IBOutlet weak var guidesEndTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionStyle = .none
        // Configure the view for the selected state
    }
    
}
