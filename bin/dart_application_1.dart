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
        Future<void> searchByItem(int userId) async {
  stdout.write("Enter keyword (item): ");
  final keyword = stdin.readLineSync()?.trim();

  if (keyword == null || keyword.isEmpty) {
    print("Please enter a keyword.");
    return;
  }

  // เรียก GET /expenses/search/:user_id?item=keyword
  final uri = Uri.http(
    'localhost:3000',
    '/expenses/search/$userId',
    {'item': keyword},
  );

  final resp = await http.get(uri);

  if (resp.statusCode != 200) {
    print('Error ${resp.statusCode}: ${resp.body}');
    return;
  }

  final List result = jsonDecode(resp.body);

  if (result.isEmpty) {
    print('— No item contains "$keyword" —');
    return;
  }

  int total = 0;
  int order = 1;
  print("-------------- SEARCH: \"$keyword\" --------------");
  for (final exp in result) {
    final paid = (exp['paid'] as num).toInt();
    total += paid;
    print("$order. ${exp['item']} : ${paid}฿ @ ${exp['date']} (id=${exp['id']})");
    order++;
  }
  print("Total (matched) = $total฿");
}




        //--------------------------- Add new expense -------------------------------
        case '4':
          stdout.write("Item: ");
          String? item = stdin.readLineSync()?.trim();

          stdout.write("Paid: ");
          String? paidInput = stdin.readLineSync()?.trim();
          int? paid = int.tryParse(paidInput ?? '');

          if (item == null || item.isEmpty || paid == null) {
            print("Invalid input. Please try again.");
            break;
          }

          final addUrl = Uri.parse('http://localhost:3000/expenses');
          final addBody = {
            "user_id": userId.toString(),
            "item": item,
            "paid": paid.toString(),
          };

          final addResponse = await http.post(addUrl, body: addBody);

          if (addResponse.statusCode == 201) {
            print("Expense added successfully.");
          } else {
            print('Error ${addResponse.statusCode}: ${addResponse.body}');
          }
          break;
        


        //-------------------------- Delete an expense -----------------------------
        // เขียนตรงนี้  //




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
