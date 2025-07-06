# Use the official Arch Linux base image
FROM archlinux:latest

# Set environment variables
ENV TERM=xterm

# Install necessary packages (excluding noVNC from pacman)
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

# Clone and set up noVNC manually
RUN git clone https://github.com/novnc/noVNC.git /noVNC
WORKDIR /noVNC
RUN git checkout v1.2.0
RUN npm install
RUN ln -s /noVNC/vnc.html /noVNC/index.html

# Expose noVNC port (default 8080 for web access)
EXPOSE 8080

# Configure noVNC to connect to Xvfb (virtual X server)
CMD ["bash", "-c", "\
    Xvfb :1 -screen 0 1280x800x24 & \
    DISPLAY=:1 openbox & \
    /noVNC/utils/launch.sh --listen 8080 --vnc localhost:5901 \
"]
