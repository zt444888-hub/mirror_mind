#!/bin/bash
# iOS模拟环境测试脚本

echo "1. 检查Flutter环境"
flutter --version

echo "2. 获取依赖"
flutter pub get

echo "3. 检查iOS项目"
cd ios
if [ -f "Podfile" ]; then
    echo "Podfile存在"
else
    echo "Podfile缺失"
fi

echo "4. 运行Web版本（模拟iOS）"
cd ..
flutter run -d chrome --web-port=8080

echo "5. 构建Web版本"
flutter build web --release --web-renderer html

echo "测试完成！"
