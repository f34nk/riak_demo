package openriak.typescript.codegen;

import software.amazon.smithy.codegen.core.CodegenException;
import software.amazon.smithy.model.shapes.BigDecimalShape;
import software.amazon.smithy.model.shapes.BigIntegerShape;
import software.amazon.smithy.model.shapes.MemberShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.traits.TimestampFormatTrait.Format;
import software.amazon.smithy.typescript.codegen.SmithyCoreSubmodules;
import software.amazon.smithy.typescript.codegen.TypeScriptDependency;
import software.amazon.smithy.typescript.codegen.integration.DocumentMemberDeserVisitor;
import software.amazon.smithy.typescript.codegen.integration.ProtocolGenerator.GenerationContext;

final class OpenRiakJsonMemberDeserVisitor extends DocumentMemberDeserVisitor {

    private final MemberShape memberShape;

    OpenRiakJsonMemberDeserVisitor(
        GenerationContext context,
        MemberShape memberShape,
        String dataSource,
        Format defaultTimestampFormat
    ) {
        super(context, dataSource, defaultTimestampFormat);
        this.memberShape = memberShape;
        context.getWriter()
            .addImportSubmodule("_json", null, TypeScriptDependency.SMITHY_CORE, SmithyCoreSubmodules.CLIENT);
        this.serdeElisionEnabled = !context.getSettings().generateServerSdk();
    }

    @Override
    protected MemberShape getMemberShape() {
        return memberShape;
    }

    @Override
    public String bigDecimalShape(BigDecimalShape shape) {
        return unsupportedShape(shape);
    }

    @Override
    public String bigIntegerShape(BigIntegerShape shape) {
        return unsupportedShape(shape);
    }

    private String unsupportedShape(Shape shape) {
        throw new CodegenException(
            String.format(
                "Cannot deserialize shape type %s on openRiakHttp, shape: %s.",
                shape.getType(),
                shape.getId()
            )
        );
    }
}
