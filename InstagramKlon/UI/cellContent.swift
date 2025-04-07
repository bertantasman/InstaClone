//
//  cellContent.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 29.03.2025.
//

import UIKit

// Delegate protokolü
protocol cellContentDelegate: AnyObject {
    func didTapOptionsButton(cell: cellContent)
}

class cellContent: UITableViewCell {

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
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
