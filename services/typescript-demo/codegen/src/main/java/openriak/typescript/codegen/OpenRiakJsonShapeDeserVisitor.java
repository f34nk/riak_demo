package openriak.typescript.codegen;

import java.util.Map;
import java.util.TreeMap;
import java.util.function.BiFunction;
import software.amazon.smithy.codegen.core.SymbolProvider;
import software.amazon.smithy.model.shapes.CollectionShape;
import software.amazon.smithy.model.shapes.DocumentShape;
import software.amazon.smithy.model.shapes.MapShape;
import software.amazon.smithy.model.shapes.MemberShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.ShapeVisitor;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.model.shapes.UnionShape;
import software.amazon.smithy.model.traits.JsonNameTrait;
import software.amazon.smithy.model.traits.SparseTrait;
import software.amazon.smithy.model.traits.TimestampFormatTrait.Format;
import software.amazon.smithy.typescript.codegen.SmithyCoreSubmodules;
import software.amazon.smithy.typescript.codegen.TypeScriptDependency;
import software.amazon.smithy.typescript.codegen.TypeScriptWriter;
import software.amazon.smithy.typescript.codegen.integration.DocumentShapeDeserVisitor;
import software.amazon.smithy.typescript.codegen.integration.ProtocolGenerator.GenerationContext;

final class OpenRiakJsonShapeDeserVisitor extends DocumentShapeDeserVisitor {

    private final BiFunction<MemberShape, String, String> memberNameStrategy;

    OpenRiakJsonShapeDeserVisitor(GenerationContext context, boolean serdeElisionEnabled) {
        super(context);
        this.serdeElisionEnabled = serdeElisionEnabled;
        this.memberNameStrategy = (memberShape, memberName) -> memberShape.getTrait(JsonNameTrait.class)
            .map(JsonNameTrait::getValue)
            .orElse(memberName);
    }

    private ShapeVisitor<String> getMemberVisitor(MemberShape memberShape, String dataSource) {
        return new OpenRiakJsonMemberDeserVisitor(getContext(), memberShape, dataSource, Format.EPOCH_SECONDS);
    }

    @Override
    protected void deserializeCollection(GenerationContext context, CollectionShape shape) {
        TypeScriptWriter writer = context.getWriter();
        Shape target = context.getModel().expectShape(shape.getMember().getTarget());
        String filter = shape.hasTrait(SparseTrait.ID) ? "" : ".filter((e: any) => e != null)";
        String returnExpression = target.accept(getMemberVisitor(shape.getMember(), "entry"));
        if (returnExpression.equals("entry")) {
            writer.write("return (output || [])$L;", filter);
        } else {
            writer.openBlock("return (output || [])$L.map((entry: any) => {", "});", filter, () -> {
                if (shape.hasTrait(SparseTrait.ID)) {
                    writer.openBlock("if (entry === null) {", "}", () -> writer.write("return null as any;"));
                }
                writer.write("return $L;", target.accept(getMemberVisitor(shape.getMember(), "entry")));
            });
        }
    }

    @Override
    protected void deserializeDocument(GenerationContext context, DocumentShape shape) {
        context.getWriter().write("return output;");
    }

    @Override
    protected void deserializeMap(GenerationContext context, MapShape shape) {
        TypeScriptWriter writer = context.getWriter();
        Shape target = context.getModel().expectShape(shape.getValue().getTarget());
        SymbolProvider symbolProvider = context.getSymbolProvider();
        writer.openBlock(
            "return Object.entries(output).reduce((acc: $T, [key, value]: [string, any]) => {",
            "",
            symbolProvider.toSymbol(shape),
            () -> {
                writer.openBlock("if (value === null) {", "}", () -> {
                    if (shape.hasTrait(SparseTrait.ID)) {
                        writer.write("acc[key as $T] = null as any;", symbolProvider.toSymbol(shape.getKey()));
                    }
                    writer.write("return acc;");
                });
                writer.write(
                    "acc[key as $T] = $L;",
                    symbolProvider.toSymbol(shape.getKey()),
                    target.accept(getMemberVisitor(shape.getValue(), "value"))
                );
                writer.write("return acc;");
            }
        );
        writer.writeInline("}, {} as $T);", symbolProvider.toSymbol(shape));
    }

    @Override
    protected void deserializeStructure(GenerationContext context, StructureShape shape) {
        TypeScriptWriter writer = context.getWriter();
        writer.addImportSubmodule("take", null, TypeScriptDependency.SMITHY_CORE, SmithyCoreSubmodules.CLIENT);
        writer.openBlock("return take(output, {", "}) as any;", () -> {
            Map<String, MemberShape> members = new TreeMap<>(shape.getAllMembers());
            members.forEach((memberName, memberShape) -> {
                String wireName = memberNameStrategy.apply(memberShape, memberName);
                boolean hasJsonName = memberShape.hasTrait(JsonNameTrait.class);
                Shape target = context.getModel().expectShape(memberShape.getTarget());
                String propertyAccess = "output." + wireName;
                String valueExpression = target.accept(getMemberVisitor(memberShape, propertyAccess));
                if (hasJsonName) {
                    if (valueExpression.equals(propertyAccess)) {
                        writer.write("'$L': [,,`$L`],", memberName, wireName);
                    } else {
                        writer.write("'$L': [, (_: any) => $L, `$L`],", memberName, valueExpression, wireName);
                    }
                } else if (valueExpression.equals(propertyAccess)) {
                    writer.write("'$1L': [],", memberName);
                } else {
                    writer.write("'$1L': (_: any) => $L,", memberName, valueExpression);
                }
            });
        });
    }

    @Override
    protected void deserializeUnion(GenerationContext context, UnionShape shape) {
        TypeScriptWriter writer = context.getWriter();
        Map<String, MemberShape> members = new TreeMap<>(shape.getAllMembers());
        members.forEach((memberName, memberShape) -> {
            Shape target = context.getModel().expectShape(memberShape.getTarget());
            String locationName = memberNameStrategy.apply(memberShape, memberName);
            String memberValue = target.accept(getMemberVisitor(memberShape, "output." + locationName));
            writer.openBlock("if (output.$L != null) {", "}", locationName, () -> {
                writer.openBlock("return {", "};", () -> writer.write("$L: $L", memberName, memberValue));
            });
        });
        writer.write("return { $$unknown: Object.entries(output)[0] };");
    }
}
