terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "1.99.0"
    }
  }
}
provider "alicloud" {
  # Configuration options
  access_key = "LTAI5tLx8a7JJQU2UBwNwDtm"
  secret_key = "onYrXy31oxfD6ViYupskDdaHhFT22c"
  region = "cn-shenzhen"
}

resource "alicloud_vpc" "vpc" {
  name       = "tf_test_foo"
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "vsw" {
  vpc_id            = alicloud_vpc.vpc.id
  cidr_block        = "172.16.0.0/21"
  availability_zone = "cn-shenzhen-b"
}

resource "alicloud_security_group" "default" {
  name   = "default"
  vpc_id = alicloud_vpc.vpc.id
}

resource "alicloud_instance" "instance" {
  # cn-shenzhen
  availability_zone = "cn-shenzhen-b"
  security_groups   = alicloud_security_group.default.*.id
  # series III
  instance_type              = "ecs.n2.small"
  system_disk_category       = "cloud_efficiency"
  image_id                   = "centos_8_5_x64_20G_alibase_20220428.vhd"
  instance_name              = "test_foo"
  vswitch_id                 = alicloud_vswitch.vsw.id
  internet_max_bandwidth_out = 10
  password = "skyhellode123.."
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.default.id
  cidr_ip           = "0.0.0.0/0"
}
