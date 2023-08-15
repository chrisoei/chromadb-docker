# $Source: /home/c/Dropbox/src/docker/latex/RCS/Makefile,v $
# $Date: 2023/02/19 22:43:48 $
# $Revision: 1.1 $

all: build.log

TAG0=$(shell cat tag.txt)
TAG1=chrisoei/$(TAG0)

build.log: timestamp.txt
	DOCKER_BUILDKIT=1 docker build --progress=plain -t $(TAG1):`cat timestamp.txt` . 2>&1 | tee build.log
	docker tag $(TAG1):`cat timestamp.txt` $(TAG1):latest

push.log: build.log
	docker push $(TAG1):`cat timestamp.txt` 2>&1 | tee push.log
	docker push $(TAG1):latest 2>&1 | tee -a push.log

push: push.log

clean:
	rm -f build.log push.log timestamp.txt

timestamp.txt: Dockerfile
	./stardate.pl --underscore > timestamp.txt

# vim: set noet ff=unix ft=make nocp sts=2 sw=2 ts=2:
