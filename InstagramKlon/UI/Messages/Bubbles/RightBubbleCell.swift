//
//  rigtBubbleCell.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 30.05.2025.
//

import UIKit

class RightBubbleCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        bubbleView.layer.cornerRadius = 16
        bubbleView.backgroundColor = UIColor.systemBlue
        messageLabel.numberOfLines = 0
        messageLabel.textColor = .white
    }
}
