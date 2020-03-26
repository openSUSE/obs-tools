build:
	docker build -t obs-pullrequest-package .

run:
	docker run --restart always -v $(PWD):/home/package-bot/obs-pullrequest-package -e RUN_EVERY=600 -d obs-pullrequest-package


