//
//  PlayerViewController.swift
//  BookPlay
//
//  Created by Jarco Katsalay on 6/24/17.
//  Copyright © 2017 Jarco Katsalay. All rights reserved.
//

import UIKit
import CoreData
import AVKit
import AVFoundation

class PlayerViewController: UIViewController, PlayListsViewControlerDelegate {

    var managedObjectContext: NSManagedObjectContext? = nil
    var playListVC: PlayListsViewControler!
    
    var player: AVQueuePlayer!
    
    var currentPlayList: PlayList? = nil
    var playing = false {
        didSet {
            if playing {
                
                let mediaItems: [MediaItem] = currentPlayList?.getAll() ?? []
                
                let playerItems: [AVPlayerItem] = mediaItems.map({
                    
                    AVPlayerItem(url: URL(string: $0.url!)!)
                })
                
                player = AVQueuePlayer(items: playerItems)
                
                player.play()
            } else {
                
                player.pause()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let playlistNavigationController = self.childViewControllers[0] as! UINavigationController
        playListVC = playlistNavigationController.topViewController as! PlayListsViewControler
        playListVC.managedObjectContext = self.managedObjectContext
        playListVC.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - PlayListsViewControlerDelegate
    func play(_ playList: PlayList) {
        
        currentPlayList = playList
        playing = true
    }
    
    func pause(_ playList: PlayList) {
        
        playing = false
    }

}
