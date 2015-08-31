# Photo Store

Web application for storing and managing photo libraries that are stored using
cloud computing services.

It's intended to be deployed to [Heroku](https://www.heroku.com) and use
[Amazon Web Services] (https://aws.amazon.com/) for data storage. A library of
about 10GB can be stored for about $10/month. This provides storage that is
very safe from hardware failure (much safer than storage on a hard disk drive
in your house, for example). It can be securely accessed from any Internet
connection.

## Privacy Considerations

When used with Heroku/Amazon, the administrators of those systems will also be
able to access your photo library, but since these are infrastructure/platform
services privacy intrusions are probably less likely than services like
Facebook.

## Risks

 * Heroku or Amazon price increases.

# Setup

## Heroku / Amazon S3

1. Create AWS account:
  1. Visit [Amazon Web Services](https://aws.amazon.com).
  1. Click "Create an AWS Account".
  1. Follow steps to create an account.
1. Create AWS S3 bucket:
  1. From [AWS Console](https://console.aws.amazon.com)
  1. Click "S3".
  1. Click "Create Bucket".
  1. Enter bucket name. Suggest name that is the same as your Heroku
     application. Remember the name for later.
  1. Region: select region that matches the region of your Heroku application
     (US: "US Standard", Euro: "Ireland"). Remember the region for later.
  1. Click "Create".
1. Create AWS IAM User to allow application to access your S3 storage:
  1. From [AWS Console](https://console.aws.amazon.com)
  1. Click "Identity & Access Management".
  1. Click "Users".
  1. Click "Create New Users".
  1. Enter name "S3".
  1. Click "Create".
  1. Click "Show User Security Credentials".
  1. Remember "Access Key ID" and "Secret Access Key" for later.
  1. Click "Close".
  1. Click your new user.
  1. Click "Attach Policy".
  1. Check "AmazonS3FullAccess".
  1. Click "Attach Policy".
1. Create Heroku Application:
  1. Click [![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)
  1. Enter an app name, use lower case letters and hyphens only.
  1. Select region that matches your S3 configuration (US or EU).
  1. Enter HOST, use "<app-name>.herokuapp.com". (Can be changed later).
  1. Enter AWS and S3 options using values obtained from AWS configuration in
     previous steps. (Can be changed later).
  1. Click "Deploy for Free".
  1. Wait for app to deploy.
  1. Press "View".

TODO add admin account
TODO add user account

## Self Hosted

It should be possible to configure the application to run on your own hardware
without too much effort, instructions for doing so are not written. Feel free
to contribute some.

# Backup

## Heroku PGBackups

TODO

## Amazon Glacier

TODO
