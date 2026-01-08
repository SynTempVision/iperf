### install no internet from Linux (cam)

- Copy to camera from Sophia Lapop
```
scp C:\plant-tools\iperf3-aarch64 pi@cam_ip:/tmp/iperf3

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

