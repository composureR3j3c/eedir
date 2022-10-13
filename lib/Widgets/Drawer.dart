import 'package:flutter/material.dart';
import 'package:ridee/Helpers/sendMail.dart';
class DrawerWidget extends StatelessWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      width: 255.0,
      child: Drawer(
        child: Column(
          children: [
            AppBar(
              title: Text('Hello Friend'),
              //no back button
              automaticallyImplyLeading: false,
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('History'),
              onTap: () {
                // Navigator.pushReplacementNamed(context, '/');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Visit Profile'),
              onTap: () {
                // Navigator.pushReplacementNamed(context, OrdersScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.info),
              title: Text('About'),
              onTap: () {
                // Navigator.pushReplacementNamed(
                    // context, UserProductScreen.routeName);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.help_center),
              title: Text('Support'),
              onTap: () {
                sendMail();
                Navigator.pop(context);
                // Provider.of<Auth>(context, listen: false).logout();
              },
            ),
          ],
        ),
      ),
    );
  }
}
