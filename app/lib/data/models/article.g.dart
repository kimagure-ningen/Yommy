// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'article.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ArticleAdapter extends TypeAdapter<Article> {
  @override
  final int typeId = 0;

  @override
  Article read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Article(
      id: fields[0] as String,
      url: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String?,
      thumbnailUrl: fields[4] as String?,
      sourceName: fields[5] as String?,
      memo: fields[6] as String?,
      status: fields[7] as ArticleStatus,
      createdAt: fields[8] as DateTime,
      readAt: fields[9] as DateTime?,
      tags: (fields[10] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Article obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.thumbnailUrl)
      ..writeByte(5)
      ..write(obj.sourceName)
      ..writeByte(6)
      ..write(obj.memo)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.readAt)
      ..writeByte(10)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ArticleStatusAdapter extends TypeAdapter<ArticleStatus> {
  @override
  final int typeId = 1;

  @override
  ArticleStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ArticleStatus.unread;
      case 1:
        return ArticleStatus.read;
      default:
        return ArticleStatus.unread;
    }
  }

  @override
  void write(BinaryWriter writer, ArticleStatus obj) {
    switch (obj) {
      case ArticleStatus.unread:
        writer.writeByte(0);
        break;
      case ArticleStatus.read:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArticleStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
