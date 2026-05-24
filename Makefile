.PHONY: all
all: clean build

.PHONY: build
build:
	time $(MAKE) run 2>&1 | tee -i build.log
	if grep -q "All demos finished" build.log; then \
		echo "build.log ...ok"; \
	else \
		echo "build.log ...failed"; \
		exit 1 ; \
	fi;

.PHONY: run
run:
	#
	# build
	#
	docker compose up --build -d
	i=0; \
	while [ $$i -lt 180 ]; do \
		state=$$(docker compose ps -a --format '{{.State}}' demo-done 2>/dev/null | head -1); \
		case "$$state" in \
			exited) \
				code=$$(docker compose ps -a --format '{{.ExitCode}}' demo-done 2>/dev/null | head -1); \
				if [ "$$code" = "0" ]; then break; fi; \
				echo "demo-done exited with code $$code"; \
				docker compose logs; \
				exit 1; \
				;; \
		esac; \
		sleep 1; \
		i=$$((i + 1)); \
	done; \
	if [ $$i -ge 180 ]; then \
		echo "timed out waiting for demo-done"; \
		docker compose logs; \
		exit 1; \
	fi
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
