package openriak.erlang.codegen;

import io.smithy.beam.core.BeamHttpBindings;
import io.smithy.beam.core.BeamProtocolCodegen;
import io.smithy.beam.core.BeamProtocolCodegenFactory;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.shapes.ShapeId;

public final class OpenRiakBeamProtocolCodegenFactory {

    private OpenRiakBeamProtocolCodegenFactory() {}

    public static BeamProtocolCodegen create(Model model, ShapeId resolvedProtocolTraitId) {
        if (OpenRiakHttpProtocolCodegen.OPEN_RIAK_HTTP.equals(resolvedProtocolTraitId)) {
            return new OpenRiakHttpProtocolCodegen(BeamHttpBindings.from(model));
        }
        return BeamProtocolCodegenFactory.create(model, resolvedProtocolTraitId);
    }
}
