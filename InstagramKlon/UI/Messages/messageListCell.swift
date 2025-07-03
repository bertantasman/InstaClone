//
//  messageListCell.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 28.05.2025.
//

import UIKit

class messageListCell: UITableViewCell {

    @IBOutlet weak var listPhoto: UIImageView!
    @IBOutlet weak var listLastMessage: UILabel!
    @IBOutlet weak var listNickname: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        listPhoto.contentMode = .scaleAspectFill
        listPhoto.clipsToBounds = true
        listPhoto.layer.cornerRadius = listPhoto.frame.size.width / 2

        listLastMessage.numberOfLines = 0
        listNickname.lineBreakMode = .byWordWrapping
        listNickname.numberOfLines = 2
        listNickname.adjustsFontSizeToFitWidth = false
        listNickname.minimumScaleFactor = 1.0
        listPhoto.layer.cornerRadius = listPhoto.frame.size.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
