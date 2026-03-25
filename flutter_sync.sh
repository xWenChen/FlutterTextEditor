#!/bin/bash

# 1. 遇到错误立即停止执行
set -e

echo "--------------------------------"
echo "🚀 [1/2] 正在获取依赖..."
flutter pub get

echo ""
echo "🛠️ [2/2] 正在生成代码..."
# 建议在 Flutter 项目中统一使用 flutter pub run
dart run build_runner build --delete-conflicting-outputs -v

echo ""
echo "✅ 执行完毕！"
echo "--------------------------------"