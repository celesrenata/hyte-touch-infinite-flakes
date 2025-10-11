FROM nixos/nix:latest

# Install weston and dependencies
RUN nix-env -iA nixpkgs.weston nixpkgs.mesa nixpkgs.libdrm

# Create runtime directory
RUN mkdir -p /run/user/1000

# Set environment variables
ENV XDG_RUNTIME_DIR=/run/user/1000
ENV USER=weston

# Create weston user
RUN adduser -D -s /bin/sh weston

# Copy weston configuration
COPY weston.ini /etc/weston/weston.ini

# Start weston targeting DP-3
CMD ["weston", "--backend=drm", "--drm-device=/dev/dri/card1", "--output-name=DP-3"]
