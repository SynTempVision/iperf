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

## NOTES
##### Does it matter which side is server vs client?
- Yes — it matters a LOT.
- iperf is directional.
- Changing server/client changes the traffic direction.
- That’s critical because:
```
Fiber polarity
TX/RX issues
Bad SFPs
Asymmetric routing
Role	What it does
Server (-s)	Just listens
Client (-c)	Sends traffic
```

- A typical good result looks like:
```
[  5]   0.00-10.00  sec  1.08 GBytes   930 Mbits/sec  0             sender
[  5]   0.00-10.00  sec  1.08 GBytes   929 Mbits/sec                receiver
```

##### Focus on four things only
 1. Throughput (Mbps)
```
Gigabit link: 850–940 Mbps
Fast Ethernet: 90–95 Mbps
Large deviations matter.
```

2. Stability over time
```
Bad:

0–2 sec: 900 Mbps
2–4 sec: 300 Mbps
4–10 sec: 0 Mbps
```
- That screams:
- marginal fiber
- polarity issues
- bad optics

3. Retransmits (TCP)
- Example:
```
sender: 120 retransmits
0–5 retransmits → normal
```
- Dozens or hundreds → physical layer problem


















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

