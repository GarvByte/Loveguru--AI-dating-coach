import 'package:flutter/material.dart';
import 'package:loveguru/config/theme/app_colors.dart';
import 'package:loveguru/config/theme/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loveguru/models/authentication_model/authentication.dart';

class AuthenticationPage extends ConsumerStatefulWidget {
  const AuthenticationPage({super.key});

  @override
  ConsumerState<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends ConsumerState<AuthenticationPage> {
  @override
  Widget build(BuildContext context) {
    TextEditingController loginController = TextEditingController();
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.surface, AppColors.background],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                "Welcome, Lets quickly get you a nickname.",
                textAlign: TextAlign.left,
                style: TextStyle(color: AppColors.text, fontSize: 30),
              ),
            ),

            SizedBox(
              height: 180, // Fixed height for the carousel
              child: CarouselView.weighted(
                shape: CircleBorder(),
                scrollDirection: Axis.horizontal,
                flexWeights: [2, 4, 2],
                children: List.generate(
                  avatar.length,
                  (index) =>
                      CircleAvatar(backgroundImage: AssetImage(avatar[index])),
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  // color: AppColors.background,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    style: TextStyle(color: AppColors.primary),
                    showCursor: true,
                    cursorColor: AppColors.primary,
                    controller: loginController,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 20,
                      ),
                      hint: Text(
                        "Nickname",
                        style: TextStyle(
                          color: AppColors.surface,
                          fontSize: 18,
                        ),
                      ),

                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(40),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                    ),
                    onPressed: () async {
                      final nickname = loginController.text.trim();

                      if (nickname.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Nickname cannot be empty")),
                        );
                        return;
                      }

                      final success = await ref
                          .read(aunthenticationprovider.notifier)
                          .isRegistered(nickname);

                      if (success) {
                        Navigator.pushNamed(context, "/chat");
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/chat',
                          (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Authentication failed. Try again."),
                          ),
                        );
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Continue",
                        style: TextStyle(
                          color: AppColors.background,
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
