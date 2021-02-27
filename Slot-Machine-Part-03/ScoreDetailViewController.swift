//
//  ScoreDetailViewController.swift
//  Slot-Machine-Part-03
//
//  Created by Raj Kumar Shahu on 2021-02-21.
//

import UIKit
import Firebase

class ScoreDetailViewController: UIViewController {
    
    let db = Firestore.firestore()
    
    var jackpot: String?

    @IBOutlet weak var jackpotLabel: UILabel!
    
    var jackpotAmount: Int = 0 {
        didSet {
            jackpotLabel.text = "\(String(describing: jackpot))"
        }
    }
    
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    var balance: Int = 0 {
        didSet {
            balanceLabel.text = "\(String(describing: balance))"
        }
    }
    
    
    
    @IBOutlet weak var totalWinLabel: UILabel!
    var totalWin: Int = 0 {
        didSet {
            totalWinLabel.text = "\(String(describing: totalWin))"
        }
    }
    
    
    @IBOutlet weak var currentBetLabel: UILabel!
    
    var currentBet: Int = 0 {
        didSet {
            currentBetLabel.text = "\(String(describing: currentBet))"
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db.collection("slotMachine")
            .document("scoreBoard")
            .getDocument { (document, error) in

            // Check for error
            if error == nil {

                // Check that this document exists
                if document != nil && document!.exists {

                    let documentData = document!.data()



                    //print(documentData!["jackpotAmount"]!)

                    self.jackpotAmount = documentData!["jackpotAmount"]! as! Int
                    self.balance = documentData!["balance"]! as! Int
                    self.totalWin = documentData!["totalWin"]! as! Int
                    self.currentBet = documentData!["bet"]! as! Int

                    self.jackpotLabel.text = String(self.jackpotAmount)
                    self.balanceLabel.text = String(self.balance)
                    self.totalWinLabel.text = String(self.totalWin)
                    self.currentBetLabel.text = String(self.currentBet)

                }
            }
        }
        
//        if let jackpot = jackpot {
//            jackpotLabel.text = jackpot
//        }
        
        
    }
}
