class DataWithRevision<T> {
  final T data;
  final int revision;
  DataWithRevision(this.data, this.revision);

  @override
  String toString() => 'DataWithRevision<$T>(revision: $revision, data: $data)';
}
