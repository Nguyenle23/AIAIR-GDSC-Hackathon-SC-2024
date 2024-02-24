import 'package:flutter/material.dart';

class PredictScreen extends StatelessWidget {
  const PredictScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Predict'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Air Quality Prediction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder for prediction logic
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Prediction in progress...')));
              },
              child: const Text('Predict Air Quality'),
            )
          ],
        ),
      ),
    );
  }
}
