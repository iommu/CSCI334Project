import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../utils/constants/app_globals.dart' as globals;

class VaccinePage extends StatefulWidget {
  final String uuid;
  VaccinePage({Key key, @required this.uuid}) : super(key: key);

  @override
  _VaccinePageState createState() => _VaccinePageState();
}

class _VaccinePageState extends State<VaccinePage> {
  @override
  Widget build(BuildContext context) {
    const String getPerson = '''
    query GetPerson(\$uuid: String!, \$jwt: String!) {
      person(uuid: \$uuid, jwt: \$jwt) {
        uuid,
        vaccineName,
        vaccineInj,
        vaccineRecInj,
        vaccineDate
      }
    }
    ''';
    return Scaffold(
        body: SafeArea(
            child: Query(
                options: QueryOptions(
                  document: gql(
                      getPerson), // this is the query string you just created
                  variables: {'uuid': widget.uuid, 'jwt': globals.jwt},
                  pollInterval: Duration(seconds: 10),
                ),
                builder: (QueryResult result,
                    {VoidCallback refetch, FetchMore fetchMore}) {
                  var person = result.data['person'];
                  int access = globals.access;
                  bool vacinated = !(person['vaccineName'] == "" ||
                      person['vaccineName'] == null);
                  var date = new DateTime.fromMillisecondsSinceEpoch(
                      person['vaccineDate'] * 1000);
                  return Scaffold(
                    appBar: AppBar(
                      title: const Text('Vaccine certification'),
                    ),
                    body: Padding(
                      padding: EdgeInsets.all(30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          if (vacinated)
                            Text("Vaccinated with " + person['vaccineName'],
                                textScaleFactor: 1.5),
                          SizedBox(height: 20),
                          if (vacinated)
                            Text(
                                "Vaccines recieved " +
                                    person['vaccineInj'].toString() +
                                    "/" +
                                    person['vaccineRecInj'].toString(),
                                textScaleFactor: 1.5),
                          SizedBox(height: 20),
                          if (vacinated)
                            Text(
                                "Vaccinated on " +
                                    date.year.toString() +
                                    "/" +
                                    date.month.toString() +
                                    "/" +
                                    date.day.toString(),
                                textScaleFactor: 1.5),
                          if (access >= 3)
                            Expanded(
                              child: Align(
                                alignment: FractionalOffset.bottomCenter,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                VaccineEditPage(
                                                    uuid: widget.uuid)));
                                  },
                                  child: Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(16.0),
                                      child: Text("Edit",
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 1.5)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                })));
  }
}

class VaccineEditPage extends StatefulWidget {
  final String uuid;
  VaccineEditPage({Key key, @required this.uuid}) : super(key: key);

  @override
  _VaccineEditPageState createState() => _VaccineEditPageState();
}

class _VaccineEditPageState extends State<VaccineEditPage> {
  final vaccNameController = TextEditingController();
  final vaccRecivedController = TextEditingController();
  final vaccRecommendController = TextEditingController();

  OnMutationUpdate get update => (cache, result) {
        if (result.hasException) {
          print(result.exception);
          // if (result.exception.graphqlErrors[0] != null) {
          //   if (result.exception.graphqlErrors[0].message ==
          //       "error: incorrect password") {
          //     passController.text = "";
          //     _simpleAlert(context, "Incorrect password");
          //   } else if (result.exception.graphqlErrors[0].message ==
          //       "error: incorrect phoneNum") {
          //     phoneController.text = "";
          //     _simpleAlert(context, "Incorrect phone number");
          //   }
          // }
        } else {
          Navigator.pop(context);
        }
      };

  @override
  Widget build(BuildContext context) {
    const String getPerson = '''
    query GetPerson(\$uuid: String!, \$jwt: String!) {
      person(uuid: \$uuid, jwt: \$jwt) {
        uuid,
        firstName,
        lastName,
        vaccineName,
        vaccineInj,
        vaccineRecInj,
        vaccineDate
      }
    }
    ''';
    const String vaccinate = '''
    mutation Vaccinate(\$uuid: String!, \$vaccName: String!, \$vaccDoses: Int!, \$vaccRecommend: Int!){
      action: vaccinate(uuid:\$uuid, vaccineName: \$vaccName, vaccineInj: \$vaccDoses, vaccineRecInj: \$vaccRecommend) {
        updated
      }
    }
    ''';
    return Scaffold(
      body: SafeArea(
          child: Query(
              options: QueryOptions(
                document:
                    gql(getPerson), // this is the query string you just created
                variables: {'uuid': widget.uuid, 'jwt': globals.jwt},
                pollInterval: Duration(seconds: 10),
              ),
              builder: (QueryResult result,
                  {VoidCallback refetch, FetchMore fetchMore}) {
                var person = result.data['person'];
                int access = globals.access;
                return Mutation(
                    options: MutationOptions(
                      document: gql(vaccinate),
                      update: update,
                    ),
                    builder: (RunMutation _vaccinate, QueryResult result) {
                      return Scaffold(
                        appBar: AppBar(
                          title: Text('Edit ' +
                              person['firstName'] +
                              ' ' +
                              person['lastName']),
                        ),
                        body: Padding(
                          padding: EdgeInsets.all(30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text("User UUID : " + widget.uuid),
                              SizedBox(height: 20),
                              TextField(
                                keyboardType: TextInputType.name,
                                controller: vaccNameController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Vaccine Name'),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                keyboardType: TextInputType.phone,
                                controller: vaccRecivedController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Doses Received'),
                              ),
                              SizedBox(height: 20),
                              TextField(
                                keyboardType: TextInputType.phone,
                                controller: vaccRecommendController,
                                decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Recommended Doses'),
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          _vaccinate({
                                            'uuid': widget.uuid,
                                            'vaccName': vaccNameController.text,
                                            'vaccDoses': int.parse("0" +
                                                vaccRecivedController.text),
                                            'vaccRecommend': int.parse("0" +
                                                vaccRecommendController.text),
                                          });
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Text("Update"))),
                                  ),
                                  SizedBox(width: 30),
                                  Expanded(
                                    flex: 1,
                                    child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.all(16),
                                            child: Text("Discard"))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              })),
    );
  }
}