# AWS CloudWatch CPU Monitoring

## Overview

This phase extends the Linux monitoring project with AWS CloudWatch monitoring for an existing Amazon EC2 instance.

The implementation uses EC2 basic monitoring and a CloudWatch metric alarm to monitor CPU utilization.

## AWS Environment

| Setting | Value |
|---|---|
| AWS Region | ap-southeast-2 (Sydney) |
| EC2 Instance Type | t3.micro |
| EC2 Instance ID | i-08ef142562e75920a |
| Operating System | Amazon Linux 2023 |
| EC2 Monitoring | Basic monitoring |
| EBS Volume | 8 GiB gp3 |

## CloudWatch CPU Metrics

Metric namespace: `AWS/EC2`

Metric name: `CPUUtilization`

Dimension: `InstanceId`

The instance published CPU utilization metrics at approximately five-minute intervals.

Sample readings collected during testing:

| Timestamp (IST) | Average CPU Utilization |
|---|---:|
| 14:50 | 0.2462% |
| 14:55 | 0.3883% |
| 15:00 | 0.3533% |
| 15:05 | 0.3468% |
| 15:10 | 0.3634% |
| 15:15 | 0.3448% |
| 15:20 | 0.3469% |

These readings were retrieved from CloudWatch using the AWS CLI.

## CloudWatch Alarm

| Setting | Value |
|---|---|
| Alarm Name | CloudMonitoring-High-CPU |
| Metric | CPUUtilization |
| Namespace | AWS/EC2 |
| Statistic | Average |
| Period | 300 seconds |
| Evaluation Periods | 1 |
| Datapoints to Alarm | 1 |
| Threshold | 80% |
| Comparison | GreaterThanOrEqualToThreshold |
| Missing Data | notBreaching |

## Verification

The alarm was created successfully and verified using the AWS CLI.

The alarm initially reported `INSUFFICIENT_DATA` while waiting for evaluation.

It subsequently transitioned to `OK`.

The recorded evaluation showed CPU utilization of approximately 0.3555%, below the configured 80% threshold.

## Testing Limitations

- Real CPU metrics were collected and verified.
- The alarm configuration and normal `OK` state were verified.
- A real CPU threshold breach has not yet been tested.
- SNS notifications have not been configured.
- Memory metrics have not yet been integrated through the CloudWatch Agent.
- No claim is made that high-CPU alert delivery has been tested.

## Cost Management

The EC2 instance was stopped after the monitoring verification.

Stopping the instance avoids ongoing EC2 compute charges, but the attached EBS volume and CloudWatch alarm may continue to incur charges.

The EBS volume is 8 GiB gp3 and is not encrypted.

## Next Improvements

- Integrate CloudWatch Agent for memory metrics.
- Configure SNS notifications for alarm state changes.
- Test a controlled CPU threshold breach.
- Document incident investigation and recovery.
