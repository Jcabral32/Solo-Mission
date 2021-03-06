//
//  GameViewController.swift
//  Solo Mission
//
//  Created by Jean Cabral on 8/22/16.
//  Copyright (c) 2016 Jean Cabral. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        _ = UIInterfaceOrientationMask.allButUpsideDown
        _ = self.shouldAutorotate
        _ = self.prefersStatusBarHidden
        
        let scene = MainMenuScene(size: CGSize(width: 1536, height: 2048)) // This line makes the game size a hardcoded value which can be scaled based on the aspect ratio size of the screen the game is played on //
        
            // Configure the view.
        let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
        
            skView.presentScene(scene)
        
        
    }

    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    
}
