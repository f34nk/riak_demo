.PHONY: all
all: clean build

.PHONY: build
build:
	time $(MAKE) run 2>&1 | tee -i build.log

.PHONY: run
run:
	#
	# build
	#
	docker compose up --build -d
	docker compose wait demo-done
	docker compose logs
	docker compose down -v --rmi local

.PHONY: rebuild
rebuild: clean
	#
	# rebuild
	#
	docker compose build --no-cache riak | tee rebuild.log

.PHONY: clean
clean:
	#
	# clean
	#
	rm -f *.log
	docker compose down -v --rmi local
