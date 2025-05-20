terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

# Container Registry
resource "yandex_container_registry" "my_registry" {
  name = "k8s-registry"
}


# Bastion host
resource "yandex_compute_instance" "bastion_host" {
  name        = "bastion"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"

  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8r7e7939o13595bpef"  # Ubuntu 22.04
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = var.subnet_a
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys   = "ubuntu:${file(var.ssh_public_key_path)}"
    user-data  = file("${path.module}/bastion-cloud-init.yaml")
  }
}

# Kubernetes node 1
resource "yandex_compute_instance" "k8s_node1" {
  name        = "k8s-node1"
  zone        = "ru-central1-a"
  platform_id = "standard-v2"

  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8r7e7939o13595bpef"  # Ubuntu 22.04
      size     = 30
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = var.subnet_a
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

# Kubernetes node 2
resource "yandex_compute_instance" "k8s_node2" {
  name        = "k8s-node2"
  zone        = "ru-central1-b"
  platform_id = "standard-v2"

  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8r7e7939o13595bpef"  # Ubuntu 22.04
      size     = 30
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = var.subnet_b
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}

# Kubernetes node 3
resource "yandex_compute_instance" "k8s_node3" {
  name        = "k8s-node3"
  zone        = "ru-central1-d"
  platform_id = "standard-v2"

  allow_stopping_for_update = true

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8r7e7939o13595bpef"  # Ubuntu 22.04
      size     = 30
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id = var.subnet_d
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }
}
