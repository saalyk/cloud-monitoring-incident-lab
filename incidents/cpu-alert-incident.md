# CPU Usage Alert — Incident Report

## 1. Incident Summary
A CPU usage warning was generated when the monitoring script was tested with a simulated CPU usage value of 95%.

## 2. Alert Details
- Alert threshold: 80%
- Simulated CPU usage: 95%
- Result: WARNING
- Log file: `logs/monitor.log`
- Alert timestamp: Sat Oct 31 02:56:39 IST 2026

## 3. Validation
The monitoring script correctly:
- Detected CPU usage above the 80% threshold.
- Displayed a warning in the terminal.
- Saved the warning in the log file.

Memory and disk checks remained below the alert threshold during this test.

## 4. Process Investigation
The process snapshot was collected using:

`ps aux --sort=-%cpu | head -n 6`

The highest listed process, `containerd`, showed approximately 0.1% CPU usage. Other listed processes showed 0.0%.

No actual high-CPU process was identified in this snapshot.

## 5. Root Cause
No real CPU incident was confirmed. The 95% value was deliberately supplied as a test input to validate the alert mechanism.

Therefore, the root cause of an actual CPU spike remains undetermined.

## 6. Investigation Steps for a Real CPU Incident
1. Identify CPU-consuming processes using `top` or `ps`.
2. Inspect the process ID, command, and associated service.
3. Review relevant application and system logs.
4. Check whether CPU usage is sustained or temporary.
5. Identify the underlying cause before taking corrective action.

## 7. Outcome
The simulated CPU alert and log-writing functionality passed validation. No production remediation was required because no real CPU incident was established.
