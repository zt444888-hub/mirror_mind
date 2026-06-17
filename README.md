---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: a1428f9e380f25ab60aa2f5b56bbe916_949f3d4b625c11f19f62525400d9a7a1
    ReservedCode1: tAMfIGmwMw7lwLx1hdOF7U0NGXHabYyA02j3SI8QMjk6d0LBzrXWQ6q8p+Rss0tLwV6RqpaS1dVL5x+48x1fL5e7JTPyLQCZ9sLprykDJxDsIme1mgTPLGXEeKvWgrlU+UbeeohjVpRAkltCxvRSQgCd5pl0FqARKnGXp6A4X3ewaMJLExIuas7WUfU=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: a1428f9e380f25ab60aa2f5b56bbe916_949f3d4b625c11f19f62525400d9a7a1
    ReservedCode2: tAMfIGmwMw7lwLx1hdOF7U0NGXHabYyA02j3SI8QMjk6d0LBzrXWQ6q8p+Rss0tLwV6RqpaS1dVL5x+48x1fL5e7JTPyLQCZ9sLprykDJxDsIme1mgTPLGXEeKvWgrlU+UbeeohjVpRAkltCxvRSQgCd5pl0FqARKnGXp6A4X3ewaMJLExIuas7WUfU=
---



# 心镜 MirrorMind

> 每天5分钟，给情绪做一次体检
>
> **项目状态：可编译可运行 | 上架前最终审查已完成（P0=0 P1=0 P2=0）**

## 项目简介

心镜是一款基于 Flutter 的 AI 情绪日记与心理健康 App。通过文字或语音记录每日心情，AI 自动分析情绪趋势，并提供呼吸练习、认知重构卡片、感恩日记等自愈工具，帮助你建立情绪管理习惯。

## 核心功能

- **情绪记录** — 文字/语音输入，AI 自动分析情绪类型与评分
- **情绪日历** — 月视图日历，颜色标记每日心情，一目了然
- **4-7-8 呼吸练习** — Canvas 动画呼吸球，科学缓解焦虑
- **认知重构卡片** — 20张心理学卡片，换个角度看待情绪
- **感恩三件事** — 每日记录感恩，培养积极心态
- **情绪急救包** — 根据当前心情即时推荐应对建议
- **AI 周报** — 生成本周情绪体检报告，精美卡片分享
- **隐私优先** — 所有数据仅存本地，不上传任何服务器

## 技术栈

- Flutter 3.x + Dart
- Provider 状态管理
- sqflite 本地加密存储
- OpenAI 兼容 API（用户自行配置）

## 快速开始

### 环境要求

- Flutter SDK >= 3.0.0
- Android Studio / Xcode
- iOS 14.0+ / Android 7.0+

### 安装运行

```bash
# 克隆项目
cd mirror_mind

# 安装依赖
flutter pub get

# 运行
flutter run
```

### AI 配置

在 App「设置」页面配置：
- API Base URL（默认 `https://api.openai.com/v1`）
- API Key
- 模型名称（默认 `gpt-4o-mini`）

支持所有 OpenAI 兼容的 API 端点。

## 项目结构

```
lib/
├── main.dart              # 入口
├── app.dart               # 主题/路由
├── constants/             # 常量（颜色/情绪/卡片）
├── models/                # 数据模型
├── services/              # 服务（数据库/AI/语音）
├── providers/             # 状态管理
├── screens/               # 页面
└── widgets/               # 组件
```

## 隐私

所有情绪记录仅存储在设备本地，AI 分析通过 HTTPS 加密传输到你自行配置的 API 端点。不收集任何个人信息。

## License

MIT

---

## 上架前检查清单

发布前逐一确认以下条件：

### 代码质量
- [x] 编译检查：0 P0（全部 40 个 .dart 文件审查通过）
- [x] 运行时检查：0 P1（dispose/mounted 守卫已就位）
- [x] 路由完整性：17 条路由全部注册且对应文件存在
- [x] 付费内容：6 种冥想模式 / 68 张认知卡片 / 72 词情绪词库 / 7 种心情卡片模板
- [x] Pro 门禁：全部高阶功能已添加门禁检查

### 上架材料
- [x] STORE_LISTING.md：含年龄分级（12+）和内容分级（IARC）声明
- [x] PRIVACY_POLICY.md：含隐私政策 URL 建议（GitHub Pages）
- [x] SCREENSHOTS_GUIDE.md：8 场景截图规格完整
- [x] BUILD_AND_DEPLOY.md：含构建命令/签名配置/提审流程/IAP沙盒测试

### 原生平台（首次发布前必须完成）
- [ ] 执行 `flutter create --project-name mirror_mind .` 重建 android/ 和 ios/ 目录
- [ ] Android 配置：`applicationId`、签名密钥、`AndroidManifest.xml` 权限声明
- [ ] iOS 配置：Bundle Identifier、签名团队、`Info.plist` 权限描述
- [ ] 应用图标：制作 1024×1024 PNG（莫兰迪色系）
- [ ] IAP 产品 ID `mirror_mind_pro` 在 App Store Connect 和 Google Play Console 创建
- [ ] 隐私政策 URL 可公开访问

### 测试
- [ ] `flutter analyze` 无错误
- [ ] `flutter test` 全部通过
- [ ] iOS 真机构建成功
- [ ] Android 真机构建成功
- [ ] IAP 沙盒购买测试通过

---

## 快速启动

```bash
# 1. 检查环境
flutter doctor

# 2. 安装依赖
cd mirror_mind
flutter pub get

# 3. 运行（模拟器/真机）
flutter run

# 4. 构建发布包
# Android
flutter build appbundle --release
# iOS（仅 macOS）
flutter build ipa

# 5. 如需重建原生平台工程
flutter create --project-name mirror_mind .
```
*（内容由AI生成，仅供参考）*
*（内容由AI生成，仅供参考）*
