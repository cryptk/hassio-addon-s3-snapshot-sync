#!/usr/bin/with-contenv bashio

KEY=$(bashio::config 'aws_access_key_id')
SECRET=$(bashio::config 'aws_secret_access_key')
BUCKET=$(bashio::config 's3_bucket_name')

# Allow the S3 endpoint URL to be overridden
S3ENDPOINTURL=""
if bashio::config.has_value 's3_endpoint_url'; then
	bashio::log "s3_endpoint_url is set, using custom S3 endpoint"
	S3ENDPOINTURL="--endpoint-url "$(bashio::config 's3_endpoint_url')
fi

aws configure set aws_access_key_id $KEY
aws configure set aws_secret_access_key $SECRET

aws s3 sync $S3ENDPOINTURL /backup/ s3://$BUCKET/

if bashio::config.has_value 'purge_days'; then
	bashio::log "purge_days is set, cleaning up old backups"
	DAYS=$(bashio::config 'purge_days')
	find /backup/ -mindepth 1 -mtime +${DAYS} -print -exec rm {} \;
fi

bashio::exit.ok "Backup run complete"
