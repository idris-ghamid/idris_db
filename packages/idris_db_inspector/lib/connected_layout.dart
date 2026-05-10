import 'dart:async';

import 'package:flutter/material.dart';
import 'package:idris_db/idris_db.dart';
import 'package:idris_db_inspector/collection/collection_area.dart';
import 'package:idris_db_inspector/connect_client.dart';
import 'package:idris_db_inspector/sidebar.dart';

class ConnectedLayout extends StatefulWidget {
  const ConnectedLayout({
    required this.client,
    required this.instances,
    super.key,
  });

  final ConnectClient client;
  final List<String> instances;

  @override
  State<ConnectedLayout> createState() => _ConnectedLayoutState();
}

class _ConnectedLayoutState extends State<ConnectedLayout> {
  late StreamSubscription<void> infoSubscription;

  String? selectedInstance;
  String? selectedCollection;
  final List<IdrisDbSchema> schemas = [];

  @override
  void initState() {
    _selectInstance(widget.instances.firstOrNull);
    infoSubscription = widget.client.collectionInfoChanged.listen((_) {
      setState(() {});
    });
    super.initState();
  }

  @override
  void didUpdateWidget(ConnectedLayout oldWidget) {
    if (!widget.instances.contains(selectedInstance)) {
      _selectInstance(widget.instances.firstOrNull);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    unawaited(infoSubscription.cancel());
    super.dispose();
  }

  void _selectInstance(String? instance) {
    if (instance == selectedInstance) {
      return;
    }

    selectedInstance = instance;
    selectedCollection = null;
    schemas.clear();

    if (instance != null) {
      unawaited(widget.client.watchInstance(instance));
      unawaited(
        widget.client.getSchemas(instance).then((newSchemas) {
          if (mounted && selectedInstance == instance) {
            setState(() {
              schemas.addAll(newSchemas);
              selectedCollection = schemas
                  .where((e) => !e.embedded)
                  .firstOrNull
                  ?.name;
            });
          }
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(25),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 320,
            child: Sidebar(
              instances: widget.instances,
              selectedInstance: selectedInstance,
              onInstanceSelected: (instance) {
                setState(() {
                  _selectInstance(instance);
                });
              },
              schemas: schemas,
              collectionInfo: widget.client.collectionInfo,
              selectedCollection: selectedCollection,
              onCollectionSelected: (collection) {
                setState(() {
                  selectedCollection = collection;
                });
              },
            ),
          ),
          const SizedBox(width: 25),
          if (selectedInstance != null && selectedCollection != null)
            Expanded(
              child: CollectionArea(
                key: Key('$selectedInstance.$selectedCollection'),
                instance: selectedInstance!,
                collection: selectedCollection!,
                client: widget.client,
                schemas: {for (final schema in schemas) schema.name: schema},
              ),
            ),
        ],
      ),
    );
  }
}
