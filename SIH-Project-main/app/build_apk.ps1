# Sanchari Flutter Release APK Build Script
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "🚀 Building Sanchari Release APK..." -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# 1. Clean Flutter cache
Write-Host " Cleaning previous build artifacts..." -ForegroundColor Yellow
flutter clean

# 2. Get dependencies
Write-Host "📥 Fetching pub dependencies..." -ForegroundColor Yellow
flutter pub get

# 3. Build release APK
Write-Host "📦 Compiling release APK with tree-shaking..." -ForegroundColor Yellow
flutter build apk --release --split-per-abi

if ($LASTEXITCODE -eq 0) {
    Write-Host "====================================================" -ForegroundColor Green
    Write-Host "✅ Release APK compilation completed successfully!" -ForegroundColor Green
    Write-Host "📁 APK Output directory: build/app/outputs/flutter-apk/" -ForegroundColor Green
    Write-Host "====================================================" -ForegroundColor Green
} else {
    Write-Host "====================================================" -ForegroundColor Red
    Write-Host "❌ APK Compilation failed. Check console error logs." -ForegroundColor Red
    Write-Host "====================================================" -ForegroundColor Red
}
