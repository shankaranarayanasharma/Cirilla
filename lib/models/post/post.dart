import 'package:cirilla/constants/assets.dart';
import 'package:cirilla/mixins/mixins.dart';
import 'package:cirilla/models/models.dart';
import 'package:cirilla/utils/utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'post.g.dart';

@JsonSerializable()
class Post {
  int? id;

  int? author;

  @JsonKey(name: 'post_title', fromJson: unescape)
  String? postTitle;

  PostTitle? title;

  PostTitle? excerpt;

  PostTitle? content;

  String? date;

  String? link;

  String? type;

  String? format;

  @JsonKey(fromJson: _imageFromJson)
  String? image;

  @JsonKey(fromJson: _imageFromJson)
  String? thumb;

  @JsonKey(name: 'thumb_medium', fromJson: _imageFromJson)
  String? thumbMedium;

  List<int>? tags;

  @JsonKey(name: 'post_categories', fromJson: _toList)
  List<PostCategory>? postCategories;

  @JsonKey(name: 'post_tags')
  List<PostTag>? postTags;

  @JsonKey(name: 'post_comment_count')
  int? postCommentCount;

  @JsonKey(name: 'post_author')
  String? postAuthor;

  @JsonKey(name: 'post_author_avatar_urls')
  AvatarAuthor? postAuthorImage;

  @JsonKey(name: 'acf', fromJson: _relatedFromJson, toJson: _relatedToJson)
  List<int>? relatedIds;

  List<dynamic>? blocks;

  Post({
    this.id,
    this.author,
    this.title,
    this.excerpt,
    this.content,
    this.date,
    this.link,
    this.format,
    this.image,
    this.thumb,
    this.tags,
    this.postCategories,
    this.postTags,
    this.postCommentCount,
    this.postAuthor,
    this.postAuthorImage,
    this.blocks,
  });

  static String _imageFromJson(dynamic value) =>
      value == null || value == false || value == "" ? Assets.noImageUrl : value as String;

  static List<PostCategory> _toList(List<dynamic>? data) {
    List<PostCategory> _categories = <PostCategory>[];

    if (data == null) return _categories;

    _categories = data.map((d) => PostCategory.fromJson(d)).toList().cast<PostCategory>();

    return _categories;
  }

  factory Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

  static List<int> _relatedFromJson(dynamic value) {
    dynamic ids = value is Map ? get(value, ['related_post'], '') : null;
    final List<int> data = [];
    if (ids is String && ids.isNotEmpty) {
      List arrIds = ids.split(',');
      for (int i = 0; i < arrIds.length; i++) {
        data.add(ConvertData.stringToInt(arrIds[i]));
      }
    }
    return data;
  }

  static dynamic _relatedToJson(List<int>? value) {
    return {
      'related_post': value?.join(',') ?? '',
    };
  }

  Map<String, dynamic> toJson() => _$PostToJson(this);
}

@JsonSerializable()
class AvatarAuthor {
  @JsonKey(name: '24')
  String? small;
  @JsonKey(name: '48')
  String? medium;
  @JsonKey(name: '96')
  String? large;

  AvatarAuthor({
    this.small,
    this.medium,
    this.large,
  });

  factory AvatarAuthor.fromJson(Map<String, dynamic> json) => _$AvatarAuthorFromJson(json);

  Map<String, dynamic> toJson() => _$AvatarAuthorToJson(this);
}

class PostBlocks {
  PostBlocks._();

  static const String category = 'Category';
  static const String name = 'Name';
  static const String date = 'Date';
  static const String author = 'Author';
  static const String countComment = 'CountComment';
  static const String navigateComment = 'NavigateComment';
  static const String wishlist = 'Wishlist';
  static const String share = 'Share';
  static const String featureImage = 'FeatureImage';
  static const String content = 'Content';
  static const String tag = 'Tag';
  static const String comments = 'Comments';
  static const String relatedPost = 'RelatedPost';
}
