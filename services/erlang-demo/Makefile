M2_LOCAL := file://$(HOME)/.m2/repository
MAVEN_CENTRAL := https://repo.maven.apache.org/maven2
export SMITHY_MAVEN_REPOS := $(M2_LOCAL)|$(MAVEN_CENTRAL)

SMITHY_BEAM_SRC ?= $(CURDIR)/.smithy-beam
SMITHY_BEAM_REPO ?= https://github.com/f34nk/smithy-beam.git
SMITHY_BEAM_REF ?= develop
CODEGEN_JAR := $(HOME)/.m2/repository/io/smithy/beam/codegen-erlang/0.1.0-SNAPSHOT/codegen-erlang-0.1.0-SNAPSHOT.jar

JDK21 := $(shell asdf where java openjdk-21)
SMITHY_HOME := $(shell brew --prefix smithy-cli)/libexec

.PHONY: all
all: build

.PHONY: install-codegen
install-codegen: $(CODEGEN_JAR)

$(CODEGEN_JAR):
	@test -d "$(SMITHY_BEAM_SRC)/codegen" || { \
		echo "Cloning smithy-beam ($(SMITHY_BEAM_REF))..."; \
		git clone --depth 1 --branch "$(SMITHY_BEAM_REF)" "$(SMITHY_BEAM_REPO)" "$(SMITHY_BEAM_SRC)"; \
	}
	cd "$(SMITHY_BEAM_SRC)/codegen" && ./gradlew publishToMavenLocal

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
	rm -rf build generated
