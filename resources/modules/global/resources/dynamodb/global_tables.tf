resource "aws_dynamodb_table" table-a {

  name             = "table-a-${var.stage}"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  billing_mode     = "PAY_PER_REQUEST"

  hash_key         = "id"

  attribute {
    name = "id"
    type = "S"
  }

 replica {
    region_name = var.regions.secondary_region
  }
}

resource "aws_dynamodb_table" table-b {

  name             = "table-b-${var.stage}"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"
  billing_mode     = "PAY_PER_REQUEST"

  hash_key         = "id"

  attribute {
    name = "id"
    type = "S"
  }

 replica {
    region_name = var.regions.secondary_region
  }
}

output "dynamodb_table_name_table-a" {
  value = aws_dynamodb_table.table-a.id
}

output "dynamodb_table_name_table-b" {
  value = aws_dynamodb_table.table-b.id
}
