#!/bin/bash
# Test the Ctrl+C mouse tracking cleanup fix

echo "==================================================================="
echo "Ctrl+C Mouse Tracking Cleanup Test"
echo "==================================================================="
echo ""
echo "This will test if mouse tracking is properly cleaned up when"
echo "pressing Ctrl+C."
echo ""
echo "Steps:"
echo "  1. The demo will start"
echo "  2. Navigate to 'Bar Chart' using arrow keys"
echo "  3. Press Ctrl+C"
echo "  4. Then scroll your mouse wheel"
echo ""
echo "EXPECTED: Normal scrolling (no 'unbound keyseq: mouse' errors)"
echo "FAILURE: Seeing 'unbound keyseq: mouse' when scrolling"
echo ""
echo "Press Enter to start the demo..."
read

dune exec -- miaou.demo

echo ""
echo "==================================================================="
echo "Test Complete"
echo "==================================================================="
echo ""
echo "Did you see 'unbound keyseq: mouse' errors when scrolling?"
echo "  - NO:  ✓ FIX WORKS! Mouse tracking was properly disabled"
echo "  - YES: ✗ Issue persists. Run: printf '\\033[?1006l\\033[?1015l\\033[?1005l\\033[?1003l\\033[?1002l\\033[?1000l'"
echo ""
