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
- ~~**Image Classification**: Use Vision framework for image classification.~~
- ~~**Object Detection**: Detect objects and facial features within images.~~
- ~~**Barcode/QR Code Recognition**: Scan and decode barcodes and QR codes in images.~~

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

   This will start the local server, which will listen on `http://localhost:8080` by default.

### Using the API

Once the server is running, you can send HTTP requests to interact with the API.

For more API detail visit: http://localhost:8080/Swagger/index.html

## TODO
- [ ] Text Area Recognition
- [ ] Image Classification
- [ ] Face and body detection
- [ ] Barcode detection
- [ ] Image aesthetics analysis
- [ ] Animal detection
- [ ] Background removal

## Contributing

Contributions are welcome! If you have suggestions for features or encounter issues, feel free to submit an issue or pull request.