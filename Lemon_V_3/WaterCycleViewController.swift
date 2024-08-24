//
//  ViewController.swift
//  Lemon
//
//  Created by Andre Pham on 10/6/2023.
//

import UIKit
import AVFoundation
import Vision

class WaterCycleViewController: UIViewController, CaptureDelegate, HandDetectionDelegate, ModelDetectionDeletegate, LiveSpeechToTextDelegate {
    
    var modelURL: URL?
    
    func onModelDetection(outcome: NewModelDetectionOutcome?) {
        if let outcome {
            if self.runModels {
                self.predictionOverlay.drawBoxes(for: outcome)
                self.proximityOverlay.drawProximityJoints(modelDetectionOutcome: outcome)
            } else {
                self.clearOverlays()
            }
            self.detectionCompiler.addOutcome(outcome, handOutcome: self.activeHandDetection)
        }
        if self.detectionCompiler.newResultsReady {
            let results = self.detectionCompiler.retrieveResults()
            self.handleDetectionResults(results)
        }
    }
    
    
    
    
    /// Determines how frequently the model is ran on a frame (every nth frame)
    private var predictionInterval = 6
    /// The camera capture session for producing a camera output
    private let captureSession = CaptureSession()
    /// Speech synthesizer for producing speech (tts)
    private let synthesizer = SpeechSynthesizer()
    /// Speech recognizer for recognising speech
    private let recognizer = SpeechRecognizer()
    /// The model used for detecting tagmata within a frame
//    private var tagmataDetector: DetectsModel = ModelQuadrantDetection(modelURL: Bundle.main.url(forResource: "TagmataDetector5_5000", withExtension: "mlmodelc")!)
    
    var waterCycleDetector =  ModelQuadrantDetection(modelURL: modelURL)
    /// Compiles multiple detections into usable results
    private let detectionCompiler = ModelDetectionCompiler()
    /// The model used for detecting hands within a frame
    private let handDetector = HandDetector()
    /// The currently detected hands to read to make associations with the results from the tagmata detector
    private var activeHandDetection = HandDetectionOutcome()
    /// The frame id used as a counter to run a model on every nth frame
    @WrapsToZero(threshold: 600) private var currentFrameID = 0
    /// Indicates if the overlay frames needs to be synced up (frames matched) to the main screen dimensions (e.g. if the device rotates)
    private var overlayFrameSyncRequired = true
    /// True if audio is being recorded
    private var isRecordingAudio = false
    /// If the app is "live" - audio is being recorded, commands being listed for
    private var isLive = false
    /// The currently queued command to be executed upon the next compiled results being available
    private var loadedCommand: Command = .none
    /// Whatever tagma is in focus (currently being described by the synthesizer, or equivalent) or was last in focus
    private var focusedWaterCycle: ModelClassification? = nil
    /// Responsible for recording and playing back audio
    private let audioRecorder = AudioRecorder()
    /// The audio action to trigger when the synthesis finishes speaking
    private var synthesisDidFinishAudioAction: AudioAction = .none
    /// The manager for controlling the quiz component of the application
    private let quizMaster = QuizMasterWaterCycle()
    /// The last time a visual check for a quiz answer was made (so the tts doesn't spam an "incorrect" response)
    private var lastVisualAnswerCheck = DispatchTime.now()
    /// True if the models should be continuously running at this moment
    private var runModels: Bool {
        return (
            (!self.isLive) ||
            (self.isLive && (
                !(self.loadedCommand == .none) ||
                self.synthesizer.isSpeaking ||
                self.quizMaster.readyForVisualAnswer ||
                self.audioRecorder.isRecording
            ))
        )
    }
    
    private var root: LemonView { return LemonView(self.view) }
    private var image = LemonImage()
    private var predictionOverlay = ModelPredictionBoxView()
    private var jointPositionsOverlay = JointPositionsView()
    private var proximityOverlay = ModelProximityView()
    private var anglesOverlay = AnglesView()
    private var handClassificationOverlay = HandClassificationView()
    private let stack = LemonVStack()
    private let buttonRowStack = LemonHStack()
    private let optionsContainer = LemonView()
    private let optionsStack = LemonVStack()
    private let speakButton = LemonIconButton()
    private let audioButton = LemonIconButton()
    private let recordButton = LemonIconButton()
    private let flipButton = LemonIconButton()
    private let interruptButton = LemonIconButton()
    private let intervalSlider = LemonLabelledSlider()
    private let detectorSwitch = LemonLabelledSwitch()
    private let anglesOverlaySwitch = LemonLabelledSwitch()
    private let jointsOverlaySwitch = LemonLabelledSwitch()
    private let predictionOverlaySwitch = LemonLabelledSwitch()
    private let proximityOverlaySwitch = LemonLabelledSwitch()
    private let handClassificationSwitch = LemonLabelledSwitch()
    private let speakerModeSwitch = LemonLabelledSwitch()
    private let liveSwitch = LemonLabelledSwitch()
    private let transcriptionContainer = LemonView()
    private let transcriptionText = LemonText()
    private let hideEverythingButton = LemonIconButton()
    private var overlays: [LemonUIView] {
        return [
            self.predictionOverlay,
            self.jointPositionsOverlay,
            self.proximityOverlay,
            self.anglesOverlay,
            self.handClassificationOverlay,
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        #if DEBUG
            self.setupSubviews()
        #else
            self.startLiveSession()
        #endif
        self.setupObjectDetection()
        self.setupHandDetection()
        self.setupSpeechRecognition()
        self.setupSpeechSynthesizer()
        self.setupAndBeginCapturingVideoFrames()
        // Stop the device automatically sleeping
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func startLiveSession() {
        self.root
            .addSubview(self.image)
            .addSubview(self.proximityOverlay)
            .addSubview(self.anglesOverlay)
        self.image.setFrame(to: self.root.frame)
        self.isLive = true
        self.startAudioRecording()
    }
    
    func setupSubviews() {
        // Root
        self.root
            .addSubview(self.image)
            .addSubview(self.stack)
            .addSubview(self.hideEverythingButton)
        
        // Video view
        self.image.setFrame(to: self.root.frame)
        
        // Overlays
        for overlay in self.overlays {
            self.image.addSubview(overlay)
        }
        
        // Hide everything button
        self.hideEverythingButton
            .constrainRight(padding: 20)
            .constrainBottom()
            .setIcon(to: "eye.circle.fill")
            .setOnTap({
                self.hideEverythingButton.setIcon(to: self.stack.isHidden ? "eye.circle.fill" : "eye.circle")
                self.stack.setHidden(to: !self.stack.isHidden)
            })
        
        // Stack
        self.stack
            .constrainAllSides()
            .addView(self.optionsContainer)
            .addSpacer()
            .addView(self.transcriptionContainer)
        
        // Options container
        self.optionsContainer
            .constrainHorizontal(padding: 24)
            .setBackgroundColor(to: UIColor.white.withAlphaComponent(0.6))
            .setCornerRadius(to: 20)
            .addSubview(self.optionsStack)
        
        // Transcription container
        self.transcriptionContainer
            .addSubview(self.transcriptionText)
            .setBackgroundColor(to: UIColor.white)
            .setCornerRadius(to: 12)
        
        // Transcription text
        self.transcriptionText
            .constrainAllSides(padding: 12)
            .setSize(to: 16)
            
        // Options stack
        self.optionsStack
            .constrainHorizontal(padding: 24)
            .constrainVertical(padding: 16)
            .setSpacing(to: 8)
            .addView(self.buttonRowStack)
            .addView(self.intervalSlider)
            .addView(self.detectorSwitch)
            .addView(self.anglesOverlaySwitch)
            .addView(self.jointsOverlaySwitch)
            .addView(self.predictionOverlaySwitch)
            .addView(self.proximityOverlaySwitch)
            .addView(self.handClassificationSwitch)
            .addView(self.speakerModeSwitch)
            .addView(self.liveSwitch)
        
        // Button row stack
        self.buttonRowStack
            .constrainHorizontal()
            .setDistribution(to: .equalSpacing)
            .addView(self.speakButton)
            .addView(self.audioButton)
            .addView(self.recordButton)
            .addView(self.flipButton)
            .addView(self.interruptButton)
        
        // Speak button
        self.speakButton
            .setIcon(to: "waveform.circle.fill")
            .setOnTap({
                print(AudioSessionManager.inst.activeMode)
                if self.audioRecorder.isPlaying {
                    self.audioRecorder.stopPlayback()
                } else {
                    self.audioRecorder.startPlayback(audioFileName: "test.m4a")
                }
            })
        
        // Audio button
        self.audioButton
            .setIcon(to: "mic.circle")
            .setOnTap({
                if self.audioRecorder.isRecording {
                    self.audioRecorder.stopRecording()
                    self.audioButton.setIcon(to: "mic.circle")
                } else {
                    self.audioRecorder.startRecording(audioFileName: "test.m4a")
                    self.audioButton.setIcon(to: "mic.circle.fill")
                }
            })
        
        // Record button
        self.recordButton
            .setIcon(to: "record.circle")
            .setOnTap({
                self.transcriptionText.setText(to: "")
                self.toggleAudioRecording()
                if !self.isRecordingAudio {
                    self.liveSwitch.switchView.setState(isOn: false, animated: true)
                }
            })
        
        // Flip button
        self.flipButton
            .setIcon(to: "arrow.clockwise.circle")
            .setOnTap({
                self.flipCamera()
            })
        
        // Interrupt button
        self.interruptButton
            .setIcon(to: "xmark.circle.fill")
            .setOnTap({
                self.synthesizer.stopSpeaking()
            })
            .setAccessibilityLabel(to: "STOP")
        
        // Interval slider
        self.intervalSlider
            .constrainHorizontal()
            .setPadding(top: 8)
        self.intervalSlider.stack
            .setSpacing(to: 16)
        self.intervalSlider.labelText
            .setText(to: "Interval")
            .setPadding(right: 30)
        self.intervalSlider.slider
            .setValues(minimumValue: 1, maximumValue: 60, value: self.predictionInterval)
            .setRoundToNearest(1)
            .setOnDrag({ value in
                self.predictionInterval = Int(value)
            })
        
        // Detector switch
        self.detectorSwitch
            .constrainHorizontal()
        self.detectorSwitch.labelText
            .setText(to: "Alternate Model")
        self.detectorSwitch.switchView
            .setOnFlick({ isOn in
                if isOn {
                    self.waterCycleDetector = ModelDetector(mlModelFile: self.modelURL)
                } else {
                    self.waterCycleDetector = ModelDetector(mlModelFile: self.modelURL)
                }
                self.setupObjectDetection()
            })
        
        // Angles overlay switch
        self.anglesOverlaySwitch
            .constrainHorizontal()
        self.anglesOverlaySwitch.labelText
            .setText(to: "Angles Overlay")
        self.anglesOverlaySwitch.switchView
            .setOnFlick({ isOn in
                self.anglesOverlay.setHidden(to: !isOn)
            })
            .setState(isOn: false, animated: false)
        
        // Joints overlay switch
        self.jointsOverlaySwitch
            .constrainHorizontal()
        self.jointsOverlaySwitch.labelText
            .setText(to: "Joints Overlay")
        self.jointsOverlaySwitch.switchView
            .setOnFlick({ isOn in
                self.jointPositionsOverlay.setHidden(to: !isOn)
            })
            .setState(isOn: false, animated: false)
        
        // Prediction overlay switch
        self.predictionOverlaySwitch
            .constrainHorizontal()
        self.predictionOverlaySwitch.labelText
            .setText(to: "Prediction Overlay")
        self.predictionOverlaySwitch.switchView
            .setOnFlick({ isOn in
                self.predictionOverlay.setHidden(to: !isOn)
            })
            .setState(isOn: false, animated: false)
        
        // Proximity overlay switch
        self.proximityOverlaySwitch
            .constrainHorizontal()
        self.proximityOverlaySwitch.labelText
            .setText(to: "Joints Proximity Overlay")
        self.proximityOverlaySwitch.switchView
            .setOnFlick({ isOn in
                self.proximityOverlay.setHidden(to: !isOn)
            })
            .setState(isOn: false, animated: false)
        
        // Hand classification switch
        self.handClassificationSwitch
            .constrainHorizontal()
        self.handClassificationSwitch.labelText
            .setText(to: "Hand Classification Overlay")
        self.handClassificationSwitch.switchView
            .setOnFlick({ isOn in
                self.handClassificationOverlay.setHidden(to: !isOn)
            })
            .setState(isOn: false, animated: false)
        
        // Speaker mode switch
        self.speakerModeSwitch
            .constrainHorizontal()
        self.speakerModeSwitch.labelText
            .setText(to: "Speaker Mode")
        self.speakerModeSwitch.switchView
            .setOnFlick({ isOn in
                if isOn {
                    AudioSessionManager.inst.setToSpeakerMode()
                } else {
                    AudioSessionManager.inst.setToVOIPMode()
                }
            })
            .setState(isOn: true, animated: false)
        
        // Live switch
        self.liveSwitch
            .constrainHorizontal()
        self.liveSwitch.labelText
            .setText(to: "App is Live")
        self.liveSwitch.switchView
            .setOnFlick({ isOn in
                self.isLive = isOn
                if isOn {
                    self.transcriptionText.setText(to: "")
                    self.startAudioRecording()
                } else {
                    self.stopAudioRecording()
                }
            })
    }
    
    func clearOverlays() {
        self.overlays.forEach({ $0.clearSubviewsAndLayers() })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.captureSession.stopCapturing {
            super.viewWillDisappear(animated)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.image.setFrame(to: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        // React to change in device orientation
        self.setupAndBeginCapturingVideoFrames()
        self.overlayFrameSyncRequired = true
    }
    
    override func viewDidLayoutSubviews() {
        self.overlayFrameSyncRequired = true
    }
    
    private func setVideoImage(to image: CGImage) {
        self.image.setImage(image)
        if self.overlayFrameSyncRequired {
            self.matchOverlayFrame()
            self.overlayFrameSyncRequired = false
        }
    }
    
    private func matchOverlayFrame() {
        let overlaySize = self.image.imageSize
        var overlayFrame = CGRect(origin: CGPoint(), size: overlaySize).scale(toAspectFillSize: self.image.frame.size)
        // Align overlay frame center to view center
        overlayFrame.origin.x += self.image.frame.center.x - overlayFrame.center.x
        overlayFrame.origin.y += self.image.frame.center.y - overlayFrame.center.y
        for overlay in self.overlays {
            overlay.setFrame(to: overlayFrame)
        }
    }
    
    private func setupAndBeginCapturingVideoFrames() {
        self.captureSession.setUpAVCapture { error in
            if let error {
                assertionFailure("Failed to setup camera: \(error)")
                return
            }
            
            self.captureSession.captureDelegate = self
            self.captureSession.startCapturing()
        }
    }
    
    private func setupObjectDetection() {
        self.waterCycleDetector.objectDetectionDelegate = self
        self.tagmataDetector.objectDetectionDelegate = self

        
    }
    
    private func setupHandDetection() {
        self.handDetector.handDetectionDelegate = self
    }
    
    private func setupSpeechRecognition() {
        self.recognizer.liveSpeechToTextDelegate = self
    }
    
    private func setupSpeechSynthesizer() {
        self.synthesizer.didCancelDelegate = {
            // Reset the transcript so none of the text the synthesiser said gets registered as a command
            self.recognizer.resetTranscript()
        }
        self.synthesizer.didFinishDelegate = {
            // Reset the transcript so none of the text the synthesiser said gets registered as a command
            self.recognizer.resetTranscript()
            switch self.synthesisDidFinishAudioAction {
            case .head:
                AudioPlayer.inst.playAudio(file: "head", type: "m4a", volume: 0.45)
            case .thorax:
                AudioPlayer.inst.playAudio(file: "thorax", type: "m4a", volume: 0.45)
            case .abdomen:
                AudioPlayer.inst.playAudio(file: "abdomen", type: "m4a", volume: 0.8)
            case .wings:
                AudioPlayer.inst.playAudio(file: "wings", type: "m4a", volume: 1.0)
            case .completed:
                AudioPlayer.inst.playAudio(file: "completed", type: "m4a", volume: 0.8)
            case .correct:
                AudioPlayer.inst.playAudio(file: "correct", type: "m4a", volume: 0.8)
            case .none:
                break
            }
            self.synthesisDidFinishAudioAction = .none
            // Make sure we clear overlays if necessary after focus is lost
            if !self.runModels {
                self.clearOverlays()
            }
        }
    }
    
    private func toggleAudioRecording() {
        self.isRecordingAudio.toggle()
        if self.isRecordingAudio {
            self.recordButton.setIcon(to: "record.circle.fill")
            self.recognizer.resetTranscript()
            self.recognizer.startTranscribing()
        } else {
            self.recordButton.setIcon(to: "record.circle")
            self.recognizer.stopTranscribing()
        }
    }
    
    private func startAudioRecording() {
        guard !self.isRecordingAudio else {
            return
        }
        self.isRecordingAudio = true
        self.recordButton.setIcon(to: "record.circle.fill")
        self.recognizer.startTranscribing()
    }
    
    private func stopAudioRecording() {
        guard self.isRecordingAudio else {
            return
        }
        self.isRecordingAudio = false
        self.recordButton.setIcon(to: "record.circle")
        self.recognizer.stopTranscribing()
    }
    
    private func flipCamera() {
        self.captureSession.flipCamera { error in
            if let error {
                assertionFailure("Failed to flip camera: \(error)")
                return
            }
        }
    }
    
    func onCapture(session: CaptureSession, frame: CGImage?) {
        if let frame {
            if self.runModels {
                self.handDetector.makePrediction(on: frame)
                if self.currentFrameID%self.predictionInterval == 0 {
                    self.waterCycleDetector.makePrediction(on: frame)
                }
            }
            
            self.setVideoImage(to: frame)
            
            self.currentFrameID += 1
        }
    }
    
  
    func onHandDetection(outcome: HandDetectionOutcome?) {
        if let outcome {
            if self.runModels {
                self.jointPositionsOverlay.drawJointPositions(for: outcome)
                self.handClassificationOverlay.drawHandClassification(for: outcome)
            } else {
                self.clearOverlays()
            }
        }
        self.activeHandDetection = outcome ?? HandDetectionOutcome()
    }
    
    func onWordRecognition(currentTranscription: SpeechText) {
        if !currentTranscription.text.isEmpty {
            self.transcriptionText.setText(to: currentTranscription.text)
        }
        if self.isLive {
            guard !self.synthesizer.isSpeaking else {
                // We don't accept commands while the synthesiser is speaking
                // Otherwise responses can cause loops if the response has the command within it (or similar text to the command)
                return
            }
            guard !self.audioRecorder.isRecording && !self.audioRecorder.isPlaying else {
                // If the audio recorder is recording/playing, we don't want command and recognition to interrupt it
                return
            }
            
            // React to audio answer (for quiz)
            if self.quizMaster.readyForAudioAnswer && !currentTranscription.text.isEmpty && !self.quizMaster.isActivatedBy(speech: currentTranscription) {
                let outcome = self.quizMaster.acceptAnswer(provided: currentTranscription)
                if outcome == .correct {
                    self.synthesisDidFinishAudioAction = .correct
                    self.synthesizer.speak(Strings("feedback.correct").local)
                }
                if outcome == .incorrect {
                    self.recognizer.resetTranscript()
                    self.synthesizer.speak(Strings("feedback.tryAgain").local)
                }
                // If it's a partially correct answer, just continue receiving input until it's wrong/right
                return
            }
            
            // Quiz command
            if self.quizMaster.isActivatedBy(speech: currentTranscription) && !self.quizMaster.readyForVisualAnswer && !self.quizMaster.questionReceived {
                self.quizMaster.markQuestionAsReceived(true)
                self.focusedWaterCycle = nil // Remove any focus so the text isn't cancelled by letting go
                if self.quizMaster.readyForAudioAnswer {
                    self.quizMaster.loadCurrentQuestion()
                } else {
                    self.quizMaster.loadNextQuestion()
                }
                // Add a delay so we don't respond immediately - feels more conversational
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.synthesizer.speak(self.quizMaster.loadedQuestionText) {
                        // Only be ready to respond to answers AFTER the question has been asked
                        self.quizMaster.markReadyForAnswer()
                        self.quizMaster.markQuestionAsReceived(false)
                    }
                }
                return
            }
            
            for command in Command.allCases {
                if  currentTranscription.contains(Command.switchToTagmata) {
                    self.detectorSwitch.switchView.setState(isOn: true)
                    self.synthesizer.speak("Switched to Tagmata")
                    self.detectionCompiler.clearOutcomes()
                    self.loadedCommand = command
                    self.waterCycleDetector = ModelDetector(mlModelFile: Bundle.main.url(forResource: "TagmataDetector5_5000", withExtension: "mlmodelc")!)
                    self.setupObjectDetection()
                    self.recognizer.resetTranscript()
                    return
                }
                if  currentTranscription.contains(Command.switchToWaterCycle) {
                    self.detectorSwitch.switchView.setState(isOn: false)
                    self.synthesizer.speak("Switched to WaterCycle")
                    self.detectionCompiler.clearOutcomes()
                    self.loadedCommand = command
                    self.waterCycleDetector = ModelDetector(mlModelFile: Bundle.main.url(forResource: "watercycle", withExtension: "mlmodelc")!)
                    self.setupObjectDetection()
                    self.recognizer.resetTranscript()
                    return

                }
                if currentTranscription.contains(command) {
                    self.detectionCompiler.clearOutcomes()
                    self.loadedCommand = command
                    self.recognizer.resetTranscript()
                    return
                }
            }
        }
    }
    
    func handleDetectionResults(_ results: ModelCompiledResults) {
        if self.isLive {

            print(self.loadedCommand)
            print(results.heldModel.first)
            // Test command to make sure everything is working
            if self.loadedCommand == .test {
                self.synthesizer.speak("Lemon")
                self.loadedCommand = .none
                return
            }
            // First, if the command requires only one tagma to be held at once, cancel the command and tell the user
            // E.g. if they're using two hands AND holding two tagma, we don't want to guess which one they mean, we bail
            if ((self.loadedCommand == .name ||
                 self.loadedCommand == .information ||
                 self.loadedCommand == .connect ||
                 self.loadedCommand == .addLabel ||
                 self.loadedCommand == .listenLabel) &&
                results.handsUsed > 1
            ) {
                self.loadedCommand = .none
                self.focusedWaterCycle = nil
                self.synthesizer.speak(Strings("tip.twoHands").local)
                return
            }
            // Alright now we can check for the commands that require they hold one tagma
            if let tagmata = results.heldModel.first {
                if self.loadedCommand == .name {
                    self.loadedCommand = .none
                    self.focusedWaterCycle = tagmata
                    self.synthesizer.speak(tagmata.name)
                    return
                } else if self.loadedCommand == .information {
                    self.loadedCommand = .none
                    self.focusedWaterCycle = tagmata
                    self.synthesizer.speak(tagmata.description)
                    return
                } else if self.loadedCommand == .connect {
                    self.loadedCommand = .none
                    self.focusedWaterCycle = tagmata
                    return
                } else if self.loadedCommand == .addLabel {
                    // If a command was said during the recording, we don't want it being maintained in the transcript
                    self.recognizer.stopTranscribing()
                    self.loadedCommand = .none
                    self.focusedWaterCycle = tagmata
                    AudioPlayer.inst.playAudio(file: "correct", type: "m4a")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.audioRecorder.startRecording(audioFileName: tagmata.name + ".m4a")
                        let recordingID = self.audioRecorder.recordingSessionID
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                            // Force-end after 10 seconds
                            if self.audioRecorder.recordingSessionID == recordingID {
                                self.endLabelRecording()
                            }
                        }
                    }
                    // TODO: If I add a queue on to stop recording, then I start a new recording before the old finished,
                    // it will cancel the new one
                    return
                } else if self.loadedCommand == .listenLabel {
                    // If a command was said during the recording, we don't want it being maintained in the transcript
                    self.recognizer.stopTranscribing()
                    self.loadedCommand = .none
                    self.focusedWaterCycle = tagmata
                    self.audioRecorder.startPlayback(audioFileName: tagmata.name + ".m4a") {
                        self.recognizer.startTranscribing()
                        self.clearOverlays()
                    }
                    return
                }
            }
            // Any other commands go next
            if self.loadedCommand == .completed {
                self.loadedCommand = .none
                self.focusedWaterCycle = nil
                if results.modelIsComplete {
                    self.synthesisDidFinishAudioAction = .completed
                    self.synthesizer.speak(Strings("completion.success").local)
                } else {
                    self.synthesizer.speak(Strings("completion.failure").local)
                }
                return
            }
            // If the quiz master is waiting for an answer, handle it
            if self.quizMaster.readyForVisualAnswer {
                guard results.handsUsed <= 1 else {
                    self.synthesizer.speak(Strings("tip.twoHands").local)
                    return
                }
                if let tagmata = results.heldModel.first {
                    let outcome = self.quizMaster.acceptAnswer(provided: tagmata)
                    if outcome == .correct {
                        self.synthesizer.stopSpeaking()
                        self.synthesisDidFinishAudioAction = .correct
                        self.detectionCompiler.clearOutcomes()
                        self.synthesizer.speak(Strings("feedback.correct").local)
                    }
                    if outcome == .incorrect {
                        // We don't want to continuously bombard the user with "please try again"
                        // But we only care about continuously stating they're wrong - if they're right, respond straight away
                        // Hence we only manage the lastVisualAnswerCheck in the incorrect response
                        let now = DispatchTime.now()
                        let seconds = Double(now.uptimeNanoseconds - self.lastVisualAnswerCheck.uptimeNanoseconds)/1_000_000_000
                        if seconds < 3.0 {
                            return
                        } else {
                            self.lastVisualAnswerCheck = DispatchTime.now()
                        }
                        self.detectionCompiler.clearOutcomes()
                        self.synthesizer.speak(Strings("feedback.tryAgain").local)
                    }
                }
                // Return here so we don't cancel any speaking (triggered below)
                return
            }
            // If there's no command to be responded to, and they were holding a tagma, and they stopped, stop speaking
            if let focusedWaterCycle, !results.modelStillHeld(original: focusedWaterCycle) {
                self.synthesizer.stopSpeaking()
                self.endLabelRecording()
            }
        }
    }
    
    func endLabelRecording() {
        if self.audioRecorder.isRecording {
            self.audioRecorder.stopRecording()
            AudioPlayer.inst.playAudio(file: "correct", type: "m4a")
            self.recognizer.startTranscribing()
        }
    }

}

