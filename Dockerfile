FROM amd64/ubuntu

RUN apt-get update && apt-get install -y git wget build-essential gcc-aarch64-linux-gnu