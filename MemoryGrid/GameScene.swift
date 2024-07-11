//
//  GameScene.swift
//  MemoryGrid
//
//  Created by 乐海丰 on 2024/6/29.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
//    private var label : SKLabelNode?
//    private var spinnyNode : SKShapeNode?
    private var circleGrid = [SKSpriteNode]()
    private var labelRange:SKLabelNode?
    private var labelScore:SKLabelNode?
    private var labelMsg:SKLabelNode?
    private var labelStart:SKLabelNode?
    private var labelReset:SKLabelNode?
    private let greenTexture = SKTexture(imageNamed: "circleGreen")
    private let buleTexrure = SKTexture(imageNamed: "circleBlue")
    private let redTexture = SKTexture(imageNamed: "circleRed")
    var nums = [0,1,2,3,4,5,6,7,8]
    var answer:[Int] = []
    var level:Int = 1
    let maxLevel:Int = 9
    var range:Int = 1
    let maxRange = 6
    var passTime:Int = 0
    var errorTime:Int = 0
    let maxErrorTime: Int = 3
    let maxPassTime = 5
    var score = 0
    private var gussNum:Int = 4
    private var timeInterval:Double = 2
    private var timeMemory:Double = 4
//    当前状态，0:默认状态，1:正在演示，，2:用户输入
    var status = 0
    var indexInput = 0
    
    override func didMove(to view: SKView) {
        
        self.labelRange = self.childNode(withName: "//labelRange") as? SKLabelNode
        if let label = self.labelRange{
            label.text = "range1-1"
            label.name = "labelRange"
        }
        self.labelScore = self.childNode(withName: "//labelScore") as? SKLabelNode
        if let scoreLabel = self.labelScore{
            scoreLabel.text = String(self.score)
        }
        self.labelMsg = self.childNode(withName: "//labelMsg") as? SKLabelNode
        self.labelStart = self.childNode(withName: "//labelStart") as? SKLabelNode
        if let labelStart = self.labelStart{
            labelStart.name = "labelStart"
        }
        self.labelReset = self.childNode(withName: "labelReset") as? SKLabelNode
        if let labelReset = self.labelReset{
            labelReset.name = "labelReset"
        }
//        计算尺寸
//        let margin:CGFloat = 20
        let screenWidth = self.size.width
//        let screenHeight = self.size.height
        let gridSize = (screenWidth - 200) / 3.0
        let circleSize = gridSize
        
        self.circleGrid = [SKSpriteNode]()
        let bluuTexture = SKTexture(imageNamed: "circleBlue")
        
        for row in 0..<3{
            for col in 0..<3{
                let x = CGFloat(col-1) * gridSize
                let y = -CGFloat(row-1) * gridSize
                let node = SKSpriteNode(texture: bluuTexture)
                node.userData = NSMutableDictionary()
                node.userData?["type"] = "circle"
                node.userData?["index"] = row*3 + col
                node.size = CGSize(width: circleSize, height: circleSize)
                node.position = CGPoint(x: x, y: y)
                self.circleGrid.append(node)
                self.addChild(node)
            }
        }
        
//        self.showToast(message: "game start", duration: 2)
        self.loadScore()
        
        self.updateGameInfo()
        
    }
    


//    检查用户点击是否正确，在每次用户点击后执行
    func checkAnswer(gridIndex : Int){
        if self.answer[self.indexInput] == gridIndex{
//            点击正确
            self.indexInput += 1
            self.circleGrid[gridIndex].texture = self.greenTexture
//            本次连续点击结束
            if self.indexInput == self.gussNum{
                self.passTime += 1
                self.score += 10
                self.indexInput = 0
                self.updateGameInfo()
            }
        }else{
            self.indexInput = 0
            self.circleGrid[gridIndex].texture = self.redTexture
            self.run(SKAction.wait(forDuration: 2.0))
//            DispatchQueue.main.asyncAfter(deadline: .now()+2.0){
//                
//            }
            self.errorTime += 1
            self.updateGameInfo()
        }
    }
    
//    通过status设置所有组件状态
    func updateByStatus(){
        if status == 0{
//            默认状态，
        }else if status == 1{
            
        }else if status == 2{
            
        }
    }
    
    
//  根据通过关卡次数更新游戏关卡参数，在用户点击完一轮后执行
    func updateGameInfo(){
        self.updateByStatus()
//        更新level
        if self.passTime == self.maxPassTime{
//            通过本关level + 1
            self.level += 1
            self.passTime = 0
            self.errorTime = 0
        }
        if self.errorTime == self.maxErrorTime{
            print("restart this level")
            self.passTime = 0
            self.errorTime = 0
        }
//        更新range
        if self.level > self.maxLevel{
            self.range += 1
            self.level = 1
        }
        if self.range > self.maxRange{
            print("game passed!")
        }
        
        self.saveScore()
        
        self.gussNum = self.range + 3
        self.timeInterval = 2.0 - 0.2 * Double(self.level)
        self.timeMemory = 4.0 - 0.4 * Double(self.level)
        
        
//        更新标题
        self.labelRange?.text = "Range "+String(self.range)+"-"+String(self.level)
        self.labelScore?.text = String(self.score)
        
    }
    
//    生产action，将所有原点恢复到初始状态
    func clearAllTextureAction() -> SKAction{
        let action = SKAction.run {
            for node in self.circleGrid{
                node.texture = self.buleTexrure
            }
        }
        return action
    }
    
    func startGame(){
        self.updateGameInfo()
        var actions = [SKAction]()
        
        actions.append(self.clearAllTextureAction())
//
        self.nums.shuffle()
//      正确答案
        self.answer.removeAll()
        
        let waitInterval = SKAction.wait(forDuration: self.timeInterval)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        let vibrationAction = SKAction.run {
            generator.impactOccurred()
        }
        for i in 0..<self.gussNum{
            let gridIndex = self.nums[i]
            actions.append(waitInterval)
            let changeGreen = SKAction.run {
                self.circleGrid[gridIndex].texture = self.greenTexture
            }
            actions.append(changeGreen)
            actions.append(vibrationAction)
            self.answer.append(gridIndex)
        }
        let waitMemory = SKAction.wait(forDuration: self.timeMemory)
        actions.append(waitMemory)
        actions.append(self.clearAllTextureAction())
        
        let sequence = SKAction.sequence(actions)
        
        self.run(sequence)
    }
    
    func showToast(message: String, duration: TimeInterval) {
        self.labelMsg?.text = message
        let action = SKAction.run {
            self.labelMsg?.text = message
            SKAction.wait(forDuration: duration)
            self.labelMsg?.text = ""
        }
        self.labelMsg?.run(action)
    }
    
    func saveScore(){
        UserDefaults.standard.set(self.score, forKey: "score")
        UserDefaults.standard.set(self.range, forKey: "range")
        UserDefaults.standard.set(self.level, forKey: "level")
    }
    func loadScore(){
        if let score = UserDefaults.standard.value(forKey: "score") as? Int {
            self.score = score
        }
        if let range = UserDefaults.standard.value(forKey: "range") as? Int {
            self.range = range
        }
        if let level = UserDefaults.standard.value(forKey: "level") as? Int{
            self.level = level
        }
    }
    

    
    func touchDown(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.green
//            self.addChild(n)
//        }
    }
    
    
    func touchMoved(toPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.blue
//            self.addChild(n)
//        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
//        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
//            n.position = pos
//            n.strokeColor = SKColor.red
//            self.addChild(n)
//        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 获取触摸点
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // 获取触摸点处的节点
        let touchedNodes = self.nodes(at: location)
        
        
        let generator = UIImpactFeedbackGenerator(style: .medium)
        
        for node in touchedNodes {
            if node.name == "labelStart"{
                generator.impactOccurred()
                if self.status == 0 || self.status == 2{
                    self.startGame()
                }
            }
            if node.name == "labelReset"{
                self.score = 0
                self.range = 1
                self.level = 1
                self.updateGameInfo()
            }
            if node.name == "labelRange"{
                generator.impactOccurred()
                self.level += 1
                self.updateGameInfo()
            }
            
    //            点击的是圆点
            if let spriteNode = node as? SKSpriteNode{
                if let type = spriteNode.userData?["type"] as? String, type == "circle"{
                    generator.impactOccurred()
//                    检查点击是否正确
                    self.checkAnswer(gridIndex: spriteNode.userData?["index"] as! Int)
                }
            }
            
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
