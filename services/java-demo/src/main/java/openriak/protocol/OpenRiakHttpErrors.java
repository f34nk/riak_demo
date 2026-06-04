package openriak.protocol;

import java.util.LinkedHashMap;
import java.util.Map;
import software.amazon.smithy.java.core.error.CallException;
import software.amazon.smithy.java.core.schema.ApiOperation;
import software.amazon.smithy.java.core.schema.Schema;
import software.amazon.smithy.java.core.schema.ShapeBuilder;
import software.amazon.smithy.java.http.api.HttpResponse;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.knowledge.HttpBinding;
import software.amazon.smithy.model.knowledge.HttpBindingIndex;
import software.amazon.smithy.model.shapes.ShapeId;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.model.traits.HttpErrorTrait;

final class OpenRiakHttpErrors {

    private final Model model;
    private final HttpBindingIndex bindingIndex;

    OpenRiakHttpErrors() {
        this.model = OpenRiakModel.model();
        this.bindingIndex = OpenRiakModel.bindings();
    }

    CallException toException(ApiOperation<?, ?> operation, HttpResponse response) {
        int status = response.statusCode();
        for (Schema errorSchema : operation.errorSchemas()) {
            StructureShape errorShape = model.expectShape(errorSchema.id(), StructureShape.class);
            if (errorShape.hasTrait(HttpErrorTrait.class)) {
                int code = errorShape.expectTrait(HttpErrorTrait.class).getCode();
                if (code == status) {
                    ShapeBuilder<?> builder = operation.errorRegistry().createBuilder(errorSchema.id());
                    bindErrorHeaders(builder, errorSchema, response);
                    return (CallException) builder.build();
                }
            }
        }
        throw new RuntimeException("Unexpected HTTP status " + status + " for " + operation.schema().id());
    }

    private void bindErrorHeaders(ShapeBuilder<?> builder, Schema errorSchema, HttpResponse response) {
        for (HttpBinding binding : bindingIndex.getResponseBindings(errorSchema.id()).values()) {
            Schema member = errorSchema.member(binding.getMemberName());
            switch (binding.getLocation()) {
                case HEADER -> {
                    String raw = response.headers().firstValue(binding.getLocationName());
                    if (raw != null) {
                        builder.setMemberValue(member, raw);
                    }
                }
                case PREFIX_HEADERS -> builder.setMemberValue(
                        member,
                        readPrefixHeaders(response, binding.getLocationName()));
                default -> { }
            }
        }
    }

    private static Map<String, String> readPrefixHeaders(HttpResponse response, String prefix) {
        Map<String, String> result = new LinkedHashMap<>();
        int prefixLength = prefix.length();
        response.headers().forEachEntry((name, value) -> {
            if (name.length() >= prefixLength && name.regionMatches(true, 0, prefix, 0, prefixLength)) {
                result.put(name.substring(prefixLength), value);
            }
        });
        return result;
    }
}
