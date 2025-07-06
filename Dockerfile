# Use the official Arch Linux base image
FROM archlinux:latest

# Environment setup
ENV TERM=xterm

# Install required packages
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        sudo \
        xfce4 \
        xorg-xinit \
        tigervnc \
        dbus \
        ttf-dejavu \
        firefox && \
    pacman -Sc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/*

# Create a non-root user
RUN useradd -m -s /bin/bash user && \
    echo "user:password" | chpasswd && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Configure TigerVNC with modern vncsession approach
RUN mkdir -p /etc/tigervnc && \
    echo ":1=user" > /etc/tigervnc/vncserver.users && \
    echo "session=xfce" > /etc/tigervnc/vncserver-config-defaults

# Set VNC password
RUN mkdir -p /home/user/.vnc && \
    echo "password" | vncpasswd -f > /home/user/.vnc/passwd && \
    chmod 600 /home/user/.vnc/passwd && \
    chown -R user:user /home/user/.vnc

# Expose VNC port
EXPOSE 5901

# Switch to non-root user
USER user
ENV HOME /home/user

# Start the VNC session using modern method
CMD ["/bin/bash", "-c", "vncsession user :1 && sleep 5 && tail -f /dev/null"]
