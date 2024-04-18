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
  List<Map<String, dynamic>> imageData,
  String GuardName,
  String StartTime,
  String EndTime,
  String patrolCount,
  String TotalpatrolCount,
  String Location,
  String Status,
  String patrolTimein,
  String patrolTimeout,
) async {
  final url = 'https://backend-sceurity-app.onrender.com/api/send_email';

  for (var toEmail in toEmails) {
    String imagesHTML = '';
    for (var data in imageData) {
      String statusReportedTime = data['StatusReportedTime'];
      List<String> imageUrls = List<String>.from(data['ImageUrls']);
      String statusComment = data['StatusComment'] ?? "";

      // Add a paragraph with the StatusReportedTime and StatusComment
      imagesHTML += '<p>StatusReportedTime: $statusReportedTime</p>';
      imagesHTML += '<p>StatusComment: $statusComment</p>';

      // Add image tags for each ImageUrl with a specific size
      for (var imageUrl in imageUrls) {
        imagesHTML +=
            '<img src="$imageUrl" alt="Image" style="width: 150px; height: 150px; object-fit: cover; border: 1px solid #ccc; margin-right: 8px;">';
      }
    }
    final htmlcontent2 = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patrol Report</title>
    <style>
        body {
            background-image: url('path/to/your/background/image.jpg');
            background-size: cover; /* Ensure the background image covers the entire body */
            background-repeat: no-repeat; /* Prevent the background image from repeating */
            font-family: Arial, sans-serif; /* Use a readable font */
            margin: 0; /* Remove default margin */
            padding: 0; /* Remove default padding */
        }
        #shift-patrol-report {
            width: 100%;
            padding: 2rem;
            box-sizing: border-box;
        }
        .patrol-section {
            border: 1px solid #ddd;
            padding: 1rem;
            margin-bottom: 1rem; /* Add some space between sections */
            background-color: #fff; /* Set a white background color for sections */
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 0.5rem;
            text-align: left;
        }
        .details {
            white-space: pre-line; /* Preserve line breaks in the 'Data' field */
        }
        img {
            max-width: 100%; /* Ensure images don't exceed their container width */
            height: auto; /* Maintain aspect ratio */
            display: block; /* Prevent inline images from affecting layout */
            margin-bottom: 0.5rem; /* Add some space between images */
        }
    </style>
</head>
<body>
    <div id="shift-patrol-report">
        <h2>SHIFT/PATROL REPORT</h2>
        <div class="patrol-section">
            <h3>Patrol Details</h3>
            <table>
                <thead>
                    <tr>
                        <th>Guard name</th>
                        <th>Patrol time in</th>
                        <th>Patrol time out</th>
                        <th>Total Patrol Count</th>
                        <th>Total hits</th>
                        <th>Status</th>
                        <th>Incident</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>$GuardName</td>
                        <td>$patrolTimein</td>
                        <td>$patrolTimeout</td>
                        <td>$TotalpatrolCount</td>
                        <td>$patrolCount</td>
                        <td>$Status</td>
                        <td class="details">$Data</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="patrol-section">
            <h3>Patrol with Photos</h3>
            <p id="patrol-details"></p>
            $imagesHTML
        </div>
        <div class="report-section">
            <h3>Important Note</h3>
            <p id="important-note"></p>
        </div>
    </div>
    <script src="script.js"></script>
</body>
</html>




""";
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'to_email': toEmail,
        'subject': Subject,
        'from_name': "TactTik Reports",
        'html': htmlcontent2,
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
}

Future<void> sendShiftEmail(
  List<String> toEmails,
  String Subject,
  String fromName,
  String Data,
  String type,
  String date,
  List<Map<String, dynamic>> imageData,
  String GuardName,
  String StartTime,
  String EndTime,
  String Location,
  String Status,
  String patrolTimein,
  String patrolTimeout,
) async {
  final url = 'https://backend-sceurity-app.onrender.com/api/send_email';

  String imagesHTML = '';
  for (var data in imageData) {
    String statusReportedTime = data['StatusReportedTime'];
    List<String> imageUrls = List<String>.from(data['ImageUrls']);
    String statusComment = data['StatusComment'] ?? "";

    // Add a paragraph with the StatusReportedTime and StatusComment
    imagesHTML += '<p>StatusReportedTime: $statusReportedTime</p>';
    imagesHTML += '<p>StatusComment: $statusComment</p>';

    // Add image tags for each ImageUrl with a specific size
    for (var imageUrl in imageUrls) {
      imagesHTML +=
          '<img src="$imageUrl" alt="Image" style="width: 150px; height: 150px; object-fit: cover; border: 1px solid #ccc; margin-right: 8px;">';
    }
  }
  final htmlcontent2 = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patrol Report</title>
    <style>
        body {
            background-image: url('path/to/your/background/image.jpg');
            background-size: cover; /* Ensure the background image covers the entire body */
            background-repeat: no-repeat; /* Prevent the background image from repeating */
            font-family: Arial, sans-serif; /* Use a readable font */
            margin: 0; /* Remove default margin */
            padding: 0; /* Remove default padding */
        }
        #shift-patrol-report {
            width: 100%;
            padding: 2rem;
            box-sizing: border-box;
        }
        .patrol-section {
            border: 1px solid #ddd;
            padding: 1rem;
            margin-bottom: 1rem; /* Add some space between sections */
            background-color: #fff; /* Set a white background color for sections */
        }
        table {
            width: 100%;
            border-collapse: collapse;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 0.5rem;
            text-align: left;
        }
        .details {
            white-space: pre-line; /* Preserve line breaks in the 'Data' field */
        }
        img {
            max-width: 100%; /* Ensure images don't exceed their container width */
            height: auto; /* Maintain aspect ratio */
            display: block; /* Prevent inline images from affecting layout */
            margin-bottom: 0.5rem; /* Add some space between images */
        }
    </style>
</head>
<body>
    <div id="shift-patrol-report">
        <h2>SHIFT/PATROL REPORT</h2>
        <div class="patrol-section">
            <h3>Patrol Details</h3>
            <table>
                <thead>
                    <tr>
                        <th>Guard name</th>
                        <th>Patrol time in</th>
                        <th>Patrol time out</th>
                        <th>Total Patrol Count</th>
                        <th>Total hits</th>
                        <th>Status</th>
                        <th>Incident</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>$GuardName</td>
                        <td>$patrolTimein</td>
                        <td>$patrolTimeout</td>
                        <td>$Status</td>
                        <td class="details">$Data</td>
                    </tr>
                </tbody>
            </table>
        </div>
        <div class="patrol-section">
            <h3>Patrol with Photos</h3>
            <p id="patrol-details"></p>
            $imagesHTML
        </div>
        <div class="report-section">
            <h3>Important Note</h3>
            <p id="important-note"></p>
        </div>
    </div>
    <script src="script.js"></script>
</body>
</html>




""";
  final response = await http.post(
    Uri.parse(url),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'to_email': "sutarvaibhav37@gmail.com",
      'subject': "Testing",
      'from_name': GuardName,
      'html': htmlcontent2,
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

// final htmlContent = '''
//   <!DOCTYPE html>
// <html>
//   <head>
//     <style>
//       /* Add some basic styling */
//       body {
//         font-family: Arial, sans-serif;
//       }
//       table {
//         border-collapse: collapse;
//         width: 100%;
//       }
//       th, td {
//         border: 1px solid black;
//         padding: 8px;
//         text-align: left;
//       }
//       th {
//         background-color: #f2f2f2;
//       }
//       .images {
//         height: 150px;
//         width: 150px;
//         object-fit: cover;
//         border: 1px solid #ccc;
//         margin-right: 8px;
//       }
//       .details {
//         margin-top: 8px;
//       }
//     </style>
//   </head>
//   <body>
//     <h2>SHIFT/PATROL REPORT</h2>
//     <table>
//       <thead>
//         <tr>
//           <th>guard name</th>
//           <th>shift Time in</th>
//           <th>shift Time out</th>
//           <th>patrol time in</th>
//           <th>patrol time out</th>
//           <th>total hits</th>
//           <th>any incident</th>
//           <th>patrol details</th>
//           <th>patrol time</th>
//         </tr>
//       </thead>
//       <tbody>
//         <tr>
//           <td>$GuardName</td>
//           <td>6:00pm</td>
//           <td>$EndTime</td>
//           <td>6:00pm</td>
//           <td>6:20pm</td>
//           <td>$patrolCount</td>
//           <td>$Status</td>
//           <td class="details">
//             $Data<br>
//             $imagesHTML
//           </td>
//           <td>$patrolTimein to $patrolTimeout</td>
//         </tr>
//       </tbody>
//     </table>
//     <p>Important Note: SHIFT / PATROL REPORT guard name shift Time in Shift Time out patrol time in patrol time out total hits any incident patrol details patrol time 6:00 pm to 6:20 pm Patrol with photos Details Looks all good IMAGES</p>
//   </body>
// </html>
//   ''';
