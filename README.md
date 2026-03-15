<div align="center">

[中文](README_CN.md) | English

# 🔍 Vision API

**Apple's on-device ML power, exposed as a clean REST API — self-hosted, zero cloud, zero cost.**

**Apple 设备端 ML 能力，封装为简洁的 REST API —— 本地自托管，零云服务，零成本。**

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Vapor](https://img.shields.io/badge/Vapor-4-blue.svg)](https://vapor.codes)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)](https://developer.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

> Stop paying per-API-call for image intelligence you can run for free on your own Mac.

**Vision API** is a developer tool that turns your Mac into a private image-intelligence server. It wraps Apple's native [Vision framework](https://developer.apple.com/documentation/vision/) — the same ML engine powering macOS Photos, Live Text, and Shortcuts — and exposes its capabilities as a plain HTTP/JSON API. Your Mac already has these models built in; this project just gives them a network interface.

The intended use case is **local or intranet self-hosting**: run it on a Mac you control, call it from your app, script, or CI pipeline, and never touch a third-party cloud service. Drop it on any Mac, hit an endpoint, get results. No API keys. No usage limits. No image data leaving your machine.

Built for indie developers and small teams who want production-quality image analysis without the cloud bill or the privacy trade-off.

```bash
# Three commands from zero to running:
git clone https://github.com/tdawn0-0/vision-api && cd vision-api
swift package resolve
swift run App
# → Server live at http://localhost:9493
```

---

## ✨ What It Can Do

| Feature | Endpoint | macOS |
|---|---|---|
| 📄 **OCR / Text Recognition** | Extract printed & handwritten text from any image | 10.15+ |
| ✂️ **Background Removal** | Remove backgrounds with pixel-perfect subject masking | 12+ |
| 🎨 **Aesthetics Scoring** | Score photo quality (blur, exposure, composition) and detect utility images | 15+ |
| 🏷️ **Auto Tagging / Classification** | Get 1000+ semantic labels (`dog`, `beach`, `food`) with confidence scores | 10.15+ |
| 🔳 **Barcode / QR Detection** | Detect & decode QR codes, EAN-13, and 20+ other formats | 10.13+ |

> 📖 Interactive API docs available at `http://localhost:9493/Swagger/index.html` once running.

**Why this beats a cloud API:**
- 🔒 **Private** — images never leave your machine
- ⚡ **Fast** — no network round-trip, runs on Apple Neural Engine
- 💸 **Free** — no per-call pricing, no subscription
- 🧩 **Simple** — `multipart/form-data` upload, JSON response, done

---

## 🚀 Getting Started

### Prerequisites

- macOS (required — Vision framework is Apple-only)
- Swift toolchain (comes with Xcode or [swift.org](https://swift.org/download/))

### Installation

**1. Clone & install dependencies:**

```bash
git clone https://github.com/tdawn0-0/vision-api
cd vision-api
swift package resolve
```

**2. Start the server:**

```bash
swift run App
```

The server starts on `http://localhost:9493` by default. All image endpoints accept `multipart/form-data` with a binary `imageFile` field.

**Custom port** — three ways, highest to lowest priority:

```bash
# CLI flag
swift run App serve --port 9493

# Environment variable
PORT=9493 swift run App
```

### Try It Out

Once running, open the Swagger UI for interactive docs and live testing:

```
http://localhost:9493/Swagger/index.html
```

Or send a quick request from the terminal:

```bash
curl -X POST http://localhost:9493/ocr \
  -F "imageFile=@/path/to/image.png"
```

---

## 🗺️ Roadmap

### Available Now

- [x] **Text Recognition (OCR)** — `VNRecognizeTextRequest`
- [x] **Background Removal** — `VNGenerateForegroundInstanceMaskRequest`
- [x] **Image Aesthetics Scoring** *(macOS 15+)* — `CalculateImageAestheticsScoresRequest`
  - `overallScore` (-1 to 1): blur, exposure, color balance, composition
  - `isUtility`: separates artistic photos from screenshots / receipts / documents
- [x] **Image Classification / Auto Tagging** *(macOS 10.15+)* — `VNClassifyImageRequest`
  - 1000+ category labels, optional `confidenceThreshold` and `maxResults` filters
- [x] **Barcode & QR Detection** *(macOS 10.13+)* — QR, EAN-13, Code128, DataMatrix, and more
  - Returns `payload` and `symbology` (e.g. `VNBarcodeSymbologyQR`)

### Coming Soon

- [ ] **Saliency Heatmap / Smart Crop** *(macOS 10.15+)* — attention & objectness-based cropping hints
- [ ] **Image Similarity** *(macOS 10.15+)* — feature vector comparison for reverse image search & dedup
- [ ] **Face Detection & Landmarks** *(macOS 10.13+)* — bounding boxes + 68-point facial keypoints
- [ ] **Face Capture Quality** *(macOS 10.15+)* — 0–1 quality score for ID photo validation
- [ ] **Document Scanner** *(macOS 12+)* — corner detection + perspective correction
- [ ] **Human / Animal Detection** *(macOS 10.15+)* — bounding boxes for people and pets
- [ ] **Body & Hand Pose** *(macOS 11+)* — 19-point body skeleton, 21-point hand keypoints
- [ ] **Animal Body Pose** *(macOS 14+)* — skeleton keypoints for cats & dogs

See the full [Vision framework capability list](https://developer.apple.com/documentation/vision/) for what's on the horizon.

---

## ⚖️ Legal Notice

> **Read this before deploying Vision API in any commercial or production context.**

This project calls macOS system frameworks (primarily [Apple Vision](https://developer.apple.com/documentation/vision/)) that are licensed as part of the macOS operating system. A few things to keep in mind:

- **Personal & development use** — running this on your own Mac for personal projects or internal tooling is straightforward and the intended use case.
- **Commercial SaaS / hosted service** — if you plan to wrap Vision API into a paid product, expose it to external users, or build a business around it, you are responsible for ensuring your use complies with Apple's [macOS Software License Agreement](https://www.apple.com/legal/sla/), your own jurisdiction's laws, and any relevant export regulations.
- **Data & privacy** — Vision API processes images locally by design, but if you deploy it on a shared or internet-facing server, you are responsible for any privacy obligations (GDPR, CCPA, etc.) that apply to the image data passing through it.
- **No warranty** — this project is provided as-is under the MIT license. The author(s) make no representations about fitness for any particular purpose.

**The maintainers of this project accept no liability for any legal, regulatory, or commercial consequences arising from your use of Vision API. Commercial use is at your own risk.**

---

## 🤝 Contributing

All contributions are welcome — new endpoints, bug fixes, docs, or ideas. Open an issue to discuss or submit a pull request directly.
