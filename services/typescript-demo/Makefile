JDK21 := $(shell asdf where java openjdk-21)
SMITHY_HOME := $(shell brew --prefix smithy-cli)/libexec
CLIENT_DIR := generated/client/typescript-client-codegen

.PHONY: build smithy-codegen build-client
build: smithy-codegen build-client

smithy-codegen:
	#
	# Smithy codegen
	#
	JAVA_HOME="$(JDK21)" "$(JDK21)/bin/java" -XX:-UsePerfData -classpath "$(SMITHY_HOME)/lib/*" software.amazon.smithy.cli.SmithyCli build --config smithy-build.json 2>build-errors.log || (cat build-errors.log; exit 1)
	rm -f build-errors.log

build-client:
	cd $(CLIENT_DIR) && npm install && npm run build

.PHONY: demo
demo: build

.PHONY: clean
clean:
	#
	# Clean
	#
	rm -rf build generated build-errors.log
