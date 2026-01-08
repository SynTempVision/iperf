### install no internet from Linux (cam)

- Copy to camera from Sophia Lapop
```
scp C:\plant-tools\iperf3-aarch64 pi@cam_ip:/tmp/iperf3

```
- run
```
chmod +x /tmp/iperf3
/tmp/iperf3 --version
```

- Move to more permanent dir
```
sudo mv /tmp/iperf3 /usr/local/bin/iperf3
sudo chmod 755 /usr/local/bin/iperf3
```

- Run :
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

