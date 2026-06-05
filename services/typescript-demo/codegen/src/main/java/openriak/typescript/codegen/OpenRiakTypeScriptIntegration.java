package openriak.typescript.codegen;

import java.util.List;
import software.amazon.smithy.typescript.codegen.integration.ProtocolGenerator;
import software.amazon.smithy.typescript.codegen.integration.TypeScriptIntegration;

public final class OpenRiakTypeScriptIntegration implements TypeScriptIntegration {

    @Override
    public List<ProtocolGenerator> getProtocolGenerators() {
        return List.of(new OpenRiakHttpProtocolGenerator());
    }
}
