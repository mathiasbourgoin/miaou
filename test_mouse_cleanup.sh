#!/bin/bash
# Test script to verify mouse tracking cleanup works properly

echo "==================================================================="
echo "Mouse Tracking Cleanup Test"
echo "==================================================================="
echo ""
echo "This test verifies that mouse tracking is properly disabled when"
echo "the app is terminated with Ctrl+C."
echo ""
echo "Test procedure:"
echo "  1. Build the demo"
echo "  2. Run demo and navigate to Bar Chart page"
echo "  3. Press Ctrl+C to terminate"
echo "  4. Verify mouse tracking is disabled"
echo ""
echo "Press Enter to continue..."
read

echo ""
echo "Building demo..."
dune build

echo ""
echo "==================================================================="
echo "MANUAL TEST INSTRUCTIONS:"
echo "==================================================================="
echo ""
echo "1. Run: dune exec -- miaou.demo"
echo "2. Navigate to 'Bar Chart' (use arrow keys)"
echo "3. Press Ctrl+C to exit"
echo "4. Scroll your mouse wheel in this terminal"
echo ""
echo "EXPECTED: Normal scrolling behavior"
echo "FAILURE: 'unbound keyseq: mouse' errors or escape sequences"
echo ""
echo "If test fails, run: printf '\\033[?1006l\\033[?1015l\\033[?1005l\\033[?1003l\\033[?1002l\\033[?1000l'"
echo ""
echo "Press Enter to run the demo, or Ctrl+C to exit..."
read

dune exec -- miaou.demo
