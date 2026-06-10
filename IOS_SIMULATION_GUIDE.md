# iOS模拟环境使用指南

## 在Windows上模拟iOS开发

### 1. Web模拟（推荐）
```bash
# 运行Web版本模拟iOS界面
flutter run -d chrome

# 构建Web版本
flutter build web --release --web-renderer html
```

### 2. 使用Cupertino组件
确保在代码中使用iOS风格的Cupertino组件：
```dart
import 'package:flutter/cupertino.dart';

// 使用Cupertino组件
CupertinoApp(
  title: '心镜',
  theme: CupertinoThemeData(
    brightness: Brightness.light,
    primaryColor: CupertinoColors.systemBlue,
  ),
  home: MyHomePage(),
);
```

### 3. 远程iOS编译
使用GitHub Actions在云端编译iOS版本：
- 推送代码到GitHub仓库
- Actions会自动在macOS环境中编译iOS版本
- 下载编译产物进行测试

### 4. 权限配置
在`ios/Runner/Info.plist`中添加必要的权限声明：
```xml
<key>NSMicrophoneUsageDescription</key>
<string>心镜App需要使用麦克风进行语音日记记录</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>心镜App需要访问照片库来添加心情图片</string>
```

### 5. 测试建议
1. **UI测试**: 在Chrome中测试iOS风格UI
2. **功能测试**: 确保所有功能在Web版本中正常工作
3. **权限测试**: 模拟iOS权限请求流程
4. **通知测试**: 测试Web通知功能

### 6. 下一步
1. 获取Apple Developer账号
2. 在macOS真机或模拟器测试
3. 配置证书和配置文件
4. 提交App Store审核
