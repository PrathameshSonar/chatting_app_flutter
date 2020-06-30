import 'package:chatapp/helper/constants.dart';
import 'package:chatapp/helper/helperfunctions.dart';
import 'package:chatapp/services/database.dart';
import 'package:chatapp/views/conversation_screen.dart';
import 'package:chatapp/widgets/widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

String _myName;

class _SearchScreenState extends State<SearchScreen> {
  DatabaseMethods databaseMethods = new DatabaseMethods();
  TextEditingController searchTextEditingController =
      new TextEditingController();

  QuerySnapshot searchSnapshot;


  Widget searchList() {
    return searchSnapshot != null
        ? ListView.builder(
      itemCount: searchSnapshot.documents.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return SearchTile(
          userName: searchSnapshot.documents[index].data['name'],
          userEmail: searchSnapshot.documents[index].data['email'],
        );
      },
    )
        : Container();
  }


  initiateSearch() {
    databaseMethods
        .getUserByUserName(searchTextEditingController.text)
        .then((val) {
      setState(() {
        searchSnapshot = val;
      });
    });
  }

  ///create chatroom, send user to conversation screen, push replacement

  createChatRoomAndStartConversation({String userName}){
    print('${Constants.myName} + createChatRoom');
    if(userName != Constants.myName) {
      String chatRoomId = getChatRoomId(userName, Constants.myName);
      List<String> users = [userName, Constants.myName];
      Map<String, dynamic> chatRoomMap = {
        'users' : users,
        'chatroomId' : chatRoomId,
      };
      DatabaseMethods().createChatRoom(chatRoomId, chatRoomMap);
      Navigator.push(context, MaterialPageRoute(
          builder: (context) => ConversationScreen()
      ));
    } else {
      print('You can not send msg to yourself');
    }
  }

  Widget SearchTile({String userName, String userEmail}){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16 ),
      child: Row(
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                userName,
                style: mediumTextStyle(),
              ),
              Text(
                userEmail,
                style: mediumTextStyle(),
              ),
            ],
          ),
          Spacer(),
          GestureDetector(
            onTap: (){
              createChatRoomAndStartConversation(
                userName: userName,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Message', style: mediumTextStyle(),),
            ),
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    getUserInfo();
    super.initState();
  }

  getUserInfo() async {
    _myName = await HelperFunctions.getUserNameSharedPreference();
    setState(() {

    });
    print(_myName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarMain(context),
      body: Container(
        child: Column(
          children: <Widget>[
            Container(
              color: Color(0x54FFFFFF),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: searchTextEditingController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search username...',
                        hintStyle: TextStyle(
                          color: Colors.white54,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      initiateSearch();
                    },
                    child: Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0x36FFFFFF),
                              const Color(0x0FFFFFFF),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(40),
                        ),
                        padding: EdgeInsets.all(12),
                        child: Image.asset('assets/images/search_white.png')),
                  ),
                ],
              ),
            ),
            searchList(),
          ],
        ),
      ),
    );
  }
}


getChatRoomId(String a, String b){
  if(a.substring(0,1).codeUnitAt(0) > b.substring(0, 1).codeUnitAt(0)) {
    return '$b\_$a';
  } else {
    return '$a\_$b';
  }

}