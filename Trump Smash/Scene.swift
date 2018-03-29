//
//  Scene.swift
//  Trump Smash
//
//  Created by Kristen Kulha on 3/29/18.
//  Copyright © 2018 Kristen Kulha. All rights reserved.
//

import SpriteKit
import ARKit

class Scene: SKScene {
    
    let trumpsLabel = SKLabelNode(text: "Trumps")
    let numberOfTrumpsLabel = SKLabelNode(text: "0")
    let scoreLabel = SKLabelNode(text: "Score")
    let totalScoreLabel = SKLabelNode(text: "0")
    var creationTime : TimeInterval = 0
    var trumpCount = 0 {
        didSet {
            self.numberOfTrumpsLabel.text = "\(trumpCount)"
        }
    }
    var score = 0 {
        didSet {
            self.totalScoreLabel.text = "\(score)"
        }
    }
    let killSound = SKAction.playSoundFileNamed("trump-sound", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        // Setup your scene here
        trumpsLabel.fontSize = 20
        trumpsLabel.fontName = "STHeitiSC-Medium"
        trumpsLabel.color = .white
        trumpsLabel.position = CGPoint(x: 40, y: 50)
        addChild(trumpsLabel)
        
        numberOfTrumpsLabel.fontSize = 30
        numberOfTrumpsLabel.fontName = "STHeitiSC-Medium"
        numberOfTrumpsLabel.color = .white
        numberOfTrumpsLabel.position = CGPoint(x: 40, y:10)
        addChild(numberOfTrumpsLabel)
        
        let xPosition = frame.maxX - 40
        
        scoreLabel.fontSize = 20
        scoreLabel.fontName = "STHeitiSC-Medium"
        scoreLabel.color = .white
        scoreLabel.position = CGPoint(x: xPosition, y: 50)
        addChild(scoreLabel)
        
        totalScoreLabel.fontSize = 30
        totalScoreLabel.fontName = "STHeitiSC-Medium"
        totalScoreLabel.color = .white
        totalScoreLabel.position = CGPoint(x: xPosition, y: 10)
        addChild(totalScoreLabel)
        
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if currentTime > creationTime {
            createTrumpAnchor()
            creationTime = currentTime + TimeInterval(randomFloat(min: 3.0, max: 6.0))
        }
    }
    
    func randomFloat(min: Float, max: Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func createTrumpAnchor() {
        guard let sceneView = self.view as? ARSKView else {
            return
        }
        // Define 360 degrees in radians
        let _360degrees = 2.0 * Float.pi
        //Place Trump in random position. Create random rotation matrix on the X and Y axis.
        let rotateX = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 1, 0, 0))
        //SCNMatrix4MakeRotation returns a matrix describing a rotation transformation.
        // simd_float4x4 coverts result into a 4x4 matrix
        let rotateY = simd_float4x4(SCNMatrix4MakeRotation(_360degrees * randomFloat(min: 0.0, max: 1.0), 0, 1, 0))
        // Combine both rotation matrices with a multiplication operation
        let rotation = simd_mul(rotateX, rotateY)
        // Create a translation matrix in the Z-axis with a random value between -1 and -2 meters
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -1 - randomFloat(min: 0.0, max: 1.0)
        // Combine the rotation and translation matrices
        let transform = simd_mul(rotation, translation)
        // Create and add anchor to the screen
        let anchor = ARAnchor(transform: transform)
        sceneView.session.add(anchor: anchor)
        // Increment the Trump counter
        trumpCount += 1
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        
        // Get location of touch in AR scene
        let location = touch.location(in: self)
        
        // Get the nodes at that location
        let hit = nodes(at: location)
        
        // Get first node (if any). Check if the node represents a trump.
        if let node = hit.first {
            if node.name == "trump" {
    
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                
                // Group the fade out and sound actions
                let groupKillingActions = SKAction.group([fadeOut, killSound])
                // Create an action sequence
                let sequenceAction = SKAction.sequence([groupKillingActions, remove])
                
                //Execute the actions
                node.run(sequenceAction)
                
                // Update the counter
                trumpCount -= 1
                score += 1
            }
        }
        
    }
}
