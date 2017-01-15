provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

data "terraform_remote_state" "cb_tfstate" {
  backend = "s3"
  config {
    bucket = "${var.s3_bucket}"
    key = "terraform/terraform.tfstate"
    region = "${var.region}"
  }
}

resource "aws_security_group" "cb_sg" {
  name = "cb_sg"
  description = "Allows Couchbase traffic"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8091
    to_port = 8091
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8092
    to_port = 8092
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8093
    to_port = 8093
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "allow_couchbase_ports"
  }
}

resource "aws_instance" "cb" {
  ami = "${lookup(var.amis, var.region)}"
  instance_type = "${var.instance_type}"
  key_name = "${var.key_name}"
  security_groups = ["${aws_security_group.cb_sg.name}"]

  ebs_block_device {
    device_name = "/dev/xvdf"
    snapshot_id = "${var.ebs_snapshot_id}"
    volume_size = "40"
    volume_type = "standard"
    delete_on_termination = false
  }

  connection {
    user = "ubuntu"
    private_key = "${file("./${var.key_name}.pem")}"
  }

  provisioner "file" {
    source = "setup.sh"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup.sh",
      "/tmp/setup.sh ${var.cb_version} ${var.cb_password}"
    ]
  }

  tags {
    Name = "cb"
  }
}

output "couchbase_instance" {
  value = "[ ${aws_instance.cb.public_dns} ]"
}
