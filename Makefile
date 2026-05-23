.PHONY: all
all: 
	time make build 2>build-errors.log
	[ -s build-errors.log ] || rm -rf build-errors.log

.PHONY: build
build: clean
	#
	# build
	#
	docker compose up --build -d
	docker compose wait demo-done
	docker compose logs
	docker compose down

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
