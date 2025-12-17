# System Monitor

A real-time system monitoring dashboard showing CPU, memory, and network usage with live sparklines and historical charts.

## Key Features

- **Real-time metrics**: CPU%, memory%, and network usage
- **Sparkline visualization**: Compact real-time graphs
- **Historical chart**: CPU usage history over time
- **Auto-updating**: Refreshes every ~150ms via service_cycle
- **Braille mode**: Toggle between ASCII and Braille rendering

## Metrics Displayed

- **System Information**: Hostname, uptime, load averages
- **CPU Usage**: Current value + sparkline + historical line chart
- **Memory Usage**: Current value + sparkline
- **Network Usage**: KB/s throughput + sparkline

## Keys

- b - Toggle between ASCII and Braille rendering mode
- Esc - Return to launcher

## Data Sources

On Linux, reads from:
- `/proc/stat` for CPU usage
- `/proc/meminfo` for memory
- `/proc/net/dev` for network

Falls back to simulated data on other platforms.

## Integration Tips

- Use `service_cycle` for automatic metric updates
- Combine multiple sparklines for dashboard layouts
- Use thresholds for color-coded status indicators
