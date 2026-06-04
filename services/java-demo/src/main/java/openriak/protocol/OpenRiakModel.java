package openriak.protocol;

import java.io.InputStream;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.knowledge.HttpBindingIndex;
import software.amazon.smithy.model.loader.ModelAssembler;
import software.amazon.smithy.model.node.Node;

final class OpenRiakModel {

    private static final OpenRiakModel INSTANCE = new OpenRiakModel();

    private final Model model;
    private final HttpBindingIndex bindingIndex;

    private OpenRiakModel() {
        try (InputStream in = OpenRiakModel.class.getResourceAsStream("/openriak/openriak-3.4.model.json")) {
            if (in == null) {
                throw new IllegalStateException("Missing classpath resource /openriak/openriak-3.4.model.json");
            }
            Node node = Node.parse(in);
            this.model = Model.assembler()
                    .disablePrelude()
                    .addDocumentNode(node)
                    .assemble()
                    .unwrap();
            this.bindingIndex = HttpBindingIndex.of(model);
        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    static Model model() {
        return INSTANCE.model;
    }

    static HttpBindingIndex bindings() {
        return INSTANCE.bindingIndex;
    }
}
