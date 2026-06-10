---
AIGC:
    Label: "1"
    ContentProducer: 001191440300708461136T1XGW3
    ProduceID: a1428f9e380f25ab60aa2f5b56bbe916_944c4623625c11f1832e5254006c9bbf
    ReservedCode1: nGltS7nNfBlYK99KCz9J7jODYk8oD5fzwjhpEvR4vt/vqsBbUmOxqAMMElJVz8Q6jNeSFXRPdx8+MpFkSpOnubdi85iQ5G8iowEeQF5LutGrWD64dGmLklMsHGRNrhiwJjw9LPxT/RsqIYDzMQQeGf9o+BSOLlUrOa+ABMuB2/oXTh9ux6iUUY3CFyQ=
    ContentPropagator: 001191440300708461136T1XGW3
    PropagateID: a1428f9e380f25ab60aa2f5b56bbe916_944c4623625c11f1832e5254006c9bbf
    ReservedCode2: nGltS7nNfBlYK99KCz9J7jODYk8oD5fzwjhpEvR4vt/vqsBbUmOxqAMMElJVz8Q6jNeSFXRPdx8+MpFkSpOnubdi85iQ5G8iowEeQF5LutGrWD64dGmLklMsHGRNrhiwJjw9LPxT/RsqIYDzMQQeGf9o+BSOLlUrOa+ABMuB2/oXTh9ux6iUUY3CFyQ=
---



# 心镜 MirrorMind 构建与部署指南

> 版本：1.0.0 | 更新日期：2026年6月7日

---

## 一、环境要求

| 工具 | 版本要求 | 说明 |
|---|---|---|
| Flutter SDK | 3.x（推荐 3.22+） | 使用 `flutter --version` 检查 |
| Dart SDK | 3.x | 随 Flutter SDK 附带 |
| Android Studio | Hedgehog (2023.1) 或更高 | 含 Android SDK 34+ |
| Xcode | 15.0 或更高 | 含 iOS 17 SDK（仅 macOS） |
| Java JDK | 17（推荐） | Android 编译必需 |

验证环境：
```bash
flutter doctor
```

确保所有检查项显示绿色勾号。

---

## 二、依赖安装

在项目根目录执行：

```bash
flutter pub get
```

项目依赖清单（`pubspec.yaml`）：

| 依赖 | 用途 |
|---|---|
| `provider` | 状态管理 |
| `sqflite` | SQLite 本地数据库 |
| `path` / `path_provider` | 文件路径处理 |
| `intl` | 日期格式化 |
| `shared_preferences` | 键值对本地存储 |
| `fl_chart` | 情绪趋势折线图 |
| `url_launcher` | 危机热线拨号 |
| `flutter_local_notifications` | 本地通知推送 |
| `pdf` / `printing` | PDF 报告生成 |
| `share_plus` | 心情卡片分享 |
| `timezone` | 时区处理 |
| `in_app_purchase` | 应用内购买（Pro） |
| `speech_to_text` | 语音输入 |
| `encrypt` | 数据库加密 |
| `permission_handler` | 权限管理 |
| `http` | AI API 通信 |
| `cupertino_icons` | iOS 风格图标（可选） |

---

## 三、项目结构

```
mirror_mind/
├── lib/
│   ├── main.dart                    # 入口文件
│   ├── app.dart                     # 路由配置（15 条路由）
│   ├── constants/
│   │   ├── colors.dart              # 莫兰迪色系定义
│   │   ├── cards.dart               # 认知卡片数据（20 基础 + 48 Pro）
│   │   └── emotions.dart            # 60+ 情绪词汇 + TagType 枚举
│   ├── models/
│   │   └── emotion_record.dart      # EmotionRecord 数据模型
│   ├── services/
│   │   ├── database_service.dart    # SQLite 加密存储服务
│   │   ├── ai_service.dart          # AI 情绪分析服务
│   │   ├── speech_service.dart      # 语音识别服务
│   │   ├── pdf_service.dart         # PDF 报告生成
│   │   ├── notification_service.dart # 本地通知服务
│   │   └── purchase_service.dart    # IAP 购买服务
│   ├── providers/
│   │   ├── emotion_provider.dart    # 情绪状态管理
│   │   └── settings_provider.dart   # 设置状态管理
│   ├── screens/                     # 16 个页面（详见目录）
│   └── widgets/                     # 7 个自定义组件
├── assets/                          # 静态资源
├── android/                         # Android 原生配置
├── ios/                             # iOS 原生配置
├── pubspec.yaml                     # 项目配置
├── analysis_options.yaml            # Dart 代码规范
├── STORE_LISTING.md                 # 商店描述
├── PRIVACY_POLICY.md                # 隐私政策
├── SCREENSHOTS_GUIDE.md             # 截图指南
└── BUILD_AND_DEPLOY.md              # 本文档
```

---

## 四、iOS 配置

### 4.1 签名配置

1. 在 Xcode 中打开 `ios/Runner.xcworkspace`
2. 选择 Runner target → Signing & Capabilities
3. 选择你的开发团队（Team）
4. 确保 Bundle Identifier 唯一（如 `com.yourcompany.mirrormind`）
5. 勾选 "Automatically manage signing"

### 4.2 权限配置

在 `ios/Runner/Info.plist` 中确认以下权限已配置：

```xml
<key>NSMicrophoneUsageDescription</key>
<string>心镜需要访问麦克风以进行语音情绪记录</string>
```

### 4.3 IAP 产品 ID 配置

1. 在 [App Store Connect](https://appstoreconnect.apple.com) → 你的 App → 功能 → App 内购买项目
2. 点击"+"创建新的内购买项目
3. 选择类型：**非消耗型项目**
4. 产品 ID：`mirror_mind_pro`
5. 参考名称：心镜 Pro（一次性买断）
6. 价格：¥68
7. 审核信息：上传审核截图（Pro 功能页面截图）
8. 状态设为"准备提交"

### 4.4 Capabilities 确认

在 Xcode → Signing & Capabilities 中确认：
- [x] In-App Purchase

---

## 五、Android 配置

### 5.1 签名配置

创建签名密钥（若首次配置）：

```bash
keytool -genkey -v -keystore ~/mirror-mind-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias mirror-mind-key
```

在 `android/key.properties` 中配置（此文件不提交至版本控制）：

```properties
storePassword=<你的密钥库密码>
keyPassword=<你的密钥密码>
keyAlias=mirror-mind-key
storeFile=<密钥库文件路径>
```

### 5.2 应用 ID 配置

修改 `android/app/build.gradle` 中的 `applicationId` 为你自己的包名：

```groovy
android {
    defaultConfig {
        applicationId "com.yourcompany.mirror_mind"
    }
}
```

### 5.3 权限配置

`android/app/src/main/AndroidManifest.xml` 中已配置以下权限：

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="com.android.vending.BILLING" />
```

### 5.4 Google Play Billing 配置

1. 在 [Google Play Console](https://play.google.com/console) → 你的应用 → 获利 → 应用内商品
2. 点击"创建商品"
3. 产品 ID：`mirror_mind_pro`
4. 商品类型：**非消耗型**
5. 价格：¥68
6. 状态：设为"有效"

---

## 六、构建命令

### 6.1 调试构建

```bash
# iOS 模拟器
flutter run

# Android 模拟器/设备
flutter run

# 指定设备
flutter devices                # 列出可用设备
flutter run -d <device_id>     # 指定设备运行
```

### 6.2 测试

```bash
# 单元测试
flutter test

# 特定文件测试
flutter test test/emotion_provider_test.dart
```

### 6.3 生产构建

```bash
# iOS（需在 macOS 上执行）
flutter build ios --release

# iOS Archive（用于上传 App Store）
flutter build ipa

# Android APK（直接安装）
flutter build apk --release

# Android App Bundle（上传 Google Play，推荐）
flutter build appbundle --release
```

输出文件位置：

| 构建命令 | 输出路径 |
|---|---|
| `flutter build ios --release` | `build/ios/iphoneos/Runner.app` |
| `flutter build ipa` | `build/ios/ipa/` |
| `flutter build apk --release` | `build/app/outputs/flutter-apk/app-release.apk` |
| `flutter build appbundle --release` | `build/app/outputs/bundle/release/app-release.aab` |

---

## 七、上架流程

### 7.1 通用准备

在上架前确认以下材料已就绪：

- [ ] `STORE_LISTING.md` — 商店描述文案
- [ ] `PRIVACY_POLICY.md` — 隐私政策（需可公开访问的 URL 或嵌入应用内）
- [ ] `SCREENSHOTS_GUIDE.md` — 截图已按规格制作完成
- [ ] 应用图标（1024 × 1024 PNG，无 alpha 通道）
- [ ] 功能演示视频（可选，推荐 30 秒）

### 7.2 App Store Connect 提审

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 创建新 App → 填写基本信息
3. 在"App 信息"中填写隐私政策 URL
4. 上传截图（按 SCREENSHOTS_GUIDE.md 规格）
5. 在"App 内购买项目"中确认 `mirror_mind_pro` 已提交审核
6. 使用 Xcode → Product → Archive → Distribute App 上传构建包
7. 在"构建版本"中选择已上传的版本
8. 填写"App 审核信息"（演示账号等，若需要）
9. 提交审核

### 7.3 Google Play Console 发布

1. 登录 [Google Play Console](https://play.google.com/console)
2. 创建应用 → 填写基本信息
3. 在"政策 → 应用内容"中填写隐私政策
4. 上传截图（按 SCREENSHOTS_GUIDE.md 规格）
5. 在"获利 → 应用内商品"中确认 `mirror_mind_pro` 已创建并激活
6. 在"发布 → 正式版"中创建新版本
7. 上传 `.aab` 文件
8. 填写版本说明
9. 提交审核

---

## 八、常见问题

### 8.1 IAP 沙盒测试

**问题：购买测试时提示"无法连接到 iTunes Store"**

- 确认在 iOS 设备上已退出 Apple ID（设置 → App Store → 退出登录）
- 在 Sandbox 测试中使用测试 Apple ID 登录（不要使用生产 Apple ID）
- 在 App Store Connect → 用户和访问 → Sandbox 测试员中创建测试账号

**问题：Android 测试购买失败**

- 确认测试账号已添加到 Google Play Console → 设置 → 许可测试人员
- 测试 APK 需与 Google Play 上正式版本的签名一致
- 使用 `flutter build apk --release` 构建测试包

### 8.2 通知权限

**问题：iOS 通知不弹出**

- 确认 `flutter_local_notifications` 已正确初始化（`main.dart` 中已配置）
- 检查 iPhone 设置 → 心镜 → 通知是否已开启
- 首次启动时系统会弹出通知授权请求

### 8.3 数据库迁移

**问题：更新版本后数据库崩溃**

SQLite 数据库在 `database_service.dart` 中管理。若需要修改数据库表结构：

1. 在 `openDatabase` 的 `version` 参数中递增版本号
2. 在 `onUpgrade` 回调中编写迁移逻辑
3. 确保向下兼容：旧数据在新表结构中可正常读取
4. 当前版本：v1（2026年6月）

```dart
// database_service.dart 示例
final db = await openDatabase(
  path,
  version: 2,  // 从 1 升级到 2
  onCreate: (db, version) { /* ... */ },
  onUpgrade: (db, oldVersion, newVersion) {
    if (oldVersion < 2) {
      // 迁移逻辑
    }
  },
);
```

### 8.4 AI API 配置

AI 情绪分析服务（`ai_service.dart`）使用外部 AI API。部署前需确认：

- API 密钥已正确配置（建议通过环境变量或安全存储注入，不要硬编码）
- API 端点 URL 在生产环境中指向正式服务地址
- 确保 API 调用在 `try-catch` 块中，超时设置合理（当前默认 15 秒）

### 8.5 iOS 构建失败（M1/M2/M3 Mac）

```bash
# 排除 CocoaPods 缓存问题
cd ios && pod deintegrate && pod install && cd ..

# Rosetta 模式下运行（Intel 原生 iOS 依赖需要）
sudo arch -x86_64 gem install ffi
arch -x86_64 pod install
```

### 8.6 Android 构建失败

```bash
# 清理并重新构建
flutter clean
flutter pub get
cd android && ./gradlew clean && cd ..
flutter build apk --release
```

---

## 九、版本号规范

### 当前版本：1.0.0

版本号遵循语义化版本（SemVer）：

| 位置 | 格式 | 示例 |
|---|---|---|
| `pubspec.yaml` | `version: 1.0.0+1` | 版本名 + 构建号 |
| App Store Connect | `1.0.0` | 仅版本名 |
| Google Play Console | `1.0.0 (1)` | 版本名（构建号） |

**版本递增规则**：
- **主版本号**（Major）：重大功能变更或不兼容 API 改动
- **次版本号**（Minor）：新增功能，向下兼容
- **修订号**（Patch）：Bug 修复，向下兼容
- **构建号**（Build）：每次上传递增 +1

### 更新步骤

1. 修改 `pubspec.yaml` 中的 `version`
2. 创建 Git tag：`git tag -a v1.0.0 -m "首次发布"`
3. 构建并上传

---

## 十一、原生平台工程重建

当前项目 `android/` 和 `ios/` 目录可能为空或缺失，使用以下命令重建：

```bash
cd mirror_mind
flutter create --project-name mirror_mind .
```

该命令会：
- 生成 `android/` 目录（含 `build.gradle`、`AndroidManifest.xml`、Gradle wrapper）
- 生成 `ios/` 目录（含 Xcode 工程、`Info.plist`、Podfile）
- 覆盖 `pubspec.yaml` 以外的同名文件（建议先备份已有配置）

重建后需要重新配置签名和权限。

---

## 十二、Android 权限配置

在 `android/app/src/main/AndroidManifest.xml` 中补充以下权限声明：

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.mirrormind.app">

    <!-- 网络权限（AI API 调用必须） -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- 麦克风权限（语音输入） -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />

    <!-- 通知权限（Android 13+ 运行时请求已由代码实现） -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />

    <application
        android:label="心镜"
        android:icon="@mipmap/ic_launcher">
        ...
    </application>
</manifest>
```

在 `android/app/build.gradle` 中确认：

```gradle
android {
    defaultConfig {
        applicationId "com.mirrormind.app"
        minSdkVersion 26   // Android 8.0，需 ≥ 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
    signingConfigs {
        release {
            storeFile file("keystore.jks")
            storePassword System.getenv("KEYSTORE_PASSWORD")
            keyAlias System.getenv("KEY_ALIAS")
            keyPassword System.getenv("KEY_PASSWORD")
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 十三、iOS 权限配置

在 `ios/Runner/Info.plist` 中补充以下权限描述：

```xml
<key>NSMicrophoneUsageDescription</key>
<string>心镜需要访问麦克风以使用语音输入功能记录情绪</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>心镜需要访问相册以导出心情卡片和PDF报告</string>

<key>UIBackgroundModes</key>
<array>
    <string>audio</string>
</array>
```

> macOS 配置：在 `macos/Runner/Info.plist` 中同样添加 `NSMicrophoneUsageDescription`。

在 Xcode 中（`ios/Runner.xcworkspace`）确认：
- **Bundle Identifier**：`com.mirrormind.app`
- **Team**：与 Apple Developer 账号绑定
- **Signing**：勾选 "Automatically manage signing"

---

## 十四、应用图标制作

### 规格
| 项目 | 要求 |
|---|---|
| 尺寸 | 1024 × 1024 px |
| 格式 | PNG（无透明通道） |
| 色彩 | 莫兰迪色系（低饱和度柔和色调） |
| 风格 | 建议以镜面/反射为视觉隐喻，结合柔和渐变 |

### 放置路径
```
assets/icons/app_icon.png   # 1024×1024 原图
```

使用 `flutter_launcher_icons` 自动生成各平台图标：

1. 在 `pubspec.yaml` 的 `dev_dependencies` 中添加：
   ```yaml
   flutter_launcher_icons: ^0.14.1
   ```

2. 在 `pubspec.yaml` 同级添加配置：
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: true
     image_path: "assets/icons/app_icon.png"
   ```

3. 执行生成：
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   ```

---

## 十五、隐私政策托管

Apple App Store 和 Google Play Console 均要求提供**可公开访问的隐私政策 URL**。

**当前隐私政策 URL**：`https://zt444888-hub.github.io/mirrormind-privacy/`

> 如需要自行托管，推荐方案（免费）：
> 1. 创建 GitHub 仓库 `mirrormind-privacy`
> 2. 将 `PRIVACY_POLICY.md` 重命名为 `index.md` 放入仓库
> 3. 在仓库 Settings → Pages 中启用 GitHub Pages
> 4. 获得 URL：`https://<username>.github.io/mirrormind-privacy/`

---

## 十六、App Store Connect — 创建 IAP Product ID

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 进入 App → 功能 → App 内购买项目
3. 点击 "+" 创建：
   - **类型**：非消耗型项目
   - **参考名称**：心镜 Pro 永久买断
   - **产品 ID**：`mirror_mind_pro`
   - **价格**：¥68（中国大陆 Tier 可自定）
   - **审核信息**：上传截图证明购买后解锁 6 种冥想/68 张卡片/PDF 报告
4. 保存后等待审核状态变为"已批准"

---

## 十七、Google Play Console — IARC 评级

Google Play 强制要求所有应用完成 IARC 内容评级问卷。

1. 登录 [Google Play Console](https://play.google.com/console)
2. 进入应用 → 政策 → 应用内容 → 内容分级
3. 点击"开始问卷"
4. 填写选项参考：

| 问卷类别 | 答案 |
|---|---|
| **社交与用户生成内容** | 是（用户可记录和保存日记文字内容） |
| **健康与保健信息** | 是（应用提供情绪健康相关内容，如情绪分析、认知卡片） |
| **用户交互** | 是（用户可输入日记文字） |
| **地理位置** | 否 |
| **广告** | 否（Pro 版去广告；免费版可能含广告） |

完成问卷后系统自动评定分级（预计结果为 12+ 或 Teen）。

---

## 十八、快速检查清单

发布前逐一确认：

- [ ] `flutter analyze` 无新增错误
- [ ] `flutter test` 全部通过
- [ ] iOS 构建成功：`flutter build ipa`
- [ ] Android 构建成功：`flutter build appbundle --release`
- [ ] IAP 产品 ID `mirror_mind_pro` 已在 App Store Connect 和 Google Play Console 配置
- [ ] 隐私政策 URL 已配置
- [ ] 所有截图已按规范制作（至少 3 套 iOS + 2 套 Android）
- [ ] 应用图标已替换为正式图标
- [ ] Bundle ID / Application ID 与开发者账号一致
- [ ] `STORE_LISTING.md` 文案已翻译/录入对应商店后台
*（内容由AI生成，仅供参考）*
*（内容由AI生成，仅供参考）*
