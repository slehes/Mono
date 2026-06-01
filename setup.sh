#!/bin/bash
set -e

echo "=== Mono Setup ==="

# Backend
echo ""
echo "1. Устанавливаю зависимости бэкенда..."
cd "$(dirname "$0")/mono-backend"
pip3 install -r requirements.txt

echo ""
echo "2. Генерирую Xcode проект..."
cd ../MonoApp

# Check if xcodegen is installed
if command -v xcodegen &> /dev/null; then
    xcodegen generate
    echo "   Xcode проект создан: Mono.xcodeproj"
else
    echo "   ВНИМАНИЕ: xcodegen не найден."
    echo "   Установи: brew install xcodegen"
    echo "   Затем запусти: xcodegen generate  (в папке MonoApp/)"
fi

echo ""
echo "=== Готово ==="
echo ""
echo "Чтобы запустить бэкенд:"
echo "  cd mono-backend"
echo "  uvicorn main:app --reload --port 8000"
echo ""
echo "Чтобы открыть iOS проект:"
echo "  open MonoApp/Mono.xcodeproj"
echo ""
