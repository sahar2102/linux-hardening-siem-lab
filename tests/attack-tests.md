# Attack simulations (from the Kali Linux VM)

All tests were run in the isolated VirtualBox lab against the hardened server
(`192.168.56.102`), only to validate the security controls.

| Test | Tool / command | Expected result | Control validated |
|------|----------------|-----------------|-------------------|
| Port scan | `nmap -sS -p- 192.168.56.102` | Only SSH (2102) open, other ports filtered | UFW default deny |
| Service/version detection | `nmap -sV -p 2102 192.168.56.102` | OpenSSH detected on the custom port | Attack surface reduced |
| SSH brute force | `hydra -l sahar -P passwords.txt -s 2102 ssh://192.168.56.102` | Attempts fail, attacker IP banned | Key-only auth, Fail2ban, faillock |
| DoS (SYN flood) | `hping3 -S --flood -p 2102 192.168.56.102` | Traffic rate-limited, alerts raised | UFW `limit`, IDS / Wazuh alerts |
| Ping | `ping 192.168.56.102` | No reply | ICMP blocked |

Verification on the server side:

```bash
sudo fail2ban-client status sshd      # banned IPs
sudo faillock --user sahar            # failed login counter
sudo tail -f /var/log/ufw.log         # blocked packets
```

Alerts (failed SSH logins, port scans, flooding) were then checked in the Wazuh dashboard.
