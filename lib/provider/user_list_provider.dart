import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:task_app/helper/database_helper.dart';
import 'dart:convert';

import 'package:task_app/model/user_model.dart';

class UserListProvider with ChangeNotifier {
  List<UserModelClass> users1 = [];
  List<UserModelClass> filteredUsers = [];
  bool isLoading = false;
  final DatabaseHelper dbHelper = DatabaseHelper();


  //Get user list from network API
  Future<void> fetchUsers({isDeleteAllData}) async {
    isLoading = true;

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult[0] == ConnectivityResult.mobile ||
        connectivityResult[0] == ConnectivityResult.wifi) {
      debugPrint("Internet available: Fetching API data");

      try {
        dynamic response = await http
            .get(Uri.parse('https://jsonplaceholder.typicode.com/users'));

        if (response.statusCode == 200) {
          if (isDeleteAllData == true) {
            await dbHelper.deleteAllData();

            List<dynamic> users = json.decode(response.body);

            //bool isEmpty = await _isDatabaseEmpty();
            //   if (isEmpty) {
            for (var user in users) {
              await dbHelper.insertUser({
                'id': user['id'],
                'name': user['name'],
                'username': user['username'],
                'email': user['email'],
                'phone': user['phone'],
                'website': user['website'],
                'street': user['address']['street'].toString(),
                'suite': user['address']['suite'].toString(),
                'city': user['address']['city'].toString(),
                'zipcode': user['address']['zipcode'].toString(),
                'lat': user['address']['geo']['lat'].toString(),
                'lng': user['address']['geo']['lng'].toString(),
                'companyName': user['company']['name'].toString(),
                'catchPhrase': user['company']['catchPhrase'].toString(),
                'bs': user['company']['bs'].toString(),
              });
            }
            //}
          }

          List<Map<String, dynamic>> musers = await dbHelper.fetchUsers();
          users1 = [];

          debugPrint('Filtered data 121212121 : $musers');

          for (var user in musers) {
            users1.add(UserModelClass(
              id: user['id'],
              name: user['name'],
              username: user['username'],
              email: user['email'],
              phone: user['phone'],
              website: user['website'],
              street: user['street'],
              suite: user['suite'],
              city: user['city'],
              zipcode: user['zipcode'],
              lat: user['lat'],
              lng: user['lng'],
              companyName: user['companyName'],
              catchPhrase: user['catchPhrase'],
              bs: user['bs'],
            ));
          }

          if (users1.isNotEmpty) {
            filteredUsers = users1;
          }

          debugPrint('Filtered data legnth : ${filteredUsers.length}');
          debugPrint('Filtered data : $filteredUsers');
        } else {
          throw Exception('Failed to load users');
        }
      } catch (e) {
        debugPrint('Error: $e');
      }
    } else {
      debugPrint("No internet: Fetching local database data");

      List<Map<String, dynamic>> musers = await dbHelper.fetchUsers();
      users1 = [];

      debugPrint('Filtered data 121212121 : $musers');

      for (var user in musers) {
        users1.add(UserModelClass(
          id: user['id'],
          name: user['name'],
          username: user['username'],
          email: user['email'],
          phone: user['phone'],
          website: user['website'],
          street: user['street'],
          suite: user['suite'],
          city: user['city'],
          zipcode: user['zipcode'],
          lat: user['lat'],
          lng: user['lng'],
          companyName: user['companyName'],
          catchPhrase: user['catchPhrase'],
          bs: user['bs'],
        ));
      }

      if (users1.isNotEmpty) {
        filteredUsers = users1;
      }

      debugPrint('Filtered data legnth : ${filteredUsers.length}');
      debugPrint('Filtered data : $filteredUsers');
    }

    isLoading = false;
    notifyListeners();
  }

  // Filter logic
  void filterUsers(String value) {
    if (value.isEmpty) {
      filteredUsers = users1;
    } else {
      filteredUsers = users1.where((user) {
        return user.name!.toLowerCase().contains(value.toLowerCase()) ||
            user.username!.toLowerCase().contains(value.toLowerCase()) ||
            user.email!.toLowerCase().contains(value.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }
}
