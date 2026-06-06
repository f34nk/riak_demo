package openriak.python.codegen;

import java.util.List;
import software.amazon.smithy.python.codegen.generators.ProtocolGenerator;
import software.amazon.smithy.python.codegen.integrations.PythonIntegration;

public final class OpenRiakPythonIntegration implements PythonIntegration {

    @Override
    public List<ProtocolGenerator> getProtocolGenerators() {
        return List.of(new OpenRiakHttpProtocolGenerator());
    }
}
