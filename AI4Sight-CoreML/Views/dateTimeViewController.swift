//
//  dateTimeViewController.swift
//  AI4SIGHT-VI
//
//  Created by Tia Jain on 30/03/2020.
//  Copyright © 2020 Tia Jain. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class dateTimeViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var dateTimeBackToReadAloudTapped: UIButton!
    
    let audioSession = AVAudioSession.sharedInstance()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var utterance = AVSpeechUtterance(string: "Hi")
    let synthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var dateTimeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //plays the initial audio
        do {

            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.setMode(AVAudioSession.Mode.default)

        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        self.utterance = AVSpeechUtterance(string: "One moment. Downloading the date and time for your city.")
        self.synthesizer.speak(self.utterance)
        
        var dateTimeString = "The current date and time is ... LOADING"
        
        dateTimeLabel.text = dateTimeString
        
        //Gets the current date and time
        let currentDateTime = Date()
        
        //Initializes the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        
        //Gets the date and time String from the date object
        dateTimeString = formatter.string(from: currentDateTime)
        
        dateTimeLabel.text = "Currently it is " + dateTimeString
        
        // speaks the classification aloud
        let currDandT = dateTimeLabel.text
        
        utterance = AVSpeechUtterance(string: currDandT!)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
    }
    
    //how to stop audio from playing if the user presses "BACK"
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
