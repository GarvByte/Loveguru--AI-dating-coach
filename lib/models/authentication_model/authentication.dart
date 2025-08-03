import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loveguru/config/theme/constants.dart';
import 'package:loveguru/models/supabaseProvider_model/supabase_provider_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Authentication extends Notifier<String> {
  @override
  String build() {
    final currentUser = supabase.auth.currentUser;
    return currentUser?.userMetadata?['nickname'] ?? '';
  }

  final supabase = Supabase.instance.client;

  Future<void> signUp(name) async {
    await supabase.auth.signUp(
      email: "$name@gmail.com",
      password: "nothing",
      data: {"nickname": name},
    );
    print("new user created successfully");
    state = name;
    currentUser = state;
    final uid = supabase.auth.currentUser!.id;
    await ref
        .read(supabaseprovider.notifier)
        .writeNicknameToDatabase(uid, state);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    state = "signed out";
    print("signed out successfully");
  }

  Future<void> signIn(name) async {
    await supabase.auth.signInWithPassword(
      email: "$name@gmail.com",
      password: "nothing",
    );
    state = name;
    currentUser = state;
    print("signed in successfully");
  }

  Future<bool> isRegistered(String nickname) async {
    try {
      final users = await supabase
          .from("users")
          .select('username')
          .order("created_at", ascending: true);

      final exists = users.any((user) => user["username"] == nickname);

      if (exists) {
        print("signing in");
        await signIn(nickname);
      } else {
        print("signing up");
        await signUp(nickname);
      }

      return true;
    } catch (e) {
      print("Auth failed: $e");
      return false;
    }
  }
}

final aunthenticationprovider = NotifierProvider<Authentication, String>(() {
  return Authentication();
});

  // Future<void> getUserData() async {
  //   try {
  //     final currentUserlocal = supabase.auth.currentUser;
  //     if (currentUserlocal == null) {
  //       print("user is null");
  //     } else {
  //       final uid = currentUserlocal.id;
  //       final nickname = currentUserlocal.userMetadata!['nickname'];

  //       await ref
  //           .read(supabaseprovider.notifier)
  //           .writeNicknameToDatabase(uid, nickname);
  //       // await supabaseprovider.writeNicknameToDatabase(uid, nickname);
  //       print("nickname = $nickname and uuid = $uid");
  //     }
  //   } catch (e) {
  //     print("error in getuserdata $e");
  //   }
  // }
