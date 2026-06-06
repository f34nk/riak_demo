JDK21 := $(shell asdf where java openjdk-21)
SMITHY_HOME := $(shell brew --prefix smithy-cli)/libexec
CLIENT_DIR := generated/client/typescript-client-codegen
CODEGEN_JAR := $(HOME)/.m2/repository/openriak/openriak-typescript-codegen/0.1.0/openriak-typescript-codegen-0.1.0.jar
CODEGEN_SRCS := $(shell find codegen/src codegen/pom.xml -type f 2>/dev/null)

.PHONY: install-codegen
install-codegen: $(CODEGEN_JAR)

$(CODEGEN_JAR): $(CODEGEN_SRCS)
	cd codegen && JAVA_HOME="$(JDK21)" mvn -q install

.PHONY: build
build: build/smithy build/client

.PHONY: build/smithy
build/smithy: install-codegen
	#
	# Smithy codegen
	#
	JAVA_HOME="$(JDK21)" "$(JDK21)/bin/java" -XX:-UsePerfData -classpath "$(SMITHY_HOME)/lib/*" software.amazon.smithy.cli.SmithyCli build --config smithy-build.json 2>build-errors.log || (cat build-errors.log; exit 1)
	rm -f build-errors.log

.PHONY: build/client
build/client:
	cd $(CLIENT_DIR) && npm install && npm run build

.PHONY: test
test:
	npm install && npm test

.PHONY: clean
clean:
	#
	# Clean
	#
	rm -rf build generated build-errors.log dist node_modules $(CODEGEN_JAR)
