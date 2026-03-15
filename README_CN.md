<div align="center">

[English](README.md) | 中文

# 🔍 Vision API

**Apple 设备端 ML 能力，封装为简洁的 REST API —— 本地自托管，零云服务，零成本。**

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Vapor](https://img.shields.io/badge/Vapor-4-blue.svg)](https://vapor.codes)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)](https://developer.apple.com/macos/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

</div>

---

> 不要再为本可在自己 Mac 上免费运行的图像智能服务按调用次数付费了。

**Vision API** 是一款面向开发者的工具，可将你的 Mac 变成一台私有的图像智能服务器。它封装了 Apple 原生的 [Vision 框架](https://developer.apple.com/documentation/vision/) —— 正是驱动 macOS 照片、实况文本和快捷指令的同款 ML 引擎 —— 并将其能力以标准 HTTP/JSON API 的形式对外暴露。这些模型已内置于你的 Mac；本项目只是为它们提供一个网络接口。

预期使用场景为**本地或内网自托管**：在你自己控制的 Mac 上运行，从你的应用、脚本或 CI 流水线中调用，无需接触任何第三方云服务。部署到任意 Mac，调用端点，获取结果。无需 API 密钥，无使用限制，图像数据不离开你的机器。

专为独立开发者和小型团队打造，让你在不承担云账单、不牺牲隐私的前提下获得生产级图像分析能力。

```bash
# 三条命令，从零到运行：
git clone https://github.com/tdawn0-0/vision-api && cd vision-api
swift package resolve
swift run App
# → 服务已启动，访问 http://localhost:9493
```

---

## ✨ 功能概览

| 功能 | 端点说明 | macOS 要求 |
|---|---|---|
| 📄 **OCR / 文字识别** | 从任意图像中提取印刷体与手写文字 | 10.15+ |
| ✂️ **背景移除** | 像素级精准主体抠图，完美去除背景 | 12+ |
| 🎨 **美学评分** | 评估照片质量（模糊、曝光、构图），并识别功能性图像 | 15+ |
| 🏷️ **自动标签 / 分类** | 获取 1000+ 语义标签（`狗`、`海滩`、`食物`）及置信度分数 | 10.15+ |

> 📖 服务启动后，可在 `http://localhost:9493/Swagger/index.html` 访问交互式 API 文档。

**相比云端 API 的优势：**
- 🔒 **私密** —— 图像数据永不离开你的机器
- ⚡ **快速** —— 无网络往返延迟，直接运行于 Apple 神经网络引擎
- 💸 **免费** —— 无按次计费，无订阅费用
- 🧩 **简单** —— `multipart/form-data` 上传，JSON 响应，一步到位

---

## 🚀 快速开始

### 前置条件

- macOS（必须 —— Vision 框架仅支持 Apple 平台）
- Swift 工具链（随 Xcode 附带，或从 [swift.org](https://swift.org/download/) 下载）

### 安装步骤

**1. 克隆仓库并安装依赖：**

```bash
git clone https://github.com/tdawn0-0/vision-api
cd vision-api
swift package resolve
```

**2. 启动服务器：**

```bash
swift run App
```

服务器默认在 `http://localhost:9493` 启动。所有图像端点均接受带有二进制 `imageFile` 字段的 `multipart/form-data` 请求。

**自定义端口** —— 三种方式，优先级由高到低：

```bash
# CLI 参数
swift run App serve --port 9493

# 环境变量
PORT=9493 swift run App
```

### 快速体验

服务启动后，打开 Swagger UI 查看交互式文档并进行在线测试：

```
http://localhost:9493/Swagger/index.html
```

或在终端发送一个快速请求：

```bash
curl -X POST http://localhost:9493/ocr \
  -F "imageFile=@/path/to/image.png"
```

---

## 🗺️ 路线图

### 已上线功能

- [x] **文字识别（OCR）** —— `VNRecognizeTextRequest`
- [x] **背景移除** —— `VNGenerateForegroundInstanceMaskRequest`
- [x] **图像美学评分** *(macOS 15+)* —— `CalculateImageAestheticsScoresRequest`
  - `overallScore`（-1 到 1）：模糊、曝光、色彩平衡、构图
  - `isUtility`：区分艺术照片与截图 / 收据 / 文档
- [x] **图像分类 / 自动标签** *(macOS 10.15+)* —— `VNClassifyImageRequest`
  - 1000+ 类别标签，支持可选的 `confidenceThreshold` 和 `maxResults` 过滤
- [x] **条码 & 二维码识别** *(macOS 10.13+)* —— 支持 QR、EAN-13、Code128、DataMatrix 等
  - 返回 `payload` 和 `symbology`（例如 `VNBarcodeSymbologyQR`）

### 即将推出

- [ ] **显著性热图 / 智能裁剪** *(macOS 10.15+)* —— 基于注意力与目标性的裁剪建议
- [ ] **图像相似度** *(macOS 10.15+)* —— 特征向量对比，用于以图搜图和去重
- [ ] **人脸检测与关键点** *(macOS 10.13+)* —— 边界框 + 68 个面部关键点
- [ ] **人脸采集质量评估** *(macOS 10.15+)* —— 0–1 质量分，用于证件照校验
- [ ] **文档扫描** *(macOS 12+)* —— 角点检测 + 透视校正
- [ ] **人体 / 动物检测** *(macOS 10.15+)* —— 人物与宠物的边界框
- [ ] **身体与手部姿态** *(macOS 11+)* —— 19 点身体骨架，21 点手部关键点
- [ ] **动物身体姿态** *(macOS 14+)* —— 猫狗骨架关键点

请参阅完整的 [Vision 框架能力列表](https://developer.apple.com/documentation/vision/) 了解更多规划中的功能。

---

## ⚖️ 法律声明

> **在任何商业或生产环境中部署 Vision API 之前，请务必阅读本节内容。**

本项目调用了 macOS 系统框架（主要为 [Apple Vision](https://developer.apple.com/documentation/vision/)），这些框架以 macOS 操作系统的组成部分进行授权许可。请注意以下几点：

- **个人及开发用途** —— 在自己的 Mac 上用于个人项目或内部工具是完全合理且符合预期使用场景的。
- **商业 SaaS / 托管服务** —— 若你计划将 Vision API 集成到付费产品中、向外部用户开放，或以此为基础构建商业产品，你有责任确保其使用符合 Apple 的 [macOS 软件许可协议](https://www.apple.com/legal/sla/)、所在司法管辖区的法律法规以及相关出口管制规定。
- **数据与隐私** —— Vision API 在设计上于本地处理图像，但若你将其部署在共享或面向公网的服务器上，你须自行承担适用于所处理图像数据的隐私合规义务（如 GDPR、CCPA 等）。
- **免责声明** —— 本项目依据 MIT 许可证按现状提供，作者不对其适用于任何特定用途作出任何保证。

**本项目维护者对因使用 Vision API 而产生的任何法律、监管或商业后果不承担任何责任。商业用途风险自负。**

---

## 🤝 参与贡献

欢迎一切形式的贡献 —— 新端点、Bug 修复、文档改进或想法建议。欢迎提 Issue 进行讨论，或直接提交 Pull Request。
```

Now let me add the link in the original README: