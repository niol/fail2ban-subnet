# fail2ban block ip/network subnet

A python script that group IPs into network range, to block attacks
from a network range address

Inspired by https://github.com/WKnak/fail2ban-block-ip-range

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
