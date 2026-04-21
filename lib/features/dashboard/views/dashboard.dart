import 'package:aegischeck/core/managers/color_manager.dart';
import 'package:aegischeck/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:aegischeck/features/employees/viewmodels/employees_viewmodel.dart';
import 'package:aegischeck/features/landing/widgets/tabs.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
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
    final List<PieChartdata> data = [
      PieChartdata(name: "Present", value: 70, color: Colors.green),
      PieChartdata(name: "Late", value: 40, color: Colors.orange),
      PieChartdata(name: "Absent", value: 15, color: Colors.red),
    ];

    final List<double> days = [5, 2, 7, 9, 10];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        spacing: 20,
        children: [
          CustomTabs(),
          Row(
            spacing: 20,
            children: [
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 0,
                  color: ColorManager.white,
                  child: Container(
                    height: 400,
                    padding: EdgeInsets.all(16),
                    child: SizedBox(
                      height: 200,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Align(
                            alignment: AlignmentGeometry.centerLeft,
                            child: Text(
                              "Attendance Trends (This Week)",
                              style: TextStyle(
                                fontSize: 18,
                                color: ColorManager.black,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 300,
                            child: BarChart(
                              BarChartData(
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        switch (value.toInt()) {
                                          case 0:
                                            return Text("Mon");
                                          case 1:
                                            return Text("Tues");
                                          case 2:
                                            return Text("Wed");
                                          case 3:
                                            return Text("Thu");
                                          case 4:
                                            return Text("Fri");
                                          default:
                                            return Text("");
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(
                                  5,
                                  (i) => BarChartGroupData(
                                    x: i,
                                    barRods: [
                                      BarChartRodData(
                                        toY: days[i],
                                        width: 50,
                                        color: ColorManager.primary,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //child: BarChart(data)
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  elevation: 0,
                  color: ColorManager.white,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    height: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: AlignmentGeometry.centerLeft,
                          child: Text(
                            "Daily Attendance",
                            style: TextStyle(
                              fontSize: 18,
                              color: ColorManager.black,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              centerSpaceRadius: 5,
                              borderData: FlBorderData(show: false),
                              sectionsSpace: 2,
                              pieTouchData: PieTouchData(enabled: true),
                              sections: List.generate(
                                data.length,
                                (i) => PieChartSectionData(
                                  value: context
                                      .watch<EmployeesViewModel>()
                                      .count[i]
                                      .toDouble(),
                                  color: data[i].color,
                                  title: data[i].name,
                                  titleStyle: TextStyle(
                                    fontSize: 14,
                                    color: ColorManager.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  showTitle: true,
                                  radius: 100,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          spacing: 10,
                          children: List.generate(data.length, (i) {
                            int employeeCount = context
                                .read<EmployeesViewModel>()
                                .count[i];
                            int totalCount = context
                                .read<EmployeesViewModel>()
                                .totalEmployees;
                            final percent = totalCount == 0
                              ? 0
                              : ((employeeCount / totalCount) * 100).toInt();
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  spacing: 10,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: data[i].color,
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      data[i].name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '$employeeCount ~ $percent%',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PieChartdata {
  final String name;
  final double value;
  final Color color;

  PieChartdata({required this.name, required this.value, required this.color});
}

class DashboardTabObject {
  final String title;
  final IconData icon;
  final Color color;

  DashboardTabObject({
    required this.icon,
    required this.title,
    required this.color,
  });
}
