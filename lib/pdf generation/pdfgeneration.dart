import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;

class PDFGeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Generator'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            generateAndOpenPDF(context);
          },
          child: Text('Generate PDF'),
        ),
      ),
    );
  }

  Future<void> generateAndOpenPDF(BuildContext context) async {
    try {
      final pdf = pw.Document();

      final ByteData logoImageData1 =
          await rootBundle.load('assets/TPS RGB.png');
      final ByteData logoImageData2 =
          await rootBundle.load('assets/Tactik.jpeg');
      final Uint8List logoImageBytes1 = logoImageData1.buffer.asUint8List();
      final Uint8List logoImageBytes2 = logoImageData2.buffer.asUint8List();
      final logo1 = pw.MemoryImage(logoImageBytes1);
      final logo2 = pw.MemoryImage(logoImageBytes2);

      final List<Map<String, dynamic>> patrolEntries = [
        {
          'timeIn': '21:00',
          'timeOut': '21:14',
          'comment': 'There was no QR code scanner on Level 6 right side'
        },
        {
          'timeIn': '23:00',
          'timeOut': '23:12',
          'comment': 'There was no QR code scanner on Level 6 right side'
        },
      ];

      final List<Map<String, dynamic>> detailedPatrolReport = [
        {
          'patrol': 'Patrol 1',
          'checkpointName': 'Checkpoint Name 1',
          'time': '21:00',
          'comment': 'Comment 1',
          'image': 'https://i.postimg.cc/50SkMkJC/os.png',
        },
        {
          'patrol': 'Patrol 1',
          'checkpointName': 'Checkpoint Name 2',
          'time': '21:05',
          'comment': 'Comment 2',
          'image': 'https://i.postimg.cc/50SkMkJC/os.png',
        },
        {
          'patrol': 'Patrol 1',
          'checkpointName': 'Checkpoint Name 2',
          'time': '21:05',
          'comment': 'Comment 2',
          'image': 'https://i.postimg.cc/50SkMkJC/os.png',
        },
        {
          'patrol': 'Patrol 1',
          'checkpointName': 'Checkpoint Name 2',
          'time': '21:05',
          'comment': 'Comment 2',
          'image': 'https://i.postimg.cc/50SkMkJC/os.png',
        },
        {
          'patrol': 'Patrol 1',
          'checkpointName': 'Checkpoint Name 2',
          'time': '21:05',
          'comment': 'Comment 2',
          'image': 'https://i.postimg.cc/50SkMkJC/os.png',
        },
      ];

      final List<pw.MemoryImage> images = [];
      for (var entry in detailedPatrolReport) {
        final response = await http.get(Uri.parse(entry['image']));
        if (response.statusCode == 200) {
          final Uint8List imageBytes = response.bodyBytes;
          images.add(pw.MemoryImage(imageBytes));
        }
      }

      pdf.addPage(
        pw.MultiPage(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            buildBackground: (context) => pw.FullPage(
              ignoreMargins: true,
              child: pw.Stack(
                children: [
                  pw.Positioned(
                    left: 0,
                    top: 0,
                    child: pw.Image(logo1, width: 150, height: 150),
                  ),
                  pw.Positioned(
                    right: 10,
                    top: 15,
                    child: pw.Image(logo2, width: 100, height: 90),
                  ),
                ],
              ),
            ),
          ),
          build: (context) => [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'SHIFT/PATROL REPORT',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 50),
                pw.Text(
                  'Dear ARMA WELLER,\n\nI hope this email finds you well. I wanted to provide you with an update on the recent patrol activities carried out by our assigned security guard during their shift. Below is a detailed breakdown of the patrols conducted:',
                  style: pw.TextStyle(
                    fontSize: 14,
                  ),
                ),
                pw.SizedBox(height: 40),
                pw.Text(
                  '** Shift Information:**',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black,
                      width: 2,
                    ),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Table(
                    border: null,
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                        ),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Guard Name',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Shift Time In',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Shift Time Out',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Date',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('Sukhman Kooner'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('20:00'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('06:00'),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text('April 17, 2024 - April 18, 2024'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '** Patrol Information:**',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black,
                      width: 2,
                    ),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Table(
                    border: null,
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                        ),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Patrol Count',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Patrol Time In ',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Patrol Time Out',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Comments',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (var i = 0; i < patrolEntries.length; i++)
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text((i + 1).toString()),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child:
                                  pw.Text(patrolEntries[i]['timeIn'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  patrolEntries[i]['timeOut'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  patrolEntries[i]['comment'] as String),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  '** Detailed Patrol Report:**',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(
                      color: PdfColors.black,
                      width: 2,
                    ),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Table(
                    border: null,
                    children: [
                      pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: PdfColors.blue100,
                        ),
                        children: [
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Patrol',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Checkpoint Name',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Time',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Comment',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                          pw.Padding(
                            padding: pw.EdgeInsets.all(8),
                            child: pw.Text(
                              'Image',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      for (var i = 0; i < detailedPatrolReport.length; i++)
                        pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  detailedPatrolReport[i]['patrol'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(detailedPatrolReport[i]
                                  ['checkpointName'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  detailedPatrolReport[i]['time'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(
                                  detailedPatrolReport[i]['comment'] as String),
                            ),
                            pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child:
                                  pw.Image(images[i], width: 100, height: 100),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      final output = await getExternalStorageDirectory();
      if (output != null) {
        final downloadsDirectory = Directory('${output.path}/Download');
        await downloadsDirectory.create(recursive: true);
        final file = File('${downloadsDirectory.path}/shift_patrol_report.pdf');
        final Uint8List pdfBytes = await pdf.save();
        await file.writeAsBytes(pdfBytes);
        print('PDF Generated');
        print('PDF Generated at: ${file.path}');
        // Open the PDF file
        OpenFile.open(file.path);
      } else {
        print('Error: Unable to get external storage directory.');
      }
    } catch (e) {
      print('Error generating PDF: $e');
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: PDFGeneratorPage(),
  ));
}
