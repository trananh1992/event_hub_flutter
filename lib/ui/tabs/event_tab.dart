import 'package:events_flutter/ui/tiles/event_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../blocs/global_provider.dart';
import '../../blocs/global_bloc.dart';

class EventTab extends StatelessWidget {
  static const int batchSize = 3;
  static bool moreAvailable = true;
  @override
  Widget build(BuildContext context) {
    final GlobalBloc globalBloc = GlobalProvider.of(context);
    return PagewiseListView(
      padding: EdgeInsets.all(8.0),
      pageSize: batchSize,
      pageFuture: (pageIndex) {
        return Future<List<DocumentSnapshot>>(() async {
          if (globalBloc.eventList.length <= pageIndex * batchSize) {
            if (!moreAvailable) return List<DocumentSnapshot>();
            print('fetching...');
            DocumentSnapshot last;
            if (globalBloc.eventList.length > 0)
              last = globalBloc.eventList.last;
            //fetch
            QuerySnapshot snapshot = await Firestore.instance
                .collection('events')
                .orderBy('date')
                .startAfter([last == null ? null : last['date']])
                .limit(batchSize)
                .getDocuments();
            //store it to list
            if (snapshot.documents.length < batchSize) moreAvailable = false;
            globalBloc.eventList.addAll(snapshot.documents);
            print(snapshot.documents.length);
            return snapshot.documents;
          } else {
            print('from list');
            //show from stored list
            int end = pageIndex * batchSize + batchSize;
            if (globalBloc.eventList.length < end)
              end = globalBloc.eventList.length;
            return globalBloc.eventList
                .getRange(pageIndex * batchSize, end)
                .toList();
          }
        });
      },
      itemBuilder: (context, entry, i) {
        return EventListTile(
          id: entry.documentID,
          name: entry['name'],
          date: entry['date'],
          url: entry['image'],
        );
      },
    );
  }
}