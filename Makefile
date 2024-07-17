.PHONY: build-dev-release docker-build docker-run

build-dev-release:
	mix deps.get
	mix compile
	mix release
	echo "run _build/dev/rel/fibonacci_server/bin/server start"

docker-build:
	docker build . --tag fibonacci_server

docker-run:
	docker run \
		-e SECRET_KEY_BASE=${SECRET_KEY_BASE}\
		-e PHX_HOST=${PHX_HOST} \
		-p 4000:${PORT} -d fibonacci_server
