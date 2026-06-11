package openriak.elixir.codegen;

import io.smithy.beam.core.BeamElixirLayout;
import io.smithy.beam.elixir.ElixirContext;
import software.amazon.smithy.model.shapes.OperationShape;
import software.amazon.smithy.model.shapes.ServiceShape;

/**
 * openRiakHttp codec emitter for Elixir. Stub pending full serde in Step 3.5.
 */
public final class ElixirOpenRiakHttpEmitter {

    public static final String CODEC_SUFFIX = "open_riak_http";

    private ElixirOpenRiakHttpEmitter() {}

    public static void emitCodecModule(ElixirContext ctx, ServiceShape service) {
        BeamElixirLayout layout = new BeamElixirLayout(
                ctx.settings(), service.getId().getNamespace(), service);
        String codecFile = layout.clientCodecModuleName(OpenRiakHttpProtocolCodegen.OPEN_RIAK_HTTP) + ".ex";
        String moduleName = toModuleName(
                layout.clientCodecModuleName(OpenRiakHttpProtocolCodegen.OPEN_RIAK_HTTP));

        ctx.writerDelegator().useFileWriter(codecFile, writer -> {
            writer.write("defmodule $L do", moduleName);
            writer.indent();
            writer.write("@moduledoc \"openRiakHttp codecs for $L (generated). Do not edit.\"",
                    service.getId());
            writer.dedent();
            writer.write("end");
        });
    }

    public static void emitOperation(ElixirContext ctx, ServiceShape service, OperationShape operation) {
        // Stub: full serde emitted in emitCodecModule during customize.
    }

    private static String toModuleName(String snakeName) {
        StringBuilder sb = new StringBuilder();
        for (String part : snakeName.split("_")) {
            if (!part.isEmpty()) {
                sb.append(Character.toUpperCase(part.charAt(0)));
                sb.append(part.substring(1));
            }
        }
        return sb.toString();
    }
}
