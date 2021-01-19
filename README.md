# Hassio Addon for Backing up to S3 Bucket

Add-on for uploading Home Assistant OS snapshots to AWS S3 and remove older backups from Home Assistant OS.

## About

NOTE: You will need an AWS account in order for this addon to be useful
This addon manages the process of offloading snapshots to AWS S3.
Automatically removing older snapshots from Home Assistant OS is also possible.

This addon does NOT handle removing old snapshots from the S3 bucket. It is recommended to configure
a bucket lifecycle policy to handle expiring old backups. An example is provided in the documentation.
