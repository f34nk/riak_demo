X:=$(shell find services/*/smithy-build.json -type f -maxdepth 1 -exec dirname {} \;)
BUILD_CONFIGS:=$(foreach x,$(X),$(x)/)
BUILD_CONFIGS_COUNT:=$(words $(BUILD_CONFIGS))

PARALLEL_JOBS=10

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
		files="$(BUILD_CONFIGS)"; \
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
	# Run $(TARGET) in parallel ($(PARALLEL_JOBS) jobs)
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

.PHONY: _demo
_demo:
	#
	# Build $(DEMO)
	#
	cd $(DEMO) && make clean && time make build
	
# Usage: make services
.PHONY: services
services:
	TARGET=services make _run

# Usage: make services/python-demo
.SILENT:
.PHONY: $(BUILD_CONFIGS)
services/%: $(BUILD_CONFIGS)
	target="$@"; \
	name="$$(echo $$target|cut -d/ -f2)"; \
	build_log=build/services.log; \
	logfile="build/services-$$name.log"; \
	echo "Running $$target > $$logfile"; \
	DEMO=$$target make _demo > $$logfile 2>&1; \
	if grep -q "make.*Error" $$logfile; then \
		echo "$$logfile ...failed" >> $$build_log; \
		exit 1 ; \
	else \
		printf ".";\
		echo "$$logfile ...ok" >> $$build_log; \
	fi; \
