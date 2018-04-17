//
//  RunTableViewCell.swift
//  Running Assistant
//
//  Created by Balogh Tamás on 2018. 04. 12..
//  Copyright © 2018. Balogh Tamás. All rights reserved.
//

import UIKit

class RunTableViewCell: UITableViewCell {

    static let reuseIdentifier = "RunCell"

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var averageSpeedLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
