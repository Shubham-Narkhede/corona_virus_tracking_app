import 'package:coronavirustrackingapp/models/country_detail.dart';
import 'package:coronavirustrackingapp/screens/all_countries.dart';
import 'package:coronavirustrackingapp/screens/country_details.dart';
import 'package:coronavirustrackingapp/screens/main_details.dart';
import 'package:coronavirustrackingapp/screens/all_about_covid.dart';
import 'package:coronavirustrackingapp/widgets/most_infected_countries.dart';
import 'package:coronavirustrackingapp/widgets/most_infected_countries_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' show Client;
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shimmer/shimmer.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard>
    with AutomaticKeepAliveClientMixin {
  Client client = Client();
  String cases, deaths, recovered, active;
  int timestamp;
  String updatedOn;
  Map<String, dynamic> mainDetails;

  DateTime dateTime;

  Future _allCountriesFuture;
  List<CountryDetail> _allCountriesDetailsList;

  Future totalCasesFuture;

  @override
  void initState() {
    super.initState();

    updatedOn = '--';
    totalCasesFuture = getAllCountries();
    _allCountriesFuture = getAllCountriesDetails();
  }

  refresh() async {
    setState(() {
      updatedOn = 'Refreshing';
      totalCasesFuture = getAllCountries();
      _allCountriesFuture = getAllCountriesDetails();
    });
  }

  Future getAllCountries() async {
    final response = await client.get('https://corona.lmao.ninja/all');

    if (response.statusCode == 200) {
      mainDetails = json.decode(response.body);
      cases = mainDetails['cases'].toString();
      deaths = mainDetails['deaths'].toString();
      recovered = mainDetails['recovered'].toString();
      active = mainDetails['active'].toString();
      timestamp = mainDetails['updated'];

      dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);

      setState(() {
        updatedOn = (DateFormat('dd MMM yyyy, hh:mm a').format(dateTime));
      });
    } else {
      throw Exception('Failed to get all countries names');
    }

    print(cases);

    return mainDetails;
  }

  Future getAllCountriesDetails() async {
    final response =
        await client.get('https://corona.lmao.ninja/countries?sort=cases');

    if (response.statusCode == 200) {
      List parsedJson = json.decode(response.body);

      print(parsedJson.length);

      List<CountryDetail> tempList = [];

      for (var res in parsedJson) {
        CountryDetail allCountriesDetails = CountryDetail(res);
        tempList.add(allCountriesDetails);
      }
      _allCountriesDetailsList = tempList;
    } else {
      throw Exception('Failed to get all countries names');
    }

    print(_allCountriesDetailsList);

    return _allCountriesDetailsList;
  }

  void _sendToCountryDetail(CountryDetail countryDetail, double width) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CountryDetails(
          countryDetail: countryDetail,
          width: width,
          mainDetails: mainDetails,
        ),
      ),
    );
  }

  _sendToDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MainDetails(mainDetails: mainDetails),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
       backgroundColor: Colors.black,
          body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(50.0),
              bottomLeft: Radius.circular(50.0),
            ),
            child: Stack(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 220.0,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        Colors.red,
                        Colors.red.shade900,
                      ],
                    ),
                  ),
                  child: Image.asset(
                    'assets/images/sssss.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),

              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(0),
              shrinkWrap: false,
              scrollDirection: Axis.vertical,
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                      top: 15.0, left: 20.0, right: 20.0, bottom: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Covid-19 Tracker',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFamily: 'Ubuntu',
                            ),
                          ),
//                          FlatButton(
//                            padding: EdgeInsets.symmetric(horizontal: 5.0),
//                            splashColor: Colors.blue.withOpacity(0.1),
//                            highlightColor: Colors.blue.withOpacity(0.07),
//                            onPressed: _sendToDetails,
//                            child: Text(
//                              'See Details',
//                              style: TextStyle(
//                                fontSize: 16.0,
//                                fontWeight: FontWeight.w600,
//                                color: Colors.red,
//                                fontFamily: 'Ubuntu',
//                              ),
//                            ),
//                          ),
                        ],
                      ),
                      Container(
                        height: 10,
                      ),
                      Text(
                        'Updated on today: $updatedOn',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      FutureBuilder(
                        future: totalCasesFuture,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Shimmer.fromColors(
                              period: Duration(milliseconds: 800),
                              baseColor: Colors.grey.withOpacity(0.5),
                              highlightColor: Colors.black.withOpacity(0.5),
                              child: Container(
                                padding: EdgeInsets.all(20.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(25.0),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          width: 25.0,
                                          height: 25.0,
                                        ),
                                        SizedBox(
                                          height: 15.0,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.2,
                                          height: 25.0,
                                        ),
                                        SizedBox(
                                          height: 8.0,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.15,
                                          height: 20.0,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          width: 25.0,
                                          height: 25.0,
                                        ),
                                        SizedBox(
                                          height: 15.0,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.2,
                                          height: 25.0,
                                        ),
                                        SizedBox(
                                          height: 8.0,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.15,
                                          height: 20.0,
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.grey.withOpacity(0.5),
                                          ),
                                          width: 25.0,
                                          height: 25.0,
                                        ),
                                        SizedBox(
                                          height: 15.0,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.2,
                                          height: 25.0,
                                        ),
                                        SizedBox(
                                          height: 8.0,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.5),
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                          ),
                                          width:
                                              MediaQuery.of(context).size.width *
                                                  0.15,
                                          height: 20.0,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            if (snapshot.data.length == 0) {
                              return Center(
                                child: Text(
                                  'No Countries Found',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Ubuntu',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18.0,
                                  ),
                                ),
                              );
                            }
                            return Container(
                              padding: EdgeInsets.all(20.0),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.redAccent,
                                    Colors.red,
                                    Colors.red.shade900
                                  ]
                                ),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 8.0,
                                    spreadRadius: 8.0,
                                    offset: Offset(0, 2),
                                    color: Colors.white.withOpacity(0.01),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                mainAxisSize: MainAxisSize.max,
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 20.0,
                                          color: Colors.white,
                                        ),
                                        width: 25.0,
                                        height: 25.0,
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      Text(
                                        cases,
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow,
                                          fontFamily: 'Ubuntu',
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Text(
                                        'Total Cases',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontFamily: 'Ubuntu',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.2),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 20.0,
                                          color: Colors.white,
                                        ),
                                        width: 25.0,
                                        height: 25.0,
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      Text(
                                        deaths,
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow,
                                          fontFamily: 'Ubuntu',
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Text(
                                        'Deaths',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontFamily: 'Ubuntu',
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color:  Colors.white.withOpacity(0.2),
                                        ),
                                        child: Icon(
                                          Icons.favorite,
                                          size: 20.0,
                                          color: Colors.white,
                                        ),
                                        width: 25.0,
                                        height: 25.0,
                                      ),
                                      SizedBox(
                                        height: 15.0,
                                      ),
                                      Text(
                                        recovered,
                                        style: TextStyle(
                                          fontSize: 22.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.yellow,
                                          fontFamily: 'Ubuntu',
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ),
                                      Text(
                                        'Recovered',
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                          fontFamily: 'Ubuntu',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Most Affected Countries',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          fontFamily: 'Ubuntu',
                        ),
                      ),
                      FlatButton(
                        padding: EdgeInsets.all(0),
                        splashColor: Colors.blue.withOpacity(0.1),
                        highlightColor: Colors.blue.withOpacity(0.07),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllCountries(
                                allCountriesDetailsList: _allCountriesDetailsList,
                                mainDetails: mainDetails,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                            fontFamily: 'Ubuntu',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: _allCountriesFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 250.0,
                        child: Shimmer.fromColors(
                          period: Duration(milliseconds: 800),
                          baseColor: Colors.grey.withOpacity(0.5),
                          highlightColor: Colors.black.withOpacity(0.5),
                          child: ListView.builder(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            physics: NeverScrollableScrollPhysics(),
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return MostInfectedCountriesShimmer();
                            },
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        height: 250.0,
                        child: ListView.builder(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: false,
                          addAutomaticKeepAlives: true,
                          itemCount: 5,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                print('Send to details');
                                _sendToCountryDetail(
                                    _allCountriesDetailsList[index],
                                    MediaQuery.of(context).size.width);
                              },
                              child: MostInfectedCountries(
                                index: index,
                                countryDetail: _allCountriesDetailsList[index],
                                countryCode: _allCountriesDetailsList[index]
                                    .countryInfo['iso2']
                                    .toString()
                                    .toLowerCase(),
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
                SizedBox(
                  height: 10.0,
                ),
//                GestureDetector(
//                  onTap: (){
//                    Navigator.push(
//                      context,
//                      MaterialPageRoute(
//                        builder: (context) => AllAboutCovid(),
//                      ),
//                    );
//                  },
//                  child: Container(
//                    child: Column(
//                      children: <Widget>[
//                        Text(
//                          'Want to know about Covid-19',
//                          textAlign: TextAlign.start,
//                          style: TextStyle(
//                            fontSize: 18.0,
//                            fontWeight: FontWeight.w500,
//                            color: Colors.white,
//                            fontFamily: 'Ubuntu',
//                          ),
//                        ),
//                        SizedBox(height: 10.0),
//                        Text(
//                            'Read More',
//                            textAlign: TextAlign.start,
//                            style: TextStyle(
//                              fontSize: 14.0,
//                              fontWeight: FontWeight.w500,
//                              color: Colors.red,
//                              fontFamily: 'Ubuntu',
//                            )
//                        )
//                      ],
//                    ),
//                  ),
//                ),

                SizedBox(
                  height: 15.0,
                ),

//                Padding(
//                  padding: const EdgeInsets.all(20.0),
//                  child: GestureDetector(
//                    onTap: () {
//                      Navigator.push(
//                        context,
//                        MaterialPageRoute(
//                          builder: (context) => AllAboutCovid(),
//                        ),
//                      );
//                    },
//                    child: Container(
//                      width: MediaQuery.of(context).size.width,
//                      height: 200.0,
//                      child: Stack(
//                        alignment: Alignment.bottomLeft,
//                        children: <Widget>[
////                          Container(
////                            height: 170.0,
////                            padding: EdgeInsets.all(20.0),
////                            decoration: BoxDecoration(
////                              color: Colors.blue.withOpacity(0.05),
////                              borderRadius: BorderRadius.circular(25.0),
////                            ),
////                          ),
////                          Hero(
////                            child: SvgPicture.asset(
////                              'assets/images/nurse.svg',
////                              fit: BoxFit.contain,
////                            ),
////                            tag: 'TOP',
////                          ),
//                          Positioned(
//                            height: 130.0,
//                            right: 0,
//                            bottom: 0,
//                            width: MediaQuery.of(context).size.width * 0.4,
//                            child: Column(
//                              mainAxisSize: MainAxisSize.min,
//                              mainAxisAlignment: MainAxisAlignment.start,
//                              crossAxisAlignment: CrossAxisAlignment.start,
//                              children: <Widget>[
//                                Text(
//                                  'All you need to know about Covid-19',
//                                  textAlign: TextAlign.start,
//                                  style: TextStyle(
//                                    fontSize: 18.0,
//                                    fontWeight: FontWeight.w500,
//                                    color: Colors.white,
//                                    fontFamily: 'Ubuntu',
//                                  ),
//                                ),
//                                SizedBox(height: 10.0),
//                                Text(
//                                  'Read More',
//                                  textAlign: TextAlign.start,
//                                  style: TextStyle(
//                                    fontSize: 14.0,
//                                    fontWeight: FontWeight.w500,
//                                    color: Colors.red,
//                                    fontFamily: 'Ubuntu',
//                                  ),
//                                ),
//                              ],
//                            ),
//                          ),
//                        ],
//                      ),
//                    ),
//                  ),
//                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
