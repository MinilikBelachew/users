import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:users/assistant/assistant_request.dart';
import 'package:users/info_mnager/info_app.dart';
import 'package:users/models/prediced_place.dart';
import 'package:users/widgets/page_dialog.dart';

import '../global/global.dart';
import '../models/directions.dart';

class PredicatedPlaceDesign extends StatefulWidget {
  final PredictedPlaces? predictedPlaces;
  const PredicatedPlaceDesign({super.key, this.predictedPlaces});

  // const PredicatedPlaceDesign({super.key});

  @override
  State<PredicatedPlaceDesign> createState() => _PredicatedPlaceDesignState();
}

class _PredicatedPlaceDesignState extends State<PredicatedPlaceDesign> {
  @override
  getPlaceDirectionsDetails(String? placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: "Setting up Drop.off. please wait",
      ),
    );
    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey";

    var responseApi = await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);
    Navigator.pop(context);
    if(responseApi == "Error Occured,No Response") {
      return;
    }
    if(responseApi["status"] == "OK") {
      Directions directions=Directions();
      directions.locationName= responseApi["result"]["name"];
      directions.locationId=placeId;
      directions.locationLatitude= responseApi ['result']["geometry"]["location"]["lat"];
      directions.locationLongitude= responseApi ["result"]["geometry"]["location"]["lng"];

      Provider.of<AppInfo> (context, listen: false).updateDropOffLocationAddress(directions);

      setState(() {
        userDropOffAddress= directions.locationName!;
      });
      Navigator.pop(context, "obtainDropoff");

    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return ElevatedButton(
        onPressed: () {

          getPlaceDirectionsDetails(widget.predictedPlaces!.place_id, context);
        },
        child: Row(
          children: [
            Icon(Icons.add_location,
                color: darkTheme ? Colors.lightBlue : Colors.blue),
            const SizedBox(
              width: 10,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.predictedPlaces!.main_text!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 16,
                      color: darkTheme ? Colors.white : Colors.black),
                ),
                Text(
                  widget.predictedPlaces?.secondery_text ?? "", // Use null-aware operator and provide a default value
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: darkTheme ? Colors.blueAccent : Colors.red,
                  ),
                ),

              ],
            ))
          ],
        ));
  }
}
