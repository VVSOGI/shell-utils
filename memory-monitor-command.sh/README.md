# Memory Monitor Command

Bash script to monitor memory usage of any command execution in real-time.

## Usage

```bash
bash ./memory-monitor-command.sh "<command>"
```

## Features

- Real-time memory usage monitoring with 1-second intervals
- CSV log file creation for later analysis
- Execution summary with time elapsed and peak memory usage
- Support for monitoring any command or process

## Examples

```bash
# Monitor Next.js build process
./memory-monitor-command.sh "yarn next build"

# Monitor npm test execution
./memory-monitor-command.sh "npm run test"

# Monitor any memory-intensive process
./memory-monitor-command.sh "node heavy-process.js"
```

## Output

The script displays real-time memory information in the terminal:

```
[2025-03-25 08:25:20] Total: 3922.82MB | Free: 1388.35MB | Available: 1780.81MB | Used: 2019.72MB | Buffer/Cache: 514.75MB
```

After command completion, a summary is displayed:

```
================ RESULT ================
Command: yarn next build
Exit Code: 0
Execution Time: 00:03:45
Maximum memory usage: 3782.00MB (at 2025-03-25 08:25:36)
Memory usage log: memory_logs/yarn_20250325_082510.log
=======================================
```

## Log Files

All memory data is saved to a log file in the `memory_logs` directory with the command name and timestamp:

```
memory_logs/yarn_20250325_082510.log
```

The log file contains the same information that's displayed in real-time, allowing for post-execution analysis.

## Requirements

- Requires `bc` for floating-point calculations
- Requires `awk` for data processing
- Works on Linux systems with `/proc/meminfo` available

## How It Works

The script reads the `/proc/meminfo` file every second to gather memory statistics while your command runs in the foreground. It calculates actual memory usage by considering buffers and cache, providing an accurate picture of memory consumption.
