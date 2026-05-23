.PHONY: build
build: clean
	#
	# build
	#
	docker compose up --build --abort-on-container-exit=false --exit-code-from demo-done | tee build.log

.PHONY: rebuild
rebuild: clean
	#
	# rebuild
	#
	docker compose build --no-cache riak | tee rebuild.log
	docker compose up --abort-on-container-exit=false --exit-code-from demo-done | tee build.log

.PHONY: clean
clean:
	#
	# clean
	#
	rm -f *.log
	docker compose down -v --rmi local
