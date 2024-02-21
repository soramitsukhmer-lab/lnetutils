# lnetutils
A lightweight networking utilities such as ping, traceroute, etc.

## Usage

```sh
docker run -d --log-driver=json-file --log-opt max-size=5m --log-opt max-file=5 \
		-e TARGET_HOST=10.20.33.10 \
	ghcr.io/soramitsukhmer-lab/lnetutils:main
```
