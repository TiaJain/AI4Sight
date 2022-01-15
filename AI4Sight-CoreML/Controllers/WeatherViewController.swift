//
//  readAloudViewController.swift
//  AI4SIGHT-VI
//
//  Created by Tia Jain on 29/03/2020.
//  Copyright © 2020 Tia Jain. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import Speech

class WeatherViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var weatherBackToReadAloudTapped: UIButton!
    
    let audioSession = AVAudioSession.sharedInstance()
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var utterance = AVSpeechUtterance(string: "Hi")
    let synthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var adviceLabel: UILabel!
    
    var weatherManager = WeatherManager()
    let locationManager = CLLocationManager()
    
    @IBAction func weatherBackToReadAloudTapped(_ sender: Any) {
        performSegue(withIdentifier: "weatherBackToReadAloudTapped", sender: self)
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
        
        /*
        //plays the initial audio
        do {

            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.setMode(AVAudioSession.Mode.default)

        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        */
        
        self.utterance = AVSpeechUtterance(string: "One moment. Fetching current weather data for your city.")
        self.synthesizer.speak(self.utterance)
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
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
    
    //-----------------------------------------
        
         @IBAction func microphoneTapped(_ sender: Any) {
                
                if synthesizer.isSpeaking {
                    synthesizer.pauseSpeaking(at: .immediate)
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
                        //cameraIcon.action
                        
                    case "Juan":
                        synthesizer.stopSpeaking(at: .immediate)
                        
                    case "Won":
                        synthesizer.stopSpeaking(at: .immediate)
                        
                    
                    case "Two":
                        synthesizer.stopSpeaking(at: .immediate)
                        
                        
                    case "True":
                        synthesizer.stopSpeaking(at: .immediate)
                        
                    case "To":
                        synthesizer.stopSpeaking(at: .immediate)
                        
                    case "Too":
                        synthesizer.stopSpeaking(at: .immediate)
                        
                    
                    case "Back":
                        synthesizer.stopSpeaking(at: .immediate)
                        weatherBackToReadAloudTapped.sendActions(for: .touchUpInside)
                        
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
    
//-----------------------------------
    
    //how to stop audio from playing if the user presses "BACK"
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = "Currently, in \(weather.cityName) it is"
            
            switch weather.conditionName {
            case "cloud.bolt":
                self.adviceLabel.text = "and stormy. Bring an umbrella if going outside, but try to stay inside if you can!"
            case "cloud.drizzle":
                self.adviceLabel.text = "with intermittent drizzles. Bring a jacket!"
            case "cloud.rain":
                self.adviceLabel.text = "and rainy. Bring an umbrella!"
            case "cloud.snow":
                self.adviceLabel.text = "and snowy. Dress warm!"
            case "cloud.fog":
                self.adviceLabel.text = "and foggy. Stay safe and beware of low visibility!"
            case "sun.max":
                self.adviceLabel.text = "and sunny. Bring sunglasses!"
            default:
                self.adviceLabel.text = "and cloudy. Bring a sweater!"
            }
            
            let weatherSpoken = "In \(weather.cityName), it is currently \(weather.temperatureString) degrees fahrenheit \(self.adviceLabel.text ?? "error")."
            
            self.utterance = AVSpeechUtterance(string: weatherSpoken)
            self.utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            self.synthesizer.speak(self.utterance)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
