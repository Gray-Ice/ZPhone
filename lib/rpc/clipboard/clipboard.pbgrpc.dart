///
//  Generated code. Do not modify.
//  source: clipboard/clipboard.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'clipboard.pb.dart' as $0;
import '../google/protobuf/empty.pb.dart' as $1;
export 'clipboard.pb.dart';

class ClipboardClient extends $grpc.Client {
  static final _$shareClipboard =
      $grpc.ClientMethod<$0.ClipboardContent, $1.Empty>(
          '/clipboard_rpc.Clipboard/ShareClipboard',
          ($0.ClipboardContent value) => value.writeToBuffer(),
          ($core.List<$core.int> value) => $1.Empty.fromBuffer(value));

  ClipboardClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$1.Empty> shareClipboard($0.ClipboardContent request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$shareClipboard, request, options: options);
  }
}

abstract class ClipboardServiceBase extends $grpc.Service {
  $core.String get $name => 'clipboard_rpc.Clipboard';

  ClipboardServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.ClipboardContent, $1.Empty>(
        'ShareClipboard',
        shareClipboard_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ClipboardContent.fromBuffer(value),
        ($1.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$1.Empty> shareClipboard_Pre($grpc.ServiceCall call,
      $async.Future<$0.ClipboardContent> request) async {
    return shareClipboard(call, await request);
  }

  $async.Future<$1.Empty> shareClipboard(
      $grpc.ServiceCall call, $0.ClipboardContent request);
}
