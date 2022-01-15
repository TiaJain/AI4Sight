//
//  cameraViewController.swift
//  AI4SIGHT-VI
//
//  Created by Tia Jain on 29/03/2020.
//  Copyright © 2020 Tia Jain. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import Speech

class homeViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    let backgroundImageView = UIImageView()
    let locationManager = CLLocationManager()
    
    let audioSession = AVAudioSession.sharedInstance()
    
    @IBOutlet weak var cameraB: UIButton!
    @IBOutlet weak var optB: UIButton!
    @IBOutlet weak var healthB: UIButton!
    @IBOutlet weak var commFB: UIButton!
    @IBOutlet weak var readAlB: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    //@IBOutlet weak var textView: UITextView!
    
    //var dontCallViewDidAppearOnStartup : Int
    var dontCallViewDidAppearOnStartup = 0
    
    @IBOutlet weak var micButton: UIButton!
    private var buttonSelected: String!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let synthesizer = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: (""))
    var utterance2 = AVSpeechUtterance(string: (""))
    var utterance3 = AVSpeechUtterance(string: (""))
    var utterance4 = AVSpeechUtterance(string: (""))
    var utterance5 = AVSpeechUtterance(string: (""))
    var utterance6 = AVSpeechUtterance(string: (""))
    var utterance7 = AVSpeechUtterance(string: (""))
    var utterance8 = AVSpeechUtterance(string: (""))
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
    }
    
    @IBAction func forumPressed(_ sender: UIButton) {
        synthesizer.stopSpeaking(at: .immediate)
        
        //open the forum on app's website!
        guard let url = URL(string: "https://www.ai4sight.org/forum")
            else {
                return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    @IBAction func cameraPressed(_ sender: UIButton) {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    @IBAction func healthInfoPressed(_ sender: UIButton) {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    @IBAction func readAloudPressed(_ sender: UIButton) {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    //-----------------------------------------------------------------------------------------------------
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
            
            utterance7 = AVSpeechUtterance(string: "To start voice recording, click the start button near the bottom of the screen and say the corresponding number between 1 and 5. If you need a reminder of the corresponding functionalities, keep listening:")
            utterance7.postUtteranceDelay = 0.5
            utterance8 = AVSpeechUtterance(string: "say one for barcode scanning, face detection, image labelling, or text recognition. say 2 to locate optometrists near you. Say 3 for eye health information. Say 4 to access our community forum. Say 5 to be read aloud the current date and time or the current weather.")
            
            synthesizer.speak(utterance7)
            synthesizer.speak(utterance8)
        }
        dontCallViewDidAppearOnStartup+=1
    }
    
    //------------------------------------------------------------------------------------------------------
    //override func viewWillApp
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        micButton.isEnabled = false  //2
        
        speechRecognizer?.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            
            default:
                isButtonEnabled = true
            }
            
            OperationQueue.main.addOperation() {
                self.micButton.isEnabled = isButtonEnabled
            }
        }
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        titleLabel.text = ""
        var charIndex = 0.2
        let titleText = "AI4Sight"
        
        for letter in titleText
        {
            Timer.scheduledTimer(withTimeInterval: 0.4 * charIndex, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            charIndex += 1
        }
        
        utterance = AVSpeechUtterance(string: ("Welcome to AI4Sight, your personal vision assistant."))
        utterance.postUtteranceDelay = 0.35
        
        utterance2 = AVSpeechUtterance(string: "Say one to use any of the following features: barcode scanning, face detection, image labelling, or text recognition.")
        //utterance2.rate = 0.53
        utterance2.postUtteranceDelay = 0.2
        
        utterance3 = AVSpeechUtterance(string: "Say two to locate optometrists near you.")
        //utterance3.rate = 0.53
        utterance3.postUtteranceDelay = 0.2
        
        utterance4 = AVSpeechUtterance(string: "Say 3 to get some quick eye health information.")
        utterance4.postUtteranceDelay = 0.2
        
        utterance5 = AVSpeechUtterance(string: "Say 4 to access to the community forum on our website.")
        utterance5.postUtteranceDelay = 0.2
        
        utterance6 = AVSpeechUtterance(string: "Say 5 to be read aloud the current date and time or to get the current weather. In order to start voice recording, please click the start button near the botton of your screen.")
        
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        synthesizer.speak(utterance)
        synthesizer.speak(utterance2)
        synthesizer.speak(utterance3)
        synthesizer.speak(utterance4)
        synthesizer.speak(utterance5)
        synthesizer.speak(utterance6)
    }
    
    //------------------------------------------------------------------------------------------------------
    
    @IBAction func microphoneTapped(_ sender: Any) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
            //stopSpeaking(at: .immediate)
        }
        
        //we want to stop the recording function and change it back to playback
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            
            audioEngine.inputNode.removeTap(onBus: 0)
            
            //let audioSession = AVAudioSession.sharedInstance()
            do {
                
                try audioSession.setCategory(AVAudioSession.Category.playback)
                try audioSession.setMode(AVAudioSession.Mode.default)
                
            } catch {
                print("audioSession properties weren't set because of an error.")
            }
            
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
        
        //textView.text = "Say something, I'm listening!"
        
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
            self.buttonSelected = "Camera Button"
            performSegue(withIdentifier: "homeToMLOptionsVC", sender: cameraB)
            
            //cameraB.sendActions(for: .touchUpInside)
            //show(mlOptionsVC, sender: self)
            //self.show(mlOptionsVC, sender: UIButton.self)
            //self.present(mlOptionsVC, animated: true, completion: nil)
            
        case "Juan":
            synthesizer.stopSpeaking(at: .immediate)
            self.buttonSelected = "Camera Button"
            performSegue(withIdentifier: "homeToMLOptionsVC", sender: cameraB)
        case "Won":
            synthesizer.stopSpeaking(at: .immediate)
            self.buttonSelected = "Camera Button"
            performSegue(withIdentifier: "homeToMLOptionsVC", sender: cameraB)
        case "Bon":
            synthesizer.stopSpeaking(at: .immediate)
            self.buttonSelected = "Camera Button"
            performSegue(withIdentifier: "homeToMLOptionsVC", sender: cameraB)
            
        case "Two":
            synthesizer.stopSpeaking(at: .immediate)
            self.buttonSelected = "Optometrists Near Me Button"
            optB.sendActions(for: .touchUpInside)
            
        case "True":
            synthesizer.stopSpeaking(at: .immediate)
            self.buttonSelected = "Optometrists Near Me Button"
            optB.sendActions(for: .touchUpInside)
        case "To":
            synthesizer.stopSpeaking(at: .immediate)
            self.buttonSelected = "Optometrists Near Me Button"
            optB.sendActions(for: .touchUpInside)
        case "Too":
            synthesizer.stopSpeaking(at: .immediate)
            self.buttonSelected = "Optometrists Near Me Button"
            optB.sendActions(for: .touchUpInside)
            
        case "Three":
            synthesizer.stopSpeaking(at: .immediate)
            self.buttonSelected = "Health Info Button"
            performSegue(withIdentifier: "homeToHealthInfoVC", sender: healthB)
            
        case "Four":
            synthesizer.stopSpeaking(at: .immediate)
            self.buttonSelected = "Community Forum Button"
            commFB.sendActions(for: .touchUpInside)
        case "For":
            synthesizer.stopSpeaking(at: .immediate)
            self.buttonSelected = "Community Forum Button"
            commFB.sendActions(for: .touchUpInside)
        case "Fore":
            synthesizer.stopSpeaking(at: .immediate)
            self.buttonSelected = "Community Forum Button"
            commFB.sendActions(for: .touchUpInside)
            
        case "Five":
            synthesizer.stopSpeaking(at: .immediate)
            //readAlB.sendActions(for: .touchUpInside)
            self.buttonSelected = "Read Info Aloud Button"
            performSegue(withIdentifier: "homeToReadAloudVC", sender: readAlB)
            
        case "I've":
            synthesizer.stopSpeaking(at: .immediate)
            //readAlB.sendActions(for: .touchUpInside)
            self.buttonSelected = "Read Info Aloud Button"
            performSegue(withIdentifier: "homeToReadAloudVC", sender: readAlB)
        default:
            alertNotFound()
        }
        print(receivedString)
        print("received string should have been printed!")
    }
    
    /*------------------------------------------------------------------------------------------------------
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     if(segue.identifier == "homeToMLOptionsVC"){
     let mlOptVC = segue.destination as! mlOptionsViewController
     //mlOptVC.buttonName = self.buttonSelected
     }
     }
     
     ------------------------------------------------------------------------------------------------------*/
    
    func alertNotFound() {
        let alert = UIAlertController(title: "Sorry", message: "Action not found! Please, Try again!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        //print("Error: alert not found")
    }
    
    func alertFound(buttonName : String) {
        
    }
    
    //how to stop audio from playing if the user presses "BACK"
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    func setBackground() {
        view.addSubview(backgroundImageView)
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        backgroundImageView.image = UIImage(named: "home-screen-bkgd")
    }
}

//MARK: - CLLocationManagerDelegate
extension homeViewController: CLLocationManagerDelegate {
    
    @IBAction func optPressed(_ sender: UIButton)
    {
        synthesizer.stopSpeaking(at: .immediate)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        utterance = AVSpeechUtterance(string: ("Redirecting."))
        synthesizer.speak(utterance)
        
        do {
            // disableAVSession()
        }
        
        locationManager.requestLocation()
    }
    
    private func disableAVSession() {
        do {
            try AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't disable.")
        }
    }
    
    //function created to fetch the user's current lat and lon coordinates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("made it into locationManager")
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            
            //open google maps so the user can find optometrists near them
            guard let url = URL(string: "comgooglemapsurl://www.google.com/maps/search/optometrists+near+me/@\(lat),\(lon),14z/data=!3m1!4b1")
                else {
                    return
            }
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
