# Podman secrets

1. Run `./addsecrets.sh` to setup the required secret values

# Podman compose systemd
1. `podman-compose up --build` # Check for errors and <kbd>CTRL+C</kbd> to stop
2. `podman-compose down`
3. `podman-compose systemd -a create-unit`
4. `podman-compose systemd -a register`
5. `systemctl --user daemon-reload`
6. `sudo loginctl enable-linger $USER`
7. `systemctl --user start 'podman-compose@keycloak-compose'`

# Download requires packages

1. `dnf download --resolve --destdir=~/rhel_packages podman podman-compose netavark aardvark-dns`

# Install required packages

1. `sudo dnf install ~/rhel_packages/*.rpm`