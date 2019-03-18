buid:
	docker build -t pull_request_package .

run:
	docker run --restart always -v $(PWD):/home/puller/pull_request_package -e RUN_EVERY=600 -d pull_request_package
