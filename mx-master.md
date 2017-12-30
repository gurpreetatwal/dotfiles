# Pairing MX Master Via Bluetooth

## Prereq
- must have bluetoothctl installed

## Steps

```bash
bluetoothctl
[bluetooth]# power off
[bluetooth]# power on
[bluetooth]# scan on
[bluetooth]# connect XX:XX:XX:XX:XX:XX
[MX Master]# trust
[MX Master]# connect XX:XX:XX:XX:XX:XX
[MX Master]# pair
[MX Master]# unblock
[MX Master]# power off
[bluetooth]# power on
```
