package openriak.protocol;

import software.amazon.smithy.java.client.http.HttpClientProtocol;
import software.amazon.smithy.java.context.Context;
import software.amazon.smithy.java.core.schema.ApiOperation;
import software.amazon.smithy.java.core.schema.SerializableStruct;
import software.amazon.smithy.java.core.serde.Codec;
import software.amazon.smithy.java.core.serde.TypeRegistry;
import software.amazon.smithy.java.http.api.HttpRequest;
import software.amazon.smithy.java.http.api.HttpResponse;
import software.amazon.smithy.java.io.uri.SmithyUri;
import software.amazon.smithy.model.shapes.ShapeId;

public final class OpenRiakHttpProtocol extends HttpClientProtocol {

    public static final ShapeId ID = ShapeId.from("openriak.v3_4.api#openRiakHttp");

    private final OpenRiakHttpBindings bindings = new OpenRiakHttpBindings();
    private final OpenRiakHttpErrors errors = new OpenRiakHttpErrors();

    public OpenRiakHttpProtocol() {
        super(ID);
    }

    @Override
    public Codec payloadCodec() {
        return OpaqueBodyCodec.INSTANCE;
    }

    @Override
    public <I extends SerializableStruct, O extends SerializableStruct> HttpRequest createRequest(
            ApiOperation<I, O> operation,
            I input,
            Context context,
            SmithyUri endpointUri
    ) {
        return bindings.toRequest(operation, input, endpointUri);
    }

    @Override
    public <I extends SerializableStruct, O extends SerializableStruct> O deserializeResponse(
            ApiOperation<I, O> operation,
            Context context,
            TypeRegistry types,
            HttpRequest request,
            HttpResponse response
    ) {
        if (response.statusCode() != bindings.expectedSuccessStatus(operation)) {
            throw errors.toException(operation, response);
        }
        return bindings.toSuccessOutput(operation, response);
    }
}
