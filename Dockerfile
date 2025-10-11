FROM nvidia/cuda:13.0-devel-ubuntu24.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    weston \
    mesa-utils \
    libdrm2 \
    libdrm-dev \
    && rm -rf /var/lib/apt/lists/*

# Create runtime directory
RUN mkdir -p /run/user/1000

# Set environment variables
ENV XDG_RUNTIME_DIR=/run/user/1000
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=all

# Start weston targeting DP-3
CMD ["weston", "--backend=drm", "--drm-device=/dev/dri/card1", "--output-name=DP-3"]
