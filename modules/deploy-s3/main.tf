#Ressource bucket s3 qui se nomme "pa-esgi-2023-b1"

resource "aws_s3_bucket" "pa-esgi-2023-b1" {
  bucket = var.bucket_name
}

#Ressource pour lié la policy au bucket "pa-esgi-2023-bXXX"
#Cette policy va réaliser l'action sur le bucket s3 de deny les droits des ressources du bucket
#On rajoute une condition afin que notre EC2 puisse gérer les ressources du bucket s3
resource "aws_s3_bucket_policy" "public_read_access" { 
  bucket = aws_s3_bucket.pa-esgi-2023-b1.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowIPAddress",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.pa-esgi-2023-b1.id}/*"
      ],
      "Condition": {
        "NotIpAddress": {
          "aws:SourceIp": "${var.ec2-public-ip}"
        }
      }
    }
  ]
}
EOF
}