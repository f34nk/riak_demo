package openriak.typescript.codegen;

import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.knowledge.HttpBinding;
import software.amazon.smithy.model.shapes.DocumentShape;
import software.amazon.smithy.model.shapes.MemberShape;
import software.amazon.smithy.model.shapes.OperationShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.ShapeId;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.model.shapes.UnionShape;
import software.amazon.smithy.model.traits.ErrorTrait;
import software.amazon.smithy.model.traits.HttpErrorTrait;
import software.amazon.smithy.model.traits.StreamingTrait;
import software.amazon.smithy.model.traits.TimestampFormatTrait.Format;
import software.amazon.smithy.typescript.codegen.TypeScriptWriter;
import software.amazon.smithy.typescript.codegen.integration.HttpBindingProtocolGenerator;
import software.amazon.smithy.typescript.codegen.integration.ProtocolGenerator.GenerationContext;

public final class OpenRiakHttpProtocolGenerator extends HttpBindingProtocolGenerator {

    public OpenRiakHttpProtocolGenerator() {
        super(false);
    }

    @Override
    public ShapeId getProtocol() {
        return ShapeId.from("openriak.current.api#openRiakHttp");
    }

    @Override
    public String getName() {
        return "openRiakHttp";
    }

    @Override
    protected Format getDocumentTimestampFormat() {
        return Format.EPOCH_SECONDS;
    }

    @Override
    protected String getDocumentContentType() {
        return "application/json";
    }

    @Override
    public Map<String, ShapeId> getOperationErrors(GenerationContext context, Collection<OperationShape> operations) {
        Model model = context.getModel();
        Map<String, ShapeId> errors = new TreeMap<>();
        for (OperationShape operation : operations) {
            for (ShapeId errorId : operation.getErrors()) {
                StructureShape error = model.expectShape(errorId, StructureShape.class);
                int code = error.getTrait(HttpErrorTrait.class)
                    .map(HttpErrorTrait::getCode)
                    .orElse(error.expectTrait(ErrorTrait.class).getDefaultHttpStatusCode());
                errors.put(String.valueOf(code), errorId);
            }
        }
        return errors;
    }

    @Override
    public void generateSharedComponents(GenerationContext context) {
        super.generateSharedComponents(context);
        OpenRiakProtocolUtils.generateJsonParseBody(context);
    }

    @Override
    protected void writeErrorCodeParser(GenerationContext context) {
        context.getWriter().write("const errorCode = String(output.statusCode);");
    }

    @Override
    protected void generateDocumentBodyShapeSerializers(GenerationContext context, Set<Shape> shapes) {
        OpenRiakProtocolUtils.generateDocumentBodyShapeSerde(
            context,
            shapes,
            new OpenRiakJsonShapeSerVisitor(context, enableSerdeElision())
        );
    }

    @Override
    protected void generateDocumentBodyShapeDeserializers(GenerationContext context, Set<Shape> shapes) {
        OpenRiakProtocolUtils.generateDocumentBodyShapeSerde(
            context,
            shapes,
            new OpenRiakJsonShapeDeserVisitor(context, enableSerdeElision())
        );
    }

    @Override
    protected void serializeInputDocumentBody(
        GenerationContext context,
        OperationShape operation,
        List<HttpBinding> documentBindings
    ) {
        TypeScriptWriter writer = context.getWriter();
        if (documentBindings.isEmpty()) {
            writer.write("body = \"\";");
            return;
        }
        serializeDocumentBody(context, documentBindings);
    }

    @Override
    protected void serializeOutputDocumentBody(
        GenerationContext context,
        OperationShape operation,
        List<HttpBinding> documentBindings
    ) {
        TypeScriptWriter writer = context.getWriter();
        if (documentBindings.isEmpty()) {
            writer.write("body = \"{}\";");
            return;
        }
        serializeDocumentBody(context, documentBindings);
    }

    @Override
    protected void serializeErrorDocumentBody(
        GenerationContext context,
        StructureShape error,
        List<HttpBinding> documentBindings
    ) {
        TypeScriptWriter writer = context.getWriter();
        if (documentBindings.isEmpty()) {
            writer.write("body = \"{}\";");
            return;
        }
        serializeDocumentBody(context, documentBindings);
    }

    @Override
    protected void serializeInputPayload(
        GenerationContext context,
        OperationShape operation,
        HttpBinding payloadBinding
    ) {
        super.serializeInputPayload(context, operation, payloadBinding);
        maybeJsonEncodePayload(context, payloadBinding);
    }

    @Override
    protected void serializeOutputPayload(
        GenerationContext context,
        OperationShape operation,
        HttpBinding payloadBinding
    ) {
        super.serializeOutputPayload(context, operation, payloadBinding);
        maybeJsonEncodePayload(context, payloadBinding);
    }

    @Override
    protected void serializeErrorPayload(
        GenerationContext context,
        StructureShape error,
        HttpBinding payloadBinding
    ) {
        super.serializeErrorPayload(context, error, payloadBinding);
        maybeJsonEncodePayload(context, payloadBinding);
    }

    @Override
    protected void serializeInputEventDocumentPayload(GenerationContext context) {
        context.getWriter().write("body = context.utf8Decoder(JSON.stringify(body));");
    }

    @Override
    protected void deserializeInputDocumentBody(
        GenerationContext context,
        OperationShape operation,
        List<HttpBinding> documentBindings
    ) {
        deserializeDocumentBody(context, documentBindings);
    }

    @Override
    protected void deserializeOutputDocumentBody(
        GenerationContext context,
        OperationShape operation,
        List<HttpBinding> documentBindings
    ) {
        deserializeDocumentBody(context, documentBindings);
    }

    @Override
    protected void deserializeErrorDocumentBody(
        GenerationContext context,
        StructureShape error,
        List<HttpBinding> documentBindings
    ) {
        deserializeDocumentBody(context, documentBindings);
    }

    @Override
    protected HttpBinding deserializeOutputPayload(
        GenerationContext context,
        OperationShape operation,
        HttpBinding payloadBinding
    ) {
        HttpBinding binding = super.deserializeOutputPayload(context, operation, payloadBinding);
        readJsonDocumentPayload(context, payloadBinding);
        return binding;
    }

    @Override
    protected HttpBinding deserializeErrorPayload(
        GenerationContext context,
        StructureShape error,
        HttpBinding payloadBinding
    ) {
        HttpBinding binding = super.deserializeErrorPayload(context, error, payloadBinding);
        readJsonDocumentPayload(context, payloadBinding);
        return binding;
    }

    @Override
    protected boolean requiresNumericEpochSecondsInPayload() {
        return true;
    }

    @Override
    protected boolean enableSerdeElision() {
        return true;
    }

    @Override
    public void generateProtocolTests(GenerationContext context) {}

    private void maybeJsonEncodePayload(GenerationContext context, HttpBinding payloadBinding) {
        TypeScriptWriter writer = context.getWriter();
        MemberShape payloadMember = payloadBinding.getMember();
        Shape target = context.getModel().expectShape(payloadMember.getTarget());

        if (target.isBlobShape() || target.hasTrait(StreamingTrait.class)) {
            return;
        }

        if (target instanceof DocumentShape
            || target instanceof StructureShape
            || (target instanceof UnionShape && !target.hasTrait(StreamingTrait.class))) {
            if (target instanceof StructureShape || target instanceof UnionShape) {
                writer.openBlock("if (body === undefined) {", "}", () -> writer.write("body = {};"));
            }
            writer.write("body = JSON.stringify(body);");
        }
    }

    private void readJsonDocumentPayload(GenerationContext context, HttpBinding payloadBinding) {
        TypeScriptWriter writer = context.getWriter();
        Shape target = context.getModel().expectShape(payloadBinding.getMember().getTarget());
        if (target instanceof DocumentShape) {
            writer.write("contents.$L = JSON.parse(data);", payloadBinding.getMemberName());
        }
    }

    private void serializeDocumentBody(GenerationContext context, List<HttpBinding> documentBindings) {
        TypeScriptWriter writer = context.getWriter();
        var symbolProvider = context.getSymbolProvider();
        writer.addImportSubmodule(
            "take",
            null,
            software.amazon.smithy.typescript.codegen.TypeScriptDependency.SMITHY_CORE,
            software.amazon.smithy.typescript.codegen.SmithyCoreSubmodules.CLIENT
        );
        writer.openBlock("body = JSON.stringify(take(input, {", "}));", () -> {
            for (HttpBinding binding : documentBindings) {
                MemberShape memberShape = binding.getMember();
                String memberName = symbolProvider.toMemberName(memberShape);
                String wireName = memberShape.getTrait(software.amazon.smithy.model.traits.JsonNameTrait.class)
                    .map(software.amazon.smithy.model.traits.JsonNameTrait::getValue)
                    .orElseGet(binding::getLocationName);
                boolean hasJsonName = memberShape.hasTrait(software.amazon.smithy.model.traits.JsonNameTrait.class);
                if (hasJsonName) {
                    writer.write("'$L': [,,`$L`],", wireName, memberName);
                } else {
                    writer.write("'$1L': [],", wireName);
                }
            }
        });
    }

    private void deserializeDocumentBody(GenerationContext context, List<HttpBinding> documentBindings) {
        TypeScriptWriter writer = context.getWriter();
        var symbolProvider = context.getSymbolProvider();
        writer.addImportSubmodule(
            "take",
            null,
            software.amazon.smithy.typescript.codegen.TypeScriptDependency.SMITHY_CORE,
            software.amazon.smithy.typescript.codegen.SmithyCoreSubmodules.CLIENT
        );
        writer.openBlock("const doc = take(data, {", "});", () -> {
            for (HttpBinding binding : documentBindings) {
                String memberName = symbolProvider.toMemberName(binding.getMember());
                String wireName = binding.getMember().getTrait(software.amazon.smithy.model.traits.JsonNameTrait.class)
                    .map(software.amazon.smithy.model.traits.JsonNameTrait::getValue)
                    .orElseGet(binding::getLocationName);
                boolean hasJsonName = binding.getMember().hasTrait(software.amazon.smithy.model.traits.JsonNameTrait.class);
                if (hasJsonName) {
                    writer.write("'$L': [,,`$L`],", memberName, wireName);
                } else {
                    writer.write("'$1L': [],", wireName);
                }
            }
        });
        writer.write("Object.assign(contents, doc);");
    }
}
