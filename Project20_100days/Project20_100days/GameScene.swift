//
//  GameScene.swift
//  Project20_100days
//
//  Created by user228564 on 3/1/23.
//

import SpriteKit

class GameScene: SKScene {
    
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    var scoreLabel: SKLabelNode!
    var explodeLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!


    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1180 + 22

    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var currentLaunch = 0
    let totalLaunches = 5
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.frame.size
        background.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "chalkduster")
        scoreLabel.position = CGPoint(x: 1140, y: 790)
        scoreLabel.zPosition = 1
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        explodeLabel = SKLabelNode(fontNamed: "chalkduster")
        explodeLabel.position = CGPoint(x: 24, y: 790)
        explodeLabel.zPosition = 1
        explodeLabel.horizontalAlignmentMode = .left
        explodeLabel.text = "Explode"
        explodeLabel.name = "explode"
        addChild(explodeLabel)
        
        gameOverLabel = SKLabelNode(fontNamed: "chalkduster")
        gameOverLabel.position = CGPoint(x: self.frame.size.width/2, y: self.frame.size.height/2)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.zPosition = 1
        gameOverLabel.text = "Out Of Fireworks!"
        gameOverLabel.fontSize = 48
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    @objc func launchFireworks() {
        currentLaunch += 1
        
        if currentLaunch >= totalLaunches {
            stopFireworks()
            return
        }
        
        let movementAmount: CGFloat = 1800

        switch Int.random(in: 0...3) {
        case 0:
            // fire five, straight up
            createFirework(xMovement: 0, x: 590, y: bottomEdge)
            createFirework(xMovement: 0, x: 590 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 590 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 590 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 590 + 200, y: bottomEdge)

        case 1:
            // fire five, in a fan
            createFirework(xMovement: 0, x: 590, y: bottomEdge)
            createFirework(xMovement: -200, x: 590 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 590 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 590 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 590 + 200, y: bottomEdge)

        case 2:
            // fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

        case 3:
            // fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

        default:
            break
        }
    }
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        // 1
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)

        // 2
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1
        firework.name = "firework"
        node.addChild(firework)

        // 3
        switch Int.random(in: 0...2) {
        case 0:
            firework.color = .cyan

        case 1:
            firework.color = .green

        case 2:
            firework.color = .red

        default:
            break
        }

        // 4
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))

        // 5
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        node.run(move)

        // 6
        if let emitter = SKEmitterNode(fileNamed: "fuse") {
            emitter.position = CGPoint(x: 0, y: -22)
            node.addChild(emitter)
        }

        // 7
        fireworks.append(node)
        addChild(node)
    }
    
    func stopFireworks() {
        gameTimer?.invalidate()
        
        for node in fireworks {
            node.removeFromParent()
        }
        
        addChild(gameOverLabel)
    }
    
    func checkTouches(_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }

        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKLabelNode in nodesAtPoint {
            if node.name == "explode" {
                explodeFireworks()
                return
            }
        

        }
             
        
        for case let node as SKSpriteNode in nodesAtPoint {
            
            guard node.name == "firework" else { continue }
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue }

                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                }
            }
            
            node.name = "selected"
            node.colorBlendFactor = 0
        }
         
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches)
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
            
            let actionWait = SKAction.wait(forDuration: 1.5)
            let actionRemove = SKAction.run {
                emitter.removeFromParent()
            }
            let actionSequence = SKAction.sequence([actionWait, actionRemove])
            emitter.run(actionSequence)
        }
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0

        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }

            if firework.name == "selected" {
                // destroy this firework!
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }

        switch numExploded {
        case 0:
            // nothing – rubbish!
            break
        case 1:
            score += 200
        case 2:
            score += 500
        case 3:
            score += 1500
        case 4:
            score += 2500
        default:
            score += 4000
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                // this uses a position high above so that rockets can explode off screen
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
    }
}
