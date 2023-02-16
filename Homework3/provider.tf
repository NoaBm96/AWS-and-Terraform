provider "aws" {
 region = var.region
 profile = "noa-admin"

 default_tags {
     tags = {
      Owner   = var.owner_tag
      Purpose = var.purpose_tag
    }
  }
}

