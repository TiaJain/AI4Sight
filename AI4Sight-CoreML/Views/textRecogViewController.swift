import UIKit
import Firebase
import AVFoundation
import Speech

class textRecogViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var textRecBackToMlOptTapped: UIButton!
    
    @IBOutlet weak var photoLibIcon: UIBarButtonItem!
    @IBOutlet weak var cameraIcon: UIBarButtonItem!

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    var utterance = AVSpeechUtterance(string: "")
    var utterance2 = AVSpeechUtterance(string: "")
    var utterance3 = AVSpeechUtterance(string: "")
    let synthesizer = AVSpeechSynthesizer()
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultView: UITextView!
    let imagePicker = UIImagePickerController()
    var elementLanguages = ""
    
    let audioSession = AVAudioSession.sharedInstance()
    
    @IBAction func textRecBackToMlOptTapped(_ sender: Any) {
        performSegue(withIdentifier: "textRecBackToMlOptTapped", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        
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
        
        utterance2 = AVSpeechUtterance(string: ("This text recognizer supports 30 different languages, including English, French, German, Mandarin, Hindi, Russian, and more."))
        
        utterance3 = AVSpeechUtterance(string: ("Use the icons in the top right corner to either upload a photo or take a picture..., Please note that at this time, this feature is only effective if the entire image contains text of the same language."))
        
        synthesizer.speak(utterance2)
        synthesizer.speak(utterance3)
        
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
    
//-------------------------------------------------------------------------
        
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
                        textRecBackToMlOptTapped.sendActions(for: .touchUpInside)
                        
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
    
    //how to stop audio from playing if the user presses "BACK"
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if self.isMovingFromParent {
            synthesizer.pauseSpeaking(at: .immediate)
        }
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        synthesizer.pauseSpeaking(at: .immediate)
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func photoLibraryTapped(_ sender: Any) {
        synthesizer.pauseSpeaking(at: .immediate)
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            
            let vision = Vision.vision()
            let textRecognizer = vision.cloudTextRecognizer()
            let visionImage = VisionImage(image: image)
            
            self.resultView.text = ""
            textRecognizer.process(visionImage) { (result, error) in
                guard error == nil, let result = result else {
                    self.resultView.text = "Could not identify this text"
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                for block in result.blocks {
                    for line in block.lines {
                        for element in line.elements {
                            if (element.recognizedLanguages.first?.languageCode) == nil {
                                print("Sorry, there was an error! Please try again")
                            } else {
                                self.elementLanguages = (element.recognizedLanguages.first?.languageCode)!
                            }
                            self.resultView.text = self.resultView.text + "\(element.text) "
                        }
                    }
                }
                //use AVSpeechSynthesizer to read the text aloud
                if self.resultView?.text == "" {
                    self.resultView.text = "Sorry, the labels were nil."
                } else {
                    let classification = self.resultView!.text
                    self.resultView.isScrollEnabled = true
                    self.utterance = AVSpeechUtterance(string: classification!)
                    self.utterance.voice = AVSpeechSynthesisVoice(language: self.elementLanguages)
                    self.synthesizer.pauseSpeaking(at: .word)
                    self.synthesizer.speak(self.utterance)
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
