import 'package:flutter/material.dart';
import 'package:reminiscence/features/data_loader/data_archive_loader/utils.dart';

class ViewReactionsWidget extends StatefulWidget {
  final List<Map<String, dynamic>> tabs;

  const ViewReactionsWidget(this.tabs, {super.key});

  @override
  State<ViewReactionsWidget> createState() => _ViewReactionsWidgetState();

  static ViewReactionsWidget fromData(List<dynamic> reactions) {
    final tabs = ViewReactionsWidget.getReactionsInfo(reactions);
    return ViewReactionsWidget(tabs);
  }

  static List<Map<String, dynamic>> getReactionsInfo(List<dynamic> reactions) {
    List<Map<String, dynamic>> reactionsInfo = [];
    Map<String, int> reactionIndexes = {};

    for (Map<String, dynamic> reaction in reactions) {
      String reactionEmoji = decodeData(reaction["reaction"]);
      String reactorName = decodeData(reaction["actor"]);

      if (!reactionIndexes.containsKey(reactionEmoji)) {
        reactionIndexes[reactionEmoji] = reactionsInfo.length;
        reactionsInfo.add({"emoji": reactionEmoji, "actors": []});
      }

      int i = reactionIndexes[reactionEmoji]!;
      reactionsInfo[i]["actors"].add(reactorName);
    }

    return reactionsInfo;
  }
}

class _ViewReactionsWidgetState extends State<ViewReactionsWidget> {
  ScrollController controller = ScrollController();
  int selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      height: 400,
      child: Row(
        children: [
          // Column of emojis (left side)
          Container(
            color: Theme.of(context).colorScheme.surfaceContainer,
            width: 80,
            child: ListView.builder(
              itemCount: widget.tabs.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedTab = index;
                      controller.jumpTo(0.0);
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    color:
                        selectedTab == index
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.transparent,
                    child: Text(
                      "${widget.tabs[index]['emoji']}  ${widget.tabs[index]['actors'].length}",
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                );
              },
            ),
          ),

          // Content for the selected tab (right side)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 0.0,
                horizontal: 16.0,
              ),
              child:
                  widget.tabs.isEmpty
                      ? Text(
                        textAlign: TextAlign.center,
                        "No reactions here",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      )
                      : ListView.separated(
                        controller: controller,
                        itemCount: widget.tabs[selectedTab]['actors'].length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                              textAlign: TextAlign.center,
                              widget.tabs[selectedTab]['actors'][index],
                              style: Theme.of(context).textTheme.bodyMedium!
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(height: 0.0);
                        },
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
