package openriak.typescript.codegen;

import java.util.Map;
import java.util.TreeMap;
import java.util.function.BiFunction;
import software.amazon.smithy.codegen.core.Symbol;
import software.amazon.smithy.codegen.core.SymbolProvider;
import software.amazon.smithy.model.knowledge.HttpBinding.Location;
import software.amazon.smithy.model.knowledge.HttpBindingIndex;
import software.amazon.smithy.model.shapes.CollectionShape;
import software.amazon.smithy.model.shapes.DocumentShape;
import software.amazon.smithy.model.shapes.MapShape;
import software.amazon.smithy.model.shapes.MemberShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.model.shapes.UnionShape;
import software.amazon.smithy.model.traits.JsonNameTrait;
import software.amazon.smithy.model.traits.SparseTrait;
import software.amazon.smithy.model.traits.TimestampFormatTrait;
import software.amazon.smithy.model.traits.TimestampFormatTrait.Format;
import software.amazon.smithy.typescript.codegen.SmithyCoreSubmodules;
import software.amazon.smithy.typescript.codegen.TypeScriptDependency;
import software.amazon.smithy.typescript.codegen.TypeScriptWriter;
import software.amazon.smithy.typescript.codegen.integration.DocumentShapeSerVisitor;
import software.amazon.smithy.typescript.codegen.integration.HttpProtocolGeneratorUtils;
import software.amazon.smithy.typescript.codegen.integration.ProtocolGenerator.GenerationContext;

final class OpenRiakJsonShapeSerVisitor extends DocumentShapeSerVisitor {

    private static final Format TIMESTAMP_FORMAT = Format.EPOCH_SECONDS;

    private final BiFunction<MemberShape, String, String> memberNameStrategy;

    OpenRiakJsonShapeSerVisitor(GenerationContext context, boolean serdeElisionEnabled) {
        super(context);
        this.serdeElisionEnabled = serdeElisionEnabled;
        this.memberNameStrategy = (memberShape, memberName) -> memberShape.getTrait(JsonNameTrait.class)
            .map(JsonNameTrait::getValue)
            .orElse(memberName);
    }

    private OpenRiakJsonMemberSerVisitor getMemberVisitor(String dataSource) {
        return new OpenRiakJsonMemberSerVisitor(getContext(), dataSource, TIMESTAMP_FORMAT);
    }

    @Override
    public void serializeCollection(GenerationContext context, CollectionShape shape) {
        TypeScriptWriter writer = context.getWriter();
        Shape target = context.getModel().expectShape(shape.getMember().getTarget());
        String filter = shape.hasTrait(SparseTrait.ID) ? "" : ".filter((e: any) => e != null)";
        String returnedExpression = target.accept(getMemberVisitor("entry"));
        if (returnedExpression.equals("entry")) {
            writer.write("return input$L;", filter);
        } else {
            writer.openBlock("return input$L.map(entry => {", "});", filter, () -> {
                if (shape.hasTrait(SparseTrait.ID)) {
                    writer.write("if (entry === null) { return null as any; }");
                }
                writer.write("return $L;", target.accept(getMemberVisitor("entry")));
            });
        }
    }

    @Override
    public void serializeDocument(GenerationContext context, DocumentShape shape) {
        context.getWriter().write("return input;");
    }

    @Override
    public void serializeMap(GenerationContext context, MapShape shape) {
        TypeScriptWriter writer = context.getWriter();
        Shape target = context.getModel().expectShape(shape.getValue().getTarget());
        writer.openBlock(
            "return Object.entries(input).reduce((acc: Record<string, any>, [key, value]: [string, any]) => {",
            "}, {});",
            () -> {
                writer.openBlock("if (value === null) {", "}", () -> {
                    if (shape.hasTrait(SparseTrait.ID)) {
                        writer.write("acc[key] = null as any;");
                    }
                    writer.write("return acc;");
                });
                writer.write("acc[key] = $L;", target.accept(getMemberVisitor("value")));
                writer.write("return acc;");
            }
        );
    }

    @Override
    public void serializeStructure(GenerationContext context, StructureShape shape) {
        TypeScriptWriter writer = context.getWriter();
        SymbolProvider symbolProvider = context.getSymbolProvider();
        HttpBindingIndex httpIndex = HttpBindingIndex.of(context.getModel());
        writer.addImportSubmodule("take", null, TypeScriptDependency.SMITHY_CORE, SmithyCoreSubmodules.CLIENT);
        writer.openBlock("return take(input, {", "});", () -> {
            Map<String, MemberShape> members = new TreeMap<>(shape.getAllMembers());
            members.forEach((memberName, memberShape) -> {
                String wireName = memberNameStrategy.apply(memberShape, memberName);
                boolean hasJsonName = memberShape.hasTrait(JsonNameTrait.class);
                Shape target = context.getModel().expectShape(memberShape.getTarget());
                String valueExpression = memberShape.hasTrait(TimestampFormatTrait.class)
                    ? HttpProtocolGeneratorUtils.getTimestampInputParam(
                        context,
                        "_",
                        memberShape,
                        httpIndex.determineTimestampFormat(memberShape, Location.DOCUMENT, TIMESTAMP_FORMAT)
                    )
                    : target.accept(getMemberVisitor("_"));
                String valueProvider = "_ => " + valueExpression;
                if (hasJsonName) {
                    if (valueProvider.equals("_ => _")) {
                        writer.write("'$L': [,,`$L`],", wireName, memberName);
                    } else {
                        writer.write("'$L': [,$L,`$L`],", wireName, valueProvider, memberName);
                    }
                } else if (valueProvider.equals("_ => _")) {
                    writer.write("'$1L': [],", memberName);
                } else {
                    writer.write("'$1L': $2L,", memberName, valueProvider);
                }
            });
        });
    }

    @Override
    public void serializeUnion(GenerationContext context, UnionShape shape) {
        TypeScriptWriter writer = context.getWriter();
        Symbol symbol = context.getSymbolProvider()
            .toSymbol(shape)
            .toBuilder()
            .putProperty("typeOnly", false)
            .build();
        writer.openBlock("return $T.visit(input, {", "});", symbol, () -> {
            Map<String, MemberShape> members = new TreeMap<>(shape.getAllMembers());
            members.forEach((memberName, memberShape) -> {
                String locationName = memberNameStrategy.apply(memberShape, memberName);
                Shape target = context.getModel().expectShape(memberShape.getTarget());
                writer.write(
                    "$L: value => ({ $S: $L }),",
                    memberName,
                    locationName,
                    target.accept(getMemberVisitor("value"))
                );
            });
            writer.write("_: (name, value) => ({ [name]: value } as any)");
        });
    }
}
