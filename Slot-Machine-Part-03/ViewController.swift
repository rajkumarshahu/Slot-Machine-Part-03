//
//  ViewController.swift
//  Slot Machine
//
//  Created by Raj Kumar Shahu and Supriya Gadkari
//  Created on 2021-02-09.
//  @Description: Using a Data persistence strategy (Firestore) to keep track of the global Jackpot that will be displayed for all users as well as personal highest winnings paid out.

import UIKit
import Lottie
import AVFoundation
import Canvas
import Firebase

class ViewController: UIViewController {

let db = Firestore.firestore()
var audioPlayer: AVAudioPlayer?
var totalWin = 0
let animationView = AnimationView()
let ref = Database.database().reference()

@IBOutlet weak var winLabel: UILabel!
var winAmount: Int = 0 {
    didSet {
        winLabel.text = "You won \(winAmount) coins"
    }
}

@IBOutlet weak var winAnimationView: CSAnimationView!

@IBOutlet weak var balanceLabel: UILabel!
var balance: Int = 0 {
    didSet {
        balanceLabel.text = "\(balance)"
    }
}

@IBOutlet weak var betLabel: UILabel!
var bet: Int = 0 {
    didSet {
        betLabel.text = "\(bet)"
    }
}

@IBOutlet weak var jackPotLabel: UILabel!
var jackpot: Int = 0 {
    didSet {
        jackPotLabel.text = "\(jackpot)"
    }
}

@IBOutlet weak var firstImage: UIImageView!
@IBOutlet weak var secondImage: UIImageView!
@IBOutlet weak var thirdImage: UIImageView!
@IBOutlet weak var fourthImage: UIImageView!
@IBOutlet weak var fifthImage: UIImageView!
@IBOutlet weak var sixthImage: UIImageView!
@IBOutlet weak var seventhImage: UIImageView!
@IBOutlet weak var eighthImage: UIImageView!
@IBOutlet weak var ninethImage: UIImageView!
@IBOutlet weak var decreaseButtonImage: UIButton!
@IBOutlet weak var increaseBtnImage: UIButton!
@IBOutlet weak var spinButtonImage: UIButton!
@IBOutlet weak var jackpotLineImage: UIImageView!
@IBOutlet weak var diagonalLineImage: UIImageView!
@IBOutlet weak var spinAreaAnimation: CSAnimationView!
@IBOutlet weak var jackpotImage: UIImageView!


override func viewDidLoad() {
    
    super.viewDidLoad()
    
    playSound(sound: "chimeup", type: "mp3")
    
    self.setupSpinAreaAnimation(spinColumn: spinAreaAnimation, duration: 0.01, delay: 0.02, type: "shake")
    
    loadData()
    
    winLabel.text = "Welcome"
    
    animationView.animation = Animation.named("stars-winner")
    animationView.frame = CGRect(x: 75, y: 160, width: 300, height: 300)
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .loop
    view.addSubview(animationView)
    animationView.play()
}


@IBAction func btnReset(_ sender: Any) {
    let resetAlert = UIAlertController(title: "Reset", message: "It will reset everything except Jackpot. Do you really want to reset?.", preferredStyle: UIAlertController.Style.alert)
    
    resetAlert.addAction(UIAlertAction(title: "Reset", style: .destructive, handler: { (action: UIAlertAction!) in
        self.reset()
    }))
    
    resetAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        print("Cancelled")
    }))
    
    present(resetAlert, animated: true, completion: nil)
}

@IBAction func quitButton(_ sender: UIButton) {
    let quitAlert = UIAlertController(title: "Quit", message: "Do you really want to quit?.", preferredStyle: UIAlertController.Style.alert)
    
    quitAlert.addAction(UIAlertAction(title: "Quit", style: .destructive, handler: { (action: UIAlertAction!) in
        exit(0)
    }))
    
    quitAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
        print("Cancelled")
    }))
    
    present(quitAlert, animated: true, completion: nil)
    
}

@IBAction func btnSpin(_ sender: UIButton) {
    
    print("Spin win", self.winAmount)
    
    totalWin = totalWin + self.winAmount
    
    print("Spin total", totalWin)
    
    self.winAmount = 0
    
    balance = (balance - bet) + self.winAmount
    
    jackpot = jackpot + Int(Double(self.winAmount) * 0.1)
    
    db.collection("slotMachine").document("scoreBoard").setData(["jackpotAmount": jackpot, "balance": balance, "bet": bet, "totalWin": totalWin])
    
    
    ref
        .child("jackpotgame")
        //.childByAutoId()
        .setValue(["jackpotAmount": jackpot + Int(Double(winAmount) * 0.1), "balance": balance, "bet": bet, "totalWin": totalWin])
    
    
    updateImages()
    
    self.setupSpinAreaAnimation(spinColumn: spinAreaAnimation, duration: 0.01, delay: 0.01, type: "bounceUp")
    
    buttonValidations()
    
    playSound(sound: "slot-machine", type: "mp3")
    determineWinnings()
}

@IBAction func btnBetIncrease(_ sender: UIButton) {
    
    playSound(sound: "casino-chips", type: "mp3")
    
    if balance <= 0 {
        spinButtonImage.isEnabled = false
        increaseBtnImage.isEnabled = false
        bet += 0
        balance -= 0
    } else {
        bet += 10
        balance -= 10
    }
    buttonValidations()
}

@IBAction func btnBetDecrease(_ sender: UIButton) {
    
    playSound(sound: "casino-chips", type: "mp3")
    
    if bet == 10 {
        bet -= 0
        balance += 0
        
    } else {
        bet -= 10
        balance += 10
    }
    buttonValidations()
}


@IBAction func btnHelp(_ sender: UIButton) {
    playSound(sound: "casino-chips", type: "mp3")
}

@IBAction func scoreButtonTapped(_ sender: UIButton) {
    loadData()
    playSound(sound: "casino-chips", type: "mp3")
}

// MARK: - reset Function

func reset() {
    //jackpot = 1000
    balance = 1000
    bet = 10
    winAmount = 0
    totalWin = 0
    winLabel.text = "Welcome"
    spinButtonImage.isEnabled = true
    decreaseButtonImage.isEnabled = true
    increaseBtnImage.isEnabled = true
    jackpotImage.image = nil
    jackpotLineImage.image = nil
    firstImage.image = UIImage(named: "bell")
    secondImage.image = UIImage(named: "cherry")
    thirdImage.image = UIImage(named: "crown")
    fourthImage.image = UIImage(named: "diamond")
    fifthImage.image = UIImage(named: "bell")
    sixthImage.image = UIImage(named: "leaf")
    seventhImage.image = UIImage(named: "magnet")
    eighthImage.image = UIImage(named: "seven")
    ninethImage.image = UIImage(named: "star")
    playSound(sound: "chimeup", type: "mp3")
    animationView.animation = Animation.named("stars-winner")
    animationView.frame = CGRect(x: 75, y: 160, width: 300, height: 300)
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .loop
    view.addSubview(animationView)
    animationView.play()
    self.setupSpinAreaAnimation(spinColumn: spinAreaAnimation, duration: 0.01, delay: 0.02, type: "shake")
}

// MARK: - loadData Function

func loadData() {
    db.collection("slotMachine")
        .document("scoreBoard")
        .getDocument { (document, error) in
            // Check for error
            if error == nil {
                // Check that this document exists
                if document != nil && document!.exists {
                    let documentData = document!.data()
                    self.jackpot = documentData!["jackpotAmount"]! as! Int
                    self.balance = documentData!["balance"]! as! Int
                    self.totalWin = documentData!["totalWin"]! as! Int
                    self.bet = documentData!["bet"]! as! Int
                    self.jackPotLabel.text = String(self.jackpot)
                    self.balanceLabel.text = String(self.balance)
                    self.betLabel.text = String(self.bet)
                }
            }
        }
    }


// MARK: - updateImages Function

func updateImages () {
    
    let seven = [String](repeating: "seven", count: 40) // 5.5%
    let bell = [String](repeating: "bell", count: 50) // 7%
    let cherry = [String](repeating: "cherry", count: 55) // 7.6%
    let crown = [String](repeating: "crown", count: 57) // 7.9%
    let diamond = [String](repeating: "diamond", count: 60) // 8.3%
    let leaf = [String](repeating: "leaf", count: 70) // 9.7%
    let magnet = [String](repeating: "magnet", count: 80) // 11%
    let star = [String](repeating: "star", count: 90) // 12.5
    let strawberry = [String](repeating: "strawberry", count: 100) // 13.9
    let watermelon = [String](repeating: "watermelon", count: 120) // 16.7
    
    
    let imageList = seven + bell + cherry + crown + diamond + leaf + magnet + star + strawberry + watermelon
    
    firstImage.image = UIImage(named: imageList.randomElement()!)
    secondImage.image = UIImage(named: imageList.randomElement()!)
    thirdImage.image = UIImage(named: imageList.randomElement()!)
    fourthImage.image = UIImage(named: imageList.randomElement()!)
    fifthImage.image = UIImage(named: imageList.randomElement()!)
    sixthImage.image = UIImage(named: imageList.randomElement()!)
    seventhImage.image = UIImage(named: imageList.randomElement()!)
    eighthImage.image = UIImage(named: imageList.randomElement()!)
    ninethImage.image = UIImage(named: imageList.randomElement()!)
}

// MARK: - setupCoinAnimation Function

func setupCoinAnimation() {
    animationView.animation = Animation.named("coin-collect")
    animationView.frame = CGRect(x: 75, y: 160, width: 300, height: 300)
    animationView.contentMode = .scaleAspectFit
    animationView.loopMode = .playOnce
    view.addSubview(animationView)
    animationView.play()
}

// MARK: - determineWinnings Function

func determineWinnings() {
    let seven = UIImage(named: "seven")
    let bell = UIImage(named: "bell")
    let cherry = UIImage(named: "cherry")
    let crown = UIImage(named: "crown")
    let diamond = UIImage(named: "diamond")
    let leaf = UIImage(named: "leaf")
    let magnet = UIImage(named: "magnet")
    let star = UIImage(named: "star")
    let strawberry = UIImage(named: "strawberry")
    let watermelon = UIImage(named: "watermelon")
    
    if (secondImage.image == seven && fifthImage.image == seven && eighthImage.image == seven ) || (firstImage.image == seven && fifthImage.image == seven && ninethImage.image == seven) {
        
        setupWin(winAmount: 1000)
        //jackpot = jackpot + Int(Double(self.winAmount) * 0.1)
        //balance = balance + jackpot
        
        jackpot = 1000
        
//        jackpotLineImage.image = UIImage(named: "jackpotLine")
//
        jackpotImage.image = UIImage(named: "jackpotImage-1")
        
        winLabel.isHidden = true
        playSound(sound: "high-score", type: "mp3")
        
        animationView.animation = Animation.named("fireworks-display")
        animationView.frame = CGRect(x: 75, y: 160, width: 300, height: 300)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        view.addSubview(animationView)
        animationView.play()
        
    } else if secondImage.image == seven && fifthImage.image == seven {
        setupWin(winAmount: 300)
        
    } else if (secondImage.image == bell && fifthImage.image == bell && eighthImage.image == bell) || (firstImage.image == bell && fifthImage.image == bell && ninethImage.image == bell) {
        
        setupWin(winAmount: 200)
        
        
    } else if secondImage.image == bell && fifthImage.image == bell {
        setupWin(winAmount: 100)
        
    } else if (secondImage.image == cherry && fifthImage.image == cherry && eighthImage.image == cherry) || (firstImage.image == cherry && fifthImage.image == cherry && ninethImage.image == cherry) {
        setupWin(winAmount: 150)
        
    } else if secondImage.image == cherry && fifthImage.image == cherry {
        setupWin(winAmount: 75)
        
    } else if (secondImage.image == crown && fifthImage.image == crown && eighthImage.image == crown ) || (firstImage.image == crown && fifthImage.image == crown && ninethImage.image == crown) {
        setupWin(winAmount: 125)
    } else if secondImage.image == crown && fifthImage.image == crown {
        setupWin(winAmount: 65)
        
    } else if (secondImage.image == diamond && fifthImage.image == diamond && eighthImage.image == diamond) || (firstImage.image == diamond && fifthImage.image == diamond && ninethImage.image == diamond) {
        
        setupWin(winAmount: 100)
        
    } else if secondImage.image == diamond && fifthImage.image == diamond {
        
        setupWin(winAmount: 60)
        
    } else if secondImage.image == leaf && fifthImage.image == leaf && eighthImage.image == leaf  {
        setupWin(winAmount: 90)
        
    } else if secondImage.image == leaf && fifthImage.image == leaf {
        setupWin(winAmount: 50)
        
        
    } else if secondImage.image == magnet && fifthImage.image == magnet && eighthImage.image == magnet  {
        setupWin(winAmount: 125)
        
    } else if secondImage.image == magnet && fifthImage.image == magnet {
        
        setupWin(winAmount: 50)
        
    } else if secondImage.image == star && fifthImage.image == star && eighthImage.image == star  {
        setupWin(winAmount: 70)
        
    } else if secondImage.image == star && fifthImage.image == star {
        setupWin(winAmount: 40)
    } else if secondImage.image == strawberry && fifthImage.image == strawberry && eighthImage.image == strawberry  {
        
        setupWin(winAmount: 50)
        
    } else if secondImage.image == strawberry && fifthImage.image == strawberry {
        setupWin(winAmount: 35)
        
    } else if secondImage.image == watermelon && fifthImage.image == watermelon && eighthImage.image == watermelon  {
        setupWin(winAmount: 25)
        
    } else if secondImage.image == watermelon && fifthImage.image == watermelon {
        setupWin(winAmount: 10)
    }
    else {
        jackpot = jackpot + (bet / 10)
        winLabel.isHidden = true
        jackPotLabel.text = String(jackpot)
        balanceLabel.text = String(balance)
        jackpotLineImage.image = nil
        // diagonalLineImage.image = nil
        jackpotImage.image = nil
        animationView.stop()
    }
}

// MARK: - setupWin Function

func setupWin(winAmount: Int) {
    balance = balance + winAmount
    
    self.winAmount = winAmount
    
    jackpot = jackpot + Int(Double(self.winAmount) * 0.1)
    playSound(sound: "coin-collect", type: "mp3")
    setupCoinAnimation()
    
    print(self.winAmount)
}

// MARK: - playSound Function

func playSound(sound: String, type: String) {
    if let path = Bundle.main.path(forResource: sound, ofType: type){
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        } catch {
            print("Error occured while fetching the sound file!")
        }
    }
}

// MARK: - setupSpinAreaAnimation Function

func setupSpinAreaAnimation(spinColumn: CSAnimationView, duration: TimeInterval, delay: TimeInterval, type: String) {
    winLabel.isHidden = false
    spinColumn.duration = duration
    spinColumn.type = type
    spinColumn.delay = delay
    self.view.addSubview(spinColumn)
    spinColumn.startCanvasAnimation()
}

// MARK: - buttonValidations Function

func buttonValidations() {
    
    if balance >= bet && bet > 10 {
        spinButtonImage.isEnabled = true
        increaseBtnImage.isEnabled = true
        decreaseButtonImage.isEnabled = true
    } else if balance >= bet {
        spinButtonImage.isEnabled = true
        increaseBtnImage.isEnabled = true
        decreaseButtonImage.isEnabled = true
    } else if balance <= 10  {
        spinButtonImage.isEnabled = false
        increaseBtnImage.isEnabled = false
    }
    else if balance < bet  {
        spinButtonImage.isEnabled = false
        increaseBtnImage.isEnabled = false
        
    } else if bet >= 10 {
        spinButtonImage.isEnabled = true
        decreaseButtonImage.isEnabled = true
    } else if bet <= 10 && bet == 0 {
        spinButtonImage.isEnabled = false
        decreaseButtonImage.isEnabled = false
    } else if bet <= 10 {
        decreaseButtonImage.isEnabled = false
    }
}
}

