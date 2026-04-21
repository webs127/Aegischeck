import 'dart:async';

import 'package:aegischeck/features/employees/model/employees_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmployeesViewModel with ChangeNotifier {
  final FirebaseFirestore _firestore;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _employeesSubscription;

  EmployeesViewModel(this._firestore) {
    calculateEmployees();
  }
  List<EmployeesObj> employees = [];

  int presentEmployees = 0;
  int lateEmployees = 0;
  int absentEmployees = 0;
  int get totalEmployees => employees.length;

  List<int> get count => [
    presentEmployees,
    lateEmployees,
    absentEmployees,
    totalEmployees,
  ];

  void calculateEmployees() {
    presentEmployees = 0;
    lateEmployees = 0;
    absentEmployees = 0;

    for (var element in employees) {
      if (element.status == "Present") {
        presentEmployees++;
      }
      if (element.status == "Late") {
        lateEmployees++;
      }
      if (element.status == "Absent") {
        absentEmployees++;
      }
    }

    debugPrint(
      "presentEmployees: $presentEmployees, lateEmployees: $lateEmployees, absentEmployees: $absentEmployees, totalEmployees: $totalEmployees",
    );
  }

  Future<void> loadEmployeesByOrgId(String orgId) async {
    try {
      final normalizedOrgId = orgId.trim();
      if (normalizedOrgId.isEmpty) {
        employees = [];
        calculateEmployees();
        notifyListeners();
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .where('orgId', isEqualTo: normalizedOrgId)
          .get();

      employees = snapshot.docs.map((doc) {
        final data = doc.data();
        final fullname = (data['fullname'] ?? data['username'] ?? '')
            .toString();
        final rawRole = (data['role'] ?? '').toString().trim();
        final isAdmin = rawRole.toLowerCase() == 'admin';
        final rawDepartment = (data['department'] ?? '').toString().trim();

        return EmployeesObj(
          id: doc.id,
          name: fullname.isEmpty ? 'Unknown User' : fullname,
          email: (data['email'] ?? '').toString(),
          role: isAdmin ? 'admin' : (rawRole.isEmpty ? 'N/A' : rawRole),
          department: isAdmin ? '' : rawDepartment,
          status: (data['status'] ?? 'Absent').toString(),
        );
      }).toList();

      calculateEmployees();
      notifyListeners();
    } catch (e) {
      debugPrint('[EmployeesViewModel.loadEmployeesByOrgId] Failed: $e');
      rethrow;
    }
  }

  void watchEmployeesByOrgId(String orgId) {
    final normalizedOrgId = orgId.trim();

    _employeesSubscription?.cancel();

    if (normalizedOrgId.isEmpty) {
      employees = [];
      calculateEmployees();
      notifyListeners();
      return;
    }

    _employeesSubscription = _firestore
        .collection('users')
        .where('orgId', isEqualTo: normalizedOrgId)
        .snapshots()
        .listen(
          (snapshot) {
            employees = snapshot.docs.map((doc) {
              final data = doc.data();
              final fullname = (data['fullname'] ?? data['username'] ?? '')
                  .toString();
              final rawRole = (data['role'] ?? '').toString().trim();
              final isAdmin = rawRole.toLowerCase() == 'admin';
              final rawDepartment = (data['department'] ?? '')
                  .toString()
                  .trim();

              return EmployeesObj(
                id: doc.id,
                name: fullname.isEmpty ? 'Unknown User' : fullname,
                email: (data['email'] ?? '').toString(),
                role: isAdmin ? 'admin' : (rawRole.isEmpty ? 'N/A' : rawRole),
                department: isAdmin ? '' : rawDepartment,
                status: (data['status'] ?? 'Absent').toString(),
              );
            }).toList();

            calculateEmployees();
            notifyListeners();
          },
          onError: (error) {
            final text = error.toString();
            if (text.contains('permission-denied')) {
              _employeesSubscription?.cancel();
              _employeesSubscription = null;
              employees = [];
              calculateEmployees();
              notifyListeners();
              debugPrint(
                '[EmployeesViewModel.watchEmployeesByOrgId] Stopped watcher after permission-denied.',
              );
              return;
            }

            debugPrint('[EmployeesViewModel.watchEmployeesByOrgId] Failed: $error');
          },
        );
  }

  @override
  void dispose() {
    _employeesSubscription?.cancel();
    super.dispose();
  }

  Color statusColor(EmployeesObj status) {
    switch (status.status) {
      case "Present":
        return Colors.green;
      case "Late":
        return Colors.yellow.shade700;
      case "Not Marked":
      case "Absent":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
