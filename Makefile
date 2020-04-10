clean:
	rm -rvf build/ dist/ cld3/*.cpp *.so src/cld_3/ *.egg-info cld3/__pycache__ __pycache__ *.dist-info cld3/*.so

test:
	python -m pip install --disable-pip-version-check -e .
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

check:
	command -v check-wheel-contents || python -m pip install --disable-pip-version-check check-wheel-contents
	find . -name '*.whl' -type f -not -path "*venv*" -print0 | xargs -0 check-wheel-contents
