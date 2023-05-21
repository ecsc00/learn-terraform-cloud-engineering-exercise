#attempt to recreate the previous assingments infrastructure 
/*Including the use of six subnets: 6 pub, 3 priv

Utilise 3 AZ
Recreate an IG to allow connectivity from within pub subnets 
Recreate the NAT gateway to route traffic any priv subnet instances need to public subnet the out.

Restrict SSH in to both subnets only from specified IP.*/

#make variables for region, subnets, cidr, subnets AZ, ssh IP

#variables set up a more cleaner use & reuse of key information
variable "region_lon" {
  default = "eu-west-2"
}

variable "cidr_range" {
  default = "10.0.0.0/16"
}


variable "public_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  default = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  default = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
}

variable "ssh_access_ip" {
  default = "20.108.10.67/32" # This CIDR format allows only one specific IP
}

#setting aws region
provider "aws" {
  region = var.region_lon
}

# new vpc with desired cidr range & active dns services
resource "iac_vpc" "main" {
  cidr_block = var.cidr_range
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "main"
  }
}
