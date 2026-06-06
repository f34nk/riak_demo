package openriak.erlang.codegen;

import io.smithy.beam.core.BeamHttpBindings;
import io.smithy.beam.core.BeamProtocolCodegen;
import io.smithy.beam.erlang.ErlangContext;
import io.smithy.beam.erlang.ErlangIntegration;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.shapes.ShapeId;

import java.util.Optional;

public final class OpenRiakErlangIntegration implements ErlangIntegration {

    @Override
    public String name() {
        return "openriak-erlang";
    }

    @Override
    public Optional<BeamProtocolCodegen> createProtocolCodegen(
            Model model, ShapeId protocolTraitId) {
        if (OpenRiakHttpProtocolCodegen.OPEN_RIAK_HTTP.equals(protocolTraitId)) {
            return Optional.of(new OpenRiakHttpProtocolCodegen(BeamHttpBindings.from(model)));
        }
        return Optional.empty();
    }

    @Override
    public Optional<String> codecModuleSuffix(ShapeId protocolTraitId) {
        if (OpenRiakHttpProtocolCodegen.OPEN_RIAK_HTTP.equals(protocolTraitId)) {
            return Optional.of(ErlangOpenRiakHttpEmitter.CODEC_SUFFIX);
        }
        return Optional.empty();
    }

    @Override
    public void customize(ErlangContext context) {
        if (OpenRiakHttpProtocolCodegen.OPEN_RIAK_HTTP.equals(context.resolvedProtocolTraitId())) {
            ErlangOpenRiakHttpEmitter.emitCodecModule(context, context.service());
        }
    }
}
