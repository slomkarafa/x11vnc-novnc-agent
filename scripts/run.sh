# /bin/bash

x11vnc -nopw -forever -shared \
& websockify --web=/usr/share/novnc/ 6080 localhost:5900 \
& wait -n; exit 1