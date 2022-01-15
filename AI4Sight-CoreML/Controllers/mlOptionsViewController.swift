//
//  mlOptionsViewController.swift
//  AI4Sight-CoreML
//
//  Created by Tia Jain on 11/04/2020.
//  Copyright © 2020 Tia Jain. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class mlOptionsViewController: UIViewController, SFSpeechRecognizerDelegate {

    @IBOutlet weak var barcodeB: UIButton!
    @IBOutlet weak var faceDetectB: UIButton!
    @IBOutlet weak var imageClassB: UIButton!
    @IBOutlet weak var TextRecogB: UIButton!
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var mlBackToHomeTapped: UIButton!
    
    private var buttonSelected: String!
    var dontCallViewDidAppearOnStartup = 0
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    let audioSession = AVAudioSession.sharedInstance()
    
    let synthesizer = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: (""))
    var utterance2 = AVSpeechUtterance(string: (""))
    var utterance3 = AVSpeechUtterance(string: (""))
    
   // @IBAction func mlBackToHomeTapped(unwindSegue: //UIStoryboardSegue) {
        //unwindMlOptToHome
   // }
    @IBAction func unwindML( _ seg: UIStoryboardSegue) {
    }
    
    @IBAction func mlBackToHomeTapped(_ sender: Any) {
        performSegue(withIdentifier: "unwindMlOptToHome", sender: self)
    }
    
    
    @IBAction func barcodeScannerPressed(_ sender: UIButton) {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    
    @IBAction func faceDetectionPressed(_ sender: UIButton) {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    
    @IBAction func imageLabellingPressed(_ sender: UIButton) {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    
    @IBAction func textRecogPressed(_ sender: UIButton) {
        synthesizer.stopSpeaking(at: .immediate)
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("should be speaking now")
        
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
        
        utterance = AVSpeechUtterance(string: ("Say one to scan a barcode. Say 2 for face detection. Say 3 for image classification. Or say 4 for text recognition, respectively. Say back to go to the home screen."))
        
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
                self.buttonSelected = "Barcode Scanner Button"
                performSegue(withIdentifier: "mlOptionsToBarcScanner", sender: barcodeB)
            case "Juan":
                synthesizer.stopSpeaking(at: .immediate)
                self.buttonSelected = "Barcode Scanner Button"
                performSegue(withIdentifier: "mlOptionsToBarcScanner", sender: barcodeB)
            case "Won":
                synthesizer.stopSpeaking(at: .immediate)
                self.buttonSelected = "Barcode Scanner Button"
                performSegue(withIdentifier: "mlOptionsToBarcScanner", sender: barcodeB)
            
            case "Two":
                synthesizer.stopSpeaking(at: .immediate)
                self.buttonSelected = "Face Detection Button"
                performSegue(withIdentifier: "mlOptionsToFaceDetect", sender: faceDetectB)
                
            case "True":
                synthesizer.stopSpeaking(at: .immediate)
                self.buttonSelected = "Face Detection Button"
                performSegue(withIdentifier: "mlOptionsToFaceDetect", sender: faceDetectB)
            case "To":
                synthesizer.stopSpeaking(at: .immediate)
                self.buttonSelected = "Face Detection Button"
                performSegue(withIdentifier: "mlOptionsToFaceDetect", sender: faceDetectB)
            case "Too":
                synthesizer.stopSpeaking(at: .immediate)
                self.buttonSelected = "Face Detection Button"
                performSegue(withIdentifier: "mlOptionsToFaceDetect", sender: faceDetectB)
            
            case "Three":
                synthesizer.stopSpeaking(at: .immediate)
                self.buttonSelected = "Image Labelling Button"
                performSegue(withIdentifier: "mlOptionsToImgLabel", sender: imageClassB)
            
            case "Four":
                synthesizer.stopSpeaking(at: .immediate)
                self.buttonSelected = "Text Recognition Button"
                performSegue(withIdentifier: "mlOptionsToTextRecog", sender: TextRecogB)
            case "For":
                synthesizer.stopSpeaking(at: .immediate)
                self.buttonSelected = "Text Recognition Button"
                performSegue(withIdentifier: "mlOptionsToTextRecog", sender: TextRecogB)
            case "Fore":
                synthesizer.stopSpeaking(at: .immediate)
                self.buttonSelected = "Text Recognition Button"
                performSegue(withIdentifier: "mlOptionsToTextRecog", sender: TextRecogB)
            
            case "Back":
                synthesizer.stopSpeaking(at: .immediate)
                mlBackToHomeTapped.sendActions(for: .touchUpInside)
                
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
            
            utterance2 = AVSpeechUtterance(string: "To start voice recording, click the start button near the bottom of the screen and say the corresponding number between 1 and 4. If you need a reminder of the corresponding functionalities, keep listening:")
            utterance2.postUtteranceDelay = 0.5
            utterance3 = AVSpeechUtterance(string: "say one for barcode scanning, two for face detection, three for image labelling, and four for text recognition.")
            
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
