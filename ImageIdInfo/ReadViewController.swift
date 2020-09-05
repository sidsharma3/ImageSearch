//
//  ReadViewController.swift
//  ImageIdInfo
//
//  Created by Sid Sharma on 2020-09-05.
//  Copyright © 2020 Sid Sharma. All rights reserved.
//

import UIKit
import AVFoundation

class ReadViewController: UIViewController {
    // this will be filled in form the prior view controller values.
    var dataToRead :String = ""
    // set up for voice work
    var speech = AVSpeechUtterance(string: "")
    let synthesizer = AVSpeechSynthesizer()

    @IBOutlet weak var displayReadText: UILabel!
    
    override func viewDidLoad() {
        // now on load we will be able to hear the
        // explanation of the objext from wikipedia
        super.viewDidLoad()
        displayReadText.text = dataToRead
        speakText(text: dataToRead)
        // Do any additional setup after loading the view.
        displayReadText.layer.cornerRadius = 6
        displayReadText.layer.masksToBounds = true
    }
    
    func speakText(text: String) {
        speech = AVSpeechUtterance(string: text)
        // this pick the accent I selected british
        speech.voice = AVSpeechSynthesisVoice(language: "en-GB")
        // these lines acrtually speak the text
        synthesizer.speak(speech)
    }
    
    @IBAction func BackPressed(_ sender: UIButton) {
        // stop the speaking function but ensure the final word is spoken.
        synthesizer.stopSpeaking(at: .immediate)
        dismiss(animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
