import 'package:flutter/material.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            //information about the air quality index level
            const Text(
              'Air Quality Index (AQI)',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                ),
                Expanded(
                  child: Text(
                    'The AQI is an index for reporting daily air quality. It tells you how clean or polluted your air is, and what associated health effects might be a concern for you.',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                ),
                Expanded(
                  child: Text(
                    'The AQI focuses on health effects you may experience within a few hours or days after breathing polluted air.',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                ),
                Expanded(
                  child: Text(
                    'EPA calculates the AQI for five major air pollutants regulated by the Clean Air Act: ground-level ozone, particle pollution (also known as particulate matter), carbon monoxide, sulfur dioxide, and nitrogen dioxide.',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                ),
                Expanded(
                  child: Text(
                    'For each of these pollutants, EPA has established national air quality standards to protect public health.',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                ),
                Expanded(
                  child: Text(
                    'Ground-level ozone and airborne particles are the two pollutants that pose the greatest threat to human health in this country.',
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Levels of Air Quality Index',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'Each category corresponds to a different level of health concern. The six levels of health concern and what they mean are:',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
                padding: const EdgeInsets.only(
                  top: 5,
                  left: 10,
                  right: 5,
                  bottom: 10,
                ),
                child: DataTable(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset.zero,
                          blurRadius: 1,
                          blurStyle: BlurStyle.outer,
                        ),
                      ],
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'AQI',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Category',
                          style: TextStyle(fontSize: 20),
                        ),
                      ),
                    ],
                    rows: const [
                      DataRow(cells: [
                        DataCell(
                          Text(
                            '0 - 50',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(
                          'Good',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            '51 - 100',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(
                          'Moderate',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            '101 - 150',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(
                          'Unhealthy for Sensitive Groups',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            '151 - 200',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(
                          'Unhealthy',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            '201 - 300',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(
                          'Very Unhealthy',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ]),
                      DataRow(cells: [
                        DataCell(
                          Text(
                            'greater than 300',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        DataCell(Text(
                          'Hazardous',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        )),
                      ]),
                    ])),
          ],
        ),
      ),
    );
  }
}
