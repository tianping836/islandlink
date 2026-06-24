#!/usr/bin/env bash

PROJECT_NAME="IslandLink"

info()  { printf '\033[0;34m[INFO]\033[0m  %s\n' "$1"; }
ok()    { printf '\033[0;32m[OK]\033[0m    %s\n' "$1"; }
warn()  { printf '\033[1;33m[WARN]\033[0m  %s\n' "$1"; }
err()   { printf '\033[0;31m[ERROR]\033[0m %s\n' "$1"; }

echo ""
echo "═════════════════════════════════════"
echo "  屿连 IslandLink · 工程配置向导"
echo "═════════════════════════════════════"
echo ""

info "检查 Xcode..."
if ! command -v xcodebuild >/dev/null 2>&1; then
    err "未检测到 Xcode"
    exit 1
fi
XCODE_VERSION=$(xcodebuild -version 2>/dev/null | head -1 | awk '{print $2}')
info "Xcode 版本: $XCODE_VERSION"

echo ""
info "检查 XcodeGen..."
if ! command -v xcodegen >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1; then
        brew install xcodegen || { err "安装失败"; exit 1; }
    else
        err "请先安装 Homebrew: https://brew.sh"
        exit 1
    fi
else
    ok "XcodeGen 已安装"
fi

echo ""
info "创建目录..."
mkdir -p IslandLink/App IslandLink/Models IslandLink/Views
mkdir -p IslandLink/System IslandLink/Intents IslandLink/Resources
mkdir -p IslandLinkWidget
ok "目录已创建"

echo ""
info "生成 Widget Info.plist..."
cat > IslandLinkWidget/Info.plist << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
<key>CFBundleDisplayName</key>
<string>屿连 Widget</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
<key>CFBundleName</key>
<string>$(PRODUCT_NAME)</string>
<key>CFBundleShortVersionString</key>
<string>1.0</string>
<key>CFBundleVersion</key>
<string>1</string>
<key>NSExtension</key>
<dict>
>NSExtensionPointIdentifier</key>
g>com.apple.widgetkit-extension</string>
</dict>
<key>WKAppBundleIdentifier</key>
<string>com.youmind.islandlink</string>
</dict>
</plist>
PLIST
ok "Widget Info.plist 已生成"

echo ""
info "验证源文件..."
REQUIRED_FILES=(
    "IslandLink/App/IslandLinkApp.swift"
    "IslandLink/App/ContentView.swift"
    "IslandLink/Models/DataModel.swift"
    "IslandLink/DesignSystem.swift"
    "IslandLink/Views/PersonListView.swift"
    "IslandLink/Views/EventListView.swift"
    "IslandLink/Views/EventDetailView.swift"
    "IslandLink/Views/EventEditView.swift"
    "IslandLink/Views/SettingsView.swift"
    "IslandLink/System/CloudSyncObserver.swift"
    "IslandLink/System/HandoffManager.swift"
    "IslandLink/System/SpotlightIndexManager.swift"
    "IslandLink/Intents/AppIntents.swift"
    "IslandLinkWidget/IslandLinkWidget.swift"
    "IslandLinkWidget/TodayWidget.swift"
)

MISSING=()
for f in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$f" ]; then
        MISSING+=("$f")
    fi
done

if [ ${#MISSING[@]} -gt 0 ]; then
    warn "${#MISSING[@]}/15 个源文件缺失"
    for f in "${MISSING[@]}"; do
        echo "    📄 $f"
    done
    printf "  跳过缺失，继续生成 (y/N)? "
    read -r ANS
    case "$ANS" in
        [Yy]* ) warn "将跳过缺失文件" ;;
        * ) exit 0 ;;
    esac
else
    ok "全部 15 个源文件已就位"
fi

echo ""
info "生成 Xcode 工程..."
if xcodegen generate; then
    ok "${PROJECT_NAME}.xcodeproj 已生成"
else
    err "生成失败，检查 project.yml"
    exit 1
fi

echo ""
echo "═════════════════════════════════════"
echo "  工程配置完成！"
echo "═════════════════════════════════════"
echo ""
echo "  下一步："
echo "  1. 将 .swift 文件放入对应目录"
echo "  2. 打开 IslandLink.xcodeproj"
echo "  3. 配置签名 → 运行"
echo ""

open .

printf "  在 Xcode 打开项目 (Y/n)? "
read -r OPEN
case "$OPEN" in
    [Nn]* ) ;;
    * ) open "${PROJECT_NAME}.xcodeproj"; ok "Xcode 已启动" ;;
esac

ok "完成"
