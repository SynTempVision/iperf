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