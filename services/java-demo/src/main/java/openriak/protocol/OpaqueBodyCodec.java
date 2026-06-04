package openriak.protocol;

import java.io.OutputStream;
import java.nio.ByteBuffer;
import software.amazon.smithy.java.core.serde.Codec;
import software.amazon.smithy.java.core.serde.ShapeDeserializer;
import software.amazon.smithy.java.core.serde.ShapeSerializer;

final class OpaqueBodyCodec implements Codec {

    static final OpaqueBodyCodec INSTANCE = new OpaqueBodyCodec();

    private OpaqueBodyCodec() {}

    @Override
    public ShapeSerializer createSerializer(OutputStream out) {
        throw new UnsupportedOperationException("OpenRiak bodies are bound as DataStream");
    }

    @Override
    public ShapeDeserializer createDeserializer(ByteBuffer bytes) {
        throw new UnsupportedOperationException("OpenRiak error bodies are handled in OpenRiakHttpErrors");
    }
}
