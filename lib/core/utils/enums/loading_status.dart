/// Generic state representation for asynchronous UI operations
enum LoadingStatus {
  initial,
  loading,
  success,
  error,
  empty;

  bool get isInitial => this == LoadingStatus.initial;
  bool get isLoading => this == LoadingStatus.loading;
  bool get isSuccess => this == LoadingStatus.success;
  bool get isError => this == LoadingStatus.error;
  bool get isEmpty => this == LoadingStatus.empty;
}
