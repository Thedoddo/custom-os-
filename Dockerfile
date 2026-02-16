# Dockerfile for building CustomOS
FROM archlinux:latest

# Update system and install build dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --needed --noconfirm \
        base-devel \
        archiso \
        git \
        nodejs \
        npm \
        wine \
        winetricks \
        rsync \
        sudo

# Create build directory
WORKDIR /build

# Set up locale to avoid errors
RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_US.UTF-8" > /etc/locale.conf

ENV LANG=en_US.UTF-8

# Default command
CMD ["/bin/bash"]
