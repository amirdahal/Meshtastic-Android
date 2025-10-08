#!/bin/bash

# Meshtastic Android Bluetooth Debugging Script
# This script helps debug BLE communication issues

echo "🔧 Meshtastic Android Bluetooth Debug Helper"
echo "============================================="

# Function to check if device is connected
check_device() {
    if ! adb devices | grep -q "device$"; then
        echo "❌ No Android device connected via ADB"
        echo "Please connect your Android device and enable USB debugging"
        exit 1
    fi
    echo "✅ Android device connected"
}

# Function to install debug APK
install_debug_apk() {
    echo "📱 Installing debug APK..."
    if [ -f "app/build/outputs/apk/fdroid/debug/app-fdroid-debug.apk" ]; then
        adb install -r app/build/outputs/apk/fdroid/debug/app-fdroid-debug.apk
        echo "✅ Debug APK installed"
    else
        echo "❌ Debug APK not found. Please run: ./gradlew assembleFdroidDebug"
        exit 1
    fi
}

# Function to start logcat monitoring
start_bluetooth_monitoring() {
    echo "📡 Starting Bluetooth debug monitoring..."
    echo "🔍 Look for these patterns:"
    echo "  ✅ Success: 🔍→✅→🎯→🚀→📡→📥→⭕→🎯→🔔→📲"
    echo "  ❌ Failure: ⚠️ Error messages or missing 📲 notifications"
    echo ""
    echo "📝 Logs will be saved to: bluetooth_debug.log"
    echo "Press Ctrl+C to stop monitoring"
    echo ""
    
    # Clear logcat buffer
    adb logcat -c
    
    # Start monitoring with color coding
    adb logcat -s "BluetoothInterface:*" "MeshService:*" "SafeBluetooth:*" "Timber:*" | \
    while IFS= read -r line; do
        echo "$line" | tee -a bluetooth_debug.log
        
        # Color code important patterns
        if [[ $line == *"🔍 Starting BLE service discovery"* ]]; then
            echo "🎯 KEY: Service discovery started"
        elif [[ $line == *"📲 fromNum notification received"* ]]; then
            echo "🎉 SUCCESS: Notifications are working!"
        elif [[ $line == *"⚠️"* ]]; then
            echo "🚨 ERROR DETECTED: Check the line above"
        fi
    done
}

# Function to show common issues and solutions
show_troubleshooting() {
    echo ""
    echo "🩺 Common Issues & Solutions:"
    echo "============================"
    echo ""
    echo "1. 🔍 Service discovery fails:"
    echo "   → Clear Bluetooth cache: Settings → Apps → Bluetooth → Storage → Clear Cache"
    echo "   → Turn Bluetooth off/on"
    echo "   → Restart both devices"
    echo ""
    echo "2. 🔔 Notifications not working:"
    echo "   → Check if characteristic discovery succeeds"
    echo "   → Verify firmware is sending notifications"
    echo "   → Try different Android device if available"
    echo ""
    echo "3. 📥 No data received:"
    echo "   → Check if initial connection establishes properly"
    echo "   → Verify fromRadio characteristic reads return data"
    echo "   → Check firmware logs for errors"
    echo ""
    echo "4. 🔄 Connection drops:"
    echo "   → Check device power management settings"
    echo "   → Disable battery optimization for Meshtastic app"
    echo "   → Ensure devices stay in range"
}

# Main execution
echo "Starting Bluetooth debugging session..."
echo ""

check_device
install_debug_apk

echo ""
echo "🎯 NEXT STEPS:"
echo "1. Open the Meshtastic app"
echo "2. Try to connect to your Meshtastic device"
echo "3. Watch the logs below for debug information"
echo "4. Press Ctrl+C when done to see troubleshooting guide"
echo ""

start_bluetooth_monitoring

# When Ctrl+C is pressed, show troubleshooting
trap 'show_troubleshooting' INT

wait