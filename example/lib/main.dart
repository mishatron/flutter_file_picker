import 'package:flutter/material.dart';
import 'package:flutter_file_picker/flutter_document_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _path = '-';
  bool _pickFileInProgress = false;
  bool _iosPublicDataUTI = true;
  bool _checkByCustomExtension = false;
  bool _checkByMimeType = false;

  final _utiController = TextEditingController(
    text: 'com.sidlatau.example.mwfbak',
  );

  final _extensionController = TextEditingController(
    text: 'mwfbak',
  );

  final _mimeTypeController = TextEditingController(
    text: 'application/pdf image/png',
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.open_in_new),
              onPressed: _pickFileInProgress ? null : _pickDocument,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Picked file path:',
                  style: Theme.of(context).textTheme.title,
                ),
                Text('$_path'),
                _pickFileInProgress ? CircularProgressIndicator() : Container(),
                _buildCommonParams(),
                Theme.of(context).platform == TargetPlatform.iOS
                    ? _buildIOSParams()
                    : _buildAndroidParams(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _pickDocument() async {
    String result;
    try {
      setState(() {
        _path = '-';
        _pickFileInProgress = true;
      });

      FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
        allowedFileExtensions: _checkByCustomExtension
            ? _extensionController.text
                .split(' ')
                .where((x) => x.isNotEmpty)
                .toList()
            : null,
        allowedUtiTypes: _iosPublicDataUTI
            ? null
            : _utiController.text
                .split(' ')
                .where((x) => x.isNotEmpty)
                .toList(),
        allowedMimeTypes: _checkByMimeType
            ? _mimeTypeController.text
                .split(' ')
                .where((x) => x.isNotEmpty)
                .toList()
            : null,
      );

      result = await FlutterDocumentPicker.openDocument(params: params);
    } catch (e) {
      print(e);
      result = 'Error: $e';
    } finally {
      setState(() {
        _pickFileInProgress = false;
      });
    }

    setState(() {
      _path = result;
    });
  }

  _buildIOSParams() {
    return ParamsCard(
      title: 'iOS Params',
      children: <Widget>[
        Text(
          'Example app is configured to pick custom document type with extension ".mwfbak"',
          style: Theme.of(context).textTheme.body1,
        ),
        Param(
          isEnabled: !_iosPublicDataUTI,
          description:
              'Allow pick all documents("public.data" UTI will be used).',
          controller: _utiController,
          onEnabledChanged: (value) {
            setState(() {
              _iosPublicDataUTI = value;
            });
          },
          textLabel: 'Uniform Type Identifier to pick:',
        ),
      ],
    );
  }

  _buildAndroidParams() {
    return ParamsCard(
      title: 'Android Params',
      children: <Widget>[
        Param(
          isEnabled: _checkByMimeType,
          description: 'Filter files by MIME type',
          controller: _mimeTypeController,
          onEnabledChanged: (value) {
            setState(() {
              _checkByMimeType = value;
            });
          },
          textLabel: 'Allowed MIME types (separated by space):',
        ),
      ],
    );
  }

  _buildCommonParams() {
    return ParamsCard(
      title: 'Common Params',
      children: <Widget>[
        Param(
          isEnabled: _checkByCustomExtension,
          description:
              'Check file by extension - if picked file does not have wantent extension - return "extension_mismatch" error',
          controller: _extensionController,
          onEnabledChanged: (value) {
            setState(() {
              _checkByCustomExtension = value;
            });
          },
          textLabel: 'File extensions (separated by space):',
        ),
      ],
    );
  }
}

class Param extends StatelessWidget {
  final bool isEnabled;
  final ValueChanged<bool> onEnabledChanged;
  final TextEditingController controller;
  final String description;
  final String textLabel;

  Param({
    @required this.isEnabled,
    this.onEnabledChanged,
    this.controller,
    this.description,
    this.textLabel,
  })  : assert(isEnabled != null),
        assert(onEnabledChanged != null),
        assert(description != null),
        assert(textLabel != null),
        assert(controller != null);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  description,
                  softWrap: true,
                ),
              ),
            ),
            Checkbox(
              value: isEnabled,
              onChanged: onEnabledChanged,
            ),
          ],
        ),
        TextField(
          controller: controller,
          enabled: isEnabled,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: textLabel,
          ),
        ),
      ],
    );
  }
}

class ParamsCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  ParamsCard({
    @required this.title,
    @required this.children,
  })  : assert(title != null),
        assert(children != null);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headline,
                ),
              ),
            ]..addAll(children),
          ),
        ),
      ),
    );
  }
}
