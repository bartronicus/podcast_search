// Copyright (c) 2019-2021, Ben Hills. Use of this source code is governed by a
// MIT license that can be found in the LICENSE file.

import 'package:meta/meta.dart';
import 'package:podcast_search/src/model/item.dart';

enum ErrorType {
  none,
  cancelled,
  failed,
  connection,
  timeout,
}
enum ResultType {
  itunes,
  podcastIndex,
}

const startTagMap = {
  ResultType.itunes: 'results',
  ResultType.podcastIndex: 'feeds',
};
const countTagMap = {
  ResultType.itunes: 'resultCount',
  ResultType.podcastIndex: 'count',
};

/// This class is a container for our search results or for any error message
/// received whilst attempting to fetch the podcast data.
class SearchResult {
  /// The number of podcasts found.
  final int resultCount;

  /// True if the search was successful; false otherwise.
  final bool successful;

  /// The list of search results.
  final List<Item> items;

  /// The last error.
  final String lastError;

  /// The type of error.
  final ErrorType lastErrorType;

  SearchResult(this.resultCount, this.items)
      : successful = true,
        lastError = '',
        lastErrorType = ErrorType.none;

  SearchResult.fromError(this.lastError, this.lastErrorType)
      : successful = false,
        resultCount = 0,
        items = [];

  factory SearchResult.fromJson(
      {@required dynamic json, ResultType type = ResultType.itunes}) {
    /// Did we get an error message?
    if (json['errorMessage'] != null) {
      return SearchResult.fromError(json['errorMessage'], ErrorType.failed);
    }

    var dataStart = startTagMap[type];
    var dataCount = countTagMap[type];

    /// Fetch the results from the JSON data.
    final items = json[dataStart] == null
        ? null
        : (json[dataStart] as List)
            .cast<Map<String, Object>>()
            .map((Map<String, Object> item) {
            return Item.fromJson(json: item, type: type);
          }).toList();

    return SearchResult(json[dataCount], items);
  }
}
