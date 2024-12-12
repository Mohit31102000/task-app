import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_app/helper/database_helper.dart';
import 'package:task_app/model/user_model.dart';
import 'package:task_app/provider/user_list_provider.dart';
import 'package:task_app/screens/login_screen.dart';
import 'package:task_app/screens/user_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  DatabaseHelper dbHelper = DatabaseHelper();

  showSnacBar(bool status) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(status ? 'Internet connected' : 'No Internet Connection'),
        backgroundColor: status ? Colors.green : Colors.red,
      ),
    );
  }

  logoutSession() async {
    SharedPreferences? pref = await SharedPreferences.getInstance();
    pref.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    Provider.of<UserListProvider>(context, listen: false)
        .fetchUsers(isDeleteAllData: true);
  }
  

  @override
  Widget build(BuildContext context) {
    List<UserModelClass> filteredUsers =
        Provider.of<UserListProvider>(context).filteredUsers;
    bool isLoading = Provider.of<UserListProvider>(context).isLoading;
    /*  final networkProvider = Provider.of<NetworkProvider>(context);

     // Network alert
    if (!networkProvider.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
       showSnacBar(false);
      });
    }else  if (networkProvider.isConnected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
       showSnacBar(true);
      });
    }*/

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pinkAccent,
        title: const Text(
          'User List',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (String value) {
              switch (value) {
                case 'Logout':
                  logoutSession();
                  break;
                case 'Get online data':
                  Provider.of<UserListProvider>(context, listen: false)
                      .fetchUsers(isDeleteAllData: true);
                  break;
              }
            },
            itemBuilder: (BuildContext context) {
              return {'Logout', 'Get online data'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Search',
                      hintText: 'Search by name, username and email',
                    ),
                    onChanged: (value) {
                      Provider.of<UserListProvider>(context, listen: false)
                          .filterUsers(value);
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: filteredUsers.isEmpty
                        ? Center(
                            child: Text('No user found'),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            UserDetailsScreen(
                                          user: filteredUsers[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          //  color: Colors.red,
                                          child: Image.asset(
                                            "assets/images/user.png",
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 14,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              filteredUsers[index]
                                                  .name
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 18),
                                            ),
                                            Text(
                                              filteredUsers[index]
                                                  .email
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontSize: 14),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      IconButton(
                                          onPressed: () async {
                                            nameController.text =
                                                filteredUsers[index]
                                                    .name
                                                    .toString();
                                            userNameController.text =
                                                filteredUsers[index]
                                                    .username
                                                    .toString();
                                            emailController.text =
                                                filteredUsers[index]
                                                    .email
                                                    .toString();
                                            showAlertDialog(
                                              muserid: filteredUsers[index]
                                                  .id
                                                  .toString(),
                                            );
                                          },
                                          icon: const Icon(Icons.edit)),
                                      IconButton(
                                          onPressed: () {
                                            deleteUser(
                                              int.parse(
                                                filteredUsers[index]
                                                    .id
                                                    .toString(),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          )),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
    );
  }

  void deleteUser(int id) async {
    await dbHelper.deleteUser(id);
    Provider.of<UserListProvider>(context, listen: false)
        .fetchUsers(isDeleteAllData: false);
  }

  void updateUser({id, name, username, email}) async {
    Map<String, dynamic> user = {};
    user['id'] = id;
    user['name'] = name;
    user['username'] = username;
    user['email'] = email;

    debugPrint(user.toString());

    await dbHelper.updateUser(user);
    Provider.of<UserListProvider>(context, listen: false)
        .fetchUsers(isDeleteAllData: false);
  }

  void showAlertDialog({muserid}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Update Details"),
          content: Column(
            mainAxisSize:
                MainAxisSize.min, // Ensures the dialog size fits its content
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Name',
                    hintText: 'Enter Name',
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black))),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: userNameController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Username',
                    hintText: 'Enter username',
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black))),
              ),
              SizedBox(
                height: 15,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Enter Email address',
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black))),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateUser(
                  id: muserid,
                  name: nameController.text.toString(),
                  username: userNameController.text.toString(),
                  email: emailController.text.toString(),
                );

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}
