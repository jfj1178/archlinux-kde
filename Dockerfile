FROM archlinux:latest

ENV TERM=xterm

# Install core system packages
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
        curl \
        x11vnc \
        wget && \
    pacman -Sc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

# Install Node.js v18 (just in case but not used now)
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /usr/local/bin/n && \
    chmod +x /usr/local/bin/n && \
    n 18.20.2 && \
    ln -sf /usr/local/n/versions/node/18.20.2/bin/node /usr/bin/node && \
    ln -sf /usr/local/n/versions/node/18.20.2/bin/npm /usr/bin/npm

# Clone noVNC without building
RUN git clone https://github.com/novnc/noVNC.git /noVNC
WORKDIR /noVNC
RUN git checkout v1.2.0
RUN ln -s /noVNC/vnc.html /noVNC/index.html

EXPOSE 8080

CMD ["bash", "-c", "\
    Xvfb :1 -screen 0 1280x800x24 & \
    DISPLAY=:1 openbox & \
    x11vnc -display :1 -nopw -forever -shared -rfbport 5901 & \
    /noVNC/utils/launch.sh --listen 8080 --vnc localhost:5901 \
"]
