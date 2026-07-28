# iperf

## Location Report Script

`~/iperf-3.14/run_iperf_location_report.sh` runs a forward + reverse iperf3
test between a Linux node and a fixed target (Windows laptop/server), then
writes a PASS/WARN/FAIL summary to `~/iperf_reports/<date>_<LOCATION>/summary.txt`.

Usage:
```
cd ~/iperf-3.14
sudo ./run_iperf_location_report.sh <LOCATION_NAME>
```

The target machine must be running `iperf3 -s` before the script starts.

### TARGET_IP is hardcoded per site

The script has `TARGET_IP` hardcoded near the top (e.g. `192.168.103.65` for
Plant 2). Before running at a different site/subnet, update it to match the
laptop/server's actual IP on that network:

```
sed -i 's/TARGET_IP="<old-ip>"/TARGET_IP="<new-ip>"/' ~/iperf-3.14/run_iperf_location_report.sh
```

Example (Control Room / JB test, laptop at `172.17.17.182`):
```
sed -i 's/TARGET_IP="192.168.103.65"/TARGET_IP="172.17.17.182"/' ~/iperf-3.14/run_iperf_location_report.sh
```

Verify the change:
```
grep TARGET_IP ~/iperf-3.14/run_iperf_location_report.sh
```

## Known Issue: TP-LINK USB Ethernet adapters cap throughput (~85-95 Mbps)

The Windows laptop used as the iperf3 target has no built-in Ethernet NIC —
both its Ethernet interfaces are TP-LINK Gigabit Ethernet USB adapters
(likely Realtek RTL8153-family chipset). These report a `1 Gbps` link speed
in `Get-NetAdapter`, but real throughput through them caps around 85-95 Mbps
regardless of the remote device, subnet, or switch involved — confirmed
2026-07-28 by getting the same ~85-95 Mbps result across multiple different
nodes/subnets/switches, including tests where both ends were on the same
subnet with no routing hop.

**Impact:** any iperf3 test run against this laptop will currently read as
"low throughput" even on a genuinely healthy Gigabit link. Do not trust a
FAIL/low-throughput result from this laptop's iperf3 client/server until
this is fixed or worked around.

**Fix (not yet applied as of 2026-07-28):** update/replace the TP-LINK USB
adapter driver (Realtek RTL8153 chipset drivers are commonly the cause),
confirm the adapter is enumerating at USB3/SuperSpeed in Device Manager, and
disable USB selective suspend / power-saving on the adapter. Alternatively,
substitute a device with a real built-in Gigabit NIC as the target when
testing plant links, to avoid this bottleneck entirely.