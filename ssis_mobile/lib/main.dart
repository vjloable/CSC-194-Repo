import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    TextEditingController emailController = TextEditingController();
    TextEditingController passwordController = TextEditingController();

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Login Page'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Center(
            child: Column(
              children: [
                const Text(
                  "My First Application",
                  style: TextStyle(
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 50),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                  ),
                ),
                Builder(builder: (context) {
                  return ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NextPage(
                                    email: emailController.text,
                                    password: passwordController.text)));
                      },
                      child: const Text('Login'));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NextPage extends StatefulWidget {
  const NextPage({super.key, required this.email, required this.password});

  final String email;
  final String password;

  @override
  State<NextPage> createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  static const String apiUrl = '10.0.2.2:5000';
  dynamic courseDetails;
  bool isLoading = false;

  TextEditingController courseController = TextEditingController();
  TextEditingController deleteController = TextEditingController();

  Future<void> fetchcourseDetails() async {
    try {
      final Uri url = Uri.http(apiUrl, '/courses');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final dynamic body = json.decode(response.body);
        if (body is Map<String, dynamic>) {
          setState(() {
            courseDetails = body;
          });

          print('courseDetails: $courseDetails');
          setState(() {
            isLoading = false; // Hide the loading indicator
          });
        } else {
          throw Exception('Invalid response format or status is not "ok"');
        }
      } else {
        throw Exception('Failed to load details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching replay details: $e');
    }
  }

  Future<void> addCourse(String course_name) async {
    final Uri url = Uri.http(apiUrl, '/course');
    final Map<String, String> requestBody = {
      'course': course_name,
    };

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        print('Course added successfully');
      } else {
        print('Failed to add course. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> deleteCourse(int courseId) async {
    final Uri url = Uri.http(apiUrl, '/course/$courseId');

    final headers = {
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.delete(
        url,
        headers: headers,
      );

      if (response.statusCode == 200) {
        print('Course deleted successfully');
      } else {
        print('Failed to deleted course. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Next Page'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('The next page'),
            Text('Email: ${widget.email}'),
            Text(('Password: ${widget.password}')),
            ElevatedButton(
              onPressed: () {
                fetchcourseDetails();
              },
              child: const Text('Fetch Replay Details'),
            ),
            if (isLoading)
              CircularProgressIndicator() // Show a loading indicator while fetching data
            else if (courseDetails != null)
              Card(
                child: ListTile(
                  title: Text('Replay Data'), // You can customize this part
                  subtitle: Text(courseDetails
                      .toString()), // Display your fetched data here
                ),
              ),
            TextField(
              controller: courseController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Course',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                addCourse(courseController.text);
              },
              child: const Text('Add course'),
            ),
            TextField(
              controller: deleteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Delete Course',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                deleteCourse(int.tryParse(deleteController.text) ?? 0);
              },
              child: const Text('Delete course'),
            ),
          ],
        ),
      ),
    );
  }
}
