### Report
sudo chmod +x run_iperf_location_report.sh

udo nano run_iperf_location_report.sh
pi@raspberrypi:~/iperf-3.14 $ sudo chmod +x run_iperf_location_report.sh
pi@raspberrypi:~/iperf-3.14 $ sudo pkill iperf3
pi@raspberrypi:~/iperf-3.14 $ sudo ./run_iperf_location_report.sh LAB

sudo cat /root/iperf_reports/<latest_folder>/summary.txt

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

4. Run basic test

- On camera (server mode)
```
iperf3 -s
```

- On server or laptop (client mode)
```
iperf3 -c <IP-of-A>
```

5. Reverse roles (MOST IMPORTANT)
- Stop the server and swap roles
- On device B
```
iperf3 -s
```
- On device A
```
iperf3 -c <IP-of-B>
```

6. Reverse flag (one-command bidirectional test)
- Instead of swapping manually:
```
iperf3 -c <IP> -R
```

- -R = reverse (server sends to client)
- This is great when you’re short on time.

7. Stress / saturation test
```
iperf3 -c <IP> -t 30 -P 4
```
- What this does:
```
-t 30 → 30 seconds
-P 4 → 4 parallel streams
```
- What it reveals
- Marginal fiber
- Dirty connectors
- Bad SFPs
- Switch buffers failing
- If this test:
- starts OK then collapses → physical issue
- stays stable → link is solid

8. UDP test (optional but powerful)
```
iperf3 -c <IP> -u -b 500M
```
- Look for:
- lost/total datagrams
- jitter
- Packet loss > 0.1% = problem
- High jitter = unstable link
- UDP is brutal — it exposes weak links fast.


##### The single most telling comparison
- Run these two back-to-back:
```
iperf3 -c <IP>
iperf3 -c <IP> -R
```
```
Interpret like this:
Result	Meaning
Both good	Physical layer OK
Forward good, reverse bad	TX/RX polarity issue
Forward bad, reverse good	Same — direction flipped
Both bad	Optics / cable / switch
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

4. Direction symmetry
- This is the biggest tell.
- Result	Meaning
```
Both directions similar	Physical layer OK
One fast, one slow/0	TX/RX polarity issue
One works, other won’t connect	Broken direction
Both bad	Optics / cable / switch
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

