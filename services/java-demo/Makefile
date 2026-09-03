JDK21 := $(shell asdf where java openjdk-21)

MODEL_JSON := generated/client/model/model.json
MODEL_RESOURCE := src/main/resources/openriak/openriak-3.4.model.json

.PHONY: build
build: build/smithy

.PHONY: build/smithy
build/smithy:
	#
	# Build
	#
	smithy build 2>build-errors.log || (cat build-errors.log; exit 1)
	rm -f build-errors.log
	mkdir -p $(dir $(MODEL_RESOURCE))
	cp $(MODEL_JSON) $(MODEL_RESOURCE)

.PHONY: test
test:
	JAVA_HOME="$(JDK21)" mvn process-resources test

$(MODEL_RESOURCE): $(MODEL_JSON)
	mkdir -p $(dir $@)
	cp $< $@

.PHONY: clean
clean:
	#
	# Clean
	#
	rm -rf build generated target build-errors.log src/main/resources/openriak/*.json .deps
