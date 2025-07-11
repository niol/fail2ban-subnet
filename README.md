# fail2ban block ip/network subnet

A python script that group IPs into network range, to block attacks
from a network range address, inspired by
[fail2ban-block-ip-range](https://github.com/WKnak/fail2ban-block-ip-range).

The script regularly scans list of banned ip by querying the fail2ban
server process, and tries to identify bad networks, that is networks
that have more than _treshold_ banned ips. When such networks are identified:

1. ips in this network are unbanned
2. the network is banned

As all those commands go through the fail2ban ban manager, configured
increments on recidive are enforced.

Current limitations:

- unbanning can be slow with large ip sets, which opens a window for
bad ips to access the protected service, before the whole bad network is
banned.
- currently, the script bans `/24` for `ipv4` and `/48` for `ipv6`,
this could be configurable, or growing to larger masks in case
of bad adjacent networks.
- if using `nftables`, `auto-merge` may lead to failures to unban
when ban time is elpased.

## Requirements

- python3
- python3-systemd

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

See [nftables.conf - add support for cidr notation #3291](https://github.com/fail2ban/fail2ban/pull/3291).

## Example run

```
systemd[1]: Starting fail2ban-subnet.service - fail2ban block subnet / runjob triggered by timer...
fail2ban-subnet[1285274]: Identified 47.79.207.0/24 with 69 bad ips
fail2ban-subnet[1285274]: Identified 2001:ee0:4b71::/48 with 9 bad ips
fail2ban-subnet[1285274]: Identified 2001:ee0:4f3e::/48 with 748 bad ips
systemd[1]: fail2ban-subnet.service: Deactivated successfully.
```
