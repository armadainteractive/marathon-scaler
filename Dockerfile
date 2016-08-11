FROM alpine:3.4

# Add the necessary tools
RUN apk add --update \
      bash \
      curl \
      jq \
      && \
      rm -rf /var/cache/apk/*

# Copy the actual logic in and set is as default entrypoint
COPY ./scale.sh /
RUN chmod +x /scale.sh
ENTRYPOINT ["/scale.sh"]