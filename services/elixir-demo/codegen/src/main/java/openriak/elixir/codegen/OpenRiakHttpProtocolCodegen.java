package openriak.elixir.codegen;

import io.smithy.beam.core.BeamHttpBindings;
import io.smithy.beam.core.BeamProtocolCodegen;
import io.smithy.beam.elixir.ElixirContext;
import software.amazon.smithy.codegen.core.CodegenContext;
import software.amazon.smithy.model.shapes.OperationShape;
import software.amazon.smithy.model.shapes.ServiceShape;
import software.amazon.smithy.model.shapes.ShapeId;

public final class OpenRiakHttpProtocolCodegen implements BeamProtocolCodegen {

    public static final ShapeId OPEN_RIAK_HTTP =
            ShapeId.from("openriak.v3_4.api#openRiakHttp");

    private final BeamHttpBindings httpBindings;

    public OpenRiakHttpProtocolCodegen(BeamHttpBindings httpBindings) {
        this.httpBindings = httpBindings;
    }

    @Override
    public ShapeId protocolTraitId() {
        return OPEN_RIAK_HTTP;
    }

    @Override
    public void emitOperationBindings(
            CodegenContext<?, ?, ?> ctx,
            ServiceShape service,
            OperationShape operation) {
        httpBindings.requestBindings(operation);
        httpBindings.responseBindings(operation);
        httpBindings.httpResponseCode(operation);
        if (ctx instanceof ElixirContext elixirCtx) {
            ElixirOpenRiakHttpEmitter.emitOperation(elixirCtx, service, operation);
        }
    }
}
