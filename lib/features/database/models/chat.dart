import 'package:floor/floor.dart';

@Entity(tableName: 'chats')
class Chat {
  @PrimaryKey()
  final int id;

  final String title;

  Chat({
    required this.id,
    required this.title,
  }); 

}