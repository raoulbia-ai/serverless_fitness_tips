terraform {
  backend "s3" {
    bucket = "bsc.sandbox.terraform.state"
    key    = "serverless_fitness_tips"
    region = "us-east-2"
  }
}