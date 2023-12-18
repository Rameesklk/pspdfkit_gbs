import 'dart:convert';
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pspdfkit_example/newscreen.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:pspdfkit_flutter/pspdfkit.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

final client = http.Client();

class PspdfkitInstantCollaborationExample extends StatefulWidget {
  const PspdfkitInstantCollaborationExample({Key? key}) : super(key: key);

  @override
  State<PspdfkitInstantCollaborationExample> createState() =>
      _PspdfkitInstantCollaborationExampleState();
}

class _PspdfkitInstantCollaborationExampleState
    extends State<PspdfkitInstantCollaborationExample> {
  double delayTime = 0.0;
  bool enableListenToServerChanges = true;
  bool enableComments = true;
  String publicJwt='eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudF9pZCI6IjdLVzE4NksxVDBLUzNQUkhXS1BBWTBBR1JHIiwicGVybWlzc2lvbnMiOlsicmVhZC1kb2N1bWVudCIsIndyaXRlIiwiZG93bmxvYWQiXSwiY29sbGFib3JhdGlvbl9wZXJtaXNzaW9ucyI6WyJhbm5vdGF0aW9uczp2aWV3Omdyb3VwPXB1YmxpYyIsImFubm90YXRpb25zOnZpZXc6c2VsZiIsImFubm90YXRpb25zOmVkaXQ6c2VsZiJdLCJ1c2VyX2lkIjoiam9zZXBoIiwiZGVmYXVsdF9ncm91cCI6InB1YmxpYyIsImlhdCI6MTY5OTI1MzQ4NSwiZXhwIjoxNjk5NTEyNjg1fQ.dk0ImqffuDiwS0KRrWoz4TdIhc5P3UdPhpIpE9kB6gkxh5eB87fjVCCDB9R8yfoGnFLfN8T8ANSAusyojkDUNIoLjMlK1PBTzc6j9Ashdg200HZ2THc3IjV3LbwCA5L5aqccVzZaEdL85gF4xv819RQd-WLpkoZw-hHE6ekh492GsMX2PphtzMr_8JLYmal_S0hrVlokeMbtqg7oB4aImZZFdflkGVmZl_rB8oGl-_piwGWTciCDTa03uYcJRMd60zsPLJydKgf_w-mWd9FTHUSRl3iVYlbx2qiI4Us4aJVyNw1xK04ol6nTawoQR0nRcCaXkcCvv9-yor2HsdbFIg';
  String privateJwt='eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJkb2N1bWVudF9pZCI6IjdLVzE4NksxVDBLUzNQUkhXS1BBWTBBR1JHIiwicGVybWlzc2lvbnMiOlsicmVhZC1kb2N1bWVudCIsIndyaXRlIiwiZG93bmxvYWQiXSwiY29sbGFib3JhdGlvbl9wZXJtaXNzaW9ucyI6WyJhbm5vdGF0aW9uczp2aWV3Omdyb3VwPXB1YmxpYyIsImFubm90YXRpb25zOnZpZXc6c2VsZiIsImFubm90YXRpb25zOmVkaXQ6c2VsZiJdLCJ1c2VyX2lkIjoiam9zZXBoIiwiaWF0IjoxNjk5MjUzNjYzLCJleHAiOjE2OTk1MTI4NjN9.eHN2ecMUYAcORxjJwlSszz5Eox67eWPrGl7C0uq9XzMU4s7iUZG42qeTeFFU8VEfoNVLCBnzdFnUy--VmcHiR08ClcbrmAAK1l1b4HijTZv9SLwIEpgxn9FHg3gNjAZ6WFxpySCmbqBZFAF0QsfJdpEkgY_0kCK3c3nqieM-Z671hboTHn6Ns46vuv5CXv-9V8dF6Mm57ESm2nI7Ru8EndKdUZR0A4YS2lt6AHGhwhxFZsbyxEL3N6sb-K89HXarjB3TyLuQhA4AluUwNeXkj6MWp_B3h6lSwgWfyk-9OD51FiFaDnGy70jg9q54X9NGKaSe9I_OTeXTWiFGA_yCsw';
  String serverUrl='http://172.30.10.33:5000/';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instant Synchronization'),
      ),
      body: Builder(builder: (scaffoldContext) {
        return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // RichText(
                  //     text: TextSpan(
                  //         text: 'Scan the QR code from  ',
                  //         style: const TextStyle(color: Colors.black),
                  //         children: [
                  //       TextSpan(
                  //         text: 'https://web-examples.pspdfkit.com',
                  //         style: const TextStyle(color: Colors.blue),
                  //         recognizer: TapGestureRecognizer()
                  //           ..onTap = () {
                  //             // Open the URL in the browser.
                  //             launchUrl(Uri.parse(
                  //                 'https://web-examples.pspdfkit.com'));
                  //           },
                  //       ),
                  //       const TextSpan(
                  //         text: ' > Collaborate in Real-time - ',
                  //         style: TextStyle(
                  //             color: Colors.black, fontWeight: FontWeight.bold),
                  //       ),
                  //       const TextSpan(
                  //         text:
                  //             'to connect to the document shown in your browser.',
                  //         style: TextStyle(color: Colors.black),
                  //       )
                  //     ])),
                  // const Padding(
                  //   padding: EdgeInsets.all(16.0),
                  // ),
                  // RichText(
                  //     text: TextSpan(
                  //         text: 'Copy the collaboration URL from ',
                  //         style: const TextStyle(color: Colors.black),
                  //         children: [
                  //       TextSpan(
                  //         text: 'https://web-examples.pspdfkit.com',
                  //         style: const TextStyle(color: Colors.blue),
                  //         recognizer: TapGestureRecognizer()
                  //           ..onTap = () {
                  //             // Open the URL in the browser.
                  //             launchUrl(Uri.parse(
                  //                 'https://web-examples.pspdfkit.com'));
                  //           },
                  //       ),
                  //       const TextSpan(
                  //         text: ' > Collaborate in Real-time - ',
                  //         style: TextStyle(
                  //             color: Colors.black, fontWeight: FontWeight.bold),
                  //       ),
                  //       const TextSpan(
                  //         text:
                  //             'to connect to the document shown in your browser.',
                  //         style: TextStyle(color: Colors.black),
                  //       )
                  //     ])),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                                      _loadPublicDocument();

                      },
                      child: const Text('Public Document'),
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                                      _loadPrivateDocument(context);

                      },
                      child: const Text('Private Document'),
                    ),
                  ),
                  // Delay for syncing local changes
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Row(
                    children: [
                      const Text('Delay for syncing local changes: '),
                      SizedBox(
                        width: 100,
                        child: TextField(
                          onChanged: (String value) {
                            // Update the state of the app.
                            // ...
                            delayTime = double.parse(value);
                          },
                          decoration: const InputDecoration(
                              hintText: 'Delay time in seconds'),
                        ),
                      ),
                    ],
                  ),
                  // Listen to server changes
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Row(
                    children: [
                      const Text('Listen to server changes: '),
                      Checkbox(
                        value: enableListenToServerChanges,
                        onChanged: (bool? value) {
                          setState(() {
                            enableListenToServerChanges = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  // Enable comments
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                  ),
                  Row(
                    children: [
                      const Text('Enable comments: '),
                      Checkbox(
                        value: enableComments,
                        onChanged: (bool? value) {
                          setState(() {
                            enableComments = value!;
                          });
                        },
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.all(16.0),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        _loadDocumentJson(
                            context, '$serverUrl/api/documents');
                      },
                      child: const Text('Load Instant Layers')),
                ],
              ),
            ));
      }),
    );
  }


  String bytesToString(List<int> bytes) {
    return String.fromCharCodes(bytes);
  }
  Future<void> _loadPublicDocument() async {
    String token;
     {
      final jwt = JWT(
        {
          "document_id": "7NR7KBR15VBR6T4XST6HWXZ47Y",
          "permissions": ["read-document", "write", "download"],
          "collaboration_permissions": [

            "annotations:set-group:group=public",
            "annotations:view:self",
            "annotations:view:group=public",
            "annotations:edit:self",
            "annotations:delete:self",
            "comments:view:group=public",
            "comments:view:self",
            "comments:edit:self",
            "comments:delete:self",
            "comments:reply:all",
            "comments:set-group:group=public",
            "form-fields:view:all",
            "form-fields:fill:all"

          ],
          "user_id": "raman",
          "default_group": "public",
        },

      );

      // Sign it
      final ByteData data = await rootBundle.load('assets/rsa.pem');
      final List<int> bytes = data.buffer.asUint8List();
      final String pem = bytesToString(bytes);
      final key = RSAPrivateKey(pem);

      token = jwt.sign(key, algorithm: JWTAlgorithm.RS256,expiresIn: Duration(days: 1));

     }
    print('Signed token: $token\n');

    Future.delayed(const Duration(seconds: 1), () async {
      await Pspdfkit.presentInstant(serverUrl, token, {
        enableInstantComments: enableComments,
      },);
    });
  }
  Future<void> _loadPrivateDocument(BuildContext context) async {
    String token;


    /* Sign */ {
      // Create a json web token
      final jwt = JWT(
        {
          "document_id": "7NR7KBR15VBR6T4XST6HWXZ47Y",
          "permissions": ["read-document", "write", "download",],
          "collaboration_permissions": [
            "annotations:view:self",
            "annotations:view:group=public",
            "annotations:edit:self",
            "annotations:delete:self",
            "comments:view:group=public",
            "comments:view:self",
            "comments:edit:self",
            "comments:delete:self",
            "comments:reply:all",
            "form-fields:view:all",
            "form-fields:fill:all"
          ],
          "user_id": "raman",
        },

      );

      // Sign it
      final ByteData data = await rootBundle.load('assets/rsa.pem');
      final List<int> bytes = data.buffer.asUint8List();
      final String pem = bytesToString(bytes);
      final key = RSAPrivateKey(pem);

      token = jwt.sign(key, algorithm: JWTAlgorithm.RS256,expiresIn: Duration(days: 1));

      print('Signed token: $token\n');
    }
    Future.delayed(const Duration(seconds: 1), () async {
      try {
        await Pspdfkit.presentInstant(serverUrl, token, {
          enableInstantComments: enableComments,
        },).onError((error, stackTrace){
          print("error");
          return null;
        });
      } on Exception catch (e) {
        print("catch");
      }
    });
  }

  /// Fetches the document from the instant demo server.
  /// The server returns a JWT token that is used to authenticate the user.
  Future<void> _loadDocumentJson(BuildContext context, String? url) async {
    if (url != null) {
      // showDialog<dynamic>(
      //     context: context,
      //     barrierDismissible: false,
      //     builder: (BuildContext context) {
      //       return const Center(
      //         child: CircularProgressIndicator(),
      //       );
      //     });
      String privateToken;
      String publicToken;


      /* Sign */ {
        // Create a json web token
        {
          final jwt = JWT(
            {
              "document_id": "7NR7KBR15VBR6T4XST6HWXZ47Y",
              "permissions": ["read-document", "write", "download"],
              "collaboration_permissions": [

                "annotations:set-group:group=public",
                "annotations:view:self",
                "annotations:view:group=public",
                "annotations:edit:self",
                "annotations:delete:self",
                "comments:view:group=public",
                "comments:view:self",
                "comments:edit:self",
                "comments:delete:self",
                "comments:reply:all",
                "comments:set-group:group=public",
                "form-fields:view:all",
                "form-fields:fill:all"

              ],
              "user_id": "raman",
              "default_group": "public",
            },

          );

          // Sign it
          final ByteData data = await rootBundle.load('assets/rsa.pem');
          final List<int> bytes = data.buffer.asUint8List();
          final String pem = bytesToString(bytes);
          final key = RSAPrivateKey(pem);

          publicToken = jwt.sign(key, algorithm: JWTAlgorithm.RS256,expiresIn: Duration(days: 1));

        }
        final jwt = JWT(
          {
            "document_id": "7NR7KBR15VBR6T4XST6HWXZ47Y",
            "permissions": ["read-document", "write", "download",],
            "collaboration_permissions": [
              "annotations:view:self",
              "annotations:view:group=public",
              "annotations:edit:self",
              "annotations:delete:self",
              "comments:view:group=public",
              "comments:view:self",
              "comments:edit:self",
              "comments:delete:self",
              "comments:reply:all",
              "form-fields:view:all",
              "form-fields:fill:all"
            ],
            "user_id": "raman",
          },

        );

        // Sign it
        final ByteData data = await rootBundle.load('assets/rsa.pem');
        final List<int> bytes = data.buffer.asUint8List();
        final String pem = bytesToString(bytes);
        final key = RSAPrivateKey(pem);

        privateToken = jwt.sign(key, algorithm: JWTAlgorithm.RS256,expiresIn: Duration(days: 1));

        // print('Signed token: $token\n');
      }
      // _getDocumentJson(url).then((data) async {

        // var doc = data['documents'][0] as Map<String, dynamic>;
        // var tokes = doc['tokens'] as List<String>;
        // var layers = doc['layers'] as List<String>;
        await Pspdfkit.presentInstant(
          serverUrl,
          publicToken,

          {
            enableInstantComments: enableComments,
          },

          [publicToken,privateToken],
          ["Public","Private"],
        );
        await Pspdfkit.setDelayForSyncingLocalChanges(delayTime);
        await Pspdfkit.setListenToServerChanges(enableListenToServerChanges);
      // }).catchError((dynamic onError) {
      //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //     content: Text(onError.toString()),
      //   ));
      //   Navigator.of(context).pop();
      // });
    } else {
      if (kDebugMode) {
        print('No URL');
      }
    }
  }
  Future<Map<String, dynamic>> _getDocumentJson(String url) async {
    // The header is necessary to receive valid json response.
    try {
      print("Authorisation: "+'Basic ${base64.encode(utf8.encode('cato:secret'))}');
      http.Response response = await client.get(Uri.parse(url), headers: {
        'Authorization': 'Basic ${base64.encode(utf8.encode('cato:secret'))}'
      });
print("resopnse: "+response.body);
      final data = json.decode(response.body) as Map<String, dynamic>;
      return data;
    } catch (e) {
      print("error: "+e.toString());

      print(e);
      rethrow;
    }
  }
  Future<InstantDocumentDescriptor> _getDocument(String url) async {
    // The header is necessary to receive valid json response.
    http.Response response = await client.get(Uri.parse(url),
        headers: {'Accept': 'application/vnd.instant-example+json'});
    final data = json.decode(response.body) as Map<String, dynamic>;
    print("response.body:     "+response.body);
    final document = InstantDocumentDescriptor.fromJson(data);
    return document;
  }
}

class InstantBarcodeScanner extends StatefulWidget {
  const InstantBarcodeScanner({Key? key}) : super(key: key);

  @override
  State<InstantBarcodeScanner> createState() => _InstantBarcodeScannerState();
}

class _InstantBarcodeScannerState extends State<InstantBarcodeScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    try {
      if (Platform.isAndroid) {
        controller?.resumeCamera();
      } else if (Platform.isIOS) {
        controller?.resumeCamera();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: RichText(
                  text: TextSpan(
                      text: 'Scan the QR code from ',
                      style: const TextStyle(color: Colors.black),
                      children: [
                    TextSpan(
                      text: 'pspdfkit.com/instant/try',
                      style: const TextStyle(color: Colors.blue),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          // Open the URL in the browser.
                          launchUrl(
                              Uri.parse('https://pspdfkit.com/instant/try'));
                        },
                    ),
                    const TextSpan(
                      text:
                          ' to connect to the document shown in your browser.',
                      style: TextStyle(color: Colors.black),
                    )
                  ])),
            )),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    var counter = 0;
    controller.scannedDataStream.listen((scanData) {
      // Show the document in PSPDFKit.
      if (counter == 0) {
        counter++;
        Navigator.pop(context, scanData.code);
      }
    });
    try {
      controller.resumeCamera();
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class InstantDocumentDescriptor {
  final String serverUrl;
  final String documentId;
  final String jwt;
  final String documentCode;
  final String webUrl;

  InstantDocumentDescriptor(this.serverUrl, this.documentId, this.jwt,
      this.documentCode, this.webUrl);

  // From json
  factory InstantDocumentDescriptor.fromJson(Map<String, dynamic> json) {
    return InstantDocumentDescriptor(
      json['serverUrl'] as String,
      json['documentId'] as String,
      json['jwt'] as String,
      json['encodedDocumentId'] as String,
      json['url'] as String,
    );
  }
}
