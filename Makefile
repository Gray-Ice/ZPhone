PROTO_INPUT_FOLDER=./lib/rpc/protobuf
PROTO_OUTPUT_FOLDER=./lib/rpc
PROTO_GOOGLE_FOLDER=./lib/rpc/protobuf/google/protobuf
allpbf: clipboard.proto auth.proto

clipboard.proto:
	protoc -I="$(PROTO_INPUT_FOLDER)" \
	 --dart_out="grpc:$(PROTO_OUTPUT_FOLDER)" \
	"$(PROTO_INPUT_FOLDER)/clipboard/clipboard.proto" "$(PROTO_GOOGLE_FOLDER)/empty.proto"

auth.proto:
	protoc -I="$(PROTO_INPUT_FOLDER)" \
	 --dart_out="grpc:$(PROTO_OUTPUT_FOLDER)" \
	"$(PROTO_INPUT_FOLDER)/auth/auth.proto" "$(PROTO_GOOGLE_FOLDER)/empty.proto"

clean:
	@echo "Hello"