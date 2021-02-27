//
//  HelpViewController.swift
//  Slot-Machine-Part-02_v2
//
//  Created by Raj Kumar Shahu on 2021-02-14.
//

import UIKit
import AVFoundation

class HelpViewController: UIViewController {
    
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        
    }
    
    @IBAction func helpButtonTapped(_ sender: UIButton) {
        playSound(sound: "casino-chips", type: "mp3")
    }
    
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
}

