terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.65.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      system_name = "spot-instance"
      env         = "dev"
      provision   = "terraform"
    }
  }
}

## Network

module "network" {
  source       = "../../modules/network"
  cidr_vpc     = "10.10.0.0/16"
  cidr_public1 = "10.10.1.0/24"
  cidr_public2 = "10.10.2.0/24"
  az_public1   = "ap-northeast-1a"
  az_public2   = "ap-northeast-1c"
}

module "spot" {
  source    = "../../modules/spot"
  VPCID     = module.network.VPCID
  public1ID = module.network.public1ID
}

module "SpotInterruptionNotice" {
  source = "../../modules/SpotInterruptionNotice"
  email  = "<メールアドレスを入れる>"
}