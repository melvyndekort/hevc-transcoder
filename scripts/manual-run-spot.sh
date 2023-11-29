#!/bin/sh

VIDEO=/tmp/video-$$.mp4
curl -sLo $VIDEO https://sample-videos.com/video123/mp4/480/big_buck_bunny_480p_2mb.mp4
aws s3 cp $VIDEO s3://mdekort.hevc/temp.mp4
rm -f $VIDEO

aws ecs run-task \
	--no-cli-pager \
  --capacity-provider capacityProvider=FARGATE_SPOT,weight=1 \
	--task-definition $(aws ecs list-task-definitions --no-cli-pager --query 'taskDefinitionArns[*]' --output text) \
	--network-configuration "$(cat <<-EOF
{
	"awsvpcConfiguration":{
		"subnets": $(aws ec2 describe-subnets --no-cli-pager --filter 'Name=tag:Name,Values=generic-public-*' --query 'Subnets[*].SubnetId'),
		"securityGroups": $(aws ec2 describe-security-groups --no-cli-pager --filter 'Name=group-name,Values=hevc-transcoder' --query 'SecurityGroups[*].GroupId'),
		"assignPublicIp": "DISABLED"
	}
}
EOF
)" \
	--overrides "$(cat <<-EOF
{
	"containerOverrides": [
		{
			"name":"hevc-transcoder",
			"environment": [
				{
					"name":"S3_BUCKET_NAME",
					"value":"mdekort.hevc"
				},
				{
					"name":"S3_OBJECT_KEY",
					"value":"temp.mp4"
				}
			]
		}
	]
}
EOF
)"
