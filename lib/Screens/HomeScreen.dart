import 'package:cloud_chat/Authenticate/Methods.dart';
import 'package:cloud_chat/Screens/ChatRoom.dart';
import 'package:cloud_chat/components/chatCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
  bool isLoading = false;
  final TextEditingController _search = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
    setStatus("Online");
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1, String user2) {
    if (user1[0].toLowerCase().codeUnits[0] >
        user2.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void onSearch() async {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("name", isEqualTo: _search.text)
        .get()
        .then((value) {
      setState(() {
        userMap = value.docs[0].data();
        isLoading = false;
      });
      print(userMap);
    });
  }

  // Widget ChatRooms() {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: _firestore.collection('users').snapshots(),
  //     builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
  //       if (snapshot.data != null) {
  //         return ListView.builder(
  //           itemCount: snapshot.data!.docs.length,
  //           itemBuilder: (context, index) {
  //             Map<String, dynamic> map =
  //                 snapshot.data!.docs[index].data() as Map<String, dynamic>;
  //             return ChatCard(
  //               name: map['name'],
  //               profileImg: map['imgUrl'],
  //               email: map['email'],
  //               activeStatus: map['status'],
  //               onTap: () {
  //                 String roomId = chatRoomId(
  //                     _auth.currentUser!.displayName!, userMap!['name']);

  //                 Navigator.of(context).push(
  //                   MaterialPageRoute(
  //                     builder: (_) => ChatRoom(
  //                       chatRoomId: roomId,
  //                       userMap: userMap!,
  //                     ),
  //                   ),
  //                 );
  //               },
  //             );
  //           },
  //         );
  //       } else {
  //         return Container();
  //       }
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text("Cloud Chat"),
          actions: [
            IconButton(
                icon: Icon(Icons.logout), onPressed: () => logOut(context)),
          ],
        ),
        body: Column(
          children: [
            isLoading
                ? Center(
                    child: Container(
                      height: size.height / 20,
                      width: size.height / 20,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Container(
                    height: 70,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(1),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: kDefaultPadding * 0.75,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.greenAccent.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Row(
                              children: [
                                SizedBox(width: kDefaultPadding / 4),
                                Expanded(
                                  child: TextField(
                                    controller: _search,
                                    decoration: InputDecoration(
                                      hintText: "Search by name",
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                                SizedBox(width: kDefaultPadding / 4),
                                GestureDetector(
                                  onTap: () => onSearch(),
                                  child: Icon(
                                    Icons.search,
                                    size: 25,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color!
                                        .withOpacity(0.64),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
            userMap != null
                ? 
                 ChatCard(
                    name: userMap!['name'],
                    profileImg: userMap!['imgUrl'],
                    email: userMap!['email'],
                    activeStatus: userMap!['status'],
                    onTap: () {
                      String roomId = chatRoomId(
                          _auth.currentUser!.displayName!, userMap!['name']);

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChatRoom(
                            chatRoomId: roomId,
                            userMap: userMap!,
                          ),
                        ),
                      );
                    },
                  )
                : Container(),
          ],
        )

        // : Column(
        //     children: [
        //       SizedBox(
        //         height: size.height / 20,
        //       ),
        //       Container(
        //         height: size.height / 14,
        //         width: size.width,
        //         alignment: Alignment.center,
        //         child: Container(
        //           height: size.height / 14,
        //           width: size.width / 1.15,
        //           child: TextField(
        //             controller: _search,
        //             decoration: InputDecoration(
        //               hintText: "Search",
        //               border: OutlineInputBorder(
        //                 borderRadius: BorderRadius.circular(10),
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        //       SizedBox(
        //         height: size.height / 50,
        //       ),
        //       ElevatedButton(
        //         onPressed: onSearch,
        //         child: Text("Search"),
        //       ),
        //       SizedBox(
        //         height: size.height / 30,
        //       ),
        //       userMap != null
        //           ? ChatCard(
        //               name: userMap!['name'],
        //               profileImg: userMap!['imgUrl'],
        //               email: userMap!['email'],
        //               activeStatus: userMap!['status'],
        //               onTap: () {
        //                 String roomId = chatRoomId(
        //                     _auth.currentUser!.displayName!,
        //                     userMap!['name']);

        //                 Navigator.of(context).push(
        //                   MaterialPageRoute(
        //                     builder: (_) => ChatRoom(
        //                       chatRoomId: roomId,
        //                       userMap: userMap!,
        //                     ),
        //                   ),
        //                 );
        //               },
        //             )
        //           : Container(),
        //     ],
        //   ),
        );
  }
}
