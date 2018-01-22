//
//  GameScene.swift
//  Solo Mission
//
//  Created by Jean Cabral on 8/22/16.
//  Copyright (c) 2016 Jean Cabral. All rights reserved.
//

import SpriteKit

var gameScore = 0//

class GameScene: SKScene, SKPhysicsContactDelegate {
/****************
Global Variables*
*****************/
    // Sets up Categoires for each object in the game.
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1// 1
        static let Bullet: UInt32 = 0b10 // 2
        static let Enemy: UInt32 = 0b100 // 4
    }
    
    
    // Allows us to refrence our gameState as three distinct possible states. Can set up code for each state.
    enum gameState{
        case preGame
        case inGame
        case afterGame
    }
    let player = SKSpriteNode(imageNamed: "playerShip")// creates a Sprite Node object named player and assigns an asset to it.
    
    let gameArea: CGRect// creates a game area which is a rectangular shape.
    var levelNumber = 0
    var livesNumber = 3
    /* 
     Global Labels
     */
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    //Scrolling Background Utility Variables
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var amountToMovePerSecond : CGFloat = 600
    
    var currentGame = gameState.preGame
    
    
    
    
/*****************
Utility Functions*
******************/
/*****************
*/
 
/*
This function generates a random float value.
*/
    func random()-> CGFloat{
    return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    // this function generates a random value between the given min and max values
    func random(_ min: CGFloat, max: CGFloat)-> CGFloat{
    return random() * (max-min) + min
    }
    /*
     
     */
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.width / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y:0, width: playableWidth, height: size.height)
        super.init(size: size)
        }
    /*
     
     */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
/*
UI Touch Functions
*/
    override func didMove(to view: SKView) {
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
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(player)
        
/*
Score Label
*/
        
        scoreLabel.text = "Score : 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.15 , y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
/*
Lives Label
*/
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
/*
TaptoStart Label
*/
        tapToStartLabel.text = "Tap to Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.zPosition = 1
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
        let moveOntoScreenAction = SKAction.moveTo(y: self.size.height * 0.9, duration: 1.3)
        scoreLabel.run(moveOntoScreenAction)
        livesLabel.run(moveOntoScreenAction)
        }
/*
This function
*/
    
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
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            if body2.node != nil {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            gameOver()
        }
        /* we can only hit the enemy when he is on the screen. the enemy normally spawns off screen. */
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height {
            // if the bullet hits the enemy
            if body2.node != nil {
                addScore()
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
/*
This Function runs every time there is a tap on the screen. Whem you initially start the game it is pasued. The tap to begin logo appears.
The game is initially in a pre game state and tapping the screen during pre game state starts the game. Then, after we are in the InGame
state tapping the screen fires a bullet from the player ship.
*/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGame == gameState.preGame{
            startGame()
        }

        else if currentGame == gameState.inGame {
            fireBullet()
        }
    }
/*   
This code allows the player ship to move side to side. For every touch we take two points of touch subtract
them and make the difference the amount you "dragged" your finger across the screen.
Essentially the player will move in the x direction based on where your finger is.
*/
    //TODO: Fix the movement logic in this method
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            // If the game has started the player ship is allowed to move. This will affect the players position.
            if currentGame == .inGame{
                player.position.x += amountDragged
            }
            /* This code prevents the player ship from going off screen and out of the game area. If the player
               is out of the game area; it is placed immediately back in the game at the minimum x position of the game area.
               Which corresponds to the left side and the maximum x position the right side respectively.
               Making it appear your boxed in.
             */
            if player.position.x > gameArea.minX - (player.size.width / 2) {
                player.position.x = gameArea.minX - (player.size.width / 2)
            }
            if player.position.x < gameArea.minX + player.size.width / 3{
                player.position.x = gameArea.minX + player.size.width / 3
            }
        }
        
    }
/*
This function updates the Screen
*/
    override func update(_ currentTime: TimeInterval) {
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        if lastUpdateTime == 0 {
        lastUpdateTime = currentTime
        }
        else {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        /*
         
         */
        self.enumerateChildNodes(withName: "Background"){
        background, stop in
        /*
        
        */
        if self.currentGame == gameState.inGame{
            background.position.y -= amountToMoveBackground
            }
        if background.position.y < -self.size.height{
            background.position.y += self.size.height*2
            }
        }
    }
/*
This function sets the      
*/
    func loseALife() {
        /*
         
         */
        livesNumber -= 1
        livesLabel.text = " Lives: \(livesNumber)"
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp,scaleDown])
        livesLabel.run(scaleSequence)
        if livesNumber == 0 {
        gameOver()
        }
        
    }
/*
     
*/
    func addScore(){
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        /*
         
         */
        if (gameScore == 10 || gameScore == 25 || gameScore == 50) {
                startNewLevel()
        }
    }
/*
     
*/
    func gameOver(){
        currentGame = gameState.afterGame
        self.removeAllActions()
        self.enumerateChildNodes(withName: "Bullet"){
        bullet, stop in
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy"){
        enemy, stop in
            enemy.removeAllActions()
        }
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene,changeSceneAction])
        self.run(changeSceneSequence)
        
    }
/*
     
*/
    func startGame(){
        currentGame = .inGame
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction,deleteAction])
        tapToStartLabel.run(deleteSequence)
        let moveShipToScreen = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipToScreen,startLevelAction])
        player.run(startGameSequence)
        
    }
/*
     
*/
    func changeScene() {
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    
    }
/*
     
*/
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let deleteExplosion = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([scaleIn,fadeOut,deleteExplosion])
        explosion.run(explosionSequence)
        }
/*
This function begins a new level. It contains our spawn sequence where an enemy spawns then there is a 1 second delay between each spawn.
*/
    func startNewLevel(){
        var levelDuration = TimeInterval()
        levelNumber += 1
        /*
         
         */
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        /*
         
         */
        switch levelNumber{
            case 1: levelDuration = 1.2
        case 2: levelDuration = 1.0
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default: levelDuration = 0.5
            print("Cannot find level info")
        }
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn =  SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        }
/*
     
*/
    func fireBullet(){
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()// deletes the bullet
        let bulletSequence = SKAction.sequence([moveBullet, deleteBullet])// lets you run the actions in the order you specify
        bullet.run(bulletSequence)
    }
/*
This funtcion spawns an enemy at a random position on top of the screen. Enemies move in a random x-path towards the bottom of the screen.
*/
    func spawnEnemy(){
        let randomXStart = random(gameArea.minX, max: gameArea.maxX)// generates a random x position within the gameArea.
        let randomXEnd = random(gameArea.minX, max: gameArea.maxX) //  creates a different random x postion within the gameArea
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)// an initial random position x position and above the game area screen.
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2) // a random point x point that ends below the game screen.
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(enemy)
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)// moves the enemy to the endpoint
        let deleteEnemy = SKAction.removeFromParent()
        let lossOfLife = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy,deleteEnemy, lossOfLife])
        /*
         
         */
        if currentGame == gameState.inGame{
            enemy.run(enemySequence)
        }
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let amountToRotate =  atan2(deltaY, deltaX)
        enemy.zRotation = amountToRotate
    }
}
