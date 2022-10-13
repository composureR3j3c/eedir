import 'package:flutter_email_sender/flutter_email_sender.dart';


Future<dynamic> sendMail() async{

final Email send_email = Email(
  body: 'body of email',
  subject: 'Support',
  recipients: ['gezahegnebereket@gmail.com'],
  isHTML: false,
);

await FlutterEmailSender.send(send_email);


}