FROM archlinux:latest
#test
ENV TERM=xterm

# Install necessary system packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        xfce4 \
        xorg-server-xvfb \
        xorg-xinit \
        x11vnc \
        ttf-dejavu \
        dbus \
        python \
        git \
        curl \
        wget && \
    pacman -Sc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

# Clone noVNC (v1.2.0 - does not require npm)
RUN git clone https://github.com/novnc/noVNC.git /noVNC
WORKDIR /noVNC
RUN git checkout v1.2.0
RUN ln -s /noVNC/vnc.html /noVNC/index.html

EXPOSE 8080

# Start XFCE, Xvfb, x11vnc, and noVNC
CMD ["bash", "-c", "\
  Xvfb :1 -screen 0 1280x800x24 & \
  sleep 3 && \
  export DISPLAY=:1 && \
  startxfce4 & \
  x11vnc -display :1 -nopw -forever -shared -rfbport 5901 & \
  /noVNC/utils/launch.sh --listen 8080 --vnc localhost:5901 \
"]
