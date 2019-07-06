run:
	docker run -it -P --rm -v "$(PWD)":/home/ubuntu/environment cs50/baseimage || true

build:
	docker build -t cs50/baseimage .

rebuild:
	docker build --no-cache -t cs50/baseimage .
