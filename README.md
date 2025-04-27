# Self-signed certificates

1. Edit the `certs/openssl.conf` to your needs
2. Create a intermediate CSR `openssl req -new -nodes -keyout server.key -out server.csr -config certs/openssl.conf`
3. Create self-signed cert `openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt -extensions v3_req -extfile certs/openssl.conf`
4. Check the generated cert `openssl x509 -in server.crt -text -noout`

# Podman secrets

1. Run `./addsecrets.sh` to setup the required secret values (might need `chmod +x addsecrets.sh` first)
2. Manually add the server certificate and key to a secret
   ```bash
   podman secret create server.crt server.crt
   podman secret create server.key server.key
   ```
   >You can now delete the server cert and key files, as they are now stored in a podman secret (`podman secret ls`)

To view a secret `podman secret inspect <secretname> --showsecret`

# Podman compose systemd

1. `podman-compose up --build` # Check for errors and <kbd>CTRL+C</kbd> to stop
2. `podman-compose down`
3. `podman-compose systemd -a create-unit`
4. `podman-compose systemd -a register`
5. `systemctl --user daemon-reload`
6. `sudo loginctl enable-linger $USER`
7. `systemctl --user start 'podman-compose@keycloak-compose'`


# Download packages for offline use

## Download requires packages

1. `dnf download --resolve --destdir=./packages podman podman-compose netavark aardvark-dns`

## Install required packages

1. `sudo dnf install ./packages/*.rpm`