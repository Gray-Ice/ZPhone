///
//  Generated code. Do not modify.
//  source: auth/auth.proto
//
// @dart = 2.12
// ignore_for_file: annotate_overrides,camel_case_types,constant_identifier_names,directives_ordering,library_prefixes,non_constant_identifier_names,prefer_final_fields,return_of_invalid_type,unnecessary_const,unnecessary_import,unnecessary_this,unused_import,unused_shown_name

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import '../google/protobuf/empty.pb.dart' as $0;
export 'auth.pb.dart';

class AuthClient extends $grpc.Client {
  static final _$heartBeat = $grpc.ClientMethod<$0.Empty, $0.Empty>(
      '/auth_rpc.Auth/HeartBeat',
      ($0.Empty value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Empty.fromBuffer(value));

  AuthClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options, interceptors: interceptors);

  $grpc.ResponseFuture<$0.Empty> heartBeat($0.Empty request,
      {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$heartBeat, request, options: options);
  }
}

abstract class AuthServiceBase extends $grpc.Service {
  $core.String get $name => 'auth_rpc.Auth';

  AuthServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Empty, $0.Empty>(
        'HeartBeat',
        heartBeat_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Empty.fromBuffer(value),
        ($0.Empty value) => value.writeToBuffer()));
  }

  $async.Future<$0.Empty> heartBeat_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Empty> request) async {
    return heartBeat(call, await request);
  }

  $async.Future<$0.Empty> heartBeat($grpc.ServiceCall call, $0.Empty request);
}
