# Vision API

## Introduction
Self-Host, Out of the box OCR and Image Classification and more.

Vision API is an open-source project built with the Vapor framework, designed to expose various machine learning methods from Apple’s Vision framework as a RESTful API. This project aims to make it easier for independent developers and small companies to leverage powerful machine learning models for tasks like image classification, object detection, and text recognition, all hosted and self-managed.

## Project Goals

- Provide easy-to-use APIs for utilizing machine learning models from Apple Vision framework.
- Allow developers to self-host the API, reducing reliance on third-party cloud services.
- Enable seamless integration of machine learning and image analysis into developers' workflows through simple RESTful interfaces.

## Features

- **Text Recognition (OCR)**: Extract text from images using Optical Character Recognition (OCR).
- **Background Removal**: Remove the background from images.
- **Image Aesthetics Scoring** *(macOS 15+)*: Score image quality and aesthetics, returning an `overallScore` (-1 to 1) and an `isUtility` flag to distinguish artistic photos from screenshots, receipts, and documents.
- **Image Classification / Auto Tagging** *(macOS 10.15+)*: Classify image content using `VNClassifyImageRequest`, returning 1000+ category labels (e.g. `dog`, `beach`, `food`) with confidence scores.
- ~~**Object Detection**: Detect objects and facial features within images.~~
- ~~**Barcode Recognition**: Scan and decode barcodes and QR codes in images.~~

For more feature visit: [Vision Framwork](https://developer.apple.com/documentation/vision/)

## Getting Started

### Prerequisites

- macOS only
- Vapor

### Installation

1. Clone the project to your local machine:
   ```bash
   git clone https://github.com/tdawn0-0/vision-api
   cd vision-api
   ```

2. Install dependencies:
   ```bash
   swift package resolve
   ```

3. Run the project:
   ```bash
   swift run App
   ```

   This will start the local server, which will listen on `http://localhost:9493` by default.

   > All API endpoints that accept images use `multipart/form-data` with a binary `imageFile` field.

   **Configuring the port** (priority: highest → lowest):

   - `--port` CLI flag:
     ```bash
     swift run App serve --port 8080
     ```
   - `PORT` environment variable:
     ```bash
     PORT=8080 swift run App
     ```
   - Built-in default: `9493`

### Using the API

Once the server is running, you can send HTTP requests to interact with the API.

For more API detail visit: http://localhost:9493/Swagger/index.html

## TODO

- [x] Background Removal — `VNGenerateForegroundInstanceMaskRequest`
- [x] Text Recognition (OCR) — `VNRecognizeTextRequest`

- [x] **Image Aesthetics Scoring** *(macOS 15+)* — `CalculateImageAestheticsScoresRequest`
  - Returns `overallScore` (-1 to 1) based on blur, exposure, color balance, composition, subject matter
  - Returns `isUtility` to distinguish artistic photos from screenshots/receipts/documents
  - Use case: rank photos, auto-select the best shot from a burst

- [ ] **Saliency Heatmap / Smart Crop** *(macOS 10.15+)* — `VNGenerateAttentionBasedSaliencyImageRequest` / `VNGenerateObjectnessBasedSaliencyImageRequest`
  - Attention-based: simulates where human eyes are drawn first
  - Objectness-based: highlights regions most likely to contain objects
  - Use case: smart thumbnail cropping, visual focus analysis

- [x] **Image Classification / Auto Tagging** *(macOS 10.15+)* — `VNClassifyImageRequest`
  - Returns 1000+ category labels with confidence scores (e.g. `dog`, `beach`, `food`)
  - Optional `confidenceThreshold` (Float, 0–1) to filter low-confidence labels
  - Optional `maxResults` (Int) to cap the number of returned labels, sorted by confidence descending
  - Use case: automatic image tagging, content pre-filtering

- [ ] **Image Similarity / Feature Print** *(macOS 10.15+)* — `VNGenerateImageFeaturePrintRequest`
  - Generates a feature vector for an image; compute distance between two vectors for similarity score
  - Use case: reverse image search, duplicate detection

- [ ] **Barcode & QR Code Detection** *(macOS 10.13+)* — `VNDetectBarcodesRequest`
  - Supports QR, PDF417, Aztec, Code128, EAN-13, DataMatrix and more
  - Returns decoded value + bounding box position

- [ ] **Face Detection** *(macOS 10.13+)* — `VNDetectFaceRectanglesRequest`
  - Detects faces and returns bounding boxes with confidence scores

- [ ] **Face Landmarks** *(macOS 10.13+)* — `VNDetectFaceLandmarksRequest`
  - Returns 68 facial keypoints: eyes, nose, mouth, eyebrows, jaw contour

- [ ] **Face Capture Quality** *(macOS 10.15+)* — `VNDetectFaceCaptureQualityRequest`
  - Scores face image quality (0–1); use case: validate ID photo suitability

- [ ] **Document Detection / Scanner** *(macOS 12+)* — `VNDetectDocumentSegmentationRequest`
  - Detects document corners (quadrilateral) + saliency mask
  - Use case: document scanning with perspective correction

- [ ] **Human Presence Detection** *(macOS 10.15+)* — `VNDetectHumanRectanglesRequest`
  - Detects people in an image and returns body bounding boxes (partial body supported)
  - Use case: privacy detection, people counting

- [ ] **Animal Detection** *(macOS 10.15+)* — `VNRecognizeAnimalsRequest`
  - Detects cats and dogs with confidence scores
  - Use case: pet apps, content filtering

- [ ] **Human Body Pose** *(macOS 11+)* — `VNDetectHumanBodyPoseRequest`
  - Returns 19 body skeleton keypoints (shoulders, elbows, wrists, hips, knees, ankles, etc.)
  - Use case: fitness posture analysis, gesture recognition

- [ ] **Hand Pose** *(macOS 11+)* — `VNDetectHumanHandPoseRequest`
  - Returns 21 hand keypoints (4 joints per finger + wrist)
  - Use case: hand gesture recognition, sign language detection

- [ ] **Animal Body Pose** *(macOS 14+)* — `VNDetectAnimalBodyPoseRequest`
  - Returns skeleton keypoints for animals (cats, dogs)
  - Use case: animal behavior analysis, veterinary apps

## Contributing

Contributions are welcome! If you have suggestions for features or encounter issues, feel free to submit an issue or pull request.
