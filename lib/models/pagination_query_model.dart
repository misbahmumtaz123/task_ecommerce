/// Clean mapping layer for pagination queries.
/// Seamlessly maps app-level page requests to DummyJSON's [limit] and [skip] parameters.
class PaginationQuery {
  final int page;
  final int pageSize;

  const PaginationQuery({
    this.page = 1,
    this.pageSize = 30,
  }) : assert(page >= 1, 'Page must be greater than or equal to 1'),
       assert(pageSize >= 1, 'PageSize must be greater than or equal to 1');

  /// Calculated DummyJSON limit parameter
  int get limit => pageSize;

  /// Calculated DummyJSON skip parameter based on 1-indexed page
  int get skip => (page - 1) * pageSize;

  /// Converts to query parameter map ready for HTTP requests
  Map<String, dynamic> toQueryParams() => {
        'limit': limit,
        'skip': skip,
      };

  /// Creates next page query
  PaginationQuery nextPage() => PaginationQuery(page: page + 1, pageSize: pageSize);

  /// Creates a copy with modified values
  PaginationQuery copyWith({int? page, int? pageSize}) {
    return PaginationQuery(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}
