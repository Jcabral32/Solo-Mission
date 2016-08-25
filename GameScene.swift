//
//  GameScene.swift
//  Solo Mission
//
//  Created by Jean Cabral on 8/22/16.
//  Copyright (c) 2016 Jean Cabral. All rights reserved.
//

import SpriteKit

var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "playerShip")// creates a Sprite Node object named player and assigns an asset to it.
    let gameArea: CGRect// creates a game area which is a rectangular shape.
    
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1// 1
        static let Bullet: UInt32 = 0b10 // 2
        static let Enemy: UInt32 = 0b100 // 4
    }
    
    
    
    var levelNumber = 0
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
     var currentGame = gameState.preGame
    var lastUpdateTime: NSTimeInterval = 0
    var deltaFrameTime: NSTimeInterval = 0
    var amountToMovePerSecond : CGFloat = 600
    
    
    
    
    
    
    //This function generates a random float value.
    func random()-> CGFloat{
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    
    // this function generates a random value between the given min and max values
    func random(min min: CGFloat, max: CGFloat)-> CGFloat{
    return random() * (max-min) + min
    }
    
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.width / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y:0, width: playableWidth, height: size.height)
        super.init(size: size)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func didMoveToView(view: SKView) {
        gameScore = 0
       
        for i in 0...1{
        
        let background = SKSpriteNode(imageNamed: "background")// create the background object
        
        self.physicsWorld.contactDelegate = self
        /* the size of the background will be the same size as the scene and that changes based on the device being used
        */
        background.size = self.size
        background.name = "Background"
        background.anchorPoint = CGPoint(x: 0.5, y: 0)
        background.position = CGPoint(x: self.size.width/2 , y: self.size.height * CGFloat(i))
        background.zPosition = 0// sets the background behind all the other objects 
        self.addChild(background)// adds the background to the screen
        }
    
        
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)//
        
        scoreLabel.text = "Score : 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15 , y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.whiteColor()
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.Right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        tapToStartLabel.text = "Tap to Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.whiteColor()
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.zPosition = 1
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        let fadeInAction = SKAction.fadeInWithDuration(0.3)
        tapToStartLabel.runAction(fadeInAction)
        
        let moveOntoScreenAction = SKAction.moveToY(self.size.height * 0.9, duration: 1.3)
        scoreLabel.runAction(moveOntoScreenAction)
        livesLabel.runAction(moveOntoScreenAction)
        
        
        }
    
    
    override func update(currentTime: NSTimeInterval) {
        if lastUpdateTime == 0 {
        lastUpdateTime = currentTime
        }else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
            
        
        }
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        self.enumerateChildNodesWithName("Background"){
        background, stop in
            
            if self.currentGame == gameState.inGame{
            background.position.y -= amountToMoveBackground
            }
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        }
        
    }
    
    func loseALife() {
    livesNumber -= 1
        livesLabel.text = " Lives: \(livesNumber)"
        let scaleUp = SKAction.scaleTo(1.5, duration: 0.2)
        let scaleDown = SKAction.scaleTo(1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
        livesLabel.runAction(scaleSequence)
        
        if livesNumber == 0 {
        gameOver()
        }
        
    }
    
    
    func addScore(){
    gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        if (gameScore == 10 || gameScore == 25 || gameScore == 50) {
        startNewLevel()
        }
    }
    
    func gameOver(){
        
        currentGame = gameState.afterGame
    
        self.removeAllActions()
        self.enumerateChildNodesWithName("Bullet"){
        bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodesWithName("Enemy"){
        enemy, stop in
            enemy.removeAllActions()
        }
      let changeSceneAction = SKAction.runBlock(changeScene)
        let waitToChangeScene = SKAction.waitForDuration(1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene,changeSceneAction])
        self.runAction(changeSceneSequence)
        
    }
    
    func startGame(){
        currentGame = .inGame
        let fadeOutAction = SKAction.fadeOutWithDuration(0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction,deleteAction])
        tapToStartLabel.runAction(deleteSequence)
        let moveShipToScreen = SKAction.moveToY(self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.runBlock(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipToScreen,startLevelAction])
        player.runAction(startGameSequence)
        
    }

    
    func changeScene() {
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fadeWithDuration(0.5)
        
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
        body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else {
           body1 = contact.bodyB
           body2 = contact.bodyA
        }
        
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{ // if the player hits the enemy
            if body1.node != nil{
            spawnExplosion(body1.node!.position)
            }
                if body2.node != nil {
                    spawnExplosion(body2.node!.position)
                 }
            
                        body1.node?.removeFromParent()
                        body2.node?.removeFromParent()
                        gameOver()
        }
        
        /* we can only hit the enemy when he is on the screen. the enemy normally spawns off screen. */
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && body2.node?.position.y < self.size.height {
            // if the bullet hits the enemy
            if body2.node != nil {
                addScore()
            spawnExplosion(body2.node!.position)
                
            }
            
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
        
         }
        }
    
    func spawnExplosion(spawnPosition: CGPoint){
    let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        
        self.addChild(explosion)
        
        let scaleIn = SKAction.scaleTo(1, duration: 0.1)
        let fadeOut = SKAction.fadeOutWithDuration(0.1)
        let deleteExplosion = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn,fadeOut,deleteExplosion])
        explosion.runAction(explosionSequence)
        
    }

    /*
     this code lets us move our player side to side. for every touch we take two points of touch subtract
     them and make the difference the amount you "dragged" your finger across the screen. Essentially the player will move in the x direction based on where your finger is.
     */
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for touch: AnyObject in touches{
        let pointOfTouch = touch.locationInNode(self)//
        let previousPointOfTouch = touch.previousLocationInNode(self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
           
            if currentGame == .inGame{
            player.position.x += amountDragged
            }
            /* this code prevents the player from going off screen and out of the game area. if the player does
             go out of the game area he is put immediately back in the game. Making it seem like it is boxed in.
 
            */
            
            if player.position.x > CGRectGetMaxX(gameArea) - (player.size.width / 2) {
                player.position.x = CGRectGetMaxX(gameArea) - (player.size.width / 2)
                                                                                        }
            if player.position.x < CGRectGetMinX(gameArea) + player.size.width / 3{
            player.position.x = CGRectGetMinX(gameArea) + player.size.width / 3
                                                                                }
                                        }
        
        }

    
    // this function starts a new level. It contains our spawn sequence where an enemy spawns then there is a 1 second delay between each spawn.
    
    func startNewLevel(){
        levelNumber += 1
        
        if self.actionForKey("spawningEnemies") != nil {
        self.removeActionForKey("spawningEnemies")
        }
        
        var levelDuration = NSTimeInterval()
        
        switch levelNumber{
            case 1: levelDuration = 1.2
        case 2: levelDuration = 1.0
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default: levelDuration = 0.5
            print("Cannot find level info")
            
        }
        
        let spawn = SKAction.runBlock(spawnEnemy)//this line allows you to make a function into an SKAction.in this context it makes our spawnEnemy method into an action. Which we can then add to any sequence
        let waitToSpawn =  SKAction.waitForDuration(levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatActionForever(spawnSequence)
        self.runAction(spawnForever, withKey: "spawningEnemies")
        
        
    }
    

    func fireBullet()
    {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOfSize: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveToY(self.size.height + bullet.size.height, duration: 1)// allows the bullet to move in the y direction across the entire screen.
        let deleteBullet = SKAction.removeFromParent()// deletes the bullet
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])// lets you run the actions in the order you specify
        bullet.runAction(bulletSequence)
    }
    // this funtcion spawns an enemy at a random position at the top of the screen and makes the enemy move in a random path towards the bottom of the screen.
    
    
    func spawnEnemy()
    {
    let randomXStart = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))// generates a random x position within the gameArea.
        let randomXEnd = random(min: CGRectGetMinX(gameArea), max: CGRectGetMaxX(gameArea))
        //  creates a different random x postion within the gameArea
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)// an initial random position x position and above the game area screen.
        
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2) // a random point x point that ends below the game screen.
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOfSize: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.moveTo(endPoint, duration: 1.5)// moves the enemy to the endpoint
        let deleteEnemy = SKAction.removeFromParent()
        let lossOfLife = SKAction.runBlock(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy,deleteEnemy, lossOfLife])
        
        if currentGame == gameState.inGame{
        enemy.runAction(enemySequence)
        }
        
        
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let amountToRotate =  atan2(deltaY, deltaX)
        
        enemy.zRotation = amountToRotate
    }
    
   
    /*
     This Function runs every time there is a tap on the screen
     */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if currentGame == gameState.preGame{
        startGame()
        }
        
        else if currentGame == gameState.inGame {
            fireBullet()
        }
        
        
    }
    
    

}
