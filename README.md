# ngs-bits-docker

This repository contains a Dockerfile for [ngs-bits](https://github.com/imgag/ngs-bits). The image is based on Ubuntu 24.04 and buildable for amd64 and arm64.

The image also contains a current version of the [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html).

## Usage

YOu can directly use the image from docker.io: `docker run --rm -it benekenobi/ngs-bits:latest` (latest release veresion, currently _2025_01_).

## Build

To build the image, you can use the following commands (tested on Ubuntu 24.04):

```bash
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
docker run --privileged --rm tonistiigi/binfmt --install all
sudo groupadd docker
sudo usermod -aG docker $USER
sudo apt-get install -y qemu-user-static
echo '{"features":{"containerd-snapshotter":true}}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
# relogin now to apply the group change
mkdir ngs-bits
cd ngs-bits/
wget https://raw.githubusercontent.com/MHH-Humangenetik/ngs-bits-docker/refs/heads/add-dockerfile/Dockerfile
docker buildx build --platform linux/amd64,linux/arm64 -t ngs-bits:master --build-arg NGS-BITS_VERSION=master .
```

The version of ngs-bits to checkout can be set with the build-arg `NGS-BITS_VERSION`. The default is `master` but it can be set to a version tag like `2025_01`.

## License

This repository is licensed under the MIT License (as is _ngs-bits_) - see the [LICENSE](LICENSE) file for details.
