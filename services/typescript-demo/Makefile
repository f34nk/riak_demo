JDK21 := $(shell asdf where java openjdk-21)
SMITHY_HOME := $(shell brew --prefix smithy-cli)/libexec

.PHONY: build
build:
	#
	# Build
	#
	JAVA_HOME="$(JDK21)" "$(JDK21)/bin/java" -XX:-UsePerfData -classpath "$(SMITHY_HOME)/lib/*" software.amazon.smithy.cli.SmithyCli build --config smithy-build.json 2>build-errors.log || (cat build-errors.log; exit 1)
	rm -f build-errors.log

.PHONY: clean
clean:
	#
	# Clean
	#
	rm -rf build generated build-errors.log
