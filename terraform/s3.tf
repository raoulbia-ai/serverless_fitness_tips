data "aws_iam_policy_document" "site" {
  statement {
    effect = "Allow"
    principals {
      identifiers = module.cdn.cloudfront_origin_access_identity_iam_arns
      type        = "AWS"
    }
    actions   = ["s3:GetObject"]
    resources = ["${module.site.s3_bucket_arn}/*"]
  }
}

locals {
  site_directory = "${path.module}/files/workoutgenerator/build/"

  mime_types = {
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "png"  = "image/png"
    "json" = "application/json"
    "txt"  = "text/plain"
    "map"  = "application/octet-stream"
  }
}

module "site" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.site_domain

  attach_public_policy = true
  attach_policy        = true
  policy               = data.aws_iam_policy_document.site.json

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  expected_bucket_owner = data.aws_caller_identity.this.account_id

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

resource "aws_s3_object" "website-object" {
  for_each     = fileset(local.site_directory, "**/*")

  bucket       = module.site.s3_bucket_id
  key          = each.value
  source       = "${local.site_directory}/${each.value}"
  etag         = filemd5("${local.site_directory}/${each.value}")
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
}