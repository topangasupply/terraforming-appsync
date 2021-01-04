# `terraforming-appsync`

## Set up steps

*Note, these are not tested in full. Please raise an issue if you're having trouble and it may be something we should provide clarification on.*

1. Create an aws account if you don't have one you'd like to use. 
2. Configure a user with sufficient permissions to deploy this application (for demo purposes the root user will suffice)
3. Add a new profile to your local aws profiles called "terraforming-appsync" with the credential keys for your user. I simply added a new block to my file in the default location : `~/.aws/credentials`. If you want to change the profile name, it is located in `init.tf`.
4. Change the variable blocks in `variables.tf` to match the id and name of your account.
5. [Install](https://www.terraform.io/downloads.html) the `terraform` executable and have it on your PATH. I prefer to use [tfswitch](https://www.terraform.io/downloads.html) because it's very handy if you are working on projects with different terraform versions.
6. Run `terraform init` to initialize the project. We're going to manage terraform's state file locally for demonstration simplicity, but consider using dynamo or s3 for anything more.
7. Enter the appropriate variables when prompted. Alternatively, you can add a default value in `variables.tf` to avoid doing this every time.
8. Run `terraform apply`

## Changing the Lambda

*Note, we use Serverless for most of our lambda development primarily because of how the `python-serverless-requirements` plugin manages packaing. We've used terraform here, because it's the most expedient way to demonstrate the integration.*

1. The deployment directory is `./src`. Edit this directory as you please.
2. If you change the handler, you'll need to update that in the terraform resources.
3. Run `make package` to zip the deployment directory.
4. Run `terraform apply`.

