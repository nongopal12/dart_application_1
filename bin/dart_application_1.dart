import 'package:http/http.dart' as http;
import 'dart:convert'; // for jsonDecode
import 'dart:io';

void main() async {
  print('===== LOGIN =====');
  stdout.write('Username: ');
  String? username = stdin.readLineSync()?.trim();

  stdout.write('Password: ');
  String? password = stdin.readLineSync()?.trim();

  if (username == null || password == null) {
    print('Incomplete input.');
    return;
  }

  final body = {"username": username, "password": password};

  // ================ LOGIN SESSION

  final url = Uri.parse('http://localhost:3000/login');
  final response = await http.post(url, body: body);

  if (response.statusCode == 200) {
    final loginData = jsonDecode(response.body);
    int? userId = loginData['user_id'];

    // ================= LOOP EXPENSES TRACKING APP

    bool run = true;

    while (run) {
      print("========== Expense Tracking App ==========");
      print("1. Show all");
      print("2. Today's expenses");
      print("3. Search expenses");
      print("4. Add new expenses");
      print("5. Delete an expenses");
      print("6. Exit");
      stdout.write("Choose ...");
      final choice = stdin.readLineSync()?.trim();

      switch (choice) {
        case '1':
          final expenseurl = Uri.parse(
            'http://localhost:3000/expenses/$userId',
          );
          final response = await http.get(expenseurl);

          if (response.statusCode == 200) {
            final result = jsonDecode(response.body) as List;
            int total = 0;
            int order = 1;
            print("-------------- ALL EXPENSES --------------");
            for (Map exp in result) {
              total += exp['paid'] as int;
              print(
                "$order. ${exp['item']} : ${exp['paid']}฿ @ ${exp['date']}",
              );
              order++;
            }
            print("Total expenses = $total฿");
          } else {
            print('Error ${response.statusCode}: ${response.body}');
          }

          break;

        case '2':
          final todayurl = Uri.parse(
            'http://localhost:3000/expenses/today/$userId',
          );
          final todayResponse = await http.get(todayurl);

          if (todayResponse.statusCode == 200) {
            final result = jsonDecode(todayResponse.body) as List;
            int total = 0;
            int order = 1;
            print("-------------- TODAY'S EXPENSES --------------");
            for (Map exp in result) {
              total += exp['paid'] as int;
              print(
                "$order. ${exp['item']} : ${exp['paid']}฿ @ ${exp['date']}",
              );
              order++;
            }
            print("Total expenses = $total฿");
          } else {
            print('Error ${todayResponse.statusCode}: ${todayResponse.body}');
          }
          break;

        //---------------------------- resarch expense ------------------------------
        // เขียนตรงนี้  //



        //--------------------------- Add new expense -------------------------------
        // เขียนตรงนี้  //




               //-------------------------- Delete an expense -----------------------------
        case '5':
          try {
            stdout.write("Enter expense ID to delete: ");
            final idInput = stdin.readLineSync()?.trim();

            if (idInput == null || idInput.isEmpty) {
              print("❌ Invalid input! Expense ID is required.");
              break;
            }

            // ตรวจสอบว่าเป็นตัวเลข
            final expenseId = int.tryParse(idInput);
            if (expenseId == null) {
              print("❌ Expense ID must be a number.");
              break;
            }

            final deleteUrl = Uri.parse("http://localhost:3000/expenses/$expenseId");
            final deleteResponse = await http.delete(deleteUrl);

            if (deleteResponse.statusCode == 200) {
              print("✅ Expense deleted successfully!");
            } else if (deleteResponse.statusCode == 404) {
              print("❌ Expense not found!");
            } else {
              print("⚠️ Error ${deleteResponse.statusCode}: ${deleteResponse.body}");
            }
          } catch (e) {
            print("🚨 An error occurred while deleting: $e");
          }
          break;

        case '6':
          print("------ BYE ------");
          run = false;
      }
    }
  } else if (response.statusCode == 401 || response.statusCode == 500) {
    final result = response.body;
    print(result);
  } else {
    print('Unknown error!');
  }
}
