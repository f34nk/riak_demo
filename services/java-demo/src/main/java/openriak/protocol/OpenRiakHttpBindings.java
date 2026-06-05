package openriak.protocol;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.Instant;
import java.time.format.DateTimeFormatter;
import java.util.LinkedHashMap;
import java.util.Map;
import software.amazon.smithy.java.core.schema.ApiOperation;
import software.amazon.smithy.java.core.schema.Schema;
import software.amazon.smithy.java.core.schema.SerializableStruct;
import software.amazon.smithy.java.core.schema.ShapeBuilder;
import software.amazon.smithy.java.http.api.HttpRequest;
import software.amazon.smithy.java.http.api.HttpHeaders;
import software.amazon.smithy.java.http.api.ModifiableHttpHeaders;
import software.amazon.smithy.java.http.api.ModifiableHttpRequest;
import software.amazon.smithy.java.io.datastream.DataStream;
import software.amazon.smithy.java.io.uri.SmithyUri;
import software.amazon.smithy.model.knowledge.HttpBinding;
import software.amazon.smithy.model.knowledge.HttpBindingIndex;
import software.amazon.smithy.model.shapes.MemberShape;
import software.amazon.smithy.model.shapes.OperationShape;
import software.amazon.smithy.model.shapes.ShapeId;
import software.amazon.smithy.model.shapes.ShapeType;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.model.traits.HttpTrait;

final class OpenRiakHttpBindings {

    private final HttpBindingIndex index;

    OpenRiakHttpBindings() {
        this.index = OpenRiakModel.bindings();
    }

    <I extends SerializableStruct, O extends SerializableStruct> HttpRequest toRequest(
            ApiOperation<I, O> operation,
            I input,
            SmithyUri endpointUri
    ) {
        ShapeId opId = operation.schema().id();
        OperationShape opShape = OpenRiakModel.model().expectShape(opId, OperationShape.class);
        HttpTrait http = opShape.expectTrait(HttpTrait.class);

        String path = http.getUri().toString();
        ModifiableHttpHeaders headers = HttpHeaders.ofModifiable();
        StringBuilder query = new StringBuilder();
        DataStream body = null;

        StructureShape inputShape = OpenRiakModel.model().expectShape(input.schema().id(), StructureShape.class);
        Map<String, HttpBinding> requestBindings = index.getRequestBindings(opId);
        for (MemberShape memberShape : inputShape.members()) {
            HttpBinding binding = requestBindings.get(memberShape.getMemberName());
            if (binding == null) {
                continue;
            }
            Schema member = input.schema().member(binding.getMemberName());
            Object value = input.getMemberValue(member);
            if (value == null) {
                continue;
            }
            switch (binding.getLocation()) {
                case LABEL -> path = path.replace(
                        "{" + binding.getLocationName() + "}",
                        urlEncode(String.valueOf(value)));
                case QUERY -> appendQuery(query, binding.getLocationName(), String.valueOf(value));
                case HEADER -> headers.setHeader(binding.getLocationName(), String.valueOf(value));
                case PREFIX_HEADERS -> addPrefixHeaders(headers, binding.getLocationName(), (Map<String, String>) value);
                case PAYLOAD -> body = (DataStream) value;
                default -> { /* ignore UNBOUND / DOCUMENT for OpenRiak */ }
            }
        }

        ModifiableHttpRequest request = HttpRequest.create()
                .setMethod(http.getMethod())
                .setUri(endpointUri.withPath(path).withQuery(query.toString()))
                .setHeaders(headers);
        if (body != null) {
            request.setBody(body);
        }
        return request.toUnmodifiable();
    }

    <I extends SerializableStruct, O extends SerializableStruct> O toSuccessOutput(
            ApiOperation<I, O> operation,
            software.amazon.smithy.java.http.api.HttpResponse response
    ) {
        ShapeBuilder<O> builder = operation.outputBuilder();
        Schema outputSchema = operation.outputSchema();

        for (HttpBinding binding : index.getResponseBindings(operation.schema().id()).values()) {
            Schema member = outputSchema.member(binding.getMemberName());
            switch (binding.getLocation()) {
                case RESPONSE_CODE -> builder.setMemberValue(member, response.statusCode());
                case HEADER -> {
                    String raw = response.headers().firstValue(binding.getLocationName());
                    if (raw != null) {
                        builder.setMemberValue(member, coerceHeaderValue(member, raw));
                    }
                }
                case PREFIX_HEADERS -> builder.setMemberValue(member, readPrefixHeaders(response, binding.getLocationName()));
                case PAYLOAD -> builder.setMemberValue(member, response.body());
                default -> { }
            }
        }
        return builder.build();
    }

    int expectedSuccessStatus(ApiOperation<?, ?> operation) {
        return index.getResponseCode(operation.schema().id());
    }

    private static void appendQuery(StringBuilder query, String name, String value) {
        if (!query.isEmpty()) {
            query.append('&');
        }
        query.append(urlEncode(name)).append('=').append(urlEncode(value));
    }

    private static void addPrefixHeaders(ModifiableHttpHeaders headers, String prefix, Map<String, String> values) {
        for (Map.Entry<String, String> entry : values.entrySet()) {
            headers.setHeader(prefix + entry.getKey(), entry.getValue());
        }
    }

    private static Map<String, String> readPrefixHeaders(
            software.amazon.smithy.java.http.api.HttpResponse response,
            String prefix
    ) {
        Map<String, String> result = new LinkedHashMap<>();
        int prefixLength = prefix.length();
        response.headers().forEachEntry((name, value) -> {
            if (name.length() >= prefixLength && name.regionMatches(true, 0, prefix, 0, prefixLength)) {
                result.put(name.substring(prefixLength), value);
            }
        });
        return result;
    }

    private static String urlEncode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    private static Object coerceHeaderValue(Schema member, String raw) {
        ShapeType targetType = member.memberTarget().type();
        return switch (targetType) {
            case TIMESTAMP -> Instant.from(DateTimeFormatter.RFC_1123_DATE_TIME.parse(raw));
            case INTEGER -> Integer.parseInt(raw);
            case LONG -> Long.parseLong(raw);
            case BOOLEAN -> Boolean.parseBoolean(raw);
            default -> raw;
        };
    }
}
