# Use the official Arch Linux base image
FROM archlinux:latest

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm

# Install necessary packages:
# sudo: for user management
# xfce4: the lightweight desktop environment
# xorg-xinit: X server initialization
# tigervnc: the VNC server
# dbus: required by XFCE
# ttf-dejavu: common fonts for better display
# firefox: a web browser for testing the desktop (optional, adds size)
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

# Create a non-root user 'user' with password 'password'
# This is for VNC login. In a real scenario, use strong, secret passwords.
RUN useradd -m -s /bin/bash user && \
    echo "user:password" | chpasswd && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Set VNC password for the 'user'
# This password will be used to connect to the VNC server.
# It's set directly here for demonstration, but should be an environment variable in production.
RUN mkdir -p /home/user/.vnc && \
    echo "password" | vncpasswd -f > /home/user/.vnc/passwd && \
    chmod 600 /home/user/.vnc/passwd && \
    chown -R user:user /home/user/.vnc

# Configure XFCE session for VNC
# This script tells VNC how to start the XFCE desktop.
RUN echo "#!/bin/bash" > /home/user/.vnc/xstartup && \
    echo "startxfce4 &" >> /home/user/.vnc/xstartup && \
    chmod +x /home/user/.vnc/xstartup && \
    chown user:user /home/user/.vnc/xstartup

# Expose the VNC port (default is 5901)
EXPOSE 5901

# Switch to the non-root user
USER user

# Command to start the VNC server when the container runs
# Using /bin/bash -c to ensure the command and its arguments are parsed correctly by a shell.
# -geometry: sets the resolution of the virtual desktop
# -depth: sets the color depth
# :1: specifies display number 1 (VNC port will be 5901)
CMD ["/bin/bash", "-c", "vncserver -geometry 1280x800 -depth 24 :1"]
