#!/bin/bash

ROOT_DIR="${1:-.}" # Default to current dir

echo "🔍 Scanning for shallow frameworks in: $ROOT_DIR"

find "$ROOT_DIR" -type d -name "macos-arm64_x86_64" | while read -r ARCH_DIR; do
    find "$ARCH_DIR" -type d -name "*.framework" | while read -r FRAMEWORK_PATH; do
        [ -e "$FRAMEWORK_PATH" ] || continue

        FRAMEWORK_NAME=$(basename "$FRAMEWORK_PATH" .framework)

        echo "🔧 Fixing $FRAMEWORK_NAME.framework in $ARCH_DIR"

        cd "$FRAMEWORK_PATH" || continue

        # Skip if already deep
        if [ -d "Versions" ]; then
            echo "  ✅ Already deep, skipping."
            continue
        fi

        mkdir -p Versions/A/Resources

        if [ -f "$FRAMEWORK_NAME" ]; then
            mv "$FRAMEWORK_NAME" Versions/A/
        else
            echo "  ⚠️ Binary not found: $FRAMEWORK_NAME"
            continue
        fi

        if [ -f Info.plist ]; then
            mv Info.plist Versions/A/Resources/
        else
            echo "  ⚠️ Info.plist missing!"
            continue
        fi

        ln -s A Versions/Current
        ln -s Versions/Current/$FRAMEWORK_NAME "$FRAMEWORK_NAME"
        ln -s Versions/Current/Resources Resources

        echo "  ✅ Converted to deep bundle format."
    done
done

echo "🎉 All .xcframeworks processed."
