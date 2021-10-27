STACK_NAME?=vpc

validate-template:
	 aws cloudformation validate-template \
 			--template-body file://vpc.yml

create-stack:
	aws cloudformation create-stack --stack-name $(STACK_NAME) \
	        --template-body file://vpc.yml \
	        --parameters file://parameters.json \
	        --region eu-central-1 \
	        --capabilities CAPABILITY_NAMED_IAM

update-stack:
	aws cloudformation update-stack --stack-name $(STACK_NAME) \
	        --template-body file://vpc.yml \
	        --parameters file://parameters.json \
	        --region eu-central-1 \
	        --capabilities CAPABILITY_NAMED_IAM

delete-stack:
	aws cloudformation delete-stack --stack-name $(STACK_NAME) \
	        --region eu-central-1
