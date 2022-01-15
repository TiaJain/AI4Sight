import UIKit
import Firebase
import AVFoundation
import Speech

class imageLabellingViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var imgLabBackToMlOptTapped: UIButton!
    
    @IBOutlet weak var takePhotoButton: UIBarButtonItem!
    @IBOutlet weak var uploadImageButton: UIBarButtonItem!

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let synthesizer = AVSpeechSynthesizer()
    var utterance = AVSpeechUtterance(string: (""))
    var utterance2 = AVSpeechUtterance(string: (""))
    var utterance3 = AVSpeechUtterance(string: (""))
    
    let audioSession = AVAudioSession.sharedInstance()
    
    var topLabel: String? = ""

    var colorClassification = ""
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultView: UITextView!
    @IBOutlet weak var colorLabel: UILabel!
    
    var uploadedImage: UIImage!
    var activityIndicator: UIActivityIndicatorView!
    var colorViews: [UIView]!
    var colorNames:DBColorNames!
    
    var imagePicker: UIImagePickerController!
    
    let options = VisionCloudDetectorOptions()
    lazy var vision = Vision.vision()
    
    @IBAction func imgLabBackToMlOptTapped(_ sender: Any) {
        performSegue(withIdentifier: "imgLabBackToMlOptTapped", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        options.modelType = .latest
        options.maxResults = 5
        
        setColorLabel()
        uploadedImage = UIImage(named: "Placeholder")
        imageView.image = uploadedImage
        self.colorNames = DBColorNames()
        
        micButton.isEnabled = false  //2

        speechRecognizer?.delegate = self  //3
        
        OperationQueue.main.addOperation() {
            self.micButton.isEnabled = true
            //self.micButton.isEnabled = isButtonEnabled
        }
        
        //imagePicker.delegate = self
        
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try AVAudioSession.sharedInstance().setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        /*
        do {

            try audioSession.setCategory(AVAudioSession.Category.playback)
            try audioSession.setMode(AVAudioSession.Mode.default)

        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        */
        utterance = AVSpeechUtterance(string: ("You have selected the image classifier, which aims to help you with daily tasks."))
        
        utterance2 = AVSpeechUtterance(string: ("Begin by simply using the icons in the top right corner to either upload a photo from your camera roll, or take a picture with your camera. Say back to go to the previous screen."))
        
        synthesizer.speak(utterance)
        synthesizer.speak(utterance2)
        
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
                        imgLabBackToMlOptTapped.sendActions(for: .touchUpInside)
                        
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
            synthesizer.stopSpeaking(at: .immediate)
        }
    }
    
    @IBAction func cameraTapped(_ sender: Any) {
        synthesizer.stopSpeaking(at: .immediate)
        //imagePicker.sourceType = .camera
        
        //present(imagePicker, animated: true, completion: nil)
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func photoLibraryTapped(_ sender: Any) {
        synthesizer.stopSpeaking(at: .immediate)
        //imagePicker.sourceType = .photoLibrary
        
        //present(imagePicker, animated: true, completion: nil)
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            
            let imageLabeler = vision.cloudImageLabeler()
            let visionImage = VisionImage(image: image)
            
            self.resultView.text = ""
            imageLabeler.process(visionImage) { (images, error) in
                guard error == nil, let images = images, !images.isEmpty else {
                    self.resultView.text = "Could not label this image"
                    self.dismiss(animated: true, completion: nil)
                    return
                }
                
                for image in images {
                    let imgDesc = image.text
                    let confidence = Float(truncating: image.confidence!)
                    self.resultView.text = self.resultView.text + "\(imgDesc) - \(confidence * 100.0)%\n\n"
                    self.topLabel = images.first?.text
                }
                let classification = "You have a \(self.colorClassification) \(self.topLabel ?? "N/A")  in front of you"
                self.resultView.isScrollEnabled = true
                self.utterance3 = AVSpeechUtterance(string: classification)
                self.synthesizer.speak(self.utterance3)
                
            }
        }
        //dismiss(animated: true, completion: nil)
        imagePicker.dismiss(animated: true, completion: nil)
        imageView.image = info[.originalImage] as? UIImage
        dominantColorDetection(image : imageView.image ?? uploadedImage)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //------------------------------------------------------------------------------------------------
    
    //color detection
    func dominantColorDetection(image : UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let smallImage = image.resized(to: CGSize(width: 200, height: 200))
            let kMeans = KMeansClusterer()
            let points = smallImage.getPixels().map({KMeansClusterer.Point(from: $0)})
            let clusters = kMeans.cluster(points: points, into: 3).sorted(by: {$0.points.count > $1.points.count})
            let colors = clusters.map(({$0.center.toUIColor()}))
            guard let mainColor = colors.first else {
                return
            }

            //let textColor = self.makeTextColor(from: mainColor)
            DispatchQueue.main.async {  [weak self] in
                guard let self = self else {
                    return
                }
                self.showMainImage()
                //self.setBackgroundColor(mainColor)
                self.updateColorLabel(color: mainColor)
            }
        }
    }

    func updateColorLabel(color: UIColor) {
            DispatchQueue.global(qos: DispatchQoS.background.qosClass).async {
                DispatchQueue.main.async {
                    self.colorLabel.text = "Color: "  + self.colorNames.name(for: color)
                    self.colorClassification = self.colorNames.name(for: color)
                }
            }
        }

        func setBackgroundColor(_ color : UIColor) {
            view.backgroundColor = UIColor.black
            view.animate(duration: 0.3, { (view) in
                view.backgroundColor = color
            })
        }

        func showText(_ color : UIColor) {
            colorLabel.isHidden = false
            colorLabel.alpha = 0
            colorLabel.textColor = color
            colorLabel.animate(duration: 0.5) { (colorLabel) in
                colorLabel.alpha = 1
            }
        }

        
        func showMainImage() {
            imageView.alpha = 0
            imageView.isHidden = false
            imageView.transform = imageView.transform.translatedBy(x: 0, y: -imageView.bounds.height)
            imageView.animate(duration: 0.2) { (imageView) in
                imageView.transform = CGAffineTransform.identity
            }
            imageView.animate(duration: 0.4) { (imageView) in
                imageView.alpha = 1
            }
        }
        
        func makeTextColor(from color : UIColor) -> UIColor {
            return color.hslColor.shiftHue(by: 0.5).shiftSaturation(by: -0.5).shiftBrightness(by: 0.5).uiColor
        }

    /*
        func setTitle() {
            pageTitle.textAlignment = .center
            pageTitle.text = "Image Classification"
        }
   

        func setButtonTitle() {
            backButton.setTitle("Back", for: .normal)
            takePhotoButton.setTitle("Take Photo", for: .normal)
            uploadImageButton.setTitle("Upload Image", for: .normal)
        }
     
     @IBAction func backButtonPressed(_ sender: Any) {
         self.dismiss(animated: true, completion: nil);
     }
 */
        func setColorLabel() {
            colorLabel.textAlignment = .center
            colorLabel.text = "Color detected is: "
            colorLabel.numberOfLines = 0;
            //colorLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 25)
        }
/*
        @IBAction func uploadButtonPressed(_ sender: Any) {
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }

        @IBAction func uploadImageButtonPressed(_ sender: Any) {
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
    */
    }

    extension UIView {
        func animate(duration : TimeInterval, delay : TimeInterval = 0, _ animations : @escaping (UIView)->Void) {
            UIView.animate(withDuration: duration, delay: delay, options: [.curveEaseOut], animations: {
                animations(self)
            })
        }
    }
