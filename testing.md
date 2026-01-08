### Force-reset the camera network (important)

- On camera:
```
ip addr flush dev eth0
ip route flush dev eth0
```

- Then:
```
ifconfig eth0 down
sleep 5
ifconfig eth0 up
```

- This forces a fresh DHCP DISCOVER.

### MAC-level visibility check (no installs)

- On OpenWrt:
```
ip neigh
```

- Plug camera in.

- See MAC appear? → L2 ok

- No MAC? → VLAN or bridge issue

### ARP broadcast test (simple)

- From OpenWrt:
```
arp -n
```

- If cameras don’t appear at all, DHCP never stood a chance

### DHCP log check (dnsmasq is always there)
```
logread | grep -i dhcp
```

- Plug camera
- No log entries → broadcast never arrived
- DISCOVER but no OFFER → wrong interface binding

### Kill and restart DHCP 
```
/etc/init.d/dnsmasq restart
```

### 
