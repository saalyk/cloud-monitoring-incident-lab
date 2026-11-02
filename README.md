# Cloud Monitoring & Incident Lab

A Linux-based system monitoring project built with Bash. It monitors CPU usage, memory availability, and disk usage, generates threshold-based warnings, and records alerts in a log file.

## Project Objectives

- Monitor essential Linux system resources.
- Detect resource usage at or above alert thresholds.
- Record warnings with timestamps.
- Validate monitoring behavior using simulated test inputs.
- Document incident investigation and troubleshooting procedures.

## Features

- **CPU monitoring:** Collects CPU usage using `top`.
- **Memory monitoring:** Estimates unavailable memory using the available-memory value from `free`.
- **Disk monitoring:** Checks root filesystem usage using `df`.
- **Threshold alerts:** Generates warnings when a metric reaches or exceeds 80%.
- **Alert logging:** Saves warnings to `logs/monitor.log`.
- **Input validation:** Rejects non-numeric, negative, and above-100 test values.
- **Portable log path:** Saves logs in the project directory, even when the script runs from another directory.
- **Logging error handling:** Reports log-directory creation and log-write failures, continues monitoring, and exits with a non-zero status if logging fails.
- **CPU display fallback:** Continues monitoring with the collected CPU percentage if the live CPU details command fails.
- **Automatic log directory:** Creates the `logs/` directory when the script runs; runtime logs are excluded from Git.

## Project Structure

- `scripts/system-monitor.sh` — Main Bash monitoring script.
- `logs/monitor.log` — Automatically generated timestamped alert log (created when the script runs).
- `incidents/cpu-alert-incident.md` — Sample CPU alert investigation report.
- `aws-cloudwatch-monitoring.md` — AWS CloudWatch CPU and memory monitoring documentation.
- `README.md` — Project documentation.

## Requirements

- Ubuntu or another Linux distribution.
- Bash shell.
- `top`, `free`, `df`, and `awk` utilities.
- The local Bash monitoring script does not require an AWS account.
- The AWS CloudWatch monitoring phase requires an AWS account and configured AWS resources; charges may apply.

## How to Run

Run the monitoring script from the project directory:

`./scripts/system-monitor.sh`

The script collects current CPU usage, memory availability, and root filesystem disk usage.

### Simulated Testing

The script accepts optional test values in this order:

`./scripts/system-monitor.sh DISK_USAGE CPU_USAGE MEMORY_UNAVAILABLE`

Example:

`./scripts/system-monitor.sh 85 90 75`

This simulates:
- Disk usage: 85%
- CPU usage: 90%
- Memory unavailable: 75%

These arguments are for testing alert behavior. They do not change actual system resource usage.

## Alert Logic

- Warning threshold: 80%.
- A metric at exactly 80% triggers a warning.
- Values below 80% are reported as OK.
- Invalid test inputs are rejected.
- Warnings include timestamps and are appended to `logs/monitor.log`.

## Testing & Validation

The monitoring script was tested with:

- Normal values below the threshold.
- Values at the 80% alert boundary.
- Values above the threshold.
- Decimal percentage values.
- Zero and maximum valid values.
- Invalid text, negative values, and values above 100%.
- Multiple resource alerts in one run.
- Execution from outside the project directory to verify log-path handling.
- Simulated CPU collection and display command failures.
- Simulated log-write permission failures, including continued metric checks and non-zero exit status.

Shell syntax was checked using `bash -n`.

## Incident Documentation

A sample CPU alert investigation is documented in:

`incidents/cpu-alert-incident.md`

The report covers alert detection, log verification, process inspection, investigation steps, and the distinction between simulated alerts and confirmed real incidents.

## Limitations

- This is a lightweight local monitoring script, not a production monitoring platform.
- CPU readings depend on the output format provided by `top`.
- Memory unavailable is estimated using Linux's available-memory value.
- Alerts are written to a local log file; no email, SMS, or external notification is configured.
- Simulated test values validate alert logic but do not create real system load.

## Future Improvements

- Add configurable alert thresholds.
- Add automated periodic monitoring with cron.
- Add historical metric collection and trend analysis.
- Integrate external alerting and visualization tools.
