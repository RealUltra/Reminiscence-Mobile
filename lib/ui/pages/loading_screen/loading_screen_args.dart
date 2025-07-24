class LoadingScreenArgs {
  final Function(List<dynamic>) operation;
  final List<dynamic> operationParams;
  final bool showProgress;

  const LoadingScreenArgs({
    required this.operation,
    required this.operationParams,
    this.showProgress = true,
  });
}
