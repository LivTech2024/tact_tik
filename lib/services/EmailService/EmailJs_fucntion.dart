import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailjs/emailjs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_html_to_pdf/flutter_native_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart';
import 'package:tact_tik/services/firebaseFunctions/firebase_function.dart';

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
Future<void> callPdfApi() async {
  final url = Uri.parse('https://yakpdf.p.rapidapi.com/pdf');

  final headers = {
    'content-type': 'application/json',
    'X-RapidAPI-Key': '08788b2125msh872c59eba317b7fp15e98ajsnb0a96ec9fb5d',
    'X-RapidAPI-Host': 'yakpdf.p.rapidapi.com',
  };

  final body = jsonEncode({
    'source': {
      'html':
          '<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"></head><body><h1>Hello World!</h1></body></html>'
    },
    'pdf': {'format': 'A4', 'scale': 1, 'printBackground': true},
    'wait': {'for': 'navigation', 'waitUntil': 'load', 'timeout': 2500}
  });

  final response = await http.post(
    url,
    headers: headers,
    body: body,
  );

  if (response.statusCode == 200) {
    print('Response body: ${response.body}');
  } else {
    print(
        'Failed to call API: ${response.statusCode}, ${response.reasonPhrase}');
  }
}

Future<void> sendapiEmail(
    List<String> toEmails,
    String Subject,
    String fromName,
    String Data,
    String type,
    String date,
    List<Map<String, dynamic>> imageData,
    String GuardName,
    String? StartTime,
    String EndTime,
    int patrolCount,
    String TotalpatrolCount,
    String Location,
    String Status,
    String? patrolTimein,
    String patrolTimeout,
    String feedback) async {
  final url = 'https://backend-sceurity-app.onrender.com/api/send_email';

  for (var toEmail in toEmails) {
    String imagesHTML = '';
    for (var data in imageData) {
      String statusReportedTime = data['StatusReportedTime'];
      List<String> imageUrls = List<String>.from(data['ImageUrls']);
      String statusComment = data['StatusComment'] ?? "";
      print("Status Reported Time : ${statusReportedTime}");
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
            margin: 20px; /* Remove default margin */
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

            <h3>Feedback Note</h3>
            <p id="important-note"></p>
            $feedback
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

final _flutterNativeHtmlToPdfPlugin = FlutterNativeHtmlToPdf();
Future<void> generateExampleDocument() async {
  const htmlContent = """
   <!DOCTYPE html>
<html>
<head>
    <title>Sample HTML Page</title>
</head>
<body>
    <h1>Welcome to My Website!</h1>
    <p>This is a sample paragraph text.</p>
    <img src="https://picsum.photos/200/300" alt="Description of the image">
</body>
</html>
    """;

  Directory appDocDir = await getApplicationDocumentsDirectory();
  final targetPath = appDocDir.path;
  const targetFileName = "mytext";
  final generatedPdfFile = await _flutterNativeHtmlToPdfPlugin.convertHtmlToPdf(
    html: htmlContent,
    targetDirectory: targetPath,
    targetName: targetFileName,
  );

  generatedPdfFilePath = generatedPdfFile?.path;
  print(generatedPdfFile);
}

String? generatedPdfFilePath;
Future<File> savePdfLocally(String pdfBase64, String fileName) async {
  final pdfBytes = base64Decode(pdfBase64);
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/$fileName');
  await file.writeAsBytes(pdfBytes);
  return file;
}

FireStoreService fireStoreService = FireStoreService();
Future<String> generateShiftReportPdf(
  String? ClientName,
  List<Map<String, dynamic>> Data,
  String GuardName,
  String shiftinTime,
  String shiftOutTime,
) async {
  final dateFormat = DateFormat('HH:mm'); // Define the format for time

  // Generate the HTML content for the report
  String patrolInfoHTML = '';
  for (var item in Data) {
    String checkpointImagesHTML = '';
    for (var checkpoint in item['PatrolLogCheckPoints']) {
      String checkpointImages = '';
      if (checkpoint['CheckPointImage'] != null) {
        for (var image in checkpoint['CheckPointImage']) {
          checkpointImages +=
              '<img src="$image" style="max-width: 100%; height: auto; display: block; margin-bottom: 10px;">'; // Set max-width to ensure responsiveness
        }
      }
      checkpointImagesHTML += '''
        <div>
          <p>Checkpoint Name: ${checkpoint['CheckPointName']}</p>
          $checkpointImages
          <p>Comment: ${checkpoint['CheckPointComment']}</p>
          <p>Reported At: ${dateFormat.format(checkpoint['CheckPointReportedAt'].toDate())}</p>
          <p>Status: ${checkpoint['CheckPointStatus']}</p>
        </div>
      ''';
    }

    patrolInfoHTML += '''
      <tr>
        <td>${item['PatrolLogPatrolCount']}</td>
        <td>${dateFormat.format(item['PatrolLogStartedAt'].toDate())}</td>
        <td>${dateFormat.format(item['PatrolLogEndedAt'].toDate())}</td>
        <td>${checkpointImagesHTML}</td>
      </tr>
    ''';
  }

  final htmlcontent = """
    <!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Report</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        header {
            background-color: #333;
            color: white;
            padding: 20px;
            text-align: center;
        }

        .logo-container {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .logo-container img {
            max-height: 50px; /* Set the max-height for the logos */
        }

        h1 {
            margin: 0;
            font-size: 24px;
            flex-grow: 1; /* Allow the <h1> to grow and fill the space */
        }

        section {
            padding: 20px;
            background-color: #fff;
            margin-bottom: 20px;
            border-radius: 5px;
        }

        /* Other styles for tables, images, and footer */
        table {
            border-collapse: collapse;
            width: 100%;
        }

        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }

        th {
            background-color: #f2f2f2;
        }

        img {
            max-width: 100%;
            height: auto;
            display: block;
            margin-bottom: 10px;
            max-height: 200px; /* Define a max-height for the images */
        }

        footer {
            position: fixed;
            left: 0;
            bottom: 0;
            width: 100%;
            background-color: #333;
            color: white;
            text-align: center;
            padding: 10px 0;
        }
    </style>
</head>
<body>
    <header>
            <h1>Security Report</h1>
    </header>

    <section>
        <h2>Dear ${ClientName},</h2>
        <p>I hope this email finds you well. I wanted to provide you with an update on the recent patrol activities carried out by our assigned security guard during their shift. Below is a detailed breakdown of the patrols conducted.</p>
    </section>

    <section>
        <h3>Shift Information</h3>
        <table>
            <tr>
                <th>Guard Name</th>
                <th>Shift Time In</th>
                <th>Shift Time Out</th>
            </tr>
            <tr>
                <td>${GuardName}</td>
                <td>${shiftinTime}</td>
                <td>${shiftOutTime}</td>
            </tr>
        </table>
    </section>

    <section>
        <h3>Patrol Information</h3>
        <table>
            <tr>
                <th>Patrol Count</th>
                <th>Patrol Time In</th>
                <th>Patrol Time Out</th>
                <th>Checkpoint Details</th>
            </tr>
            ${patrolInfoHTML}
        </table>
    </section>

    <section>
        <h3>Comments</h3>
        <table>
            <tr>
                <th>Incident</th>
                <th>Important Note</th>
                <th>Feedback Note</th>
            </tr>
        </table>
    </section>

    <section>
        <p>Please review the information provided and let us know if you have any questions or require further details. We are committed to ensuring the safety and security of your premises, and your feedback is invaluable to us.</p>
        <p>Thank you for your continued trust in our services. We look forward to hearing from you soon.</p>
        <p>Best regards,</p>
        <p>TEAM TACTTIK</p>
    </section>

    <footer>
        <p>&copy; 2024 TEAM TACTTIK. All rights reserved.</p>
    </footer>
</body>
</html>
  """;

  // Generate the PDF
  final pdfResponse = await http.post(
    Uri.parse('https://backend-sceurity-app.onrender.com/api/html_to_pdf'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'html': htmlcontent,
      'file_name': 'security_report.pdf',
    }),
  );

  if (pdfResponse.statusCode == 200) {
    print('PDF generated successfully');
    final pdfBase64 = await base64Encode(pdfResponse.bodyBytes);
    return pdfBase64;
  } else {
    print('Failed to generate PDF. Status code: ${pdfResponse.statusCode}');
    throw Exception('Failed to generate PDF');
  }
}

final dateFormat = DateFormat('HH:mm:ss'); // Define the format for time

Future<void> sendShiftEmail(
  String? ClientName,
  List<String> toEmails,
  String Subject,
  String fromName,
  List<Map<String, dynamic>> Data,
  String type,
  String date,
  String GuardName,
  String StartTime,
  String EndTime,
  String Location,
  String Status,
  String shiftinTime,
  String shiftOutTime,
) async {
  final pdfBase64 = await generateShiftReportPdf(
      ClientName, Data, GuardName, shiftinTime, shiftOutTime);

  // Generate the HTML content for the email
  String patrolInfoHTML = '';
  for (var item in Data) {
    String checkpointImagesHTML = '';
    for (var checkpoint in item['PatrolLogCheckPoints']) {
      String checkpointImages = '';
      if (checkpoint['CheckPointImage'] != null) {
        for (var image in checkpoint['CheckPointImage']) {
          checkpointImages +=
              '<img src="$image" style="height: 100px;">'; // Set the height here
        }
      }
      checkpointImagesHTML += '''
        <div>
          <p>Checkpoint Name: ${checkpoint['CheckPointName']}</p>
          $checkpointImages
          <p>Comment: ${checkpoint['CheckPointComment']}</p>
          <p>Reported At: ${dateFormat.format(checkpoint['CheckPointReportedAt'].toDate())}</p>
          <p>Status: ${checkpoint['CheckPointStatus']}</p>
        </div>
      ''';
    }

    patrolInfoHTML += '''
      <tr>
        <td>${item['PatrolLogPatrolCount']}</td>
        <td>${dateFormat.format(item['PatrolLogStartedAt'].toDate())}</td>
        <td>${dateFormat.format(item['PatrolLogEndedAt'].toDate())}</td>
        <td>${checkpointImagesHTML}</td>
      </tr>
    ''';
  }

  final htmlcontent2 = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Security Report</title>
        <style>
          body {
                font-family: sans-serif;
                margin: 0;
                padding: 0;
            }

            header {
                background-color: #ddd;
                padding: 20px;
                text-align: center;
            }

            h1 {
                margin-bottom: 0;
            }

            table {
                border-collapse: collapse;
                width: 100%;
                margin-bottom: 20px;
            }

            th, td {
                border: 1px solid #ddd;
                padding: 8px;
            }

            th {
                text-align: left;
            }

            .patrol-info tr:nth-child(even) {
                background-color: #f2f2f2;
            }
        </style>
    </head>
    <body>
        <header>
            <h1>Security Report</h1>
        </header>

        <section>
            <h2>Dear ${ClientName},</h2>
            <p>I hope this email finds you well,I wanted to provide you with an update on the recent patrol activities carried out by our assigned security guard during thier shif.Below is a detailed breakdown of the patrols conducted.</p>
        </section>

        <h3>Shift Information</h3>
        <table class="shift-info">
            <tr>
                <th>Guard Name</th>
                <th>Shift Time In</th>
                <th>Shift Time Out</th> 
            </tr>
            <tr>
                <td> ${GuardName}</td>
                <td>${shiftinTime}</td>
                <td>${shiftOutTime}</td>
            </tr>
        </table>

        <h3>Patrol Information</h3>
        <table class="patrol-info">
            <tr>
                <th>Patrol Count</th>
                <th>Patrol Time In</th>
                <th>Patrol Time Out</th>
                <th>Checkpoint Details</th>
            </tr>
            ${patrolInfoHTML}
        </table>

        <p>Please review the information provided and let us know if you have any questions or require further 
details. We are committed to ensuring the safety and security of your premises, and your feedback is 
invaluable to us.</p>
        <p>Thank you for your continued trust in our services. We look forward to hearing from you soon.
Best regards,</p>
        <p>TEAM TACTTIK<p>
    </body>
    </html>
  """;

  // Send the email
  for (var toEmail in toEmails) {
    final emailResponse = await http.post(
      Uri.parse('https://backend-sceurity-app.onrender.com/api/send_email'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'to_email': toEmail,
        'subject': Subject,
        'from_name': fromName,
        'html': htmlcontent2,
        'attachments': [
          {
            'filename': 'security_report.pdf',
            'content': pdfBase64,
            'contentType': 'application/pdf',
          }
        ],
      }),
    );

    if (emailResponse.statusCode == 201) {
      print('Email sent successfully to $toEmail');
      // Handle success
    } else {
      print(
          'Failed to send email to $toEmail. Status code: ${emailResponse.statusCode}');
      // Handle failure
    }
  }
}



        // <p>Download the detailed report <a href='${downloadUrlValue}'>here</a>.</p>
//  final downloadurl =
//         await fireStoreService.uploadFileToStorage(pdfResponse.bodyBytes);


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
