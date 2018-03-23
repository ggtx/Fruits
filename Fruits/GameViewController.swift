//
//  GameViewController.swift
//  Fruits
//
//  Created by GAO on 2018/3/18.
//  Copyright © 2018年 GAO. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        let scene = GameScene(size: self.view.frame.size)
        let skView = self.view as! SKView
        skView.presentScene(scene)
    }
}
