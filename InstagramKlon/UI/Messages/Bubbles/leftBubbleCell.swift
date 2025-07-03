//
//  leftBubbleCell.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 30.05.2025.
//

import UIKit

class LeftBubbleCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        bubbleView.layer.cornerRadius = 16
        bubbleView.backgroundColor = UIColor.systemGray5
        messageLabel.numberOfLines = 0
    }
}
