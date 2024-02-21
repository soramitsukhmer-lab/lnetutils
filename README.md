# lnetutils
A lightweight networking utilities such as ping, traceroute, etc.

## Deploy

```sh
docker run -d --log-driver=json-file --log-opt max-size=5m --log-opt max-file=5 \
		-e TARGET_HOST=10.20.33.10 \
	ghcr.io/soramitsukhmer-lab/lnetutils:main
```

## Gather logs from container

```
Usage:  docker logs [OPTIONS] CONTAINER

Fetch the logs of a container

Aliases:
  docker container logs, docker logs

Options:
      --details        Show extra details provided to logs
  -f, --follow         Follow log output
      --since string   Show logs since timestamp (e.g. "2013-01-02T13:23:37Z") or relative (e.g. "42m" for 42 minutes)
  -n, --tail string    Number of lines to show from the end of the logs (default "all")
  -t, --timestamps     Show timestamps
      --until string   Show logs before a timestamp (e.g. "2013-01-02T13:23:37Z") or relative (e.g. "42m" for 42 minutes)
```
