import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../common/ui.dart';
import '../../../models/chat_model.dart';
import '../../../models/message_model.dart';
import '../../../models/user_model.dart';
import '../../../repositories/chat_repository.dart';
import '../../../repositories/notification_repository.dart';
import '../../../services/auth_service.dart';
import 'package:http/http.dart' as http;

class MessagesController extends GetxController {
  final uploading = false.obs;
  var message = Message([]).obs;
  ChatRepository _chatRepository;
  NotificationRepository _notificationRepository;
  AuthService _authService;
  var messages = <Message>[].obs;
  var chats = <Chat>[].obs;
  File imageFile;
  Rx<DocumentSnapshot> lastDocument = new Rx<DocumentSnapshot>(null);
  final isLoading = true.obs;
  final isDone = false.obs;
  ScrollController scrollController = ScrollController();
  final chatTextController = TextEditingController();

  MessagesController() {
    _chatRepository = new ChatRepository();
    _notificationRepository = new NotificationRepository();
    _authService = Get.find<AuthService>();
  }

  @override
  void onInit() async {
    // await createMessage(new Message([_authService.user.value], id: UniqueKey().toString(), name: 'Appliance Repair Company'));
    // await createMessage(new Message([_authService.user.value], id: UniqueKey().toString(), name: 'Shifting Home'));
    // await createMessage(new Message([_authService.user.value], id: UniqueKey().toString(), name: 'Pet Car Company'));
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          !isDone.value) {
        listenForMessages();
      }
    });
    await refreshMessages();
    super.onInit();
  }

  @override
  void onClose() {
    chatTextController.dispose();
  }

  Future createMessage(Message _message) async {
    _message.users.insert(0, _authService.user.value);
    _message.lastMessageTime = DateTime.now().millisecondsSinceEpoch;
    _message.readByUsers = [_authService.user.value.id];

    message.value = _message;

    _chatRepository.createMessage(_message).then((value) {
      listenForChats();
    });
  }

  Future refreshMessages() async {
    messages.clear();
    lastDocument = new Rx<DocumentSnapshot>(null);
    await listenForMessages();
  }

  Future listenForMessages() async {
    isLoading.value = true;
    isDone.value = false;
    Stream<QuerySnapshot> _userMessages;
    if (lastDocument.value == null) {
      _userMessages =
          _chatRepository.getUserMessages(_authService.user.value.id);
    } else {
      _userMessages = _chatRepository.getUserMessagesStartAt(
          _authService.user.value.id, lastDocument.value);
    }
    _userMessages.listen((QuerySnapshot query) {
      if (query.docs.isNotEmpty) {
        query.docs.forEach((element) {
          messages.add(Message.fromDocumentSnapshot(element));
        });
        lastDocument.value = query.docs.last;
      } else {
        isDone.value = true;
      }
      isLoading.value = false;
    });
  }

  listenForChats() async {
    message.value.readByUsers.add(_authService.user.value.id);
    _chatRepository.getChats(message.value).listen((event) {
      chats.assignAll(event);
    });
  }

  addMessage(Message _message, String text) {
    Chat _chat = new Chat(text, DateTime.now().millisecondsSinceEpoch,
        _authService.user.value.id, _authService.user.value);
    if (_message.id == null) {
      _message.id = UniqueKey().toString();
      createMessage(_message);
    }
    _message.lastMessage = text;
    _message.lastMessageTime = _chat.time;
    _message.readByUsers = [_authService.user.value.id];
    uploading.value = false;
    List<User> _users = [];
      _users.addAll(_message.users);

      var ids = [];
      for (var i = 0; i < _users.length; i++) {
        if ("${_users[i].id}" != "${_authService.user.value.id}")
        {
          ids.add("${_users[i].id}");
        }
      }
      print(ids);
      sendNotification2(ids,text);
    _chatRepository.addMessage(_message, _chat).then((value) {}).then((value) {
      List<User> _users = [];
      _users.addAll(_message.users);

      // var ids = [];
      // for (var i = 0; i < _users.length; i++) {
      //   ids.add("${_users[i].id}");
      // }
      // print(ids);
      // sendNotification2(ids,text);

      _users.removeWhere((element) => element.id == _authService.user.value.id);
      _notificationRepository.sendNotification(
          _users,
          _authService.user.value,
          "App\\Notifications\\NewMessage",
          text,
          _message.id,
          _authService.user.value.id);
    });
  }

  void sendNotification2(dynamic users,String txt) async {
    print("asdasdasd");
    var headers = {
      'Cookie':
          'XSRF-TOKEN=eyJpdiI6IjROdjF6aGFsc2M2RFlKYnJweHlSNEE9PSIsInZhbHVlIjoibXFoTXpQZytOTWpJa1k3aENVaFBUSE5Dc2d6S2dNSlRtVVRqVEZtK1N6YU1zckVSZzNTdGl1SmREbG9IMWpMd29NUjZoZkFmTzlsTTFwSU5CREh6ZStmazRsWUNZUW5rc1p3OFFvQmhXRTIwSUNnbHJRNzhrRCt6Zy9OdDBwMWMiLCJtYWMiOiJlNmMwODE1MzUzMzNmYWU0Y2ExZWNhZDhiZjNhNDVhNGRjMjMzNTM4OTg5MmM0MDVlMmJlYjg2MjNjYjJlZGFhIn0%3D; jhoice_session=eyJpdiI6ImxVNUlMbUtLb09vNDNWZTAzQnRUYUE9PSIsInZhbHVlIjoiSms5UkFaak10L1puV0t0OGdpTUNrUkYzbVBmZU1kUEtPa2xINTM1NSt3eHdUYUpyd2h6eXd4VzhtVFFFa2Yvc0pZMjUvUnRzSS9mSnVpa3J1Ui9PYmlPM0QwMDZqZXBVSWZWN3JFVVkwTE9wbWl2b2dnazAzZmFRUkRNZDdJYlIiLCJtYWMiOiJjOTRhNzcwNzNkNTQzNGUwM2UzZmZjN2M3MmUzMTA4Y2ZiODEyNmY1NzkzZGE1YTY1M2UwODUwMGVhZDhmYWUzIn0%3D'
    };
    var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            'https://jhoice.com/api/new_notify'));
    request.fields.addAll({
      'users': "${users}",
      'from': '198',
      'text': txt,
      'id': '123456'
    });
    print(request.fields);
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }

  Future getImage(ImageSource source) async {
    ImagePicker imagePicker = ImagePicker();
    XFile pickedFile;

    pickedFile = await imagePicker.pickImage(source: source);
    imageFile = File(pickedFile.path);

    if (imageFile != null) {
      try {
        uploading.value = true;
        return await _chatRepository.uploadFile(imageFile);
      } catch (e) {
        Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      }
    } else {
      Get.showSnackbar(
          Ui.ErrorSnackBar(message: "Please select an image file".tr));
    }
  }
}
