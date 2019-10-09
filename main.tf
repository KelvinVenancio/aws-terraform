#
# main Terraform file to describe automation
#

provider "aws" {
	access_key  = "${var.access_key}"
	secret_key  = "${var.secret_key}"
	region      = "${var.region}"
}

resource "aws_instance" "terra" {
	ami = "ami-04b9e92b5572fa0d1"
	availability_zone = "us-east-1c"
	instance_type = "t2.micro"
	key_name = "${var.key_name}"
	vpc_security_group_ids = ["${aws_security_group.terra.id}"]
	subnet_id = "${aws_subnet.public-subnet-in-us-east-1.id}"
	associate_public_ip_address = true
	source_dest_check = false

	connection {
		type = "ssh"
		host = "${aws_instance.terra.public_ip}"
		user = "ubuntu"
		port = "22"
		private_key = "${file("/home/kelvin/terraform/ssh/terraform.pem")}"
		agent = true
	}

	provisioner "remote-exec" {
	inline = [
		"sudo apt-get update",
		"sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
		"curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
		"sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\"",
		"sudo apt-get update",
		"sudo apt-get install docker-ce -y",
		"sudo systemctl start docker",
		"sudo systemctl enable docker"
	]
}

	tags = {
		Name = "docker-instance"
	}
}

output "public_ip" {
	value = aws_instance.terra.public_ip
	description = "The public IP of the web server"
}