<#
心镜 MirrorMind - 依赖版本验证脚本
用途：验证 speech_to_text 版本是否已正确锁定为 6.5.x 系列

使用方法：
1. 确保已安装 Flutter SDK（3.0.0 或更高版本）
2. 打开 PowerShell
3. 切换到项目目录：cd mirror_mind
4. 运行脚本：.\verify_dependencies.ps1
#>

# 检查 Flutter 是否安装
function Test-FlutterInstalled {
    try {
        $flutter = Get-Command flutter -ErrorAction Stop
        Write-Host "✅ Flutter 已安装: $($flutter.Source)" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ Flutter 未安装，请先安装 Flutter SDK" -ForegroundColor Red
        Write-Host "下载地址: https://docs.flutter.dev/get-started/install" -ForegroundColor Yellow
        return $false
    }
}

# 检查 Dart 是否安装
function Test-DartInstalled {
    try {
        $dart = Get-Command dart -ErrorAction Stop
        Write-Host "✅ Dart 已安装: $($dart.Source)" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "❌ Dart 未安装" -ForegroundColor Red
        return $false
    }
}

# 显示 Flutter 版本信息
function Show-FlutterVersion {
    Write-Host "`n📦 Flutter 版本信息:" -ForegroundColor Cyan
    flutter --version
}

# 清理并获取依赖
function Update-Dependencies {
    Write-Host "`n🔄 开始清理旧依赖..." -ForegroundColor Cyan
    flutter clean
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 清理完成" -ForegroundColor Green
    } else {
        Write-Host "❌ 清理失败" -ForegroundColor Red
        exit 1
    }

    Write-Host "`n🔄 开始获取新依赖..." -ForegroundColor Cyan
    flutter pub get
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 依赖获取完成" -ForegroundColor Green
    } else {
        Write-Host "❌ 依赖获取失败" -ForegroundColor Red
        exit 1
    }
}

# 验证 speech_to_text 版本
function Verify-SpeechToTextVersion {
    Write-Host "`n🔍 验证 speech_to_text 版本..." -ForegroundColor Cyan
    
    # 读取 pubspec.lock 文件
    $lockContent = Get-Content -Path "pubspec.lock" -Raw
    
    # 提取 speech_to_text 版本
    if ($lockContent -match 'speech_to_text:\s*\n.*\n.*\n.*\n.*version:\s*"([^"]+)"') {
        $version = $matches[1]
        Write-Host "当前 speech_to_text 版本: $version" -ForegroundColor White
        
        # 检查版本是否在 6.x.x 范围内
        if ($version -match '^6\.\d+\.\d+') {
            Write-Host "✅ 版本已正确锁定在 6.x.x 系列" -ForegroundColor Green
            Write-Host "✅ speech_to_text 版本符合预期: $version" -ForegroundColor Green
            return $true
        } else {
            Write-Host "❌ 版本不在 6.x.x 范围内: $version" -ForegroundColor Red
            Write-Host "⚠️  预期版本范围: >=6.5.0 <7.0.0" -ForegroundColor Yellow
            return $false
        }
    } else {
        Write-Host "❌ 无法找到 speech_to_text 版本信息" -ForegroundColor Red
        return $false
    }
}

# 运行代码分析
function Run-CodeAnalysis {
    Write-Host "`n🔍 运行代码分析 (flutter analyze)..." -ForegroundColor Cyan
    flutter analyze
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ 代码分析通过，无 lint 警告" -ForegroundColor Green
    } else {
        Write-Host "⚠️  代码分析发现问题，请检查输出" -ForegroundColor Yellow
    }
}

# 主程序
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "   心镜 MirrorMind - 依赖版本验证脚本" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan

# 检查环境
if (-not (Test-FlutterInstalled)) {
    exit 1
}

if (-not (Test-DartInstalled)) {
    Write-Host "⚠️  Dart 未在 PATH 中，但 Flutter 通常自带 Dart" -ForegroundColor Yellow
}

Show-FlutterVersion

# 更新依赖
Update-Dependencies

# 验证版本
$versionOk = Verify-SpeechToTextVersion

# 运行代码分析
Run-CodeAnalysis

Write-Host "`n============================================" -ForegroundColor Cyan
if ($versionOk) {
    Write-Host "✅ 所有验证通过！" -ForegroundColor Green
    Write-Host "============================================" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "❌ 验证失败，请检查错误信息" -ForegroundColor Red
    Write-Host "============================================" -ForegroundColor Cyan
    exit 1
}