class LoadingScreenArgs {
  final Function(List<dynamic>) operation;
  final List<dynamic> operationParams;

  const LoadingScreenArgs({
    required this.operation,
    required this.operationParams,
  });
}
