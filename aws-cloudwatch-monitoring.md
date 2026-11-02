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

## Cost Management

The EC2 instance was stopped after the monitoring verification.

Stopping the instance avoids ongoing EC2 compute charges, but the attached EBS volume and CloudWatch alarm may continue to incur charges.

The EBS volume is 8 GiB gp3 and is not encrypted.

## CloudWatch Agent - Memory Monitoring

### Agent Installation and Configuration

The Amazon CloudWatch Agent was installed on the Amazon Linux 2023 EC2 instance using DNF.

Agent version: `1.300071.0`

An EC2 IAM role named `CloudWatchAgentEC2Role` was associated through the `CloudWatchAgentEC2Profile` instance profile.

The role has the following managed policies:

- `CloudWatchAgentServerPolicy`
- `AmazonSSMManagedInstanceCore`

AWS Systems Manager Session Manager connectivity was verified, and Run Command was used to install and configure the agent without requiring an accepted SSH host key.

The agent was configured to collect:

- Metric: `mem_used_percent`
- Namespace: `CWAgent`
- Collection interval: 60 seconds
- Dimension: `InstanceId`

### Memory Metric Verification

Actual memory utilization datapoints were retrieved from CloudWatch using the AWS CLI.

| Timestamp (IST) | Average Memory Utilization |
|---|---:|
| 18:25 | 26.59% |
| 18:26 | 25.37% |
| 18:27 | 25.79% |
| 18:28 | 25.79% |
| 18:29 | 25.26% |

These readings confirm that the CloudWatch Agent successfully published memory metrics.

### High Memory Alarm

| Setting | Value |
|---|---|
| Alarm Name | CloudMonitoring-High-Memory |
| Metric | mem_used_percent |
| Namespace | CWAgent |
| Statistic | Average |
| Period | 300 seconds |
| Evaluation Periods | 1 |
| Datapoints to Alarm | 1 |
| Threshold | 80% |
| Comparison | GreaterThanOrEqualToThreshold |
| Missing Data | notBreaching |

The alarm initially entered `INSUFFICIENT_DATA` while waiting for evaluation.

It subsequently transitioned to `OK` after CloudWatch received a memory reading of approximately 25.48%.

A real memory threshold breach has not been tested.

## Security and Access Cleanup

- Systems Manager connectivity was verified.
- SSH inbound access was removed from the EC2 security group after SSM access was confirmed.
- The security group was verified to have no inbound port 22 rules.
- The EC2 instance was stopped after monitoring verification.

## Updated Testing Limitations

- Actual CPU and memory metrics were collected and verified.
- Both CloudWatch alarms were created and verified in the `OK` state.
- Real CPU and memory threshold breaches have not been tested.
- SNS notifications have not been configured or tested.
- No claim is made that alert delivery or automated remediation has been tested.
