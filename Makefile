build:
	swift build

release-build:
	swift build -c release -Xswiftc -static-stdlib

update:
	swift package update

image:
	docker build -t timezonelookup .

push:
	docker save timezonelookup | bzip2 > timezonelookup-prod.bz2
	scp timezonelookup-prod.bz2 docker-compose.yml darkman@jupiter.local:docker/timezonelookup/
	ssh darkman@jupiter.local "cd docker/timezonelookup; bzcat timezonelookup-prod.bz2 | docker load"

deploy:
	ssh darkman@jupiter.local "cd docker/timezonelookup; docker-compose down; nohup docker-compose up &"
