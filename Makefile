X:=$(shell find services/*/Dockerfile -type f -maxdepth 1 -exec dirname {} \;)
SERVICES:=$(foreach x,$(X),$(x)/)

Y:=$(shell find services/*/smithy-build.json -type f -maxdepth 1 -exec dirname {} \;)
DEMOS:=$(foreach y,$(Y),$(y)/)
DEMOS_COUNT:=$(words $(DEMOS))


PARALLEL_JOBS=10
BUILD_LOGS=build.log

.PHONY: all
all: clean services build

.PHONY: build
build:
	#
	# Build
	#
	time make docker/up  2>&1 | tee -i $(BUILD_LOGS)
	if grep -q "All demos finished" $(BUILD_LOGS); then \
		echo "build.log ...ok"; \
	else \
		make docker/logs; \
		echo "build.log ...failed"; \
		exit 1 ; \
	fi;

.PHONY: docker/up
docker/up: docker/down
	#
	# Docker/up
	#
	docker compose up --build -d > compose.log 2>&1
	i=0; \
	while [ $$i -lt 180 ]; do \
		state=$$(docker compose ps -a --format '{{.State}}' demo-done 2>/dev/null | head -1); \
		printf "state=%s\n" "$$state" >&2; \
		case "$$state" in \
			exited) \
				code=$$(docker compose ps -a --format '{{.ExitCode}}' demo-done 2>/dev/null | head -1); \
				if [ "$$code" = "0" ]; then break; fi; \
				echo "demo-done exited with code $$code"; \
				make docker/logs; \
				exit 1; \
				;; \
		esac; \
		sleep 1; \
		i=$$((i + 1)); \
	done; \
	if [ $$i -ge 180 ]; then \
		echo "timed out waiting for demo-done"; \
		make docker/logs; \
		exit 1; \
	fi
	make docker/logs
	make docker/down > /dev/null 2>&1
	echo "All demos finished" >> $(BUILD_LOGS)

.PHONY: docker/down
docker/down:
	#
	# Docker/down
	#
	docker compose down -v --rmi local

.SILENT: docker/logs
.PHONY: docker/logs
docker/logs:
	mkdir -p build/; \
	build_log=build/docker.log; \
	rm -rf $$build_log; \
	touch $$build_log; \
	for demo in $(SERVICES); do \
		name="$$(echo $$demo|cut -d/ -f2)"; \
		logfile="build/docker-$$name.log"; \
		echo "========== $$name =========="; \
		docker compose logs --no-color "$$name"|tee $$logfile; \
		echo; \
		if [ "$$name" != "openriak" ]; then \
			if grep -q "Demo complete" $$logfile; then \
				echo "$$logfile ...ok" >> $$build_log; \
			else \
				echo "$$logfile ...failed" >> $$build_log; \
			fi; \
		fi; \
	done; \
	cat $$build_log;

.PHONY: clean
clean:
	#
	# clean
	#
	rm -f *.log

.PHONY: validate
validate:
	smithy validate model/*.smithy | tee validate.log
	[ -s validate.log ] || rm -rf validate.log

# Usage: make services/clean
.PHONY: %/clean
%/clean:
	#
	# Clean $@
	#
	target="$$(dirname $@)"; \
	if [ "$$target" = "services" ]; then \
		files="$(DEMOS)"; \
	else \
		echo "Unknown target: $$target" ; \
		exit 1 ; \
	fi; \
	if [ -z "$$files" ]; then \
		echo "No files to clean for target: $$target" ; \
		exit 1 ; \
	fi; \
	for x in $$files; do \
		echo ; \
		echo "Cleaning: $$x" ; \
		cd $$x ; \
		make clean ; \
		cd - >/dev/null; \
	done

# Usage: TARGET=services make _run
.PHONY: _run
_run:
	mkdir -p build
	rm -rf build/*.log
	touch build/$(TARGET).log
	#
	# Build $(TARGET) in parallel ($(PARALLEL_JOBS) jobs)
	#
	find $(TARGET)/*/smithy-build.json -type f -maxdepth 1 -exec dirname {} \; |\
	xargs -S1024 -P $(PARALLEL_JOBS) -I {} sh -c ' \
		target="{}"; \
		sleep 1; \
		make $$target; \
	'; \
	STATUS=$$?; \
	echo; \
	cat build/$(TARGET).log; \
	echo; \
	exit $$STATUS; \

.PHONY: _build
_build:
	#
	# Build $(DEMO)
	#
	cd $(DEMO) && make clean && time make build && make test
	
# Usage: make services
.PHONY: services
services:
	#
	# Build services
	#
	TARGET=services make _run

# Usage: make services/python-demo
.PHONY: $(DEMOS)
services/%: $(DEMOS)
	target="$@"; \
	name="$$(echo $$target|cut -d/ -f2)"; \
	build_log=build/services.log; \
	logfile="build/services-$$name.log"; \
	echo "Building $$target > $$logfile"; \
	DEMO=$$target make _build > $$logfile 2>&1; \
	if grep -q "make.*Error" $$logfile; then \
		echo "$$logfile ...failed" >> $$build_log; \
		exit 1 ; \
	else \
		printf ".";\
		echo "$$logfile ...ok" >> $$build_log; \
	fi; \
