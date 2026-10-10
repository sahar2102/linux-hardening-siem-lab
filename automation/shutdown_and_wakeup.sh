#!/usr/bin/env bash
# Reduce the night-time attack surface: power off at 21:00, wake up at 06:00.
# Installed as /usr/local/bin/shutdown_and_wakeup.sh and run from cron at 20:30.

# Program the hardware clock to wake the machine tomorrow at 06:00
rtcwake -m no -t "$(date +%s -d 'tomorrow 06:00')"
# Shut down at 21:00
shutdown -h 21:00
