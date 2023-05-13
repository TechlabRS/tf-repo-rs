resource "aws_instance" "instance" {
  for_each               = var.components
  ami                    = data.aws_ami.centos.image_id
  instance_type          = each.value["instance_type"]
  vpc_security_group_ids = [data.aws_security_group.allow-all.id]

  tags = {
    Name = each.value["name"]
  }

  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      user     = "centos"
      password = "DevOps321"
      host     = self.private_ip
    }

    inline = [
      "rm -rf roboshop-shell",
      "git clone https://github.com/TechlabRS/myrepo",
      "cd myrepo",
      "sudo bash ${each.value["name"]}.sh"
    ]
  }
}


resource "aws_route53_record" "records" {
  for_each = var.components
  zone_id  = "Z016684615KU8Y3P3A8M9"
  name     = "${each.value["name"]}-dev.uknowme.tech"
  type     = "A"
  ttl      = 30
  records  = [aws_instance.instance[each.value["name"]].private_ip]
}
