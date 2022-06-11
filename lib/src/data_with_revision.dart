class DataWithRevision<T> {
  final T data;
  final int revision;
  final String? skylink;
  DataWithRevision(this.data, this.revision, {this.skylink});

  @override
  String toString() => 'DataWithRevision<$T>(revision: $revision, data: $data)';
}
