import Foundation
import Speech
import AVFoundation

public final class VoiceTypingViewModel: ObservableObject {
    @Published public var isRecording: Bool = false
    @Published public var transcription: String = ""
    @Published public var statusMessage: String = "Tap mic to speak (Rambler Voice)"

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    public var onFinalText: ((String) -> Void)?

    public func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    public func startRecording() {
        guard !isRecording else { return }

        let node = audioEngine.inputNode
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            if let result = result {
                var text = result.bestTranscription.formattedString
                if KeyboardSettings.shared.ramblerRemoveFillerWords {
                    text = self.applyRamblerCleanup(text)
                }
                DispatchQueue.main.async {
                    self.transcription = text
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                self.stopRecording()
            }
        }

        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }

        do {
            try audioEngine.start()
            isRecording = true
            statusMessage = "Listening with Rambler cleanup..."
        } catch {
            statusMessage = "Audio engine error"
            stopRecording()
        }
    }

    public func stopRecording() {
        guard isRecording else { return }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        let finalOutput = transcription.trimmingCharacters(in: .whitespacesAndNewlines)
        if !finalOutput.isEmpty {
            onFinalText?(finalOutput + " ")
        }

        isRecording = false
        transcription = ""
        statusMessage = "Tap mic to speak (Rambler Voice)"
    }

    // PixelBoard Gemini Rambler real-time speech cleanup filter
    public func applyRamblerCleanup(_ text: String) -> String {
        let fillerWords = [
            "\bum\b", "\buh\b", "\blike\b", "\byou know\b", "\bah\b",
            "\bso uh\b", "\bkinda\b"
        ]
        var cleaned = text
        for pattern in fillerWords {
            cleaned = cleaned.replacingOccurrences(of: pattern, with: "", options: [.regularExpression, .caseInsensitive])
        }
        // Normalize whitespace
        cleaned = cleaned.replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
        return cleaned.trimmingCharacters(in: .whitespaces)
    }
}
