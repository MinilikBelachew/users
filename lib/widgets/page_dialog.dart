import 'package:flutter/material.dart';
class ProgressDialog extends StatelessWidget {


  String? message;
  ProgressDialog({super.key, this.message});
  // const ProgressDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius:BorderRadius.circular(6)
        ),
        child: Row(
          children: [
            const SizedBox(width: 6,),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color> (Colors.green),
            ),
            const SizedBox(width: 26,),
            Text(
              message!,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 12
              ),
            )
          ],
        ),
      ),
    );
  }
}
