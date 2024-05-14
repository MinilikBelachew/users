import 'package:flutter/material.dart';
import 'package:users/splash/splash_screen.dart';

class PayPriceDialog extends StatefulWidget {
  //const PayPriceDialog({super.key});

   double? amount;


  PayPriceDialog({this.amount});

  @override
  State<PayPriceDialog> createState() => _PayPriceDialogState();
}

class _PayPriceDialogState extends State<PayPriceDialog> {

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(1),

      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme? Colors.lightBlueAccent : Colors.lightBlue,
              borderRadius: BorderRadius.circular(15),


        ),
        child: Column(
          children: [
            SizedBox(height: 20,),
            Text("Amount".toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: darkTheme ? Colors.white :Colors.black ,
              fontSize: 16
            ),
            ),
            SizedBox(height: 20,),
            Divider(
              thickness: 2,
              color: darkTheme? Colors.white:Colors.black,

            ),
            SizedBox(height: 10,),
            Text("ETB " + widget.amount.toString(),
            style: TextStyle(
              fontSize: 50,
              fontWeight: FontWeight.bold
            ),),
            Padding(padding: EdgeInsets.all(10),
            child: Text(
              "ይህ ጠቅላላ መጠን ነው። እባክዎን ይክፈሉ።",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkTheme? Colors.white: Colors.black
              ),
              // "These is the total Amount.Please pay."
            ),
            ),
            SizedBox(height: 10,),
            Padding(padding: EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: darkTheme ? Colors.white: Colors.black
              ),
              onPressed: (){
                Future.delayed(Duration(milliseconds: 10000),() {
                  Navigator.pop(context,"Cash Paid");
                  Navigator.push(context, MaterialPageRoute(builder: (c) =>SplashScreen()));
                });
                
              },
              child: Row(
                children: [
                  Text("Pay Cash",
                  style: TextStyle(
                    fontSize: 20,
                    color: darkTheme? Colors.black: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                  ),
                  Text("ETB " + widget.amount.toString(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: darkTheme? Colors.white: Colors.black
                  ),)
                ],
              ),
            ),)

          ],
        ),
      ),

    );
  }
}
