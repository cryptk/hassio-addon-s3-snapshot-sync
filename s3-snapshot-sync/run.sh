#!/usr/bin/with-contenv bashio

KEY=$(bashio::config 'aws_access_key_id')
SECRET=$(bashio::config 'aws_secret_access_key')
BUCKET=$(bashio::config 's3_bucket_name')

aws configure set aws_access_key_id "$KEY"
aws configure set aws_secret_access_key "$SECRET"

if bashio::config.has_value 's3_endpoint_url'; then
	bashio::log "s3_endpoint_url is set, using custom S3 endpoint"
	S3ENDPOINTURL=$(bashio::config 's3_endpoint_url')
	aws s3 sync --endpoint-url "${S3ENDPOINTURL}" /backup/ "s3://${BUCKET}/"
else
	aws s3 sync /backup/ "s3://${BUCKET}/"
fi

if bashio::config.has_value 'purge_days'; then
	bashio::log "purge_days is set, cleaning up old backups"
	DAYS=$(bashio::config 'purge_days')
	find /backup/ -mindepth 1 -mtime "+${DAYS}" -print -exec rm {} \;
fi

bashio::exit.ok "Backup run complete"
