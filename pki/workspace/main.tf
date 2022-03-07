terraform {
  required_providers {
    docker = {
      source = "kreuzwerker/docker"
      version = "~> 2.13.0"
    }
  }
}

provider "docker" {}

resource "docker_image" "pkiclient" {
  name         = "pkiclient:latest"
  keep_locally = false
}

resource "docker_container" "pkiclient" {
  image = docker_image.pkiclient.latest
  name  = "pkiclient"
  ports {
    internal = 443
    external = 9000
  }
}
