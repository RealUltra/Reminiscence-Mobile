import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';
import 'package:reminiscence/features/data_storage/file_opened.dart';

import 'package:reminiscence/features/database/dtos/chat_dto.dart';
import 'package:reminiscence/ui/components/info_box.dart';
import 'package:reminiscence/ui/components/selection_controller.dart';
import 'package:reminiscence/ui/pages/data_viewer/navigation_bar.dart';
import 'package:reminiscence/ui/components/value_controller.dart';
import 'package:reminiscence/ui/providers/session_data.dart';

import 'package:reminiscence/ui/pages/data_viewer/chats_list/app_bar.dart'
    as chats_list_page;
import 'package:reminiscence/ui/pages/data_viewer/chats_list/body.dart'
    as chats_list_page;

import 'package:reminiscence/ui/pages/chat/app_bar.dart' as chat_page;
import 'package:reminiscence/ui/pages/chat/body.dart' as chat_page;

import 'package:reminiscence/ui/pages/settings/app_bar.dart' as settings_page;
import 'package:reminiscence/ui/pages/settings/body.dart' as settings_page;

const privacyAlert = "A .rem file has been created using your instagram data. Please delete the zip file containing your instagram data as it poses security risks.";

class DataViewerPage extends StatefulWidget {
  const DataViewerPage({super.key});

  @override
  State<DataViewerPage> createState() => _DataViewerPageState();
}

class _DataViewerPageState extends State<DataViewerPage> {
  bool chatsListReady = false;

  final pageController = SelectionController<int>(0);
  final jumpController = ValueController<String?>(null);

  late final List<PreferredSizeWidget> appBars;
  late final List<Widget> bodies;

  ChatDto? currentChat;

  @override
  void initState() {
    super.initState();

    pageController.addListener(() => pageChanged());
    jumpController.addListener(() => jumpToMessage());

    appBars = [
      chats_list_page.MyAppBar(),
      chat_page.MyAppBar(jumpController: jumpController),
      settings_page.MyAppBar(),
    ];

    bodies = [chats_list_page.Body(), chat_page.Body(), settings_page.Body()];

    initChats();
  }

  Future<void> initChats() async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    await sessionData.loadChats();
    setState(() => chatsListReady = true);
    
    await sendPrivacyAlert();
  }

  Future<void> initMessages() async {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final chat = sessionData.chat!;
    final messageReader = sessionData.messageReader;

    if (messageReader == null || messageReader.chat.id != chat.id) {
      await sessionData.loadMessageReader();
      setState(() {});
    }
  }

  Future<void> sendPrivacyAlert() async {
    // Get the filename of the loaded file.
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final filePath = sessionData.data!.file.name;
    final filename = p.basename(filePath);

    // Check if the file has been opened before.
    final opened = await hasBeenOpened(filename);

    // If this isn't the first time the file is being opened, don't send the privacy alert.
    if (opened) return;

    // Mark the file as opened.
    await markAsOpened(filename);

    // Make sure the context is still mounted.
    if (!mounted) return;

    // Show the privacy alert.
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return InfoBox(title: "Privacy Alert", body: privacyAlert);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!chatsListReady) {
      return Scaffold();
    }

    final pageIndex = pageController.selected;

    return MultiProvider(
      providers: [
        Provider<SelectionController<int>>.value(value: pageController),
        Provider<String?>.value(value: jumpController.value),
        Provider<bool>.value(value: false),
      ],

      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) => goBack(context, didPop),

        child: Scaffold(
          appBar: appBars[pageIndex],

          body: IndexedStack(index: pageIndex, children: bodies),

          bottomNavigationBar: MyNavigationBar(
            pageController: pageController,
            messagesEnabled: currentChat != null,
          ),
        ),
      ),
    );
  }

  Future<void> goBack(BuildContext context, bool didPop) async {
    if (didPop) {
      return;
    }

    final currentPage = pageController.selected;

    // If you are on the chat page or settings page, go to the main page.
    if (currentPage != 0) {
      pageController.selected = 0;
      return;
    }

    // Go back to the data loader
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final data = sessionData.data!;

    final mustPop = await showConfirmExitDialog(context);

    if (!mustPop || !context.mounted) {
      return;
    }

    data.close();

    Navigator.of(context).pop();
  }

  void jumpToMessage() {
    if (jumpController.value == null) {
      return;
    }

    setState(() {
      bodies[1] = chat_page.Body(key: UniqueKey());
    });
  }

  void pageChanged() {
    final sessionData = Provider.of<SessionData>(context, listen: false);
    final pageIndex = pageController.selected;

    if (sessionData.chat != currentChat && pageIndex == 1) {
      currentChat = sessionData.chat;
      jumpController.setValueQuietly(null);
      bodies[1] = chat_page.Body(key: UniqueKey());
      initMessages();
    }

    setState(() {});
  }

  Future<bool> showConfirmExitDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,

          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Exit?'),
              content: Text('Are you sure you want to exit?'),

              actions: <Widget>[
                TextButton(
                  child: Text('No'),
                  onPressed: () => Navigator.of(context).pop(false),
                ),

                TextButton(
                  child: Text('Yes'),
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
