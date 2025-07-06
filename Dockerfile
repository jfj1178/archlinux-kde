# Use the official Arch Linux base image
FROM archlinux:latest

ENV TERM=xterm

# Install required system packages
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

# Clone and build noVNC (latest version)
RUN git clone https://github.com/novnc/noVNC.git /noVNC
WORKDIR /noVNC
RUN git checkout v1.4.0
RUN npm install
RUN ln -s /noVNC/vnc.html /noVNC/index.html

EXPOSE 8080

CMD ["bash", "-c", "\
    Xvfb :1 -screen 0 1280x800x24 & \
    DISPLAY=:1 openbox & \
    /noVNC/utils/launch.sh --listen 8080 --vnc localhost:5901 \
"]
