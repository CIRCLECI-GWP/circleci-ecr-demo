all: run

name = sai-test
registry = 615875458684.dkr.ecr.us-east-1.amazonaws.com/sai-test

ifndef version
$(error "version is not set!")
endif

image:
	@echo "Building docker image..."
	docker build -t $(name):$(version) .

publish: image
	@echo "Publishing Docker image to ECR..."
	eval $(shell aws ecr get-login --region us-east-1 --no-include-email)
	docker tag $(name):$(version) $(registry):latest
	docker tag $(name):$(version) $(registry):$(version)
	docker push $(registry):latest
	docker push $(registry):$(version)

deploy:
	@echo "Deploying to $(env)..."
	fargate service deploy --cluster $(env)-$(name) --service $(env)-$(name) --image $(registry)/$(name):$(version)
