#VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "Jenkins-vpc"
  cidr = var.vpc_cidr

  azs            = data.aws_availability_zones.azs.names
  public_subnets = var.public_subnets

  enable_dns_hostnames    = true
  map_public_ip_on_launch = true
  tags = {
    NAME        = "Jenkins-VPC"
    Terraform   = "true"
    Environment = "dev"
  }
  public_subnet_tags = {
    Name = "Jenkins-subnet"

  }
}

#SG
module "sg" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "Jenkins-sg"
  description = "Security group for Jenkins server"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 8080
      to_port     = 8080
      protocol    = "tcp"
      description = "HTTP"
      cidr_blocks = "0.0.0.0/0" # Allowing traffic from any source IP
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "ssh"
      cidr_blocks = "0.0.0.0/0" # Allowing SSH traffic from any source IP
    },
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1" # Allow all protocols
      description = "All traffic"
      cidr_blocks = "0.0.0.0/0" # Allowing traffic from any source IP
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"        # Allow all protocols
      cidr_blocks = "0.0.0.0/0" # Allowing traffic to any destination IP
    }
  ]

  tags = {
    Name = "Jenkins-sg"
  }
}

#EC2
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "Jenkins-Server"

  instance_type               = var.instance_type
  key_name                    = "k8skey"
  monitoring                  = true
  vpc_security_group_ids      = [module.sg.security_group_id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = file("jenkins-install.sh")
  availability_zone           = data.aws_availability_zones.azs.names[0]
  tags = {
    Name        = "Jenkins-Server"
    Terraform   = "true"
    Environment = "dev"
  }
}

