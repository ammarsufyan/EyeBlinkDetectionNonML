import Foundation
import AVFoundation
import Vision
import SwiftUI

class EyeBlinkDetector: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let session = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private let sequenceHandler = VNSequenceRequestHandler()
    
    @Published var leftEAR: CGFloat = 1.0
    @Published var rightEAR: CGFloat = 1.0
    @Published var isLeftBlink: Bool = false
    @Published var isRightBlink: Bool = false
    @Published var landmarks: [CGPoint] = []
    @Published var leftEyePoints: [CGPoint] = []
    @Published var rightEyePoints: [CGPoint] = []
    @Published var faceBoundingBox: CGRect = .zero
    @Published var faceCount: Int = 0
    @Published var selectedFaceArea: CGFloat = 0.0
    
    override init() {
        super.init()
        setupCamera()
    }
    
    private func setupCamera() {
        session.sessionPreset = .medium
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else { return }
        session.addInput(input)
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        session.addOutput(videoOutput)
        session.startRunning()
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        let request = VNDetectFaceLandmarksRequest { [weak self] request, error in
            guard let results = request.results as? [VNFaceObservation], !results.isEmpty else { 
                // Reset jika tidak ada wajah yang terdeteksi
                DispatchQueue.main.async {
                    self?.faceCount = 0
                    self?.selectedFaceArea = 0.0
                    self?.landmarks = []
                    self?.leftEyePoints = []
                    self?.rightEyePoints = []
                }
                return 
            }
            
            // Update jumlah wajah yang terdeteksi
            DispatchQueue.main.async {
                self?.faceCount = results.count
            }
            
            // Filter wajah yang terlalu kecil (threshold minimum area 0.01)
            let validFaces = results.filter { face in
                let area = face.boundingBox.width * face.boundingBox.height
                return area > 0.01  // Hanya proses wajah dengan area > 1% dari frame
            }
            
            guard !validFaces.isEmpty else {
                DispatchQueue.main.async {
                    self?.selectedFaceArea = 0.0
                }
                return
            }
            
            // Pilih wajah dengan bounding box terbesar dari wajah yang valid
            let largestFace = validFaces.max { face1, face2 in
                let area1 = face1.boundingBox.width * face1.boundingBox.height
                let area2 = face2.boundingBox.width * face2.boundingBox.height
                return area1 < area2
            }
            
            guard let selectedFace = largestFace else { return }
            
            // Hitung area wajah yang dipilih
            let selectedArea = selectedFace.boundingBox.width * selectedFace.boundingBox.height
            DispatchQueue.main.async {
                self?.selectedFaceArea = selectedArea
            }
            
            self?.processFace(selectedFace)
        }
        try? sequenceHandler.perform([request], on: pixelBuffer)
    }
    
    private func processFace(_ face: VNFaceObservation) {
        let boundingBox = face.boundingBox
        var allLandmarks: [CGPoint] = []
        var leftEyePts: [CGPoint] = []
        var rightEyePts: [CGPoint] = []
        if let all = face.landmarks?.allPoints {
            allLandmarks = all.normalizedPoints.map { convert($0, boundingBox: boundingBox) }
        }
        if let leftEye = face.landmarks?.leftEye {
            leftEyePts = leftEye.normalizedPoints.map { convert($0, boundingBox: boundingBox) }
            let ear = calculateEAR(points: leftEyePts)
            DispatchQueue.main.async {
                self.leftEAR = ear
                self.isLeftBlink = ear < 0.15
                self.leftEyePoints = leftEyePts
            }
        }
        if let rightEye = face.landmarks?.rightEye {
            rightEyePts = rightEye.normalizedPoints.map { convert($0, boundingBox: boundingBox) }
            let ear = calculateEAR(points: rightEyePts)
            DispatchQueue.main.async {
                self.rightEAR = ear
                self.isRightBlink = ear < 0.15
                self.rightEyePoints = rightEyePts
            }
        }
        DispatchQueue.main.async {
            self.landmarks = allLandmarks
            self.faceBoundingBox = boundingBox
        }
    }
    
    private func convert(_ point: CGPoint, boundingBox: CGRect) -> CGPoint {
        // Convert from face bounding box to image coordinates (normalized 0-1)
        let x = boundingBox.origin.x + point.x * boundingBox.size.width
        let y = boundingBox.origin.y + point.y * boundingBox.size.height
        return CGPoint(x: x, y: y)
    }
    
    private func calculateEAR(points: [CGPoint]) -> CGFloat {
        guard points.count >= 6 else { return 1.0 }
        func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
            hypot(a.x - b.x, a.y - b.y)
        }
        let vertical1 = distance(points[1], points[5])
        let vertical2 = distance(points[2], points[4])
        let horizontal = distance(points[0], points[3])
        return (vertical1 + vertical2) / (2.0 * horizontal)
    }
    
    func getSession() -> AVCaptureSession {
        return session
    }
} 
