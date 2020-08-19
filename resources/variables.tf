variable stage {
  type    = string
  default = "dev"
}

variable acm_certificate {
  type = object({
    primary_region   = string
    secondary_region = string
  })
}

variable zone_id {
  type = string
}

variable domain_name {
  type = string
}

variable api_id {
  type = object({
    primary_region   = string
    secondary_region = string
  })
  default = {
    primary_region   = "primary"
    secondary_region = "secondary"
  }
}

variable api_stage {
  type    = string
  default = "dev"
}

variable api_stages {
  type    = list(string)
  default = ["dev"]
}

variable api_name {
  type = string
}

variable api_key {
  type = string
}

variable regions {
  type = object({
    primary_region   = string
    secondary_region = string
  })
  default = {
    primary_region   = "ap-northeast-1"
    secondary_region = "us-west-2"
  }
}
