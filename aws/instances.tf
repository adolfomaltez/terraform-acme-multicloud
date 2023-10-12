
# WEBSERVER PUBLIC ZONE A
resource "aws_network_interface" "webserver-interface-a" {
  subnet_id   = aws_subnet.public_subnet_a.id
  private_ips = ["10.0.11.11"]
  security_groups = ["${aws_security_group.vpc_secgroup.id}"]
  tags = {
    Name = "webserver-interface-a-0"
  }
}

resource "aws_instance" "webserver-a" {
  ami           = "ami-0c840c04a7ac8abb9"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name

  network_interface {
    network_interface_id = aws_network_interface.webserver-interface-a.id
    device_index         = 0
  }

  provisioner "file" {
    source      = "webserver.sh"
    destination = "/tmp/webserver.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/webserver.sh",
      "sudo /tmp/webserver.sh",
    ]
  }

  connection {
    type        = "ssh"
    user        = "admin"
    password    = ""
    private_key = tls_private_key.key_pair.public_key_openssh
    host        = self.public_ip
  }

  tags = {
    Name = "webserver-a"
  }

  depends_on = [aws_key_pair.key_pair]
}

# WEBSERVER PUBLIC ZONE B
resource "aws_network_interface" "webserver-interface-b" {
  subnet_id   = aws_subnet.public_subnet_b.id
  private_ips = ["10.0.12.11"]
  security_groups = ["${aws_security_group.vpc_secgroup.id}"]
  tags = {
    Name = "webserver-interface-b-0"
  }
}

resource "aws_instance" "webserver-b" {
  ami           = "ami-0c840c04a7ac8abb9"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.key_pair.key_name

  network_interface {
    network_interface_id = aws_network_interface.webserver-interface-b.id
    device_index         = 0
  }

  provisioner "file" {
    source      = "webserver.sh"
    destination = "/tmp/webserver.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/webserver.sh",
      "sudo /tmp/webserver.sh",
    ]
  }

  connection {
    type        = "ssh"
    user        = "admin"
    password    = ""
    private_key = tls_private_key.key_pair.public_key_openssh
    host        = self.public_ip
  }

  tags = {
    Name = "webserver-b"
  }
  depends_on = [aws_key_pair.key_pair]
}

# EIP
resource "aws_eip" "webserver-a-eip" {
  instance = aws_instance.webserver-a.id
}

resource "aws_eip" "webserver-b-eip" {
  instance = aws_instance.webserver-b.id
}
