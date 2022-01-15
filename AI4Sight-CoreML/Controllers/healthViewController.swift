//
//  healthViewController.swift
//  AI4SIGHT-VI
//
//  Created by Tia Jain on 29/03/2020.
//  Copyright © 2020 Tia Jain. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class healthViewController: UIViewController, SFSpeechRecognizerDelegate {

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    let synthesizer = AVSpeechSynthesizer()
    
    //@IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var healthBackToHomePressed: UIButton!
    // Create UIButton
    let microphoneButton = UIButton()
    
    @IBAction func healthBackToHomePressed(_ sender: Any) {
        performSegue(withIdentifier: "healthBackToHomePressed", sender: self)
    }
    
    
    let glassesImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "healthTopImage"))
        // this enables autolayout for our imageView
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        //textView.text =
       // textView.font = .systemFont(ofSize: 25)
       // textView.font = UIFont.systemFont(ofSize: 25)
        textView.backgroundColor = .white
        
        let text = "EYE HEALTH INFO:\nDebunk Some Common Myths:\n   1. Eating Carrots will help improve your vision:  False.\n\n   2. Sitting too close to the TV or reading in the dark will worsen your eyes: False.\n\nGet your nutrients! Omega-3 fatty acids, lutein, zinc, and vitamins C and E help prevent age-related vision problems. \nEat:\n     1. Fish (like salmon and tuna)\n     2. Green leafy vegetables like spinach, kale, and collards\n     3. Protein (Eggs, nuts, beans, meat)\n     4. Oranges and other citrus fruits or juices\n\n- Stay at a healthy weight and maintain a healthy BMI to lower your odds of obesity and type 2 diabetes, which are the leading causes of blindness in adults.\n\n- Wear proper sun protection.\n\n- Avoid smoking at all costs!"
        
        let attributedText = NSMutableAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.black])
        
        textView.attributedText = attributedText
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isScrollEnabled = true
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // here's our entry point into our app
        view.addSubview(glassesImageView)
        view.addSubview(descriptionTextView)
        
        setupLayout()
        
        /*
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        */
        
        // speaks the classification aloud
        let utterance = AVSpeechUtterance(string: ("Here is some eye health information to keep you safe and healthy! If you would like to go back to the previous screen at any point, start the recording and say back."))
        utterance.postUtteranceDelay = 0.2
        
        let utterance2 = AVSpeechUtterance(string: ("Number 1. Eating Carrots will help improve your vision."))
        utterance2.postUtteranceDelay = 0.15
        
        let utterance3 = AVSpeechUtterance(string: ("That is false."))
        utterance3.postUtteranceDelay = 0.15
        
        let utterance4 = AVSpeechUtterance(string: ("It doesn't help much if you already get enough vitamin A in your diet."))
        utterance4.postUtteranceDelay = 0.2
        
        let utterance5 = AVSpeechUtterance(string: ("Number 2. Sitting too close to the TV or reading in the dark will worsen your eyes."))
        utterance5.postUtteranceDelay = 0.15
        
        let utterance100 = AVSpeechUtterance(string: ("That is false."))
        utterance100.postUtteranceDelay = 0.15
        
        let utterance6 = AVSpeechUtterance(string: ("Both can cause eyestrain and headaches, but won't worsen your vision."))
        utterance6.postUtteranceDelay = 0.2
        
        let utterance7 = AVSpeechUtterance(string: ("Also, remember to get your nutrients! Omega-3 fatty acids, lutein, zinc, and vitamins C and E help prevent age-related vision problems."))
        utterance7.postUtteranceDelay = 0.2
        
        let utterance8 = AVSpeechUtterance(string: ("Be sure to eat fish, Green leafy vegetables, Protein, as well as citrus fruits or juices"))
        utterance8.postUtteranceDelay = 0.2
        
        let utterance9 = AVSpeechUtterance(string: ("It is also very important to stay at a healthy weight and maintain a healthy BMI, because it will help lower your odds of obesity and type 2 diabetes, which are the leading causes of blindness in adults."))
        utterance9.postUtteranceDelay = 0.2
        
        let utterance10 = AVSpeechUtterance(string: ("Also, be sure to wear proper sun protection such as a hat and sunglasses or sunscreen that blocks 99-100% of both U.V.A and U.V.B radiation."))
        utterance10.postUtteranceDelay = 0.2
        
        let utterance11 = AVSpeechUtterance(string: ("And finally, avoid smoking at all costs!"))
        
        synthesizer.speak(utterance)
        synthesizer.speak(utterance2)
        synthesizer.speak(utterance3)
        synthesizer.speak(utterance4)
        synthesizer.speak(utterance5)
        synthesizer.speak(utterance100)
        synthesizer.speak(utterance6)
        synthesizer.speak(utterance7)
        synthesizer.speak(utterance8)
        synthesizer.speak(utterance9)
        synthesizer.speak(utterance10)
        synthesizer.speak(utterance11)
        
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
    
    //how to stop audio from playing if the user presses "BACK"
    override func viewWillDisappear(_ animated: Bool) {
        
        
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    private func setupLayout() {
        glassesImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        glassesImageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 90).isActive = true
        glassesImageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        glassesImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        descriptionTextView.topAnchor.constraint(equalTo: glassesImageView.bottomAnchor, constant: 25).isActive = true
        descriptionTextView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        descriptionTextView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive = true
        descriptionTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
        
        // Position Button
        microphoneButton.frame = CGRect(x: 55, y: 750, width: 300, height: 60)
        
        // Set text on button
        microphoneButton.setTitle("Start Recording", for: .normal)
        
        // Set button action
        microphoneButton.addTarget(self, action: #selector(micButtonClicked(sender:)), for: .touchUpInside)
        
        // Set button tint color
        microphoneButton.tintColor = UIColor.white
        // Set button background color
        microphoneButton.backgroundColor = UIColor.lightGray
        
        view.addSubview(microphoneButton)
        self.view = view
    }
    
    @objc func micButtonClicked(sender: UIButton){
        if synthesizer.isSpeaking {
            synthesizer.pauseSpeaking(at: .immediate)
            //stopSpeaking(at: .immediate)
        }
        
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            audioEngine.inputNode.removeTap(onBus: 0)
            
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            microphoneButton.setTitle("Stop Recording", for: .normal)
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
                    
                    self.microphoneButton.isEnabled = true
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
                microphoneButton.isEnabled = true
            } else {
                microphoneButton.isEnabled = false
            }
        }
        
//------------------------------------------------------------------------------------------------------
        func clickButton(_ receivedString : String) {
            
            //let mlOptionsVC = mlOptionsViewController()
            
            switch receivedString {
            
            case "Back":
                synthesizer.stopSpeaking(at: .immediate)
                healthBackToHomePressed.sendActions(for: .touchUpInside)
            
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
}
