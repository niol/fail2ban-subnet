# fail2ban block ip/network subnet

A python script that group IPs into network range, to block attacks
from a network range address, inspired by
[fail2ban-block-ip-range](https://github.com/WKnak/fail2ban-block-ip-range).

The motivation for such banning is to ease the memory and CPU pressure
of managing banned IP lists with 100k+ adresses: when this happens, the kernel
begins to use memory for nftables instead of cache and adding/removing
rules corresponding to bans begins to take a significant amount of seconds
(on a modest late 2010s machine with a 8 Gib of RAM).

The script regularly scans list of banned ip by querying the fail2ban
server process, and tries to identify bad networks (`/24` for `ipv4`
and `/64` for `ipv6`), that is networks that have more than _treshold_
banned ips. When such networks are identified:

1. An algorithm tries to grow the subnetwork to adjacent above-treshold
   subnetworks up to some limit (`/16` for `ipv4` and `/48` for `ipv6`).
   Details of the prefix lengths ranges in bits for both IP protocols can
   be seen in the code. When a subnetwork could not be widen for more than
   a few iterations, do not try to grow it anymore to avoid banning too much
   subnetworks in-between.
2. ips in this network are unbanned
3. the network is banned

As all those commands go through the fail2ban ban manager (using the
fail2ban daemon UNIX socket protocol), configured increments on recidive
are enforced.

Current limitations:

- unbanning can be slow with large ip sets, which opens a window for
bad ips to access the protected service, before the whole bad network is
banned.
- if using `nftables`, `auto-merge` may lead to failures to unban
when ban time is elapsed.

## Requirements

- python3 >= 3.6 (for dicts to be ordered)
- python3-systemd (optional)

## Requirements if using nftables

If your `fail2ban` is configured to use `nftables`, you need to change the
following line in `/etc/fail2ban/action.d/nftables.conf`:

```
_nft_add_set = <nftables> add set <table_family> <table> <addr_set> \{ type <addr_type>\; \}
```

into

```
_nft_add_set = <nftables> add set <table_family> <table> <addr_set> \{ type <addr_type>\; flags interval\; auto-merge\; \}
```

See [nftables.conf - add support for cidr notation #3291](https://github.com/fail2ban/fail2ban/pull/3291). This should be in fail2ban >= 1.1.1 .

## Example run

```
jail [aibots-http] Identified 186.158.200.0/24 with 7 bad ips
jail [aibots-http] Identified 217.142.22.0/24 with 9 bad ips
jail [aibots-http] Identified 207.46.13.0/24 with 7 bad ips
jail [aibots-http] Identified 114.250.0.0/18 with 2 bad network(s)
jail [aibots-http] Identified 185.106.28.0/22 with 2 bad network(s)
jail [aibots-http] Identified 188.132.222.0/24 with 7 bad ips
jail [aibots-http] Identified 212.237.121.0/24 with 7 bad ips
jail [aibots-http] Identified 146.174.128.0/18 with 534 bad ips
jail [aibots-http] Identified 202.76.160.0/20 with 158 bad ips
jail [aibots-http] Identified 2001:ee0:4b71::/48 with 9 bad ips
jail [aibots-http] Identified 2001:ee0:4f3e::/48 with 748 bad ips
```
