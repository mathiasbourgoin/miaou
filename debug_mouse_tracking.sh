#!/bin/bash
# Diagnostic script to check mouse tracking state

echo "==================================================================="
echo "Mouse Tracking Diagnostic Tool"
echo "==================================================================="
echo ""

# Function to check if mouse tracking is enabled
check_mouse_tracking() {
    echo "Checking mouse tracking state..."
    echo "Please scroll your mouse wheel now (within 3 seconds):"

    # Read input with timeout
    if read -t 3 -n 10 input; then
        if [[ "$input" =~ \[M|^\[\< ]]; then
            echo "❌ Mouse tracking is ENABLED (detected escape sequences)"
            echo "   Raw input: $(echo "$input" | od -An -tx1)"
            return 1
        else
            echo "✓ Mouse tracking appears to be disabled"
            return 0
        fi
    else
        echo "⚠ No input detected (might be disabled)"
        return 0
    fi
}

echo "1. First, let's disable any existing mouse tracking:"
printf '\033[?1006l\033[?1015l\033[?1005l\033[?1003l\033[?1002l\033[?1000l'
echo "Done."
echo ""

sleep 0.5
check_mouse_tracking
echo ""

echo "2. Now let's enable mouse tracking (like the app does):"
printf '\033[?1000h\033[?1006h'
echo "Done."
echo ""

sleep 0.5
check_mouse_tracking
echo ""

echo "3. Now let's disable it again (like cleanup should):"
printf '\033[?1006l\033[?1015l\033[?1005l\033[?1003l\033[?1002l\033[?1000l'
echo "Done."
echo ""

sleep 0.5
check_mouse_tracking
echo ""

echo "==================================================================="
echo "Test complete. If step 3 shows mouse tracking is disabled, the"
echo "escape sequences work in your terminal. If not, your terminal may"
echo "need a different escape sequence or have a bug."
echo ""
echo "To reset: printf '\\033[?1006l\\033[?1015l\\033[?1005l\\033[?1003l\\033[?1002l\\033[?1000l'"
echo "==================================================================="
