#!/bin/bash

# ================= CONFIG =================
LOCATION="$1"
TARGET_IP="172.17.17.182"    # Windows laptop / server
TEST_DURATION=10
PORT=5201
PARALLEL_STREAMS=4            # Used for reverse test
IFACE="eth0"                  # Interface to read negotiated speed from
# =========================================

if [ -z "$LOCATION" ]; then
  echo "Usage: $0 <LOCATION_NAME>"
  exit 1
fi

# Kill any stale iperf servers
pkill iperf3 2>/dev/null
sleep 1

DATE=$(date +"%Y-%m-%d_%H-%M-%S")
OUTDIR="$HOME/iperf_reports/${DATE}_${LOCATION}"
mkdir -p "$OUTDIR"

SUMMARY="$OUTDIR/summary.txt"

# -------- NEGOTIATED LINK SPEED (ground truth) --------
NIC_SPEED=$(cat "/sys/class/net/$IFACE/speed" 2>/dev/null)

{
  echo "iperf Location Test Report"
  echo "Location: $LOCATION"
  echo "Date: $(date)"
  echo "Node IP: $(hostname -I | awk '{print $1}')"
  echo "Target IP: $TARGET_IP"
  echo "Interface: $IFACE (negotiated: ${NIC_SPEED:-unknown} Mbps)"
  echo "Duration: ${TEST_DURATION}s | Port: $PORT | Reverse Streams: $PARALLEL_STREAMS"
  echo ""
} > "$SUMMARY"

# -------- PREFLIGHT CHECK --------
if ! ping -c 2 -W 1 "$TARGET_IP" >/dev/null 2>&1; then
  {
    echo "Overall Quality: FAIL"
    echo "Reason: Target unreachable (ping failed)"
  } >> "$SUMMARY"

  echo ""
  echo "===================================="
  echo "Location test complete: $LOCATION"
  echo "Quality: FAIL"
  echo "Reason: Target unreachable"
  echo "Report saved to: $OUTDIR"
  echo "===================================="
  exit 1
fi

# -------- FORWARD TEST (Target -> Node) --------
echo "Running FORWARD test (Target → Node)..."
iperf3 -s -1 -p $PORT > "$OUTDIR/forward_server.txt" 2>&1 &
sleep 2
iperf3 -c "$TARGET_IP" -p $PORT -t "$TEST_DURATION" > "$OUTDIR/forward_client.txt" 2>&1

# -------- REVERSE TEST (Node -> Target) --------
echo "Running REVERSE test (Node → Target)..."
iperf3 -c "$TARGET_IP" -p $PORT -R -t "$TEST_DURATION" -P $PARALLEL_STREAMS > "$OUTDIR/reverse_client.txt" 2>&1

# -------- PARSING FUNCTIONS --------
extract_sender() {
  local FILE="$1"

  if grep -q "\[SUM\].*sender" "$FILE"; then
    grep "\[SUM\].*sender" "$FILE" | tail -1
  else
    grep "sender" "$FILE" | tail -1
  fi
}

extract_mbps() {
  echo "$1" | awk '{for(i=1;i<=NF;i++) if ($i=="Mbits/sec") print $(i-1)}'
}

# -------- PARSE RESULTS --------
FWD_LINE=$(extract_sender "$OUTDIR/forward_client.txt")
REV_LINE=$(extract_sender "$OUTDIR/reverse_client.txt")

FWD_MBPS=$(extract_mbps "$FWD_LINE")
REV_MBPS=$(extract_mbps "$REV_LINE")

# Retransmits (forward test only)
RETRANS=0
FIELD_COUNT=$(echo "$FWD_LINE" | awk '{print NF}')
if [ "$FIELD_COUNT" -ge 9 ]; then
  CANDIDATE=$(echo "$FWD_LINE" | awk '{print $(NF-2)}')
  [[ "$CANDIDATE" =~ ^[0-9]+$ ]] && RETRANS="$CANDIDATE"
fi

# -------- RAW OUTPUT (AUDIT) --------
{
  echo "Raw Forward Tail:"
  tail -n 6 "$OUTDIR/forward_client.txt" 2>/dev/null || echo "N/A"
  echo ""
  echo "Raw Reverse Tail:"
  tail -n 6 "$OUTDIR/reverse_client.txt" 2>/dev/null || echo "N/A"
  echo ""
} >> "$SUMMARY"

# -------- LINK CLASSIFICATION (from actual negotiated speed, not throughput) --------
case "$NIC_SPEED" in
  1000) LINK_CLASS="Gigabit Ethernet" ;;
  100)  LINK_CLASS="Fast Ethernet (100 Mbps)" ;;
  10)   LINK_CLASS="10 Mbps Ethernet" ;;
  *)    LINK_CLASS="Unknown (interface reported: ${NIC_SPEED:-N/A} Mbps)" ;;
esac

FWD_INT=${FWD_MBPS%.*}
REV_INT=${REV_MBPS%.*}

# -------- QUALITY LOGIC --------
QUALITY="PASS"
REASON="Link healthy"

if [ -z "$FWD_MBPS" ] || [ -z "$REV_MBPS" ]; then
  QUALITY="FAIL"
  REASON="Incomplete test or parsing failure"
elif [ "$LINK_CLASS" = "Gigabit Ethernet" ] && ( [ "$FWD_INT" -lt 800 ] || [ "$REV_INT" -lt 800 ] ); then
  QUALITY="FAIL"
  REASON="Low throughput for Gigabit link (negotiated 1000Mb/s but not delivering it)"
elif [ "$LINK_CLASS" = "Fast Ethernet (100 Mbps)" ] && ( [ "$FWD_INT" -lt 80 ] || [ "$REV_INT" -lt 80 ] ); then
  QUALITY="FAIL"
  REASON="Low throughput for Fast Ethernet link"
elif [[ "$LINK_CLASS" == Unknown* ]]; then
  QUALITY="WARN"
  REASON="Could not read negotiated speed on $IFACE; throughput not evaluated against a link class"
elif [ "$RETRANS" -gt 10000 ]; then
  QUALITY="FAIL"
  REASON="Very high retransmits ($RETRANS)"
elif [ "$RETRANS" -gt 2000 ]; then
  QUALITY="WARN"
  REASON="Elevated retransmits ($RETRANS)"
fi

# -------- SUMMARY --------
{
  echo "Parsed Results:"
  echo "Forward Throughput: ${FWD_MBPS:-N/A} Mbps"
  echo "Reverse Throughput: ${REV_MBPS:-N/A} Mbps"
  echo "Retransmits (forward): $RETRANS"
  echo "Link Classification: $LINK_CLASS"
  echo ""
  echo "Overall Quality: $QUALITY"
  echo "Reason: $REASON"
} >> "$SUMMARY"

echo ""
echo "===================================="
echo "Location test complete: $LOCATION"
echo "Quality: $QUALITY"
echo "Reason: $REASON"
echo "Report saved to: $OUTDIR"
echo "Files: forward_client.txt, reverse_client.txt, forward_server.txt"
echo "===================================="
