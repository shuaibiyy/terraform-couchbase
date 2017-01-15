# Couchbase Deployer

This project deploys a couchbase server on an EC2 instance using terraform.

The terraform script stores the terraform state remotely in an S3 bucket. The Makefile by default sets up a copy of the remote state if it doesn’t exist and then runs either `terraform plan` or `terraform apply` depending on the target.

## Persistence

Terraform attaches an EBS device to the EC2 instance that gets created. You can setup a scheduled backup of the EBS volume by following this [tutorial](http://docs.aws.amazon.com/AmazonCloudWatch/latest/events/TakeScheduledSnapshot.html).

The first time you run the project, you'll have to setup the EBS device. To do that, add this command to `setup.sh` right before the `mount` command:
```
sudo mkfs -t ext4 /dev/xvdf
```

You'll also need to replace the `snapshot_id` field of the `ebs_block_device` block configuration in `main.tf`.

## Usage

Before you run the Makefile, you should set the following environment variables to authenticate with AWS:
```
$ export AWS_ACCESS_KEY_ID= <your key> # to store and retrieve the remote state in s3.
$ export AWS_SECRET_ACCESS_KEY= <your secret>
$ export AWS_DEFAULT_REGION= <your bucket region e.g. us-west-2>
$ export TF_VAR_access_key=$AWS_ACCESS_KEY # exposed as access_key in terraform scripts
$ export TF_VAR_secret_key=$AWS_SECRET_ACCESS_KEY # exposed as secret_key in terraform scripts
$ export TF_VAR_ebs_snapshot_id=<couchbase snapshot id> ID of an EBS snapshot to base the volume off of.
```

### Run 'terraform plan'

    make

### Run 'terraform apply'

    make apply

Upon completion, terraform will output the DNS name of the Couchbase instance, e.g.:
```
cb_instance = [ ec2-54-244-233-202.us-west-2.compute.amazonaws.com ]
```

## Credits

* The Makefile idea (and the Makefile itself) is taken from this [blog post](http://karlcode.owtelse.com/blog/2015/09/01/working-with-terraform-remote-statefile/).
