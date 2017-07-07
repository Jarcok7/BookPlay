//
//  PlayListsTableViewCell.swift
//  BookPlay
//
//  Created by Jarco Katsalay on 6/30/17.
//  Copyright © 2017 Jarco Katsalay. All rights reserved.
//

import UIKit

class PlayListsTableViewCell: UITableViewCell {
    
    var delegate: PlayListsTableViewCellDelegate? = nil
    
    var playList: PlayList!
    
    var playing = false {
        didSet {
            if playing {
                delegate?.play(playList)
                playPauseButton.setTitle("PAUSE", for: .normal)
                playPauseButton.setTitleColor(UIColor.red, for: .normal)
            } else {
                delegate?.pause(playList)
                playPauseButton.setTitle("PLAY", for: .normal)
                playPauseButton.setTitleColor(self.tintColor, for: .normal)
            }
        }
    }

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var playPauseButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func playPauseTouchUpInside(_ sender: UIButton) {
        
        playing = !playing
    }

}

protocol PlayListsTableViewCellDelegate {
    func play(_ playList: PlayList)
    func pause(_ playList: PlayList)
}
