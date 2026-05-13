FROM --platform=$BUILDPLATFORM golang:1.26-alpine AS builder

ARG TARGETARCH
ARG TARGETVARIANT
WORKDIR /src

# Get Portainer Agent source
# Note: You may need to clone the specific version you want
RUN apk add --no-cache git
RUN git clone https://github.com/portainer/agent.git .

# Build for ARMv6
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=6 go build -a -installsuffix cgo -ldflags '-s' -o agent ./cmd/agent/main.go

# Stage 2: Final Image
FROM arm32v6/alpine:latest
WORKDIR /app
COPY --from=builder /src/agent /app/agent

# Portainer Agent needs to communicate with Docker
ENTRYPOINT ["./agent"]
