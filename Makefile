clean:
	rm -rvf build/ dist/ cld3/*.cpp *.so src/cld_3/ *.egg-info cld3/__pycache__ *.dist-info

test:
	python -m pip install -e .
	python -m unittest discover -v -s .

PROTOBUF_VERSION ?= 3.11.4

image:
	@echo "Building Docker image for $(PROTOBUF_VERSION)"
	docker image build \
		-f docker/Dockerfile.protobuf \
		-t bsolomon1124/manylinux1_protobuf:latest \
		-t bsolomon1124/manylinux1_protobuf:$(PROTOBUF_VERSION) \
		--build-arg PROTOBUF_VERSION=$(PROTOBUF_VERSION) \
		docker/
