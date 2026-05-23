.PHONY: build
build: clean
	#
	# build
	#
	docker compose up --build --exit-code-from demo-done | tee docker.log

.PHONY: rebuild
rebuild: clean
	#
	# rebuild
	#
	docker compose build --no-cache riak | tee build.log
	docker compose up --exit-code-from demo-done | tee docker.log

.PHONY: clean
clean:
	#
	# clean
	#
	rm -f *.log
	docker compose down -v --rmi local
