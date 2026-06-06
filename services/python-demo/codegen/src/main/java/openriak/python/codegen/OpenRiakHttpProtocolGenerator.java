package openriak.python.codegen;

import software.amazon.smithy.model.shapes.ShapeId;
import software.amazon.smithy.python.codegen.ApplicationProtocol;
import software.amazon.smithy.python.codegen.GenerationContext;
import software.amazon.smithy.python.codegen.SmithyPythonDependency;
import software.amazon.smithy.python.codegen.SymbolProperties;
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
        writer.addImport("openriak.aio.protocols", "OpenRiakHttpClientProtocol");
        var serviceSymbol = context.symbolProvider().toSymbol(context.settings().service(context.model()));
        var serviceSchema = serviceSymbol.expectProperty(SymbolProperties.SCHEMA);
        writer.write("OpenRiakHttpClientProtocol($T)", serviceSchema);
    }

    @Override
    public void generateProtocolTests(GenerationContext context) {
        context.writerDelegator().useFileWriter("src/openriak/aio/__init__.py", "openriak.aio", writer -> {
            writer.write("");
        });
        context.writerDelegator().useFileWriter("src/openriak/aio/protocols.py", "openriak.aio.protocols", writer -> {
            writer.addDependency(SmithyPythonDependency.SMITHY_CORE);
            writer.addDependency(SmithyPythonDependency.SMITHY_HTTP);
            writer.addDependency(SmithyPythonDependency.SMITHY_JSON);
            writer.write("""
                    from typing import Any, Final

                    from smithy_core import URI
                    from smithy_core.codecs import Codec
                    from smithy_core.deserializers import DeserializeableShape
                    from smithy_core.exceptions import MissingDependencyError
                    from smithy_core.interfaces import TypedProperties
                    from smithy_core.schemas import APIOperation, Schema
                    from smithy_core.serializers import SerializeableShape
                    from smithy_core.shapes import ShapeID
                    from smithy_core.traits import HTTPErrorTrait
                    from smithy_core.types import TimestampFormat
                    from smithy_http import Field
                    from smithy_http.aio import HTTPRequest
                    from smithy_http.aio.interfaces import HTTPErrorIdentifier, HTTPResponse
                    from smithy_http.aio.protocols import HttpBindingClientProtocol

                    try:
                        from smithy_json import JSONCodec

                        _HAS_JSON = True
                    except ImportError:
                        _HAS_JSON = False


                    def _assert_json() -> None:
                        if not _HAS_JSON:
                            raise MissingDependencyError(
                                "Attempted to use JSON codec, but smithy-json is not installed."
                            )


                    def _prefer_modeled_content_type(request: HTTPRequest) -> None:
                        \"\"\"Keep one Content-Type when blob payload serde adds a duplicate value.\"\"\"
                        for name in ("content-type", "Content-Type"):
                            field = request.fields.get(name)
                            if field is not None and len(field.values) > 1:
                                request.fields.set_field(
                                    Field(name=field.name, values=[field.values[0]])
                                )
                                return


                    class OpenRiakHttpErrorIdentifier(HTTPErrorIdentifier):
                        \"\"\"Map HTTP status codes to modeled error shapes.\"\"\"

                        def identify(
                            self,
                            *,
                            operation: APIOperation[Any, Any],
                            response: HTTPResponse,
                        ) -> ShapeID | None:
                            for error_schema in operation.error_schemas:
                                trait = error_schema.get_trait(HTTPErrorTrait)
                                if trait is not None and trait.code == response.status:
                                    return error_schema.id
                            return None


                    class OpenRiakHttpClientProtocol(HttpBindingClientProtocol):
                        \"\"\"OpenRiak HTTP protocol with opaque blob payloads and status-based errors.\"\"\"

                        _id: Final = ShapeID("openriak.v3_4.api#openRiakHttp")
                        _content_type: Final = "application/json"
                        _error_identifier: Final = OpenRiakHttpErrorIdentifier()

                        def __init__(self, service_schema: Schema) -> None:
                            _assert_json()
                            self._codec: Final = JSONCodec(
                                default_namespace=service_schema.id.namespace,
                                default_timestamp_format=TimestampFormat.EPOCH_SECONDS,
                            )

                        @property
                        def id(self) -> ShapeID:
                            return self._id

                        @property
                        def payload_codec(self) -> Codec:
                            return self._codec

                        @property
                        def content_type(self) -> str:
                            return self._content_type

                        @property
                        def error_identifier(self) -> HTTPErrorIdentifier:
                            return self._error_identifier

                        def serialize_request[
                            OperationInput: SerializeableShape,
                            OperationOutput: DeserializeableShape,
                        ](
                            self,
                            *,
                            operation: APIOperation[OperationInput, OperationOutput],
                            input: OperationInput,
                            endpoint: URI,
                            context: TypedProperties,
                        ) -> HTTPRequest:
                            request = super().serialize_request(
                                operation=operation,
                                input=input,
                                endpoint=endpoint,
                                context=context,
                            )
                            _prefer_modeled_content_type(request)
                            return request
                    """);
        });
    }
}
