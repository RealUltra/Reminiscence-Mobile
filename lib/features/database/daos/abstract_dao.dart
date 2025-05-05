import 'package:floor/floor.dart';

@dao
abstract class AbstractDao<T> {
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertItem(T item);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<List<int>> insertItems(List<T> items);
}