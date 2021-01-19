# Home Assistant Add-on: S3 Snapshot Sync

This addon manages the process of offloading snapshots to AWS S3.
Automatically removing older snapshots from Home Assistant OS is also possible.

This addon does NOT handle removing old snapshots from the S3 bucket.  It is recommended to configure
a bucket lifecycle policy to handle expiring old backups.

## Installation 

1. Follow the instructions to configure the repository in your Home Assistant OS within the [Repo README](../README.md)
1. Search for the "S3 Snapshot Sync" addon in the Supervisor add-on store and install it
1. Create an AWS S3 bucket to store your Home Assistant snapshots
1. Create an AWS IAM user and access keys for this addon to use
1. Attach an AWS IAM policy to the user that grants it the required access to the S3 bucket (an example policy is provided below)

## Configuration

Example add-on configuration:
```yaml
aws_access_key_id: "AKIAABCDEFGHIJKLMNOP",
aws_secret_access_key: "YOURAWSSECRETKEYHERE",
s3_bucket_name: "some-aws-s3-bucket-name",
purge_days: 60
```

**Note**: _This is just an example, don't copy and paste it! Create your own!_

### Option: `aws_access_key_id`

The `aws_access_key_id` option specifies the AWS IAM Access Key ID associated with the AWS IAM user that you created for this addon to use

### Option: `aws_secret_access_key`

The `aws_secret_access_key` option specifies the AWS IAM Secret Access Key associated with the AWS IAM user that you created for this addon to use

### Option `s3_bucket_name`

The `s3_bucket_name` option specifies the name of the S3 bucket you would like to store your snapshots in.
The AWS IAM user you created must have a policy that allows a minimum of s3:PutObject and s3:ListBucket for the S3 bucket you created

### Option `s3_endpoint_url`

The `s3_endpoint_url` option allows overriding the s3 endpoint url that is provided to awscli.
This is useful if you are syncing to a non-AWS S3 (such as minio).

### Option `purge_days`

This option is OPTIONAL.  If you would like the addon to automatically delete old snapshots from Home Assistant OS, you can specify purge_days
and the addon will delete any addons over that age after a successful sync.

Please note, for now this is done with a basic find command, it will be improved at some point in the future to use the proper ha_api

## Example AWS IAM Policy

Ensure that you replace S3_BUCKET_NAME in the below example with the name of the S3 bucket you created to store your snapshots

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:ListBucket"
            ],
            "Resource": [
                "arn:aws:s3:::S3_BUCKET_NAME/*",
                "arn:aws:s3:::S3_BUCKET_NAME"
            ]
        }
    ]
}
```

## Useful Automations

Create a backup once a day at midnight
```yaml
alias: Daily Snapshot
description: ''
trigger:
  - platform: time_pattern
    hours: '0'
    minutes: '0'
    seconds: '0'
condition: []
action:
  - service: hassio.snapshot_full
    data:
      name: 'Automated Backup {{ now().strftime(''%Y-%m-%d-%H-%M-%S'') }}'
mode: single
```

Run the snapshot backup at 1AM
```yaml
alias: Backup Snapshots to S3
description: ''
trigger:
  - platform: time_pattern
    hours: '1'
    minutes: '0'
    seconds: '0'
condition: []
action:
  - service: hassio.addon_start
    data:
      addon: 0f31b3a8_s3_snapshot_sync
mode: single
```

Currently there is no event fired off in Home Assistant when a snapshot completes, so it isn't possible to trigger
the sync more intelligently than "some time after the snapshot is requested"
