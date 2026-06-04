JDK21 := $(shell asdf where java openjdk-21)
SMITHY_HOME := $(shell brew --prefix smithy-cli)/libexec

MODEL_JSON := generated/client/model/model.json
MODEL_RESOURCE := src/main/resources/openriak/openriak-3.4.model.json

.PHONY: build clean
build:
	#
	# Build
	#
	JAVA_HOME="$(JDK21)" "$(JDK21)/bin/java" -XX:-UsePerfData -classpath "$(SMITHY_HOME)/lib/*" software.amazon.smithy.cli.SmithyCli build --config smithy-build.json 2>build-errors.log || (cat build-errors.log; exit 1)
	rm -f build-errors.log

$(MODEL_RESOURCE): $(MODEL_JSON)
	mkdir -p $(dir $@)
	cp $< $@

.PHONY: demo
demo: build $(MODEL_RESOURCE)

.PHONY: clean
clean:
	#
	# Clean
	#
	rm -rf build generated build-errors.log src/main/resources/openriak/*.json
