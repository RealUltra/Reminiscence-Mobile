class LoadingScreenArgs {
  final Function(List<dynamic>) operation;
  final List<dynamic> operationParams;
  final bool showProgress;
  final String? tooltip;

  const LoadingScreenArgs({
    required this.operation,
    required this.operationParams,
    this.showProgress = true,
    this.tooltip,
  });
}
