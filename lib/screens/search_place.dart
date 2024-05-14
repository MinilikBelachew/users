import 'package:flutter/material.dart';
import 'package:users/assistant/assistant_request.dart';
import 'package:users/global/global.dart';
import 'package:users/models/prediced_place.dart';


import 'package:users/widgets/place_predication.dart';class SearchPlace extends StatefulWidget {
  const SearchPlace({super.key});

  @override
  State<SearchPlace> createState() => _SearchPlaceState();
}

class _SearchPlaceState extends State<SearchPlace> {

  List<PredictedPlaces> placePredictedList=[];

  findPlaceAutoComplete(String inputText) async {

    if(inputText.length>1){
      String urlAutoCompleteSearch= "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$apiKey&components=country:ET";
    var responseAutoCompleteSearch=await RequestAssistant.receiveRequest(urlAutoCompleteSearch);


      if(responseAutoCompleteSearch == "Error Occured,No Response") {
        return;
      }
      if(responseAutoCompleteSearch["status"] =="OK"){
        var placePredictions = responseAutoCompleteSearch["predictions"]; // Corrected "predicctions" to "predictions"
        var placePredictionList = (placePredictions as List)
            .map((jsonData) => PredictedPlaces.fromJson(jsonData))
            .toList();

        // var placePredictions=responseAutoCompleteSearch["predicctions"];
        // var placePredictionList=(placePredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

        setState(() {
          placePredictedList=placePredictionList;

        });
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.cyan.shade200,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
          ),
          title: const Text(
            "Set drop off Location",
            style: TextStyle(color: Colors.black),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.blueGrey,
                boxShadow: [BoxShadow(
           color: Colors.white54,
           blurRadius: 8,
           spreadRadius: 0.5 ,
           offset: Offset(
             0.7,
             0.7
           )       
                )
          ]
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.adjust_sharp)
                        ,
                        const SizedBox(height: 18,),
                        Expanded(child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: TextField(
                            onChanged: (value){
                              findPlaceAutoComplete(value);

                            },
                            decoration: const InputDecoration(
                              hintText: "Search Location Here",

                              fillColor: Colors.transparent,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: 11,
                                top: 0,
                                bottom: 0
                              )

                            ),
                          ),
                        ))
                      ],
                    )
                  ],
                ),
              ),
            ),

            (placePredictedList.isNotEmpty)
            ?
                Expanded(child: ListView.separated
                  (
                    itemCount: placePredictedList.length,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context,index){
                      return PredicatedPlaceDesign(
                        predictedPlaces: placePredictedList[index],
                      );
                  },
                  separatorBuilder: (BuildContext context,int index)
                  {
                    return Divider(
                      height: 0,
                      color: darkTheme ? Colors.blueAccent:  Colors.red,
                      thickness: 0,
                    );

                  },


                ),


                ):Container()

          ],
        ),
      ),
    );
  }
}
