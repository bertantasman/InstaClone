//
//  cellContent.swift
//  InstagramKlon
//
//  Created by Bertan Taşman on 29.03.2025.
//

import UIKit

protocol cellContentDelegate: AnyObject {
    func didTapOptionsButton(cell: cellContent)
    func didTapLike(cell: cellContent)
    func didDoubleTapImage(cell: cellContent)
    func didTapComment(cell: cellContent)
    func didTapShare(cell: cellContent)
}


class cellContent: UITableViewCell {

    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var content: UILabel!
    @IBOutlet weak var commentCount: UILabel!
    @IBOutlet weak var shareButton: UIButton!

    weak var delegate: cellContentDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        profilePhoto.layer.cornerRadius = profilePhoto.frame.size.width / 2
        profilePhoto.clipsToBounds = true
        profilePhoto.contentMode = .scaleAspectFill
        profilePhoto.layer.borderWidth = 1
        profilePhoto.layer.borderColor = UIColor.lightGray.cgColor

        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(imageDoubleTapped))
        doubleTap.numberOfTapsRequired = 2
        photo.addGestureRecognizer(doubleTap)
        photo.isUserInteractionEnabled = true
    }
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        delegate?.didTapComment(cell: self)
    }

    @IBAction func optionsButtonTapped(_ sender: UIButton) {
        delegate?.didTapOptionsButton(cell: self)
    }

    @IBAction func likeButtonTapped(_ sender: UIButton) {
        delegate?.didTapLike(cell: self)
    }

    @objc func imageDoubleTapped() {
        delegate?.didDoubleTapImage(cell: self)
    }

    @IBAction func shareButtonTapped(_ sender: UIButton) {
        delegate?.didTapShare(cell: self) // ✅ çağrı yapıldı
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
