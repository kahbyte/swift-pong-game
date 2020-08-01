//
//  GameScene.swift
//  Individual Learn Path
//
//  Created by Kauê Sales on 06/07/20.
//  Copyright © 2020 Kauê Sales. All rights reserved.
//

import SpriteKit
import GameplayKit



class GameScene: SKScene {
    ///MARK: Nodes
    var ball = SKSpriteNode()
    var player = SKSpriteNode()
    var opponent = SKSpriteNode()

    ///MARK: Labels
    var opponentScore = SKLabelNode()
    var playerScore = SKLabelNode()
    
    var score = (playerScore: 0, opponentScore: 0)
    var force = 8
    let maxScore = 10
    
    enum gameMode{
        case easy
        case medium
        case hard
        case localMultiplayer
        case peerToPeerMultiplayer
    }
    
    override func didMove(to view: SKView){
        
        //this allows me to use the nodes
        ball = self.childNode(withName: "ball") as! SKSpriteNode
        
        
        player = self.childNode(withName: "player") as! SKSpriteNode
        player.position.x = (-self.frame.width / 2) + 70 // sets paddle position programmatically. Helps with different sizes
             
        opponent = self.childNode(withName: "opponent") as! SKSpriteNode
        opponent.position.x = (self.frame.width / 2) - 70 // sets paddle position programmatically. Helps with different sizes
        
        playerScore = self.childNode(withName: "playerScore") as! SKLabelNode
        opponentScore = self.childNode(withName: "opponentScore") as! SKLabelNode
        
        let border = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        //Frame settings
        border.friction = 0
        border.restitution = 1
        self.physicsBody = border
        
        startGame()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            
            if location.x < 0 {
                
                player.run(SKAction.moveTo(y: location.y, duration: 0.1))
                
                sendPosition(myYPosition: location.y)
                
            } else if location.x > 0 && !isConnected {
                opponent.run(SKAction.moveTo(y: location.y, duration: 0.1))
                sendPosition(myYPosition: location.y)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            
            if location.x < 0 {
                player.run(SKAction.moveTo(y: location.y, duration: 0.1))
                
                sendPosition(myYPosition: location.y)
                
            } else if location.x > 0 && !isConnected {
                opponent.run(SKAction.moveTo(y: location.y, duration: 0.1))
                sendPosition(myYPosition: location.y)
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if ball.position.x <= player.position.x{
            addScore(playerWhoScored: opponent)
        }
        
        else if ball.position.x >= opponent.position.x{
            addScore(playerWhoScored: player)
        }
    }
}

extension GameScene {
    //MARK: Match settings
    //Sets the score of both players to 0 and apply the initial impulse for the ball
    func startGame(){
        score.playerScore = 0
        score.opponentScore = 0
        
        updateScoreLabel()
        
        /*apply the initial impulse using the force variable with random -1 or 1 scalars to decide if the ball should go left or right + down or up*/
        ball.physicsBody?.applyImpulse(CGVector(dx: randomSignedScalar() * force, dy: randomSignedScalar() * force))
    }
    
    /*Function that receives the player who scored, updates their score and launches the ball again while the score is < maxScore*/
    func addScore(playerWhoScored: SKSpriteNode){
        var impulse: CGVector!
        
        /*the ball velocity is resetted to 0 to prevent impulse stacking and the ball going faster everytime a score is added*/
        resetBall()
        
        if playerWhoScored == player{
            score.playerScore += 1
            impulse = CGVector(dx: force, dy: randomSignedScalar() * force) // the ball goes right + random up or down
        }
        
        else if playerWhoScored == opponent{
            score.opponentScore += 1
            impulse = CGVector(dx: -force, dy: randomSignedScalar() * force) // the ball goes left + random up or down
        }
        
        updateScoreLabel()
        
        /*if the maxScore is reached, the game ends. Else, the ball is launched again*/
        if score.playerScore == maxScore || score.opponentScore == maxScore{
            endGame()
        } else{
            ball.physicsBody?.applyImpulse(impulse)
        }
        
    }
    
    /*Picks -1 or 1 randomly to be used in the up or down impulse*/
    func randomSignedScalar() -> Int{
        let number = Int.random(in: 0...10)
        
        return (number % 2 == 0 ? 1 : -1) //if the generated number is even, return 1. Else, return -1.
    }
    
    //Update the labels with the current score values
    func updateScoreLabel(){
        playerScore.text = String(score.playerScore)
        opponentScore.text = String(score.opponentScore)
    }
    
    /*Resets the ball velocity to zero and to initial position*/
    func resetBall(){
        ball.position = CGPoint(x: 0, y: 0)
        ball.physicsBody?.velocity = CGVector(dx: 0, dy: 0)

    }
    
    /*the ball velocity and position resets to zero, displays the victory/defeat animation and performs the segue back to the lobby*/
    func endGame(){
        resetBall()
    }
    
    /*my first attempt to make the paddle move synched between devices*/
    func sendPosition(myYPosition: CGFloat){
        /*if mcSession?.connectedPeers.count == 0 { return }
        
        print("Recebido comando, senhor! enviando localização")
        
        let locationData = NSKeyedArchiver.archivedData(withRootObject: myYPosition)
        
        do{
            try mcSession?.send(locationData, toPeers: mcSession!.connectedPeers, with: .reliable)
            
            print("localização enviada com sucesso!")
        } catch let error{
            print(error)
        }
        
        let position = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(locationData) as? CGFloat
        
        print("teste recebido: \(String(describing: position))")*/
    }
}
