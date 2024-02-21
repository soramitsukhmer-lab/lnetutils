target "docker-metadata-action" {}
target "github-metadata-action" {}

target "template" {
  inherits = [
    "docker-metadata-action",
    "github-metadata-action",
  ]
}

target "default" {
  inherits = [
    "template",
  ]
  platforms = [
    "linux/amd64",
    "linux/arm64"
  ]
}

target "dev" {
  inherits = [
    "template",
  ]
  tags = [
    "soramitsukhmer-lab/lnetutils:local"
  ]
}
