ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8


# add aws-cli and deps
RUN apk -v --no-cache add python3 py3-pip jq && \
    pip3 install awscli

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
