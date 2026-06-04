$version: "2"

namespace openriak.current.api

use smithy.api#error
use smithy.api#http
use smithy.api#httpError
use smithy.api#httpHeader
use smithy.api#httpLabel
use smithy.api#httpPayload
use smithy.api#httpPrefixHeaders
use smithy.api#httpQuery
use smithy.api#httpResponseCode
use smithy.api#idempotent
use smithy.api#length
use smithy.api#pattern
use smithy.api#protocolDefinition
use smithy.api#readonly
use smithy.api#required
use smithy.api#streaming
use smithy.api#Document
use smithy.api#documentation
use smithy.api#trait

@trait(selector: "service")
@protocolDefinition
structure openRiakHttp {}

@openRiakHttp
service OpenRiak {
    version: "2026-05-06"
    operations: [
        GetRoot,
        Ping,
        GetStats,
        HeadStats,
        GetBucketTypeProperties,
        SetBucketTypeProperties,
        ListBuckets,
        StreamBuckets,
        ListDefaultBuckets,
        StreamDefaultBuckets,
        GetBucketProperties,
        SetBucketProperties,
        ResetBucketProperties,
        GetDefaultBucketProperties,
        SetDefaultBucketProperties,
        ResetDefaultBucketProperties,
        ListKeys,
        StreamKeys,
        ListDefaultKeys,
        StreamDefaultKeys,
        GetObject,
        HeadObject,
        PutObject,
        PutObjectReturnBody,
        PostObject,
        PostObjectReturnBody,
        CreateObject,
        CreateObjectReturnBody,
        DeleteObject,
        GetDefaultObject,
        HeadDefaultObject,
        PutDefaultObject,
        PutDefaultObjectReturnBody,
        PostDefaultObject,
        PostDefaultObjectReturnBody,
        CreateDefaultObject,
        CreateDefaultObjectReturnBody,
        DeleteDefaultObject,
        GetLegacyObject,
        HeadLegacyObject,
        PutLegacyObject,
        PutLegacyObjectReturnBody,
        PostLegacyObject,
        PostLegacyObjectReturnBody,
        DeleteLegacyObject,
        LinkWalk,
        LinkWalkDefault,
        LinkWalkLegacy,
        QuerySecondaryIndex,
        QuerySecondaryIndexRange,
        StreamSecondaryIndex,
        StreamSecondaryIndexRange,
        QueryDefaultSecondaryIndex,
        QueryDefaultSecondaryIndexRange,
        StreamDefaultSecondaryIndex,
        StreamDefaultSecondaryIndexRange,
        RunBucketQuery,
        GetBucketQueryResults,
        RunDefaultBucketQuery,
        GetDefaultBucketQueryResults,
        MapReduce,
        MapReduceChunked,
        HeadMapReduce,
        GetMapReduceUsage,
        GetDatatype,
        UpdateDatatype,
        CreateDatatype,
        GetLegacyCounter,
        UpdateLegacyCounter,
        GetMergeRootNval,
        GetMergeBranchNval,
        GetFetchClocksNval,
        GetMergeTreeRange,
        GetDefaultMergeTreeRange,
        GetFetchClocksRange,
        GetDefaultFetchClocksRange,
        GetReplKeysRange,
        GetDefaultReplKeysRange,
        GetRepairKeysRange,
        GetDefaultRepairKeysRange,
        GetFindKeysBySiblingCount,
        GetDefaultFindKeysBySiblingCount,
        GetFindKeysByObjectSize,
        GetDefaultFindKeysByObjectSize,
        GetObjectStats,
        GetDefaultObjectStats,
        GetFindTombs,
        GetDefaultFindTombs,
        GetEraseKeys,
        GetDefaultEraseKeys,
        GetReapTombs,
        GetDefaultReapTombs,
        ListAaeBuckets,
        GetMembership,
        GetQueueItem,
        PushQueueItems
    ]
}

@readonly
@http(method: "GET", uri: "/", code: 200)
operation GetRoot {
    input: AcceptInput
    output: RootOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/ping", code: 200)
operation Ping {
    output: TextOutput
    errors: [UnauthorizedError, ForbiddenError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/stats", code: 200)
operation GetStats {
    input: StatsInput
    output: NegotiatedBodyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "HEAD", uri: "/stats", code: 200)
operation HeadStats {
    input: StatsInput
    output: HeaderOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/props", code: 200)
operation GetBucketTypeProperties {
    input: BucketTypeInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "PUT", uri: "/types/{bucketType}/props", code: 204)
operation SetBucketTypeProperties {
    input: BucketTypePropertiesInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets?buckets=true", code: 200)
operation ListBuckets {
    input: ListBucketsInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets?buckets=stream", code: 200)
operation StreamBuckets {
    input: ListBucketsInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/buckets?buckets=true", code: 200)
operation ListDefaultBuckets {
    input: TimeoutInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/buckets?buckets=stream", code: 200)
operation StreamDefaultBuckets {
    input: TimeoutInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets/{bucket}/props", code: 200)
operation GetBucketProperties {
    input: BucketInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "PUT", uri: "/types/{bucketType}/buckets/{bucket}/props", code: 204)
operation SetBucketProperties {
    input: BucketPropertiesInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "DELETE", uri: "/types/{bucketType}/buckets/{bucket}/props", code: 204)
operation ResetBucketProperties {
    input: BucketInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/buckets/{bucket}/props", code: 200)
operation GetDefaultBucketProperties {
    input: DefaultBucketInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "PUT", uri: "/buckets/{bucket}/props", code: 204)
operation SetDefaultBucketProperties {
    input: DefaultBucketPropertiesInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "DELETE", uri: "/buckets/{bucket}/props", code: 204)
operation ResetDefaultBucketProperties {
    input: DefaultBucketInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets/{bucket}/keys?keys=true", code: 200)
operation ListKeys {
    input: ListKeysInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets/{bucket}/keys?keys=stream", code: 200)
operation StreamKeys {
    input: ListKeysInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/buckets/{bucket}/keys?keys=true", code: 200)
operation ListDefaultKeys {
    input: ListDefaultKeysInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/buckets/{bucket}/keys?keys=stream", code: 200)
operation StreamDefaultKeys {
    input: ListDefaultKeysInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@documentation("When siblings exist and no vtag is given, the server may respond with 300 Multiple Choices and a text body listing vtags. Send Accept: multipart/mixed to receive all siblings in one body at 200.")
@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets/{bucket}/keys/{key}", code: 200)
operation GetObject {
    input: GetObjectInput
    output: ObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, MultipleChoicesError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@documentation("When siblings exist and no vtag is given, the server may respond with 300 Multiple Choices and a text body listing vtags. Send Accept: multipart/mixed to receive all siblings in one body at 200.")
@readonly
@http(method: "HEAD", uri: "/types/{bucketType}/buckets/{bucket}/keys/{key}", code: 200)
operation HeadObject {
    input: HeadObjectInput
    output: HeadObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, MultipleChoicesError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "PUT", uri: "/types/{bucketType}/buckets/{bucket}/keys/{key}", code: 204)
operation PutObject {
    input: PutObjectInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "PUT", uri: "/types/{bucketType}/buckets/{bucket}/keys/{key}?returnbody=true", code: 200)
operation PutObjectReturnBody {
    input: PutObjectInput
    output: ObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/types/{bucketType}/buckets/{bucket}/keys/{key}", code: 204)
operation PostObject {
    input: PutObjectInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/types/{bucketType}/buckets/{bucket}/keys/{key}?returnbody=true", code: 200)
operation PostObjectReturnBody {
    input: PutObjectInput
    output: ObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/types/{bucketType}/buckets/{bucket}/keys", code: 201)
operation CreateObject {
    input: CreateObjectInput
    output: CreateObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/types/{bucketType}/buckets/{bucket}/keys?returnbody=true", code: 201)
operation CreateObjectReturnBody {
    input: CreateObjectInput
    output: CreateObjectReturnBodyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "DELETE", uri: "/types/{bucketType}/buckets/{bucket}/keys/{key}", code: 204)
operation DeleteObject {
    input: DeleteObjectInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@documentation("When siblings exist and no vtag is given, the server may respond with 300 Multiple Choices and a text body listing vtags. Send Accept: multipart/mixed to receive all siblings in one body at 200.")
@readonly
@http(method: "GET", uri: "/buckets/{bucket}/keys/{key}", code: 200)
operation GetDefaultObject {
    input: GetDefaultObjectInput
    output: ObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, MultipleChoicesError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@documentation("When siblings exist and no vtag is given, the server may respond with 300 Multiple Choices and a text body listing vtags. Send Accept: multipart/mixed to receive all siblings in one body at 200.")
@readonly
@http(method: "HEAD", uri: "/buckets/{bucket}/keys/{key}", code: 200)
operation HeadDefaultObject {
    input: HeadDefaultObjectInput
    output: HeadObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, MultipleChoicesError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "PUT", uri: "/buckets/{bucket}/keys/{key}", code: 204)
operation PutDefaultObject {
    input: PutDefaultObjectInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "PUT", uri: "/buckets/{bucket}/keys/{key}?returnbody=true", code: 200)
operation PutDefaultObjectReturnBody {
    input: PutDefaultObjectInput
    output: ObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/buckets/{bucket}/keys/{key}", code: 204)
operation PostDefaultObject {
    input: PutDefaultObjectInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/buckets/{bucket}/keys/{key}?returnbody=true", code: 200)
operation PostDefaultObjectReturnBody {
    input: PutDefaultObjectInput
    output: ObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/buckets/{bucket}/keys", code: 201)
operation CreateDefaultObject {
    input: CreateDefaultObjectInput
    output: CreateObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/buckets/{bucket}/keys?returnbody=true", code: 201)
operation CreateDefaultObjectReturnBody {
    input: CreateDefaultObjectInput
    output: CreateObjectReturnBodyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "DELETE", uri: "/buckets/{bucket}/keys/{key}", code: 204)
operation DeleteDefaultObject {
    input: DeleteDefaultObjectInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@documentation("When siblings exist and no vtag is given, the server may respond with 300 Multiple Choices and a text body listing vtags. Send Accept: multipart/mixed to receive all siblings in one body at 200.")
@readonly
@http(method: "GET", uri: "/riak/{bucket}/{key}", code: 200)
operation GetLegacyObject {
    input: GetDefaultObjectInput
    output: ObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, MultipleChoicesError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@documentation("When siblings exist and no vtag is given, the server may respond with 300 Multiple Choices and a text body listing vtags. Send Accept: multipart/mixed to receive all siblings in one body at 200.")
@readonly
@http(method: "HEAD", uri: "/riak/{bucket}/{key}", code: 200)
operation HeadLegacyObject {
    input: HeadDefaultObjectInput
    output: HeadObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, MultipleChoicesError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "PUT", uri: "/riak/{bucket}/{key}", code: 204)
operation PutLegacyObject {
    input: PutDefaultObjectInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "PUT", uri: "/riak/{bucket}/{key}?returnbody=true", code: 200)
operation PutLegacyObjectReturnBody {
    input: PutDefaultObjectInput
    output: ObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/riak/{bucket}/{key}", code: 204)
operation PostLegacyObject {
    input: PutDefaultObjectInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/riak/{bucket}/{key}?returnbody=true", code: 200)
operation PostLegacyObjectReturnBody {
    input: PutDefaultObjectInput
    output: ObjectOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, ConflictError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@idempotent
@http(method: "DELETE", uri: "/riak/{bucket}/{key}", code: 204)
operation DeleteLegacyObject {
    input: DeleteDefaultObjectInput
    output: EmptyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, PreconditionFailedError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets/{bucket}/keys/{key}/{walk+}", code: 200)
operation LinkWalk {
    input: LinkWalkInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/buckets/{bucket}/keys/{key}/{walk+}", code: 200)
operation LinkWalkDefault {
    input: LinkWalkDefaultInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/riak/{bucket}/{key}/{walk+}", code: 200)
operation LinkWalkLegacy {
    input: LinkWalkDefaultInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, NotAcceptableError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets/{bucket}/index/{field}/{value}", code: 200)
operation QuerySecondaryIndex {
    input: SecondaryIndexInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets/{bucket}/index/{field}/{start}/{end}", code: 200)
operation QuerySecondaryIndexRange {
    input: SecondaryIndexRangeInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets/{bucket}/index/{field}/{value}?stream=true", code: 200)
operation StreamSecondaryIndex {
    input: SecondaryIndexStreamInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets/{bucket}/index/{field}/{start}/{end}?stream=true", code: 200)
operation StreamSecondaryIndexRange {
    input: SecondaryIndexRangeStreamInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/buckets/{bucket}/index/{field}/{value}", code: 200)
operation QueryDefaultSecondaryIndex {
    input: DefaultSecondaryIndexInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/buckets/{bucket}/index/{field}/{start}/{end}", code: 200)
operation QueryDefaultSecondaryIndexRange {
    input: DefaultSecondaryIndexRangeInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/buckets/{bucket}/index/{field}/{value}?stream=true", code: 200)
operation StreamDefaultSecondaryIndex {
    input: DefaultSecondaryIndexStreamInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/buckets/{bucket}/index/{field}/{start}/{end}?stream=true", code: 200)
operation StreamDefaultSecondaryIndexRange {
    input: DefaultSecondaryIndexRangeStreamInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/types/{bucketType}/buckets/{bucket}/query", code: 200)
operation RunBucketQuery {
    input: BucketQueryInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets/{bucket}/query", code: 200)
operation GetBucketQueryResults {
    input: BucketQueryResultsInput
    output: QueryOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, GoneError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/buckets/{bucket}/query", code: 200)
operation RunDefaultBucketQuery {
    input: DefaultBucketQueryInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/buckets/{bucket}/query", code: 200)
operation GetDefaultBucketQueryResults {
    input: DefaultBucketQueryResultsInput
    output: QueryOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, GoneError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/mapred", code: 200)
operation MapReduce {
    input: MapReduceInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotAcceptableError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/mapred?chunked=true", code: 200)
operation MapReduceChunked {
    input: MapReduceInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotAcceptableError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "HEAD", uri: "/mapred", code: 200)
operation HeadMapReduce {
    output: HeaderOutput
    errors: [UnauthorizedError, ForbiddenError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/mapred", code: 200)
operation GetMapReduceUsage {
    output: TextOutput
    errors: [UnauthorizedError, ForbiddenError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/types/{bucketType}/buckets/{bucket}/datatypes/{key}", code: 200)
operation GetDatatype {
    input: DatatypeReadInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/types/{bucketType}/buckets/{bucket}/datatypes/{key}", code: 200)
operation UpdateDatatype {
    input: DatatypeUpdateInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, ConflictError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/types/{bucketType}/buckets/{bucket}/datatypes", code: 201)
operation CreateDatatype {
    input: DatatypeCreateInput
    output: DatatypeCreateOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, ConflictError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@documentation("Legacy counter API on default-bucket paths. Deprecated in docs but still served on openriak-3.4.")
@readonly
@http(method: "GET", uri: "/buckets/{bucket}/counters/{key}", code: 200)
operation GetLegacyCounter {
    input: CounterReadInput
    output: TextOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@documentation("Legacy counter API on default-bucket paths. Deprecated in docs but still served on openriak-3.4.")
@http(method: "POST", uri: "/buckets/{bucket}/counters/{key}", code: 200)
operation UpdateLegacyCounter {
    input: CounterUpdateInput
    output: TextOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, ConflictError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/cachedtrees/nvals/{nVal}/root", code: 200)
operation GetMergeRootNval {
    input: GetMergeRootNvalInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/cachedtrees/nvals/{nVal}/branch", code: 200)
operation GetMergeBranchNval {
    input: GetMergeBranchNvalInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/cachedtrees/nvals/{nVal}/keysclocks", code: 200)
operation GetFetchClocksNval {
    input: GetFetchClocksNvalInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/rangetrees/types/{bucketType}/buckets/{bucket}/trees/{treeSize}", code: 200)
operation GetMergeTreeRange {
    input: GetMergeTreeRangeInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/rangetrees/buckets/{bucket}/trees/{treeSize}", code: 200)
operation GetDefaultMergeTreeRange {
    input: GetDefaultMergeTreeRangeInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/rangetrees/types/{bucketType}/buckets/{bucket}/keysclocks", code: 200)
operation GetFetchClocksRange {
    input: GetFetchClocksRangeInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/rangetrees/buckets/{bucket}/keysclocks", code: 200)
operation GetDefaultFetchClocksRange {
    input: GetDefaultFetchClocksRangeInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/rangerepl/types/{bucketType}/buckets/{bucket}/queuename/{queueName}", code: 200)
operation GetReplKeysRange {
    input: GetReplKeysRangeInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/rangerepl/buckets/{bucket}/queuename/{queueName}", code: 200)
operation GetDefaultReplKeysRange {
    input: GetDefaultReplKeysRangeInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/rangerepair/types/{bucketType}/buckets/{bucket}", code: 200)
operation GetRepairKeysRange {
    input: GetRepairKeysRangeInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/rangerepair/buckets/{bucket}", code: 200)
operation GetDefaultRepairKeysRange {
    input: GetDefaultRepairKeysRangeInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/siblings/types/{bucketType}/buckets/{bucket}/counts/{count}", code: 200)
operation GetFindKeysBySiblingCount {
    input: GetFindKeysBySiblingCountInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/siblings/buckets/{bucket}/counts/{count}", code: 200)
operation GetDefaultFindKeysBySiblingCount {
    input: GetDefaultFindKeysBySiblingCountInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/objectsizes/types/{bucketType}/buckets/{bucket}/sizes/{size}", code: 200)
operation GetFindKeysByObjectSize {
    input: GetFindKeysByObjectSizeInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/objectsizes/buckets/{bucket}/sizes/{size}", code: 200)
operation GetDefaultFindKeysByObjectSize {
    input: GetDefaultFindKeysByObjectSizeInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/objectstats/types/{bucketType}/buckets/{bucket}", code: 200)
operation GetObjectStats {
    input: GetObjectStatsInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/objectstats/buckets/{bucket}", code: 200)
operation GetDefaultObjectStats {
    input: GetDefaultObjectStatsInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/tombs/types/{bucketType}/buckets/{bucket}", code: 200)
operation GetFindTombs {
    input: GetFindTombsInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/tombs/buckets/{bucket}", code: 200)
operation GetDefaultFindTombs {
    input: GetDefaultFindTombsInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/erase/types/{bucketType}/buckets/{bucket}", code: 200)
operation GetEraseKeys {
    input: GetEraseKeysInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/erase/buckets/{bucket}", code: 200)
operation GetDefaultEraseKeys {
    input: GetDefaultEraseKeysInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/reap/types/{bucketType}/buckets/{bucket}", code: 200)
operation GetReapTombs {
    input: GetReapTombsInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/reap/buckets/{bucket}", code: 200)
operation GetDefaultReapTombs {
    input: GetDefaultReapTombsInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/aaebucketlist", code: 200)
operation ListAaeBuckets {
    input: ListAaeBucketsInput
    output: StreamOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/membership_request", code: 200)
operation GetMembership {
    input: TimeoutInput
    output: JsonOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@readonly
@http(method: "GET", uri: "/queuename/{queueName}", code: 200)
operation GetQueueItem {
    input: GetQueueItemInput
    output: NegotiatedBodyOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, NotFoundError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@http(method: "POST", uri: "/queuename/{queueName}", code: 200)
operation PushQueueItems {
    input: PushQueueItemsInput
    output: TextOutput
    errors: [BadRequestError, UnauthorizedError, ForbiddenError, TimeoutError, UpgradeRequiredError, InternalServerError]
}

@pattern("^[A-Za-z0-9._~-]+$")
string UriSafeIdentifier

@length(min: 1)
string NonEmptyString

@pattern("^(default|one|quorum|all|[0-9]+)$")
string Quorum

string MediaType

string HeaderValue

string VClock

string VTag

timestamp HttpDate

document JsonDocument

@streaming
blob ByteStream

map RiakHeaders {
    key: String
    value: HeaderValue
}

enum SyncOnWrite {
    ONE = "one"
    ALL = "all"
    BACKEND = "backend"
}

@mixin
structure BucketTypeIdentity {
    @required
    @httpLabel
    bucketType: UriSafeIdentifier
}

@mixin
structure BucketIdentity with [BucketTypeIdentity] {
    @required
    @httpLabel
    bucket: UriSafeIdentifier
}

@mixin
structure DefaultBucketIdentity {
    @required
    @httpLabel
    bucket: UriSafeIdentifier
}

@mixin
structure ObjectIdentity with [BucketIdentity] {
    @required
    @httpLabel
    key: String
}

@mixin
structure DefaultObjectIdentity with [DefaultBucketIdentity] {
    @required
    @httpLabel
    key: String
}

@mixin
structure TimeoutOption {
    @httpQuery("timeout")
    timeout: Integer
}

@mixin
structure ReadOptions with [TimeoutOption] {
    @httpQuery("r")
    r: Quorum

    @httpQuery("pr")
    pr: Quorum

    @httpQuery("basic_quorum")
    basicQuorum: Boolean

    @httpQuery("notfound_ok")
    notfoundOk: Boolean

    @httpQuery("node_confirms")
    nodeConfirms: Integer

    @httpQuery("deletedvclock")
    deletedVClock: Boolean
}

@mixin
structure ObjectWriteOptions with [TimeoutOption] {
    @httpQuery("w")
    w: Quorum

    @httpQuery("dw")
    dw: Quorum

    @httpQuery("pw")
    pw: Quorum

    @httpQuery("node_confirms")
    nodeConfirms: Integer

    @httpQuery("sync_on_write")
    syncOnWrite: SyncOnWrite
}

@mixin
structure WriteOptions with [ObjectWriteOptions] {
    @httpQuery("returnbody")
    returnBody: Boolean
}

@mixin
structure DeleteOptions with [TimeoutOption] {
    @httpQuery("r")
    r: Quorum

    @httpQuery("w")
    w: Quorum

    @httpQuery("rw")
    rw: Quorum

    @httpQuery("pr")
    pr: Quorum

    @httpQuery("pw")
    pw: Quorum

    @httpQuery("dw")
    dw: Quorum
}

@documentation("Accept drives sibling resolution: multipart/mixed returns all siblings at 200; other values may yield 300 with a vtag list when siblings are unresolved.")
@mixin
structure ConditionalReadHeaders {
    @httpHeader("Accept")
    accept: MediaType

    @httpHeader("If-None-Match")
    ifNoneMatch: String

    @httpHeader("If-Modified-Since")
    ifModifiedSince: HttpDate
}

@documentation("Riak-native conditional writes use x-riak-if-not-modified with an encoded vclock from a prior read, alongside standard If-Match and If-Unmodified-Since headers.")
@mixin
structure ConditionalWriteHeaders {
    @httpHeader("If-None-Match")
    ifNoneMatch: String

    @httpHeader("If-Match")
    ifMatch: String

    @httpHeader("If-Unmodified-Since")
    ifUnmodifiedSince: HttpDate

    @httpHeader("x-riak-if-not-modified")
    ifNotModified: VClock
}

structure AcceptInput {
    @httpHeader("Accept")
    accept: MediaType
}

structure StatsInput with [TimeoutOption] {
    @httpHeader("Accept")
    accept: MediaType
}

structure TimeoutInput with [TimeoutOption] {}

structure RootOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Link")
    link: String

    @required
    @httpPayload
    body: ByteStream
}

structure HeaderOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Link")
    link: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders
}

structure TextOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpPayload
    body: String
}

structure JsonOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpPayload
    body: JsonDocument
}

@documentation("Paginated query results. Fetch responses may include returned_count, queued_count, and query_complete keys. queue_raw_keys and queue_raw_terms accumulation options return a result_queue reference for subsequent GET fetches.")
structure QueryOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("X-Riak-Continuation")
    continuation: String

    @httpPayload
    body: JsonDocument
}

structure NegotiatedBodyOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Content-Type")
    contentType: MediaType

    @required
    @httpPayload
    body: ByteStream
}

structure StreamOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Link")
    link: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders

    @required
    @httpPayload
    body: ByteStream
}

structure EmptyOutput {
    @httpResponseCode
    statusCode: Integer
}

structure BucketTypeInput with [BucketTypeIdentity, TimeoutOption] {}

structure BucketInput with [BucketIdentity, TimeoutOption] {}

structure DefaultBucketInput with [DefaultBucketIdentity, TimeoutOption] {}

structure ListBucketsInput with [BucketTypeIdentity, TimeoutOption] {}

structure ListKeysInput with [BucketIdentity, TimeoutOption] {
    @httpQuery("props")
    props: Boolean
}

structure ListDefaultKeysInput with [DefaultBucketIdentity, TimeoutOption] {
    @httpQuery("props")
    props: Boolean
}

structure BucketTypePropertiesInput with [BucketTypeIdentity] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @required
    @httpPayload
    properties: JsonDocument
}

structure BucketPropertiesInput with [BucketIdentity] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @required
    @httpPayload
    properties: JsonDocument
}

structure DefaultBucketPropertiesInput with [DefaultBucketIdentity] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @required
    @httpPayload
    properties: JsonDocument
}

structure GetObjectInput with [ObjectIdentity, ReadOptions, ConditionalReadHeaders] {
    @httpQuery("vtag")
    vtag: VTag
}

structure HeadObjectInput with [ObjectIdentity, ReadOptions, ConditionalReadHeaders] {
    @httpQuery("vtag")
    vtag: VTag
}

@documentation("Supports x-riak-if-not-modified and standard conditional headers for Riak-native conditional updates.")
structure PutObjectInput with [ObjectIdentity, ObjectWriteOptions, ConditionalWriteHeaders] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Content-Encoding")
    contentEncoding: String

    @httpHeader("Link")
    link: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders

    @required
    @httpPayload
    body: ByteStream
}

@documentation("Supports x-riak-if-not-modified and standard conditional headers for Riak-native conditional updates.")
structure CreateObjectInput with [BucketIdentity, ObjectWriteOptions, ConditionalWriteHeaders] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Content-Encoding")
    contentEncoding: String

    @httpHeader("Link")
    link: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders

    @required
    @httpPayload
    body: ByteStream
}

structure DeleteObjectInput with [ObjectIdentity, DeleteOptions, ConditionalWriteHeaders] {
    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders
}

structure GetDefaultObjectInput with [DefaultObjectIdentity, ReadOptions, ConditionalReadHeaders] {
    @httpQuery("vtag")
    vtag: VTag
}

structure HeadDefaultObjectInput with [DefaultObjectIdentity, ReadOptions, ConditionalReadHeaders] {
    @httpQuery("vtag")
    vtag: VTag
}

@documentation("Supports x-riak-if-not-modified and standard conditional headers for Riak-native conditional updates.")
structure PutDefaultObjectInput with [DefaultObjectIdentity, ObjectWriteOptions, ConditionalWriteHeaders] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Content-Encoding")
    contentEncoding: String

    @httpHeader("Link")
    link: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders

    @required
    @httpPayload
    body: ByteStream
}

@documentation("Supports x-riak-if-not-modified and standard conditional headers for Riak-native conditional updates.")
structure CreateDefaultObjectInput with [DefaultBucketIdentity, ObjectWriteOptions, ConditionalWriteHeaders] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Content-Encoding")
    contentEncoding: String

    @httpHeader("Link")
    link: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders

    @required
    @httpPayload
    body: ByteStream
}

structure DeleteDefaultObjectInput with [DefaultObjectIdentity, DeleteOptions, ConditionalWriteHeaders] {
    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders
}

structure ObjectOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Content-Encoding")
    contentEncoding: String

    @httpHeader("ETag")
    etag: String

    @httpHeader("Last-Modified")
    lastModified: HttpDate

    @httpHeader("Link")
    link: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders

    @required
    @httpPayload
    body: ByteStream
}

structure HeadObjectOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Content-Encoding")
    contentEncoding: String

    @httpHeader("ETag")
    etag: String

    @httpHeader("Last-Modified")
    lastModified: HttpDate

    @httpHeader("Link")
    link: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders
}

structure ObjectWriteOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Content-Encoding")
    contentEncoding: String

    @httpHeader("ETag")
    etag: String

    @httpHeader("Last-Modified")
    lastModified: HttpDate

    @httpHeader("Link")
    link: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders
}

structure CreateObjectOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Location")
    location: String

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Content-Encoding")
    contentEncoding: String

    @httpHeader("ETag")
    etag: String

    @httpHeader("Last-Modified")
    lastModified: HttpDate

    @httpHeader("Link")
    link: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders
}

structure CreateObjectReturnBodyOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Location")
    location: String

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Content-Encoding")
    contentEncoding: String

    @httpHeader("ETag")
    etag: String

    @httpHeader("Last-Modified")
    lastModified: HttpDate

    @httpHeader("Link")
    link: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders

    @required
    @httpPayload
    body: ByteStream
}

structure LinkWalkInput with [ObjectIdentity] {
    @required
    @httpLabel
    walk: String
}

structure LinkWalkDefaultInput with [DefaultObjectIdentity] {
    @required
    @httpLabel
    walk: String
}

@mixin
structure SecondaryIndexOptions with [TimeoutOption] {
    @httpQuery("max_results")
    maxResults: Integer

    @httpQuery("continuation")
    continuation: String

    @httpQuery("return_terms")
    returnTerms: Boolean

    @httpQuery("pagination_sort")
    paginationSort: Boolean

    @httpQuery("term_regex")
    termRegex: String
}

structure SecondaryIndexInput with [BucketIdentity, SecondaryIndexOptions] {
    @required
    @httpLabel
    field: NonEmptyString

    @required
    @httpLabel
    value: String
}

structure SecondaryIndexRangeInput with [BucketIdentity, SecondaryIndexOptions] {
    @required
    @httpLabel
    field: NonEmptyString

    @required
    @httpLabel
    start: String

    @required
    @httpLabel
    end: String
}

structure SecondaryIndexStreamInput with [BucketIdentity, SecondaryIndexOptions] {
    @required
    @httpLabel
    field: NonEmptyString

    @required
    @httpLabel
    value: String
}

structure SecondaryIndexRangeStreamInput with [BucketIdentity, SecondaryIndexOptions] {
    @required
    @httpLabel
    field: NonEmptyString

    @required
    @httpLabel
    start: String

    @required
    @httpLabel
    end: String
}

structure DefaultSecondaryIndexInput with [DefaultBucketIdentity, SecondaryIndexOptions] {
    @required
    @httpLabel
    field: NonEmptyString

    @required
    @httpLabel
    value: String
}

structure DefaultSecondaryIndexRangeInput with [DefaultBucketIdentity, SecondaryIndexOptions] {
    @required
    @httpLabel
    field: NonEmptyString

    @required
    @httpLabel
    start: String

    @required
    @httpLabel
    end: String
}

structure DefaultSecondaryIndexStreamInput with [DefaultBucketIdentity, SecondaryIndexOptions] {
    @required
    @httpLabel
    field: NonEmptyString

    @required
    @httpLabel
    value: String
}

structure DefaultSecondaryIndexRangeStreamInput with [DefaultBucketIdentity, SecondaryIndexOptions] {
    @required
    @httpLabel
    field: NonEmptyString

    @required
    @httpLabel
    start: String

    @required
    @httpLabel
    end: String
}

structure QuerySpec {
    @required
    indexName: String

    startTerm: String
    endTerm: String
    aggregationTag: String
    regularExpression: String
    evaluationExpression: String
    filterExpression: String
}

list QueryList {
    member: QuerySpec
}

@documentation("Query request body. Wire JSON uses snake_case keys: query_list, aggregation_expression, accumulation_option, accumulation_term, inactivity_timeout, max_results.")
structure BucketQueryRequest {
    @required
    queryList: QueryList

    aggregationExpression: String
    accumulationOption: String
    accumulationTerm: String
    substitutions: Document
    timeout: Integer
    inactivityTimeout: Integer
    maxResults: Integer
    continuation: String
}

structure BucketQueryInput with [BucketIdentity] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @required
    @httpPayload
    query: BucketQueryRequest
}

structure BucketQueryResultsInput with [BucketIdentity, TimeoutOption] {
    @required
    @httpQuery("result_queue")
    resultQueue: String

    @httpQuery("max_results")
    maxResults: Integer
}

structure DefaultBucketQueryInput with [DefaultBucketIdentity] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @required
    @httpPayload
    query: BucketQueryRequest
}

structure DefaultBucketQueryResultsInput with [DefaultBucketIdentity, TimeoutOption] {
    @required
    @httpQuery("result_queue")
    resultQueue: String

    @httpQuery("max_results")
    maxResults: Integer
}

structure MapReduceInput {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("Accept")
    accept: MediaType

    @required
    @httpPayload
    request: JsonDocument
}

@mixin
structure DatatypeOptions with [TimeoutOption] {
    @httpQuery("r")
    r: Quorum

    @httpQuery("pr")
    pr: Quorum

    @httpQuery("w")
    w: Quorum

    @httpQuery("pw")
    pw: Quorum

    @httpQuery("dw")
    dw: Quorum

    @httpQuery("returnbody")
    returnBody: Boolean

    @httpQuery("include_context")
    includeContext: Boolean
}

structure DatatypeReadInput with [ObjectIdentity, DatatypeOptions] {}

structure DatatypeUpdateInput with [ObjectIdentity, DatatypeOptions] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @required
    @httpPayload
    update: JsonDocument
}

structure DatatypeCreateInput with [BucketIdentity, DatatypeOptions] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @required
    @httpPayload
    update: JsonDocument
}

structure DatatypeCreateOutput {
    @httpResponseCode
    statusCode: Integer

    @httpHeader("Location")
    location: String

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpPayload
    body: JsonDocument
}

structure CounterReadInput with [DefaultObjectIdentity, ReadOptions] {}

@mixin
structure CounterWriteOptions with [TimeoutOption] {
    @httpQuery("w")
    w: Quorum

    @httpQuery("pw")
    pw: Quorum

    @httpQuery("dw")
    dw: Quorum
}

structure CounterUpdateInput with [DefaultObjectIdentity, CounterWriteOptions] {
    @httpQuery("returnvalue")
    returnValue: Boolean

    @required
    @httpPayload
    amount: String
}

@mixin
structure AaeFilterOption {
    @httpQuery("filter")
    filter: String
}

@mixin
structure AaeNValOption {
    @httpQuery("nval")
    nval: Integer
}

@mixin
structure NValIdentity {
    @required
    @httpLabel
    nVal: Integer
}

@mixin
structure TreeSizeIdentity {
    @required
    @httpLabel
    treeSize: NonEmptyString
}

@mixin
structure SiblingCountIdentity {
    @required
    @httpLabel
    count: Integer
}

@mixin
structure ObjectSizeIdentity {
    @required
    @httpLabel
    size: Integer
}

structure GetMergeRootNvalInput with [NValIdentity, TimeoutOption] {}

structure GetMergeBranchNvalInput with [NValIdentity, AaeFilterOption, TimeoutOption] {}

structure GetFetchClocksNvalInput with [NValIdentity, AaeFilterOption, TimeoutOption] {}

structure GetMergeTreeRangeInput with [BucketIdentity, TreeSizeIdentity, AaeFilterOption, TimeoutOption] {}

structure GetDefaultMergeTreeRangeInput with [DefaultBucketIdentity, TreeSizeIdentity, AaeFilterOption, TimeoutOption] {}

structure GetFetchClocksRangeInput with [BucketIdentity, AaeFilterOption, TimeoutOption] {}

structure GetDefaultFetchClocksRangeInput with [DefaultBucketIdentity, AaeFilterOption, TimeoutOption] {}

structure GetReplKeysRangeInput with [BucketIdentity, QueueNameIdentity, AaeFilterOption, TimeoutOption] {}

structure GetDefaultReplKeysRangeInput with [DefaultBucketIdentity, QueueNameIdentity, AaeFilterOption, TimeoutOption] {}

structure GetRepairKeysRangeInput with [BucketIdentity, AaeFilterOption, TimeoutOption] {}

structure GetDefaultRepairKeysRangeInput with [DefaultBucketIdentity, AaeFilterOption, TimeoutOption] {}

structure GetFindKeysBySiblingCountInput with [BucketIdentity, SiblingCountIdentity, AaeFilterOption, TimeoutOption] {}

structure GetDefaultFindKeysBySiblingCountInput with [DefaultBucketIdentity, SiblingCountIdentity, AaeFilterOption, TimeoutOption] {}

structure GetFindKeysByObjectSizeInput with [BucketIdentity, ObjectSizeIdentity, AaeFilterOption, TimeoutOption] {}

structure GetDefaultFindKeysByObjectSizeInput with [DefaultBucketIdentity, ObjectSizeIdentity, AaeFilterOption, TimeoutOption] {}

structure GetObjectStatsInput with [BucketIdentity, AaeFilterOption, TimeoutOption] {}

structure GetDefaultObjectStatsInput with [DefaultBucketIdentity, AaeFilterOption, TimeoutOption] {}

structure GetFindTombsInput with [BucketIdentity, AaeFilterOption, TimeoutOption] {}

structure GetDefaultFindTombsInput with [DefaultBucketIdentity, AaeFilterOption, TimeoutOption] {}

structure GetEraseKeysInput with [BucketIdentity, AaeFilterOption, TimeoutOption] {}

structure GetDefaultEraseKeysInput with [DefaultBucketIdentity, AaeFilterOption, TimeoutOption] {}

structure GetReapTombsInput with [BucketIdentity, AaeFilterOption, TimeoutOption] {}

structure GetDefaultReapTombsInput with [DefaultBucketIdentity, AaeFilterOption, TimeoutOption] {}

structure ListAaeBucketsInput with [AaeNValOption, TimeoutOption] {}

@mixin
structure QueueNameIdentity {
    @required
    @httpLabel
    queueName: UriSafeIdentifier
}

@mixin
structure QueueObjectFormatOption {
    @httpQuery("object_format")
    objectFormat: QueueObjectFormat
}

enum QueueObjectFormat {
    INTERNAL = "internal"
    INTERNAL_AAEHASH = "internal_aaehash"
}

structure GetQueueItemInput with [QueueNameIdentity, QueueObjectFormatOption] {}

structure PushQueueItemsInput with [QueueNameIdentity] {
    @required
    @httpHeader("Content-Type")
    contentType: MediaType

    @required
    @httpPayload
    keysClocks: JsonDocument
}

@error("client")
@httpError(400)
structure BadRequestError {
    message: String

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders
}

@error("client")
@httpError(401)
structure UnauthorizedError {
    message: String

    authenticateChallenge: String
}

@error("client")
@httpError(403)
structure ForbiddenError {
    message: String
}

@error("client")
@httpError(404)
structure NotFoundError {
    message: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders
}

@error("client")
@httpError(406)
structure NotAcceptableError {
    message: String
}

@error("client")
@httpError(409)
structure ConflictError {
    message: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders
}

@error("client")
@httpError(410)
structure GoneError {
    message: String
}

@error("client")
@httpError(300)
structure MultipleChoicesError {
    message: String

    @httpHeader("Content-Type")
    contentType: MediaType

    @httpHeader("X-Riak-Vclock")
    vclock: VClock

    @httpPayload
    body: String
}

@error("client")
@httpError(412)
structure PreconditionFailedError {
    message: String

    @httpHeader("X-Riak-Vclock")
    vclock: VClock
}

@error("client")
@httpError(426)
structure UpgradeRequiredError {
    message: String
}

@error("server")
@httpError(500)
structure InternalServerError {
    message: String
}

@error("server")
@httpError(503)
structure TimeoutError {
    message: String

    @httpHeader("Retry-After")
    retryAfter: String

    @httpPrefixHeaders("x-riak-")
    riakHeaders: RiakHeaders
}
