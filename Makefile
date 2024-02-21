.EXPORT_ALL_VARIABLES:
NODE_VERSION := 20
DOCKER_BAKE_TARGETS := dev

.PHONY: it
it: print build

print:
	@echo "Bake definition:"
	@docker buildx bake --print $(DOCKER_BAKE_TARGETS)
	@echo

build:
	@echo "Buiding images:"
	docker buildx bake $(DOCKER_BAKE_FILE) $(DOCKER_BAKE_TARGETS)
	@echo

run:
	docker run -it --rm --network host docker.io/soramitsukhmer-lab/lnetutils:local
