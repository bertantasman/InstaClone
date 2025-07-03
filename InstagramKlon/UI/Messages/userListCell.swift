//
//  userListCell.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 29.05.2025.
//

import UIKit

class userListCell: UITableViewCell {

    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2
        profilePhoto.clipsToBounds = true
        profilePhoto.contentMode = .scaleAspectFill
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
