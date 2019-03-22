build:
	docker build -t obs-package-status .

run:
	docker run --restart always -v $(PWD):/home/package-bot/obs-package-status -e RUN_EVERY=600 -d obs-package-status


