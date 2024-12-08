FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        xinput \
        novnc \
        x11vnc && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY scripts .

EXPOSE 6080

CMD ["bash", "run.sh"]
