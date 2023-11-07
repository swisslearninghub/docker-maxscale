.PHONY: default
.DEFAULT_GOAL := default

DREPO := artifactory.swisslearninghub.com/docker/maxscale-swarm

default:
	@docker build --no-cache -t $(DREPO) .
	@docker tag  $(DREPO) $(DREPO):latest
	@docker push $(DREPO):latest
