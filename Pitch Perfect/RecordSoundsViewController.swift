//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by James Jongsurasithiwat on 5/31/15.
//  Copyright (c) 2015 James Jongs. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // MARK: Variables
    
    fileprivate var audioRecorder:  AVAudioRecorder!
    fileprivate var recordedAudio:  RecordedAudio!
    fileprivate var audioRecordOn:  Bool!
    fileprivate var stopPressed:    Bool!
    
    // MARK: IBOutlet
    
    @IBOutlet weak var recordLabel: UILabel!
    @IBOutlet weak var stopButton:  UIButton!
    @IBOutlet weak var recordButton:    UIButton!
    
    // MARK: IBActions
    
    @IBAction func recordAudio(_ sender: UIButton) {
        stopPressed = false
        switch audioRecordOn {
        case true:
            audioRecorder.stop()
            recordButton.isEnabled = true
            audioRecordOn = false
            break
        case false:
            audioRecordOn = true
            recordLabel.text = "Recording in Progess"
            stopButton.isHidden = false
            let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
            let currentDateTime = Date()
            let formatter = DateFormatter()
            formatter.dateFormat = "ddMMyyyy-HHmmss"
            let recordingName = formatter.string(from: currentDateTime)+".wav"
            let pathArray = [dirPath, recordingName]
            let filePath : URL = NSURL.fileURL(withPathComponents: pathArray)!
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
                try audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
            } catch {
                displayAlertWindow("Recording Error", msg: "Please exit the app and restart", actions: nil)
            }
            audioRecorder.delegate = self
            audioRecorder.isMeteringEnabled = true;
            audioRecorder.prepareToRecord()
            audioRecorder.record()
            break
        default:
            break
        }
    }
    
    @IBAction func stopRecording(_ sender: UIButton){
        stopPressed = true
        recordLabel.text = "Tap to Record"
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false)
        } catch {
            displayAlertWindow("Stop Recording Error", msg: "Please exit the app and restart", actions: nil)
        }
    }
    
    // MARK: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        audioRecordOn = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stopButton.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "stoppedRecording"){
            let playSoundsVC:PlaySoundsViewController = segue.destination as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    // MARK: AVAudioRecorderDelegate Method
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag){
            //Save recorded audio
            recordLabel.text = "Tap to Record"
            let stringpath:String! = recorder.url.lastPathComponent
            recordedAudio = RecordedAudio(filePathUrl: recorder.url,title: stringpath)
            recordButton.isEnabled = true
            audioRecordOn = false
            
            //Move to next scene
            if (stopPressed == true){
                self.performSegue(withIdentifier: "stoppedRecording", sender: recordedAudio)
            }            
        } else {
            recordLabel.text = "Recording Failed, Restart Application"
            recordButton.isEnabled = false
            stopButton.isHidden = true
        }
    }
    
    // MARK: Specialized alert displays for UIViewControllers
    fileprivate func displayAlertWindow(_ title: String, msg: String, actions: [UIAlertAction]?){
        DispatchQueue.main.async() { () -> Void in
            let alertWindow: UIAlertController = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
            alertWindow.addAction(self.dismissAction())
            if let array = actions {
                for action in array {
                    alertWindow.addAction(action)
                }
            }
            self.present(alertWindow, animated: true, completion: nil)
        }
    }
    
    fileprivate func dismissAction()-> UIAlertAction {
        return UIAlertAction(title: "Dismiss", style: .default, handler: nil)
    }

}

