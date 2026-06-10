#!/usr/bin/env pwsh
# 心镜 MirrorMind 真机测试脚本
# 使用方法: .\run_device_test.ps1

param(
    [string]$Platform = "all",  # ios, android, all
    [switch]$Verbose
)

$ErrorActionPreference = "Continue"

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "       心镜 MirrorMind 真机测试脚本" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 获取脚本目录
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = $ScriptDir

# 1. 检查 Flutter 环境
Write-Host "[1/6] 检查 Flutter 环境..." -ForegroundColor Yellow
try {
    $flutterVersion = flutter --version 2>&1 | Select-Object -First 1
    Write-Host "  ✓ Flutter 版本: $flutterVersion" -ForegroundColor Green
} catch {
    Write-Host "  ✗ Flutter 未安装或未配置" -ForegroundColor Red
    Write-Host "  请先安装 Flutter: https://flutter.dev/docs/get-started/install" -ForegroundColor Yellow
    exit 1
}

# 2. 获取可用设备
Write-Host ""
Write-Host "[2/6] 检查可用设备..." -ForegroundColor Yellow
$devices = flutter devices 2>&1
Write-Host $devices

# 3. 获取依赖状态
Write-Host ""
Write-Host "[3/6] 检查项目依赖..." -ForegroundColor Yellow
flutter pub get

# 4. 代码分析
Write-Host ""
Write-Host "[4/6] 运行代码分析..." -ForegroundColor Yellow
flutter analyze --no-fatal-infos

# 5. 构建测试
Write-Host ""
Write-Host "[5/6] 构建测试..." -ForegroundColor Yellow

if ($Platform -eq "ios" -or $Platform -eq "all") {
    Write-Host ""
    Write-Host "=== iOS 构建 ===" -ForegroundColor Magenta
    Write-Host "检查 Xcode 是否可用..."
    try {
        $xcodeVersion = xcodebuild -version 2>&1 | Select-Object -First 1
        Write-Host "  ✓ Xcode: $xcodeVersion" -ForegroundColor Green
        Write-Host ""
        Write-Host "iOS 模拟器构建命令:" -ForegroundColor Cyan
        Write-Host "  flutter build ios --simulator --no-codesign" -ForegroundColor White
    } catch {
        Write-Host "  ⚠ Xcode 未安装或不可用 (macOS only)" -ForegroundColor Yellow
    }
}

if ($Platform -eq "android" -or $Platform -eq "all") {
    Write-Host ""
    Write-Host "=== Android 构建 ===" -ForegroundColor Magenta
    Write-Host "检查 Android SDK..."
    try {
        $adbVersion = adb version 2>&1 | Select-Object -First 1
        Write-Host "  ✓ ADB: $adbVersion" -ForegroundColor Green
    } catch {
        Write-Host "  ⚠ Android SDK 不可用" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "Android APK 构建命令:" -ForegroundColor Cyan
    Write-Host "  flutter build apk --debug" -ForegroundColor White
    Write-Host ""
    Write-Host "Android AAB 构建命令 (上架用):" -ForegroundColor Cyan
    Write-Host "  flutter build appbundle --release" -ForegroundColor White
}

# 6. 测试说明
Write-Host ""
Write-Host "[6/6] 测试说明..." -ForegroundColor Yellow
Write-Host ""
Write-Host "运行测试:" -ForegroundColor Cyan
Write-Host "  1. iOS 真机/模拟器测试:" -ForegroundColor White
Write-Host "     flutter run -d <device_id>" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Android 真机/模拟器测试:" -ForegroundColor White
Write-Host "     flutter run -d <device_id>" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. 查看详细测试用例:" -ForegroundColor White
Write-Host "     打开 test/DEVICE_TEST_CASES.md" -ForegroundColor Gray
Write-Host ""

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "                   检查完成" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# 询问是否启动应用
$response = Read-Host "是否立即运行应用? (Y/N)"
if ($response -eq "Y" -or $response -eq "y") {
    Write-Host ""
    Write-Host "启动应用..." -ForegroundColor Green
    flutter run
}

exit 0
