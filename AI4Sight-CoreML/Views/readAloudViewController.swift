//
//  readAloudViewController.swift
//  AI4SIGHT-VI
//
//  Created by Tia Jain on 30/03/2020.
//  Copyright © 2020 Tia Jain. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class readAloudViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var weatherB: UIButton!
    @IBOutlet weak var dateTimeB: UIButton!
    
    @IBOutlet weak var micButton: UIButton!
    private var buttonSelected: String!
    var dontCallViewDidAppearOnStartup = 0
    let audioSession = AVAudioSession.sharedInstance()
    
    @IBOutlet weak var RAbackToHomePressed: UIButton!
    
    @IBAction func RAbackToHomePressed(_ sender: Any) {
        performSegue(withIdentifier: "RAbackToHomePressed", sender: self)
    }
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var utterance = AVSpeechUtterance(string: ("Hello"))
    var utterance2 = AVSpeechUtterance(string: (""))
    var utterance3 = AVSpeechUtterance(string: (""))
    
    let synthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var header: UILabel!
    
    @IBAction func unwindRA( _ seg: UIStoryboardSegue) {
    }
    
    @IBAction func weatherPressed(_ sender: UIButton) {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    @IBAction func dateAndTimePressed(_ sender: UIButton) {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        micButton.isEnabled = false  //2
        
        speechRecognizer?.delegate = self  //3
        
        OperationQueue.main.addOperation() {
            self.micButton.isEnabled = true
            //self.micButton.isEnabled = isButtonEnabled
        }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        utterance = AVSpeechUtterance(string: ("Say 1 if you would like to be read aloud the current weather data. Say 2 if you would like to know the current date and time. Say back if you would like to go to the previous screen. Say home if you would like the go to the home screen"))
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
        
        do {
            disableAVSession()
        }
    }
    
    private func disableAVSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't disable.")
        }
    }
    
    @IBAction func microphoneTapped(_ sender: Any) {
        
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            //stopSpeaking(at: .immediate)
        }
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            audioEngine.inputNode.removeTap(onBus: 0)
            
            micButton.isEnabled = false
            micButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            micButton.setTitle("Stop Recording", for: .normal)
        }
    }
    
//------------------------------------------------------------------------------------------------------
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.record)
            try audioSession.setMode(AVAudioSession.Mode.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            
            var isFinal = false
            
            if result != nil {
                //self.textView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.micButton.isEnabled = true
                self.clickButton(result?.bestTranscription.formattedString ?? "Not found")
            }
            
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.removeTap(onBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
//------------------------------------------------------------------------------------------------------
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            micButton.isEnabled = true
        } else {
            micButton.isEnabled = false
        }
    }
    
//------------------------------------------------------------------------------------------------------
    func clickButton(_ receivedString : String) {
        
        //let mlOptionsVC = mlOptionsViewController()
        
        switch receivedString {
        case "One":
            synthesizer.stopSpeaking(at: .immediate)
            performSegue(withIdentifier: "readAloudToWeather", sender: weatherB)
        case "Juan":
            synthesizer.stopSpeaking(at: .immediate)
            performSegue(withIdentifier: "readAloudToWeather", sender: weatherB)
        case "Won":
            synthesizer.stopSpeaking(at: .immediate)
            performSegue(withIdentifier: "readAloudToWeather", sender: weatherB)
            
        case "Two":
            synthesizer.stopSpeaking(at: .immediate)
            performSegue(withIdentifier: "readAloudToDateTime", sender: dateTimeB)
            
        case "True":
            synthesizer.stopSpeaking(at: .immediate)
            performSegue(withIdentifier: "readAloudToDateTime", sender: dateTimeB)
        case "To":
            synthesizer.stopSpeaking(at: .immediate)
            performSegue(withIdentifier: "readAloudToDateTime", sender: dateTimeB)
        case "Too":
            synthesizer.stopSpeaking(at: .immediate)
            performSegue(withIdentifier: "readAloudToDateTime", sender: dateTimeB)
         
        case "Back":
            synthesizer.stopSpeaking(at: .immediate)
            RAbackToHomePressed.sendActions(for: .touchUpInside)
        
        default:
            alertNotFound()
        }
        print(receivedString)
        print("received string should have been printed!")
    }
    
//------------------------------------------------------------------------------------------------------
    
    func alertNotFound() {
        let alert = UIAlertController(title: "Sorry", message: "Action not found! Please, Try again!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        //print("Error: alert not found")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        print("the value of dontCallViewDidAppearOnStartup is")
        print(dontCallViewDidAppearOnStartup)
        
        if dontCallViewDidAppearOnStartup > 0 {
            do {
                
                try audioSession.setCategory(AVAudioSession.Category.playback)
                try audioSession.setMode(AVAudioSession.Mode.default)
                
            } catch {
                print("audioSession properties weren't set because of an error.")
            }
            
            utterance2 = AVSpeechUtterance(string: "To start voice recording, click the start button near the bottom of the screen and say either 1, 2, or back. If you need a reminder of the functionalities, keep listening:")
            utterance2.postUtteranceDelay = 0.5
            utterance3 = AVSpeechUtterance(string: "say one for the weather, say 2 for the current date and time, say back to go to the home screen.")
            
            synthesizer.speak(utterance2)
            synthesizer.speak(utterance3)
        }
        dontCallViewDidAppearOnStartup+=1
    }
    
    //how to stop audio from playing if the user presses "BACK"
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}
