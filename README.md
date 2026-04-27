## Installation
```bash
# install docker sandbox (MacOS)
brew install docker/tap/sbx
sbx login
```

## Quick Start
```bash
# Start a docker container and detach from it after the command finishes.
# Named 'registry', and using the "registry:2" image from docker hub.
docker run -d --restart=always -p 5000:5000 --name registry registry:2

# Use `buildx` for extended build capabilities with Buildkit (allowing us to
# run for platform `linux/arm64`)
# `localhost:5000/opencode-sandbox:dev` means:
# registry:   localhost:5000
# repository: opencode-sandbox
# tag:        dev
# `--push` to immediately push to registry (in this case `localhost:5000`) after building.
docker buildx build \
  --platform linux/arm64 \
  -t localhost:5000/opencode-sandbox:dev \
  --push \
  .

#
sbx run --template localhost:5000/opencode-sandbox:dev opencode .
```

