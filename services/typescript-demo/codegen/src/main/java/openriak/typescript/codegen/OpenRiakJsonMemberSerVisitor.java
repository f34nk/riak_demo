package openriak.typescript.codegen;

import software.amazon.smithy.codegen.core.CodegenException;
import software.amazon.smithy.model.shapes.BigDecimalShape;
import software.amazon.smithy.model.shapes.BigIntegerShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.traits.TimestampFormatTrait.Format;
import software.amazon.smithy.typescript.codegen.integration.DocumentMemberSerVisitor;
import software.amazon.smithy.typescript.codegen.integration.ProtocolGenerator.GenerationContext;

final class OpenRiakJsonMemberSerVisitor extends DocumentMemberSerVisitor {

    OpenRiakJsonMemberSerVisitor(GenerationContext context, String dataSource, Format defaultTimestampFormat) {
        super(context, dataSource, defaultTimestampFormat);
        this.serdeElisionEnabled = !context.getSettings().generateServerSdk();
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
                "Cannot serialize shape type %s on openRiakHttp, shape: %s.",
                shape.getType(),
                shape.getId()
            )
        );
    }
}
