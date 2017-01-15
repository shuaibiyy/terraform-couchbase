variable "access_key" {
  description = "The AWS access key."
}

variable "secret_key" {
  description = "The AWS secret key."
}

variable "region" {
  description = "The AWS region to create resources in."
  default = "us-east-1"
}

variable "s3_bucket" {
  description = "S3 bucket to store terraform remote state and artifactory data."
  default = "db.mydomain.com"
}

variable "key_name" {
  description = "Name of key pair. Must exist in chosen region."
}

variable "instance_type" {
  default = "t2.micro"
}

variable "amis" {
  type = "map"
  description = "Which AMI to spawn. Defaults to Amazon ECS-optimized AMI."
  default = {
    us-east-1      = "ami-2d39803a"
    us-west-1      = "ami-48db9d28"
    us-west-2      = "ami-d732f0b7"
  }
}

variable "ebs_snapshot_id" {
  description = "Snapshot ID of Couchbase EBS backup."
  default = ""
}

variable "cb_version" {
  description = "Couchbase version."
  default = "4.1.2"
}

variable "cb_password" {
  description = "Couchbase password"
}
