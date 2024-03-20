terraform {
  backend "s3" {
    bucket = "jenkins-terraform-eks-cicd"
    key    = "jenkins-eks/terraform.tfstate"
    region = "us-east-1"
  }
}