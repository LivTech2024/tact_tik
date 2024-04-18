import 'dart:convert';

import 'package:emailjs/emailjs.dart';
import 'package:http/http.dart' as http;

Future<bool> sendEmail(dynamic templateParams) async {
  try {
    await EmailJS.send(
      'service_6mmak1z',
      'template_lm9ftk9',
      templateParams,
      Options(
        publicKey: 'DAtUR9kGOvEyWhbq-',
        privateKey: 'RLNEcycnFNHoR4oPXIXUN',
      ),
    );
    print('SUCCESS!');
    return true;
  } catch (error) {
    if (error is EmailJSResponseStatus) {
      print('ERROR... ${error.status}: ${error.text}');
    }
    print(error.toString());
    return false;
  }
}

Future<bool> sendFormattedEmail(dynamic templateParams) async {
  try {
    await EmailJS.send(
      'service_6mmak1z',
      'template_f6hrfab',
      templateParams,
      Options(
        publicKey: 'DAtUR9kGOvEyWhbq-',
        privateKey: 'RLNEcycnFNHoR4oPXIXUN',
      ),
    );
    print('SUCCESS!');
    return true;
  } catch (error) {
    if (error is EmailJSResponseStatus) {
      print('ERROR... ${error.status}: ${error.text}');
    }
    print(error.toString());
    return false;
  }
}

// Future<void> sendapiEmail(String Subject, String fromName, String Data) async {
//   final url = 'https://backend-sceurity-app.onrender.com/api/send_email';
//   final response = await http.post(
//     Uri.parse(url),
//     headers: {'Content-Type': 'application/json'},
//     body: json.encode({
//       'to_email': 'sutarvaibhav37@gmail.com',
//       'subject': Subject,
//       'from_name': fromName,
//       'text': Data,
//       'html': " <p>This is a test email sent using the API.</p>",
//     }),
//   );

//   if (response.statusCode == 201) {
//     print('Email sent successfully');
//     // Handle success
//   } else {
//     print('Failed to send email. Status code: ${response.statusCode}');
//     // Handle failure
//   }
// }

Future<void> sendapiEmail(
    List<String> toEmails,
    String Subject,
    String fromName,
    String Data,
    String type,
    String date,
    String StatusReportedTime,
    String ImageUrls,
    String GuardName,
    String StartTime,
    String EndTime,
    String patrolCount,
    String Location,
    String Status,
    String patrolTImein,
    String patrolTImeout) async {
  final url = 'https://backend-sceurity-app.onrender.com/api/send_email';
  final htmlContent = '''
    <p>Hello Sir/Madam,</p>
    <p>You have received a new update on the ${type} Activity on ${date}</p>
    <div style="overflow-x: auto;">
        <table style="width: 99.9861%; border-collapse: collapse; margin: 0px auto; height: 182.898px;" border="0" cellspacing="0" cellpadding="8">
            <thead>
                <tr style="height: 76.3984px;">
                    <th style="border-bottom: 2px solid rgb(221, 221, 221); padding: 10px; text-align: center; background-color: #f2f2f2; width: 14.0065%;">Guard Name</th>
                    <th style="border-bottom: 2px solid rgb(221, 221, 221); padding: 10px; text-align: center; background-color: #f2f2f2; width: 17.5428%;">Location</th>
                    <th style="border-bottom: 2px solid rgb(221, 221, 221); padding: 10px; text-align: center; background-color: #f2f2f2; width: 15.0466%;">Status</th>
                    <th style="border-bottom: 2px solid rgb(221, 221, 221); padding: 10px; text-align: center; background-color: #f2f2f2; width: 5.47779%;">Start Time</th>
                    <th style="border-bottom: 2px solid rgb(221, 221, 221); padding: 10px; text-align: center; background-color: #f2f2f2; width: 6.93391%;">End Time</th>
                    <th style="border-bottom: 2px solid rgb(221, 221, 221); padding: 10px; text-align: center; background-color: #f2f2f2; width: 6.17118%;">Count</th>
                    <th style="border-bottom: 2px solid rgb(221, 221, 221); padding: 10px; text-align: center; background-color: #f2f2f2; width: 10.0542%;">Time in</th>
                    <th style="border-bottom: 2px solid rgb(221, 221, 221); padding: 10px; text-align: center; background-color: #f2f2f2; width: 8.32913%;">Time out</th>
                    <th style="border-bottom: 2px solid rgb(221, 221, 221); padding: 10px; text-align: center; background-color: #f2f2f2; width: 16.4249%;">Comments</th>
                </tr>
            </thead>
            <tbody>
                <tr style="height: 106.5px;">
                    <td style="border-bottom: 1px solid rgb(221, 221, 221); padding: 10px; text-align: center; vertical-align: middle; width: 14.0065%;">${GuardName}</td>
                    <td style="border-bottom: 1px solid rgb(221, 221, 221); padding-top: 10px; padding-right: 10px; padding-bottom: 10px; text-align: center; vertical-align: middle; width: 17.5428%;">${Location}</td>
                    <td style="border-bottom: 1px solid rgb(221, 221, 221); padding-top: 10px; padding-right: 10px; padding-bottom: 10px; text-align: center; vertical-align: middle; width: 15.0466%;">${Status}</td>
                    <td style="border-bottom: 1px solid rgb(221, 221, 221); padding: 10px; text-align: center; vertical-align: middle; width: 5.47779%;">${StartTime}</td>
                    <td style="border-bottom: 1px solid rgb(221, 221, 221); padding: 10px; text-align: center; vertical-align: middle; width: 6.93391%;">${EndTime}</td>
                    <td style="border-bottom: 1px solid rgb(221, 221, 221); padding: 10px; text-align: center; vertical-align: middle; width: 6.17118%;">${patrolCount}</td>
                    <td style="border-bottom: 1px solid rgb(221, 221, 221); padding: 10px; text-align: center; vertical-align: middle; width: 10.0542%;">${patrolTImein}</td>
                    <td style="border-bottom: 1px solid rgb(221, 221, 221); padding: 10px; text-align: center; vertical-align: middle; width: 8.32913%;">${patrolTImeout}</td>
                    <td style="border-bottom: 1px solid rgb(221, 221, 221); padding: 10px; text-align: center; vertical-align: middle; width: 16.4249%;">
                        <p>Safe and secure</p>
                    </td>
                </tr>
                <tr></tr>
                <tr>
                    <td style="text-align: center; vertical-align: middle;" colspan="9">Images:</td>
                </tr>
                {{#imageData}}
                <tr>
                    <td style="text-align: center; vertical-align: middle;" colspan="9">
                        <p>StatusReportedTime: ${StatusReportedTime}</p>
                        <p>ImageUrls: ${ImageUrls}</p>
                    </td>
                </tr>
                {{/imageData}}
            </tbody>
        </table>
    </div>
    <p>Best wishes,<br>Team tacttik</p>
    <style>
        @media screen and (max-width: 600px) {
            table {
                width: 100%;
                border-collapse: collapse;
                margin-bottom: 20px;
            }

            th,
            td {
                border: none;
                text-align: left;
                padding: 8px;
            }

            th {
                background-color: #f2f2f2;
            }

            td {
                font-size: 14px;
            }
        }
    </style>
  ''';
  // final encodedHtmlContent = base64Encode(utf8.encode(htmlContent));
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'to_email': 'sutarvaibhav37@gmail.com',
      'subject': "Testing",
      'from_name': "vaibhav Sutar",
      'html': htmlContent,
    }),
  );

  if (response.statusCode == 201) {
    print('Email sent successfully');
    // Handle success
  } else {
    print('Failed to send email. Status code: ${response.statusCode} ');
    // Handle failure
  }
}
