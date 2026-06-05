package openriak.typescript.codegen;

import java.util.Set;
import software.amazon.smithy.model.knowledge.NeighborProviderIndex;
import software.amazon.smithy.model.neighbor.Walker;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.ShapeVisitor;
import software.amazon.smithy.model.traits.StreamingTrait;
import software.amazon.smithy.typescript.codegen.integration.ProtocolGenerator.GenerationContext;

final class OpenRiakProtocolUtils {

    private OpenRiakProtocolUtils() {}

    static void generateDocumentBodyShapeSerde(
        GenerationContext context,
        Set<Shape> shapes,
        ShapeVisitor<Void> visitor
    ) {
        Walker shapeWalker = new Walker(NeighborProviderIndex.of(context.getModel()).getProvider());
        Set<Shape> shapesToGenerate = new java.util.TreeSet<>(shapes);
        shapes.forEach(shape -> shapesToGenerate.addAll(shapeWalker.walkShapes(shape)));
        shapesToGenerate.forEach(shape -> {
            boolean isEventStream = shape.isUnionShape() && shape.hasTrait(StreamingTrait.class);
            if (!isEventStream) {
                shape.accept(visitor);
            }
        });
    }

    static void generateJsonParseBody(GenerationContext context) {
        var writer = context.getWriter();
        writer.addImport("SerdeContext", "__SerdeContext", software.amazon.smithy.typescript.codegen.TypeScriptDependency.SMITHY_TYPES);
        writer.openBlock(
            "const parseBody = (streamBody: any, context: __SerdeContext): Promise<any> => "
                + "collectBodyString(streamBody, context).then(encoded => {",
            "});",
            () -> {
                writer.openBlock("if (encoded.length) {", "}", () -> writer.write("return JSON.parse(encoded);"));
                writer.write("return {};");
            }
        );
        writer.write("");
        writer.openBlock(
            "const parseErrorBody = (streamBody: any, context: __SerdeContext): Promise<any> => "
                + "collectBodyString(streamBody, context).then(encoded => {",
            "});",
            () -> {
                writer.openBlock("if (encoded.length) {", "}", () -> {
                    writer.openBlock("try {", "} catch { return encoded; }", () -> writer.write("return JSON.parse(encoded);"));
                });
                writer.write("return {};");
            }
        );
        writer.write("");
    }
}
