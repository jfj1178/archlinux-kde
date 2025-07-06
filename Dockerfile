# Use the official Arch Linux base image
FROM archlinux:latest

# Set environment variables
ENV TERM=xterm

# Install necessary packages (without noVNC)
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        xfce4 \
        xorg-server-xvfb \
        xorg-xinit \
        openbox \
        ttf-dejavu \
        dbus \
        python \
        git \
        nodejs \
        npm && \
    pacman -Sc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

# Clone and install noVNC manually
RUN git clone https://github.com/novnc/noVNC.git /noVNC && \
    cd /noVNC && \
    git checkout v1.2.0 && \
    npm install && \
    ln -s /noVNC/vnc.html /noVNC/index.html

# Expose noVNC port
EXPOSE 8080

# Configure noVNC to connect to Xvfb and run Openbox
CMD ["bash", "-c", "\
    Xvfb :1 -screen 0 1280x800x24 & \
    DISPLAY=:1 openbox & \
    /noVNC/utils/launch.sh --listen 8080 --vnc localhost:5901 \
    "]
