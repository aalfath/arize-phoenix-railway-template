# Arize Phoenix for Railway: the official image, pinned by version and digest.
# Bump both the tag and the digest together, and add a CHANGELOG.md entry.
FROM arizephoenix/phoenix:21.1.0@sha256:09ec48906c054a27dd09a88c8e6bcc24fe89649d3ecc94d3a8ed394e21279b31

# The image is distroless (no shell), so settings are plain ENV lines.
# UI, REST API and OTLP/HTTP on 6006 (the template sets PORT=6006 so Railway routes here);
# OTLP/gRPC on 4317 for services on the private network.
ENV PHOENIX_HOST=:: \
    PHOENIX_PORT=6006 \
    PHOENIX_GRPC_PORT=4317 \
    PHOENIX_ENABLE_AUTH=true \
    PHOENIX_USE_SECURE_COOKIES=true

EXPOSE 6006 4317

# Same command as the upstream image (its ENTRYPOINT is the Python interpreter).
CMD ["-m", "phoenix.server.main", "serve"]
