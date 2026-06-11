package openriak.elixir.codegen;

import io.smithy.beam.core.BeamHttpBindings;
import io.smithy.beam.core.BeamProtocolCodegen;
import io.smithy.beam.elixir.ElixirContext;
import io.smithy.beam.elixir.ElixirIntegration;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.shapes.ShapeId;

import java.util.Optional;

public final class OpenRiakElixirIntegration implements ElixirIntegration {

    @Override
    public String name() {
        return "openriak-elixir";
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
            return Optional.of(ElixirOpenRiakHttpEmitter.CODEC_SUFFIX);
        }
        return Optional.empty();
    }

    @Override
    public void customize(ElixirContext context) {
        if (OpenRiakHttpProtocolCodegen.OPEN_RIAK_HTTP.equals(context.resolvedProtocolTraitId())) {
            ElixirOpenRiakHttpEmitter.emitCodecModule(context, context.service());
        }
    }
}
