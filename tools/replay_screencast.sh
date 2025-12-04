#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (c) 2025 Nomadic Labs

# Simple Pure Screencast Replay Script
# Usage: ./replay_screencast.sh [frames_file.jsonl] [speed_multiplier]

FRAMES_FILE="${1:-recordings/miaou_logging_switch_frames.jsonl}"
SPEED="${2:-1.0}"

if [ ! -f "$FRAMES_FILE" ]; then
    echo "Error: Frame file '$FRAMES_FILE' not found!"
    echo "Usage: $0 [frames_file.jsonl] [speed_multiplier]"
    exit 1
fi

echo "🎬 Pure Screencast Replay"
echo "========================"
echo "File: $FRAMES_FILE"
echo "Speed: ${SPEED}x"
echo ""
echo "Press Enter to start..."
read

# Clear screen and hide cursor
clear
tput civis

# Get total frame count
total_frames=$(wc -l < "$FRAMES_FILE")
frame_num=0
prev_timestamp=""

echo "Playing $total_frames frames..."
sleep 2

while IFS= read -r line; do
    frame_num=$((frame_num + 1))
    
    # Extract frame data
    timestamp=$(echo "$line" | jq -r '.timestamp')
    frame_content=$(echo "$line" | jq -r '.frame')
    
    # Calculate delay if we have a previous timestamp
    if [ -n "$prev_timestamp" ]; then
        # Calculate delay in seconds
        delay=$(echo "scale=3; ($timestamp - $prev_timestamp) / $SPEED" | bc -l 2>/dev/null || echo "1.0")
        # Ensure minimum delay of 0.1 seconds
        if (( $(echo "$delay < 0.1" | bc -l 2>/dev/null || echo "1") )); then
            delay="0.1"
        fi
        sleep "$delay"
    fi
    
    # Clear screen and display frame
    clear
    echo "$frame_content"
    
    # Show progress
    echo ""
    echo "Frame: $frame_num/$total_frames | Timestamp: $timestamp | Speed: ${SPEED}x"
    
    prev_timestamp="$timestamp"
    
done < "$FRAMES_FILE"

# Show cursor and final message
tput cnorm
echo ""
echo "🎉 Screencast replay complete!"