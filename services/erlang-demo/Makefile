M2_LOCAL := file://$(HOME)/.m2/repository
MAVEN_CENTRAL := https://repo.maven.apache.org/maven2
export SMITHY_MAVEN_REPOS := $(M2_LOCAL)|$(MAVEN_CENTRAL)

SMITHY_BEAM_SRC ?= $(CURDIR)/.smithy-beam
SMITHY_BEAM_REPO ?= https://github.com/f34nk/smithy-beam.git
SMITHY_BEAM_REF ?= v3
CODEGEN_JAR := $(HOME)/.m2/repository/io/smithy/beam/codegen-erlang/0.1.0-SNAPSHOT/codegen-erlang-0.1.0-SNAPSHOT.jar
CODEGEN_DIR := generated/source/erlang-client-codegen
OPENRIAK_CODEGEN_JAR := $(HOME)/.m2/repository/openriak/openriak-erlang-codegen/0.1.0/openriak-erlang-codegen-0.1.0.jar
OPENRIAK_CODEGEN_SRCS := $(shell find codegen/src codegen/pom.xml -type f 2>/dev/null)

JDK21 := $(shell asdf where java openjdk-21)

.PHONY: all
all: build

.PHONY: build
build: build/smithy build/rebar

.PHONY: build/smithy
build/smithy: install-codegen install-openriak-codegen
	#
	# Build
	#
	smithy build 2>build-errors.log || (cat build-errors.log; exit 1)
	rm -f build-errors.log

.PHONY: build/rebar
build/rebar:
	rebar3 compile

.PHONY: install-codegen
install-codegen: $(CODEGEN_JAR)

$(CODEGEN_JAR):
	@test -d "$(SMITHY_BEAM_SRC)" || { \
		echo "Cloning smithy-beam ($(SMITHY_BEAM_REF))..."; \
		git clone --depth 1 --branch "$(SMITHY_BEAM_REF)" "$(SMITHY_BEAM_REPO)" "$(SMITHY_BEAM_SRC)"; \
	}
	cd "$(SMITHY_BEAM_SRC)" && make build

.PHONY: install-openriak-codegen
install-openriak-codegen: $(OPENRIAK_CODEGEN_JAR)

$(OPENRIAK_CODEGEN_JAR): $(OPENRIAK_CODEGEN_SRCS) $(CODEGEN_JAR)
	cd codegen && JAVA_HOME="$(JDK21)" mvn -q clean install

.PHONY: test
test:
	rebar3 eunit

.PHONY: demo
demo: build

.PHONY: clean
clean:
	#
	# Clean
	#
	rm -rf *.dump _build build generated .smithy-beam codegen/target $(CODEGEN_JAR) $(OPENRIAK_CODEGEN_JAR)
