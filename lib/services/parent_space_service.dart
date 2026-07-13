import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/family_event_model.dart';
import '../models/parent_personal_event_model.dart';
import '../models/parent_task_model.dart';

class ParentSpaceService {
  ParentSpaceService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _parentEventsCollection({
    required String familyId,
    required String parentId,
  }) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('parentSpaces')
        .doc(parentId)
        .collection('events');
  }

  CollectionReference<Map<String, dynamic>> _parentTasksCollection({
    required String familyId,
    required String parentId,
  }) {
    return _firestore
        .collection('families')
        .doc(familyId)
        .collection('parentSpaces')
        .doc(parentId)
        .collection('tasks');
  }

  CollectionReference<Map<String, dynamic>> _familyEventsCollection({
    required String familyId,
  }) {
    return _firestore.collection('families').doc(familyId).collection('events');
  }

  String generatePersonalEventId({
    required String familyId,
    required String parentId,
  }) {
    return _parentEventsCollection(
      familyId: familyId,
      parentId: parentId,
    ).doc().id;
  }

  String generateParentTaskId({
    required String familyId,
    required String parentId,
  }) {
    return _parentTasksCollection(
      familyId: familyId,
      parentId: parentId,
    ).doc().id;
  }

  String generateFamilyEventId({required String familyId}) {
    return _familyEventsCollection(familyId: familyId).doc().id;
  }

  Future<List<ParentPersonalEventModel>> getPersonalEvents({
    required String familyId,
    required String parentId,
  }) async {
    final snapshot = await _parentEventsCollection(
      familyId: familyId,
      parentId: parentId,
    ).orderBy('date').get();

    return snapshot.docs
        .map((doc) => ParentPersonalEventModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> createPersonalEvent(ParentPersonalEventModel event) async {
    await _parentEventsCollection(
      familyId: event.familyId,
      parentId: event.parentId,
    ).doc(event.id).set(event.toMap());
  }

  Future<void> updatePersonalEvent(ParentPersonalEventModel event) async {
    await _parentEventsCollection(
      familyId: event.familyId,
      parentId: event.parentId,
    ).doc(event.id).update(event.toMap());
  }

  Future<void> deletePersonalEvent({
    required String familyId,
    required String parentId,
    required String eventId,
  }) async {
    await _parentEventsCollection(
      familyId: familyId,
      parentId: parentId,
    ).doc(eventId).delete();
  }

  Future<void> createFamilyEvent(FamilyEventModel event) async {
    await _familyEventsCollection(
      familyId: event.familyId,
    ).doc(event.id).set(event.toMap());
  }

  Future<void> updateFamilyEvent(FamilyEventModel event) async {
    await _familyEventsCollection(
      familyId: event.familyId,
    ).doc(event.id).update(event.toMap());
  }

  Future<void> deleteFamilyEvent({
    required String familyId,
    required String eventId,
  }) async {
    await _familyEventsCollection(familyId: familyId).doc(eventId).delete();
  }

  Future<List<ParentTaskModel>> getTasks({
    required String familyId,
    required String parentId,
  }) async {
    final snapshot = await _parentTasksCollection(
      familyId: familyId,
      parentId: parentId,
    ).orderBy('createdAt').get();

    return snapshot.docs
        .map((doc) => ParentTaskModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> createTask(ParentTaskModel task) async {
    await _parentTasksCollection(
      familyId: task.familyId,
      parentId: task.parentId,
    ).doc(task.id).set(task.toMap());
  }

  Future<void> updateTask(ParentTaskModel task) async {
    await _parentTasksCollection(
      familyId: task.familyId,
      parentId: task.parentId,
    ).doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask({
    required String familyId,
    required String parentId,
    required String taskId,
  }) async {
    await _parentTasksCollection(
      familyId: familyId,
      parentId: parentId,
    ).doc(taskId).delete();
  }

  Future<void> saveTaskPlanning({
    required ParentTaskModel task,
    required ParentPersonalEventModel event,
    required FamilyEventModel? familyEvent,
    required String? previousFamilyEventId,
  }) async {
    final batch = _firestore.batch();
    batch.set(
      _parentEventsCollection(
        familyId: event.familyId,
        parentId: event.parentId,
      ).doc(event.id),
      event.toMap(),
    );
    if (previousFamilyEventId != null &&
        previousFamilyEventId != familyEvent?.id) {
      batch.delete(
        _familyEventsCollection(
          familyId: event.familyId,
        ).doc(previousFamilyEventId),
      );
    }
    if (familyEvent != null) {
      batch.set(
        _familyEventsCollection(familyId: event.familyId).doc(familyEvent.id),
        familyEvent.toMap(),
      );
    }
    batch.update(
      _parentTasksCollection(
        familyId: task.familyId,
        parentId: task.parentId,
      ).doc(task.id),
      task.toMap(),
    );
    await batch.commit();
  }

  Future<void> removeTaskPlanning({
    required ParentTaskModel task,
    required ParentPersonalEventModel event,
    required bool deleteTask,
  }) async {
    final batch = _firestore.batch();
    batch.delete(
      _parentEventsCollection(
        familyId: event.familyId,
        parentId: event.parentId,
      ).doc(event.id),
    );
    if (event.familyEventId != null) {
      batch.delete(
        _familyEventsCollection(
          familyId: event.familyId,
        ).doc(event.familyEventId!),
      );
    }
    final taskRef = _parentTasksCollection(
      familyId: task.familyId,
      parentId: task.parentId,
    ).doc(task.id);
    if (deleteTask) {
      batch.delete(taskRef);
    } else {
      batch.update(taskRef, task.toMap());
    }
    await batch.commit();
  }
}
