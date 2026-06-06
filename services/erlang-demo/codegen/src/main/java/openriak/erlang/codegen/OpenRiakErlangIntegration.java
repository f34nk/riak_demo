package openriak.erlang.codegen;

import io.smithy.beam.erlang.ErlangContext;
import io.smithy.beam.erlang.ErlangIntegration;

public final class OpenRiakErlangIntegration implements ErlangIntegration {

    @Override
    public String name() {
        return "openriak-erlang";
    }

    @Override
    public void customize(ErlangContext context) {
        if (OpenRiakHttpProtocolCodegen.OPEN_RIAK_HTTP.equals(context.resolvedProtocolTraitId())) {
            ErlangOpenRiakHttpEmitter.emitCodecModule(context, context.service());
        }
    }
}
