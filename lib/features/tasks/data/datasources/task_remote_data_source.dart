import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/failures.dart';
import '../models/task_model.dart';

abstract class TaskRemoteDataSource {
  Future<List<TaskModel>> getTasks(String userId);
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String taskId);
}

class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final FirebaseFirestore firestore;

  TaskRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<TaskModel>> getTasks(String userId) async {
    try {
      final snapshot = await firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .orderBy('dueDate')
          .get();

      return snapshot.docs.map((doc) => TaskModel.fromFirestore(doc)).toList();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> addTask(TaskModel task) async {
    try {
      await firestore.collection('tasks').doc(task.id).set(task.toFirestore());
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> updateTask(TaskModel task) async {
    try {
      await firestore
          .collection('tasks')
          .doc(task.id)
          .set(task.toFirestore(), SetOptions(merge: true));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }
}
