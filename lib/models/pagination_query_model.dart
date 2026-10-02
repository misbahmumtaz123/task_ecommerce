class PaginationQuery {
  final int page;
  final int pageSize;

  const PaginationQuery({this.page = 1, this.pageSize = 6})
    : assert(page >= 1, 'Page must be greater than or equal to 1'),
      assert(pageSize >= 1, 'PageSize must be greater than or equal to 1');

  int get limit => pageSize;

  int get skip => (page - 1) * pageSize;
  Map<String, dynamic> toQueryParams() => {'limit': limit, 'skip': skip};
  PaginationQuery nextPage() =>
      PaginationQuery(page: page + 1, pageSize: pageSize);
  PaginationQuery copyWith({int? page, int? pageSize}) {
    return PaginationQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
