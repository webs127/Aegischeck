import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/features/employees/model/employees_model.dart';
import 'package:aegischeck/features/employees/viewmodels/employees_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  List<String> tableheadertexts = [
    "EMPLOYEE",
    "ROLE / ID",
    "DEPARTMENT",
    "TODAY'S STATUS",
    "ACTION",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthViewModel>();
      final orgId = await auth.ensureOrgContext();

      if (!mounted || orgId == null || orgId.isEmpty) {
        return;
      }

      context.read<EmployeesViewModel>().watchEmployeesByOrgId(orgId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Card(
            color: ColorManager.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 20,
                    children: [
                      SizedBox(
                        width: 270,
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorManager.greybackground,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorManager.greybackground,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorManager.greybackground,
                              ),
                            ),
                            hintText: "Search employees by name or ID",
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 170,
                        child: TextFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorManager.greybackground,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorManager.greybackground,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorManager.greybackground,
                              ),
                            ),
                            hintText: "Filter: All Departments",
                          ),
                        ),
                      ),
                    ],
                  ),
                  MaterialButton(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    height: 55,
                    onPressed: () {},
                    shape: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: ColorManager.primary1,
                    child: Row(
                      children: [
                        Icon(Icons.add, color: ColorManager.white),
                        Text(
                          "Add Employee",
                          style: TextStyle(color: ColorManager.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          child: Selector<EmployeesViewModel, List<EmployeesObj>>(
            selector: (_, vm) => vm.employees,
            builder: (context, employees, child) => LayoutBuilder(
              builder: (context, constraints) {
                //state.getHighRisksEndpoints();
                return ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: Card(
                    shape: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: ColorManager.greybackground,
                      ),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    color: ColorManager.white,
                    child: DataTable(
                      columnSpacing: 10,
                      dataRowMaxHeight: 55,
                      columns: List.generate(
                        tableheadertexts.length,
                        (i) => DataColumn(
                          // columnWidth: i < 2
                          //     ? FixedColumnWidth(10)
                          //     : FixedColumnWidth(10),
                          label: Expanded(
                            child: Text(
                              tableheadertexts[i],
                              // textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: ColorManager.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      headingRowColor: WidgetStatePropertyAll(
                        ColorManager.tableHeadingColor,
                      ),
                      rows: List.generate(
                        employees.length,
                        (i) => dataRowMethod(employee: employees[i]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        Selector<EmployeesViewModel, int>(
          selector: (_, vm) => vm.employees.length,
          builder: (context, count, _) {
            if (count > 0) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'No employees found for this organization yet.',
                style: TextStyle(
                  fontSize: 14,
                  color: ColorManager.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

DataRow dataRowMethod({required EmployeesObj employee}) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          spacing: 10,
          children: [
            CircleAvatar(
              backgroundColor: ColorManager.primary1,
              child: Icon(Icons.person, color: ColorManager.white),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                    color: ColorManager.black,
                  ),
                ),
                Text(
                  employee.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: ColorManager.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      DataCell(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              employee.role,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: ColorManager.black,
              ),
            ),
            SelectableText(
              employee.id,
              maxLines: 1,
             // overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: ColorManager.grey,
              ),
            ),
          ],
        ),
      ),
      DataCell(
        Text(
          employee.department,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: ColorManager.black,
          ),
        ),
      ),
      DataCell(
        Builder(
          builder: (context) {
            final color = context.read<EmployeesViewModel>().statusColor(
              employee,
            );
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: color.withValues(alpha: .15),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 5,
                children: [
                  Icon(Icons.lock_clock, size: 20, color: color),
                  Text(
                    employee.status,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: color,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      DataCell(
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.edit_outlined, color: ColorManager.icon),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, color: ColorManager.icon),
            ),
          ],
        ),
      ),
    ],
  );
}
