# x11vnc-novnc-agent

Docker image to extend your environment with VNC functionality

It is build based on [x11vnc](https://github.com/LibVNC/x11vnc) as vnc server
and [noVNC](https://github.com/novnc/noVNC) as web VNC client

## Usage

This image can be used as sidecar to your k8s app. For example if you are running k8s on the edge, and you have some
kiosk app with XServer, where you want to be able to hijack it remotely.
Simply add sidecar container:

```yaml
        - name: vnc
          image: slomkarafa/x11vnc-novnc-agent:0.1.0
          ports:
            - name: vnc
              containerPort: 6080
              protocol: TCP
          volumeMounts:
            - name: x11-xauthority
              mountPath: /root
              subPath: .Xauthority
          securityContext:
            privileged: true  # VNC may need privileged access to shared resources
```

And you should be able to reach noVNC web UI under `/vnc.html` path of your Port Forward, Ingress or however you will
access it.
As you see the only thing you need to provide is `.Xauthority` file from X11 server and the rest should work out of the
box.

You can simply extend it by using your own `run.sh` script.

For example if you want to disable any pointers when connecting via VNC session:
```yaml
disable-touchscreen.sh: |
    # /bin/bash
  for id in $(xinput list | grep -Ei "touch|mouse" | sed -n "s/.*id=\([0-9]\+\).*/\1/p"); do xinput disable "$id"; done
enable-touchscreen.sh: |
  # /bin/bash
  for id in $(xinput list | grep -Ei "touch|mouse" | sed -n "s/.*id=\([0-9]\+\).*/\1/p"); do xinput enable "$id"; done
run.sh: |
  # /bin/bash
  x11vnc -nopw -forever -shared -afteraccept 'bash disable-touchscreen.sh' -gone 'bash enable-touchscreen.sh' \
  & websockify --web=/usr/share/novnc/ 6080 localhost:5900 \
  & wait -n; exit 1
```
