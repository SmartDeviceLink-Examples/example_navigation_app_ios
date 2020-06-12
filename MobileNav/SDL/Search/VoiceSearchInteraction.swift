//
//  VoiceSearchInteraction.swift
//  MobileNav
//
//  Created by James Lapinski on 5/21/20.
//  Copyright © 2020 Livio Inc. All rights reserved.
//

import Foundation
import MapKit
import SmartDeviceLink
import Speech

private enum VoiceSearchInteractionState {
    case listening, notListening, notAuthorized, badRegion
}

class VoiceSearchInteraction: NSObject {
    // Results: Success, Search String, Search Results
    typealias SearchCompletionHandler = (Bool, String?, [MKMapItem]?) -> Void

    fileprivate var audioData = Data()

    fileprivate let speechRecognizer: SFSpeechRecognizer!
    fileprivate var recognitionTask: SFSpeechRecognitionTask?

    fileprivate var listenState: VoiceSearchInteractionState = .notAuthorized
    fileprivate var searchCompletion: SearchCompletionHandler?

    private let screenManager: SDLScreenManager
    private var mapItemsInteraction: MapItemsListInteraction?

    private let searchManager = SearchManager()

    private let defaultLocale = Locale(identifier: "en-US")

    init(screenManager: SDLScreenManager) {
        self.speechRecognizer = SFSpeechRecognizer(locale: defaultLocale)
        self.screenManager = screenManager

        self.listenState = VoiceSearchInteraction.checkAuthorization(speechRecognizer: speechRecognizer)

        super.init()

        self.speechRecognizer.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(audioPassThruDataReceived(notification:)), name: .SDLDidReceiveAudioPassThru, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(audioPassThruEnded(response:)), name: SDLDidReceivePerformAudioPassThruResponse, object: nil)
    }

    /// Grabs the audio data from the car's built in microphone and uses the search keyword spoken by the user to find local destinations
    func present() {
        // Start the perform audio pass through
        self.performSearch { [unowned self] (success, searchString, results) in
            guard success else { return }

            guard let searchString = searchString, !searchString.isEmpty else {
                Alert.presentSpeechNotDetectedAlert()
                return
            }

            guard let results = results, !results.isEmpty else {
                Alert.presentEmptySearchResultsAlert(searchTerm: searchString)
                return
            }

            self.mapItemsInteraction = MapItemsListInteraction(screenManager: self.screenManager, searchText: searchString, mapItems: results)
            self.mapItemsInteraction?.present()
        }
    }

    private func performSearch(completionHandler: @escaping SearchCompletionHandler) {
        switch listenState {
        case .notAuthorized:
            ProxyManager.sharedManager.sdlManager.send(request: Alert.speechRecognizerDisallowedAlert())
            completionHandler(false, nil, nil)
        case .badRegion:
            ProxyManager.sharedManager.sdlManager.send(request: Alert.speechRecognizerBadLocaleAlert())
            completionHandler(false, nil, nil)
        case .listening:
            // TODO: Send an end audio pass thru?
            break
        case .notListening:
            ProxyManager.sharedManager.sdlManager.send(request: VoiceSearchInteraction.audioPassThruRequest())
            searchCompletion = completionHandler
        }
    }

    static func speechRecognizerRequest() -> SFSpeechAudioBufferRecognitionRequest {
        let speechRequest = SFSpeechAudioBufferRecognitionRequest()
        speechRequest.taskHint = .search
        speechRequest.shouldReportPartialResults = false
        return speechRequest
    }

    fileprivate static func checkAuthorization(speechRecognizer: SFSpeechRecognizer?) -> VoiceSearchInteractionState {
        // Check the speech recognizer init'd successfully
        guard speechRecognizer != nil else {
            return .badRegion
        }

        // Check speech authorization status
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized:
            return .notListening
        default:
            // Speech recognition not authorized. Voice search will not work.
            return .notAuthorized
        }
    }
}

// MARK: - RPC Requests

extension VoiceSearchInteraction {
    static func audioPassThruRequest() -> SDLPerformAudioPassThru {
        return SDLPerformAudioPassThru(initialPrompt: nil, audioPassThruDisplayText1: "Listening...", audioPassThruDisplayText2: "Search for a destination", samplingRate: .rate16KHZ, bitsPerSample: .sample16Bit, audioType: .PCM, maxDuration: 5000, muteAudio: true)
    }
}

// MARK: - PerformAudioPassThru Callbacks

extension VoiceSearchInteraction {
    // http://stackoverflow.com/a/30425212/1221798
    @objc func audioPassThruDataReceived(notification: SDLRPCNotificationNotification) {
        switch listenState {
        case .notListening:
            listenState = .listening
        case .listening: break // TODO: This shouldn't be possible, but we may want to error or something here
        default: return
        }

        guard let data = notification.notification.bulkData else {
            return
        }

        audioData.append(data)
    }

    @objc func audioPassThruEnded(response: SDLRPCResponseNotification) {
        listenState = .notListening

        guard response.response.success.boolValue == true else {
            cancelSpeechRecognitionTask()
            return
        }

        let audioFormat = AVAudioFormat(commonFormat: .pcmFormatInt16, sampleRate: 16000, channels: 1, interleaved: false)
        let numFrames = UInt32(audioData.count) / (audioFormat?.streamDescription.pointee.mBytesPerFrame)!
        let buffer = AVAudioPCMBuffer(pcmFormat: audioFormat!, frameCapacity: numFrames)!
        buffer.frameLength = numFrames
        let bufferChannels = buffer.int16ChannelData!
        let bufferDataCount = audioData.copyBytes(to: UnsafeMutableBufferPointer(start: bufferChannels[0], count: audioData.count))

        print("SDL Search about to send \(bufferDataCount) bytes in \(buffer) to be recognized")

        let recognitionRequest = VoiceSearchInteraction.speechRecognizerRequest()
        recognitionRequest.append(buffer)
        recognitionRequest.endAudio()
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, delegate: self)
    }
}

// MARK: - SFSpeechRecognitionTaskDelegate

extension VoiceSearchInteraction: SFSpeechRecognitionTaskDelegate {
    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
        if !successfully {
            cancelSpeechRecognitionTask()

            // Alert the user that no speech was detected
            guard let searchResultsHandler = searchCompletion else { return }
            searchResultsHandler(true, "", nil)
        }
    }

    func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {

        // Search for destination
        let searchString = recognitionResult.bestTranscription.formattedString
        searchManager.searchFor(searchTerm: searchString) { (mapItems, error) in
            if error != nil {
                Alert.presentSearchErrorAlert()
                return
            }

            if let mapItems = mapItems {
                guard let searchResultsHandler = self.searchCompletion else { return }
                searchResultsHandler(true, searchString, mapItems)
            }
        }

        cancelSpeechRecognitionTask()
    }

    func speechRecognitionTaskWasCancelled(_ task: SFSpeechRecognitionTask) {
        cancelSpeechRecognitionTask()
    }

    func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
    }

    fileprivate func cancelSpeechRecognitionTask() {
        audioData = Data()
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}

// MARK: - SFSpeechRecognizerDelegate

extension VoiceSearchInteraction: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        listenState = VoiceSearchInteraction.checkAuthorization(speechRecognizer: speechRecognizer)
    }
}
