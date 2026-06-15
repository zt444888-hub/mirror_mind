import plistlib
import re
import os

# 1. 删除 storyboard 文件
storyboard = "ios/Runner/Base.lproj/LaunchScreen.storyboard"
if os.path.exists(storyboard):
    os.remove(storyboard)
    print("✅ 删除 LaunchScreen.storyboard")

# 2. 从 Info.plist 移除 UILaunchStoryboardName
plist_path = "ios/Runner/Info.plist"
with open(plist_path, 'rb') as f:
    plist = plistlib.load(f)

plist.pop('UILaunchStoryboardName', None)
plist.pop('UILaunchStoryboard~ipad', None)

with open(plist_path, 'wb') as f:
    plistlib.dump(plist, f)
print("✅ Info.plist 已更新")

# 3. 从 project.pbxproj 移除 LaunchScreen 文件引用
pbxproj_path = "ios/Runner.xcodeproj/project.pbxproj"
with open(pbxproj_path, 'r') as f:
    content = f.read()

# 移除所有包含 LaunchScreen 的行（包括文件引用、构建文件、资源拷贝引用）
lines = content.split('\n')
filtered = [l for l in lines if 'LaunchScreen' not in l and 'launchScreen' not in l]
new_content = '\n'.join(filtered)

with open(pbxproj_path, 'w') as f:
    f.write(new_content)
print("✅ project.pbxproj 已清理 LaunchScreen 引用")

# 4. 验证
os.system('plutil -lint ios/Runner/Info.plist')
print("✅ 修复完成，可以运行 flutter run")
