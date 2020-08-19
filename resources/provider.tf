provider "aws" {
  version = "~> 3.0"
  alias   = "primary_region"
  region  = var.regions["primary_region"]
}

provider "aws" {
  version = "~> 3.0"
  alias   = "secondary_region"
  region  = var.regions["secondary_region"]
}
