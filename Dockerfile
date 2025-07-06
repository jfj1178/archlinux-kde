FROM archlinux:latest

ENV TERM=xterm

# Install system packages
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
        curl && \
    pacman -Sc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

# Install Node.js v18 via n (Node version manager)
RUN curl -L https://raw.githubusercontent.com/tj/n/master/bin/n -o /usr/local/bin/n && \
    chmod +x /usr/local/bin/n && \
    n 18.20.2 && \
    ln -sf /usr/local/n/versions/node/18.20.2/bin/node /usr/bin/node && \
    ln -sf /usr/local/n/versions/node/18.20.2/bin/npm /usr/bin/npm

# Clone and setup noVNC
RUN git clone https://github.com/novnc/noVNC.git /noVNC
WORKDIR /noVNC
RUN git checkout v1.2.0
RUN npm install
RUN ln -s /noVNC/vnc.html /noVNC/index.html

EXPOSE 8080

CMD ["bash", "-c", "\
    Xvfb :1 -screen 0 1280x800x24 & \
    DISPLAY=:1 openbox & \
    /noVNC/utils/launch.sh --listen 8080 --vnc localhost:5901 \
"]
