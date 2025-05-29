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
        listPhoto.layer.cornerRadius = listPhoto.frame.size.width / 2
        listPhoto.clipsToBounds = true
        listPhoto.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
