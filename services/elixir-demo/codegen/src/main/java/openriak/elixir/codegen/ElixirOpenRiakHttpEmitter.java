package openriak.elixir.codegen;

import io.smithy.beam.core.BeamElixirLayout;
import io.smithy.beam.core.BeamNameUtils;
import io.smithy.beam.core.BeamServiceIndex;
import io.smithy.beam.elixir.ElixirContext;
import io.smithy.beam.elixir.ElixirWriter;
import software.amazon.smithy.codegen.core.Symbol;
import software.amazon.smithy.codegen.core.SymbolProvider;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.knowledge.HttpBinding;
import software.amazon.smithy.model.knowledge.HttpBindingIndex;
import software.amazon.smithy.model.shapes.BlobShape;
import software.amazon.smithy.model.shapes.MemberShape;
import software.amazon.smithy.model.shapes.OperationShape;
import software.amazon.smithy.model.shapes.ServiceShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.model.shapes.ShapeId;
import software.amazon.smithy.model.traits.ErrorTrait;
import software.amazon.smithy.model.traits.HttpErrorTrait;
import software.amazon.smithy.model.traits.HttpTrait;
import software.amazon.smithy.model.traits.StreamingTrait;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * openRiakHttp codec emitter for Elixir. HTTP framing follows smithy-beam REST helpers;
 * opaque {@code @httpPayload} bodies pass through without JSON document encoding.
 */
public final class ElixirOpenRiakHttpEmitter {

    public static final String CODEC_SUFFIX = "open_riak_http";

    private ElixirOpenRiakHttpEmitter() {}

    public static void emitCodecModule(ElixirContext ctx, ServiceShape service) {
        Model model = ctx.model();
        BeamElixirLayout layout = new BeamElixirLayout(
                ctx.settings(), service.getId().getNamespace(), service);
        HttpBindingIndex httpIndex = HttpBindingIndex.of(model);
        SymbolProvider sp = ctx.symbolProvider();
        String codecFile = layout.clientCodecModuleName(OpenRiakHttpProtocolCodegen.OPEN_RIAK_HTTP) + ".ex";
        String moduleName = toModuleName(
                layout.clientCodecModuleName(OpenRiakHttpProtocolCodegen.OPEN_RIAK_HTTP));
        String runtimeMod = toModuleName(layout.runtimeTypesModuleName());
        String typesMod = toModuleName(layout.typesModuleName());
        List<OperationShape> operations = containedOperationsSorted(model, service);

        ctx.writerDelegator().useFileWriter(codecFile, writer -> {
            writer.write("defmodule $L do", moduleName);
            writer.indent();
            writer.write("@moduledoc \"openRiakHttp codecs for $L (generated). Do not edit.\"",
                    service.getId());
            writer.write("alias $L, as: RuntimeTypes", runtimeMod);
            writer.write("alias $L, as: Types", typesMod);
            writer.write("");

            for (OperationShape op : operations) {
                emitEncoder(writer, model, op, httpIndex, sp, typesMod, runtimeMod);
                emitDecoder(writer, model, op, httpIndex, sp, typesMod, runtimeMod);
            }

            for (OperationShape op : operations) {
                emitErrorDispatch(writer, model, op, sp, typesMod);
            }

            emitHelpers(writer);

            writer.dedent();
            writer.write("end");
        });
    }

    public static void emitOperation(ElixirContext ctx, ServiceShape service, OperationShape operation) {
        // Full codec module is emitted once in customize via emitCodecModule.
    }

    private static void emitEncoder(
            ElixirWriter writer,
            Model model,
            OperationShape op,
            HttpBindingIndex httpIndex,
            SymbolProvider sp,
            String typesMod,
            String runtimeMod) {

        String opName = sp.toSymbol(op).getName();
        StructureShape input = model.expectShape(op.getInputShape(), StructureShape.class);
        String inputStruct = sp.toSymbol(input).getName();
        HttpTrait httpTrait = op.expectTrait(HttpTrait.class);
        String method = httpTrait.getMethod();
        String uriTemplate = httpTrait.getUri().toString();

        List<HttpBinding> labels = httpIndex.getRequestBindings(op, HttpBinding.Location.LABEL);
        List<HttpBinding> queries = httpIndex.getRequestBindings(op, HttpBinding.Location.QUERY);
        List<HttpBinding> queryParams = httpIndex.getRequestBindings(op, HttpBinding.Location.QUERY_PARAMS);
        List<HttpBinding> headers = httpIndex.getRequestBindings(op, HttpBinding.Location.HEADER);
        List<HttpBinding> prefixHeaders = httpIndex.getRequestBindings(op, HttpBinding.Location.PREFIX_HEADERS);
        List<HttpBinding> reqPayload = httpIndex.getRequestBindings(op, HttpBinding.Location.PAYLOAD);

        writer.write("@doc \"Encode HTTP request for $L.\"", op.getId());
        writer.write("@spec encode_$L_request($L.$L.t()) :: %$L.HttpRequest{}",
                opName, typesMod, inputStruct, runtimeMod);
        writer.write("def encode_$L_request(input) do", opName);
        writer.indent();

        String pathExpr = buildElixirPathExpression(uriTemplate, labels, sp);
        writer.write("path = $L", pathExpr);
        writer.write("");

        if (!queries.isEmpty()) {
            emitRejectNilMapPipeline(writer, "query", () -> {
                for (int i = 0; i < queries.size(); i++) {
                    HttpBinding qb = queries.get(i);
                    String field = fieldName(sp, qb.getMember());
                    if (i < queries.size() - 1) {
                        writer.write("\"$L\" => encode_query_value(input.$L),", qb.getLocationName(), field);
                    } else {
                        writer.write("\"$L\" => encode_query_value(input.$L)", qb.getLocationName(), field);
                    }
                }
            });
        } else {
            writer.write("query = %{}");
        }

        for (HttpBinding qp : queryParams) {
            String field = fieldName(sp, qp.getMember());
            writer.write("query_extra =");
            writer.indent();
            writer.write("case input.$L do", field);
            writer.indent();
            writer.write("nil -> []");
            writer.write("m when is_map(m) -> Map.to_list(m)");
            writer.dedent();
            writer.write("end");
            writer.dedent();
            writer.write("");
            writer.write("query =");
            writer.indent();
            writer.write("query");
            writer.write("|> Map.to_list()");
            writer.write("|> Enum.concat(query_extra)");
            writer.write("|> Map.new()");
            writer.dedent();
            writer.write("");
        }

        if (!headers.isEmpty()) {
            emitExtraHeadersPipeline(writer, sp, headers);
            writer.write("headers = extra_headers");
        } else {
            writer.write("headers = []");
        }

        for (HttpBinding ph : prefixHeaders) {
            String field = fieldName(sp, ph.getMember());
            String prefix = ph.getLocationName();
            writer.write("headers = headers ++ prefix_headers_to_list(\"$L\", input.$L)", prefix, field);
        }

        emitOpaqueRequestBody(writer, model, reqPayload, method, sp);

        writer.write("");
        writer.write("%RuntimeTypes.HttpRequest{");
        writer.write("  method: \"$L\",", method);
        writer.write("  path: path,");
        writer.write("  query: query,");
        writer.write("  headers: headers,");
        writer.write("  body: body");
        writer.write("}");

        writer.dedent();
        writer.write("end");
        writer.write("");
    }

    private static void emitDecoder(
            ElixirWriter writer,
            Model model,
            OperationShape op,
            HttpBindingIndex httpIndex,
            SymbolProvider sp,
            String typesMod,
            String runtimeMod) {

        String opName = sp.toSymbol(op).getName();
        StructureShape output = model.expectShape(op.getOutputShape(), StructureShape.class);
        String outputStruct = sp.toSymbol(output).getName();
        int successCode = httpIndex.getResponseCode(op);

        List<HttpBinding> respHeaders = httpIndex.getResponseBindings(op, HttpBinding.Location.HEADER);
        List<HttpBinding> respPrefixHeaders = httpIndex.getResponseBindings(op, HttpBinding.Location.PREFIX_HEADERS);
        List<HttpBinding> respPayload = httpIndex.getResponseBindings(op, HttpBinding.Location.PAYLOAD);
        List<HttpBinding> respCode = httpIndex.getResponseBindings(op, HttpBinding.Location.RESPONSE_CODE);

        writer.write("@doc \"Decode HTTP response for $L.\"", op.getId());
        writer.write("@spec decode_$L_response(%$L.HttpResponse{}) :: {:ok, $L.$L.t()} | {:error, term()}",
                opName, runtimeMod, typesMod, outputStruct);

        if (!respCode.isEmpty()) {
            writer.write(
                    "def decode_$L_response(%RuntimeTypes.HttpResponse{status: http_status, headers: headers, body: body})",
                    opName);
            writer.write("    when http_status >= 200 and http_status < 300 do");
        } else {
            writer.write(
                    "def decode_$L_response(%RuntimeTypes.HttpResponse{status: $L, headers: headers, body: body}) do",
                    opName, successCode);
        }
        writer.indent();

        for (HttpBinding hb : respHeaders) {
            String field = fieldName(sp, hb.getMember());
            writer.write("$L =", field);
            writer.indent();
            writer.write("headers");
            writer.write("|> List.keyfind(\"$L\", 0)", hb.getLocationName());
            writer.write("|> case do");
            writer.indent();
            writer.write("{_, v} -> v");
            writer.write("nil -> nil");
            writer.dedent();
            writer.write("end");
            writer.dedent();
            writer.write("");
        }

        List<String> recordFields = new ArrayList<>();
        for (HttpBinding hb : respHeaders) {
            String field = fieldName(sp, hb.getMember());
            recordFields.add(field + ": " + field);
        }
        for (HttpBinding ph : respPrefixHeaders) {
            String field = fieldName(sp, ph.getMember());
            recordFields.add(field + ": prefix_headers_from_list(headers, \"" + ph.getLocationName() + "\")");
        }
        for (HttpBinding pb : respPayload) {
            String field = fieldName(sp, pb.getMember());
            recordFields.add(field + ": body");
        }
        for (HttpBinding rcb : respCode) {
            String field = fieldName(sp, rcb.getMember());
            recordFields.add(field + ": http_status");
        }

        if (recordFields.isEmpty() && !respCode.isEmpty()) {
            recordFields.add("status_code: http_status");
        }

        writer.write("{:ok, %Types.$L{", outputStruct);
        writer.indent();
        for (int i = 0; i < recordFields.size(); i++) {
            if (i < recordFields.size() - 1) {
                writer.write("$L,", recordFields.get(i));
            } else {
                writer.write("$L", recordFields.get(i));
            }
        }
        writer.dedent();
        writer.write("}}");

        writer.dedent();
        writer.write("end");
        writer.write("");
        writer.write("def decode_$L_response(%RuntimeTypes.HttpResponse{status: status, headers: headers, body: body}) do",
                opName);
        writer.indent();
        writer.write("decode_$L_response_error(status, headers, body)", opName);
        writer.dedent();
        writer.write("end");
        writer.write("");
    }

    private static void emitErrorDispatch(
            ElixirWriter writer,
            Model model,
            OperationShape op,
            SymbolProvider sp,
            String typesMod) {

        String opName = sp.toSymbol(op).getName();
        List<ShapeId> errors = new ArrayList<>(op.getErrors());

        writer.write("# Error dispatch for $L", op.getId());
        for (ShapeId errorId : errors) {
            StructureShape errShape = model.expectShape(errorId, StructureShape.class);
            String modName = sp.toSymbol(errShape).getName();
            int httpStatus = errShape.hasTrait(HttpErrorTrait.class)
                    ? errShape.expectTrait(HttpErrorTrait.class).getCode()
                    : errShape.expectTrait(ErrorTrait.class).getDefaultHttpStatusCode();
            if (httpStatus <= 0) {
                continue;
            }
            writer.write("defp decode_$L_response_error($L, _headers, _body) do", opName, httpStatus);
            writer.indent();
            List<String> fields = buildErrorFields(errShape);
            if (fields.isEmpty()) {
                writer.write("{:error, struct!($L.$L, %{})}", typesMod, modName);
            } else {
                writer.write("{:error, struct!($L.$L, %{$L})}", typesMod, modName, String.join(", ", fields));
            }
            writer.dedent();
            writer.write("end");
            writer.write("");
        }

        writer.write("defp decode_$L_response_error(status, _headers, body) do", opName);
        writer.indent();
        writer.write("{:error, {:unknown_error, status, body}}");
        writer.dedent();
        writer.write("end");
        writer.write("");
    }

    private static List<String> buildErrorFields(StructureShape errShape) {
        List<String> fields = new ArrayList<>();
        for (MemberShape member : errShape.members()) {
            if (member.getMemberName().equals("__beam_error_kind")) {
                continue;
            }
            fields.add(fieldNameFromMember(member) + ": nil");
        }
        return fields;
    }

    private static void emitOpaqueRequestBody(
            ElixirWriter writer,
            Model model,
            List<HttpBinding> reqPayload,
            String method,
            SymbolProvider sp) {

        if (reqPayload.isEmpty()
                || method.equals("GET")
                || method.equals("DELETE")
                || method.equals("HEAD")) {
            writer.write("body = \"\"");
            return;
        }

        HttpBinding payload = reqPayload.get(0);
        MemberShape member = payload.getMember();
        String fieldName = fieldName(sp, member);
        Shape target = model.expectShape(member.getTarget());

        if (target instanceof BlobShape || target.hasTrait(StreamingTrait.class)) {
            writer.write("body =");
            writer.indent();
            writer.write("case input.$L do", fieldName);
            writer.indent();
            writer.write("nil -> \"\"");
            writer.write("value -> value");
            writer.dedent();
            writer.write("end");
            writer.dedent();
            return;
        }

        writer.write("body =");
        writer.indent();
        writer.write("case input.$L do", fieldName);
        writer.indent();
        writer.write("nil -> \"\"");
        writer.write("value when is_binary(value) -> value");
        writer.write("value -> to_string(value)");
        writer.dedent();
        writer.write("end");
        writer.dedent();
    }

    private static void emitHelpers(ElixirWriter writer) {
        writer.write("# -- Private helpers --");
        writer.write("");
        writer.write("defp uri_encode(value), do: URI.encode(to_string(value))");
        writer.write("");
        writer.write("defp encode_query_value(true), do: \"true\"");
        writer.write("defp encode_query_value(false), do: \"false\"");
        writer.write("defp encode_query_value(value) when is_integer(value), do: Integer.to_string(value)");
        writer.write("defp encode_query_value(value) when is_float(value), do: Float.to_string(value)");
        writer.write("defp encode_query_value(value) when is_binary(value), do: value");
        writer.write("defp encode_query_value(value) when is_atom(value), do: Atom.to_string(value)");
        writer.write("defp encode_query_value(value), do: to_string(value)");
        writer.write("");
        writer.write("defp prefix_headers_to_list(_prefix, nil), do: []");
        writer.write("defp prefix_headers_to_list(prefix, map) when is_map(map) do");
        writer.indent();
        writer.write("Enum.map(map, fn {k, v} -> {prefix <> k, to_string(v)} end)");
        writer.dedent();
        writer.write("end");
        writer.write("");
        writer.write("defp prefix_headers_from_list(headers, prefix) do");
        writer.indent();
        writer.write("headers");
        writer.write("|> Enum.filter(fn {name, _} -> String.starts_with?(name, prefix) end)");
        writer.write("|> Map.new(fn {name, val} -> {String.slice(name, byte_size(prefix)..-1//1), val} end)");
        writer.write("|> case do");
        writer.indent();
        writer.write("map when map == %{} -> nil");
        writer.write("map -> map");
        writer.dedent();
        writer.write("end");
        writer.dedent();
        writer.write("end");
        writer.write("");
    }

    private static void emitRejectNilMapPipeline(ElixirWriter writer, String varName, Runnable emitMapEntries) {
        writer.write("$L =", varName);
        writer.indent();
        writer.write("%{");
        writer.indent();
        emitMapEntries.run();
        writer.dedent();
        writer.write("}");
        writer.write("|> Enum.reject(fn {_, v} -> is_nil(v) end)");
        writer.write("|> Map.new()");
        writer.dedent();
        writer.write("");
    }

    private static void emitExtraHeadersPipeline(
            ElixirWriter writer,
            SymbolProvider sp,
            List<HttpBinding> headers) {
        writer.write("extra_headers =");
        writer.indent();
        writer.write("[");
        writer.indent();
        for (HttpBinding hb : headers) {
            String field = fieldName(sp, hb.getMember());
            writer.write("if(input.$L != nil, do: {\"$L\", to_string(input.$L)}, else: nil),",
                    field, hb.getLocationName(), field);
        }
        writer.dedent();
        writer.write("]");
        writer.write("|> Enum.reject(&is_nil/1)");
        writer.dedent();
        writer.write("");
    }

    private static String buildElixirPathExpression(
            String uriTemplate, List<HttpBinding> labels, SymbolProvider sp) {
        if (labels.isEmpty()) {
            return "\"" + escapeElixirString(uriTemplate) + "\"";
        }
        Map<String, HttpBinding> byLocation = new HashMap<>();
        for (HttpBinding lb : labels) {
            byLocation.put(lb.getLocationName(), lb);
        }
        StringBuilder sb = new StringBuilder("\"");
        int pos = 0;
        while (pos < uriTemplate.length()) {
            int start = uriTemplate.indexOf('{', pos);
            if (start < 0) {
                sb.append(escapeElixirString(uriTemplate.substring(pos)));
                break;
            }
            if (start > pos) {
                sb.append(escapeElixirString(uriTemplate.substring(pos, start)));
            }
            int end = uriTemplate.indexOf('}', start);
            String labelName = uriTemplate.substring(start + 1, end);
            if (labelName.endsWith("+")) {
                labelName = labelName.substring(0, labelName.length() - 1);
            }
            HttpBinding lb = byLocation.get(labelName);
            if (lb != null) {
                String field = fieldName(sp, lb.getMember());
                sb.append("#{uri_encode(input.").append(field).append(")}");
            } else {
                sb.append(escapeElixirString("{" + labelName + "}"));
            }
            pos = end + 1;
        }
        sb.append("\"");
        return sb.toString();
    }

    private static String fieldName(SymbolProvider sp, MemberShape member) {
        Symbol sym = sp.toSymbol(member);
        return sym.getProperty("fieldName", String.class)
                .orElseGet(() -> BeamNameUtils.toSnakeCase(member.getMemberName()));
    }

    private static String fieldNameFromMember(MemberShape member) {
        return BeamNameUtils.toSnakeCase(member.getMemberName());
    }

    private static String escapeElixirString(String value) {
        return value.replace("\\", "\\\\").replace("\"", "\\\"");
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

    private static List<OperationShape> containedOperationsSorted(Model model, ServiceShape service) {
        List<OperationShape> operations =
                new ArrayList<>(BeamServiceIndex.of(model).containedOperations(service));
        operations.sort(Comparator.comparing(o -> o.getId().toString()));
        return operations;
    }
}
