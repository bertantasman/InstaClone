//
//  cellContent.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 29.03.2025.
//

import UIKit

protocol cellContentDelegate: AnyObject {
    func didTapOptionsButton(cell: cellContent)
}

class cellContent: UITableViewCell {

    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var content: UILabel!

    weak var delegate: cellContentDelegate?

    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        delegate?.didTapOptionsButton(cell: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2
        profilePhoto.clipsToBounds = true
        profilePhoto.contentMode = .scaleAspectFill
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor
    }



    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
