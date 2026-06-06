package openriak.python.codegen;

import software.amazon.smithy.model.shapes.ShapeId;
import software.amazon.smithy.python.codegen.ApplicationProtocol;
import software.amazon.smithy.python.codegen.GenerationContext;
import software.amazon.smithy.python.codegen.generators.ProtocolGenerator;
import software.amazon.smithy.python.codegen.writer.PythonWriter;

public final class OpenRiakHttpProtocolGenerator implements ProtocolGenerator {

    private static final ShapeId OPEN_RIAK_HTTP =
            ShapeId.from("openriak.v3_4.api#openRiakHttp");

    @Override
    public ShapeId getProtocol() {
        return OPEN_RIAK_HTTP;
    }

    @Override
    public String getName() {
        return "openRiakHttp";
    }

    @Override
    public ApplicationProtocol getApplicationProtocol(GenerationContext context) {
        return ApplicationProtocol.createDefaultHttpApplicationProtocol();
    }

    @Override
    public void initializeProtocol(GenerationContext context, PythonWriter writer) {
        // Completed in Step 3.5.
    }
}
