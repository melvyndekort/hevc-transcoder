#!/bin/sh

aws ecs run-task \
	--no-cli-pager \
	--task-definition $(aws ecs list-task-definitions --no-cli-pager --query 'taskDefinitionArns[0]') \
	--network-configuration "$(cat <<-EOF
{
	"awsvpcConfiguration":{
		"subnets": $(aws ec2 describe-subnets --no-cli-pager --filter 'Name=tag:Name,Values=generic-public-*' --query 'Subnets[*].SubnetId'),
		"securityGroups": $(aws ec2 describe-security-groups --no-cli-pager --filter 'Name=group-name,Values=hevc-transcoder' --query 'SecurityGroups[*].GroupId'),
		"assignPublicIp": "ENABLED"
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
					"value":"TODO/temp.mp4"
				}
			]
		}
	]
}
EOF
)"
