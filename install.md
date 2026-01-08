### install no internet from Linux (cam)

1. Get iperf3 on a machine WITH internet (lab/laptop)
- On Ubuntu / Debian / Pi (same CPU arch as cameras)
```
which iperf3
```

- Usually:
```
/usr/bin/iperf3
```

- If it’s not installed yet:
```
sudo apt install iperf3
```
2. Copy the binary to the camera or server

- Copy to camera
```
scp /usr/bin/iperf3 camera@CAMERA_IP:/tmp/iperf3
```
- Copy to server
```
scp /usr/bin/iperf3 user@SERVER_IP:/tmp/iperf3
```

3. Make it executable

- On camera / server:
```
chmod +x /tmp/iperf3
```

- Run it:
```
/tmp/iperf3 --version
```

4. Run the test

- On camera (server mode)
```
/tmp/iperf3 -s
```

- On server or laptop (client mode)
```
/tmp/iperf3 -c CAMERA_IP
```

### Gratuitous ARP test

- From camera (if it has any IP, even static):
```
arping -c 3 <gateway-ip>
```

- If this fails but ping works intermittently → ARP not propagating reliably (classic fiber issue).



1. https://files.budman.pw/

```
# Pi
iperf3 -s

# Laptop
iperf3 -c <pi-ip>
```

