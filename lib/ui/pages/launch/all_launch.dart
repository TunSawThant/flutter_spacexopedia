import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spacexopedia/bloc/launches/bloc.dart';
import 'package:flutter_spacexopedia/helper/utils.dart';
import 'package:flutter_spacexopedia/ui/pages/common/no_connection.dart';
import 'package:flutter_spacexopedia/ui/pages/common/no_content.dart';
import 'package:flutter_spacexopedia/ui/theme/extentions.dart';
import 'package:flutter_spacexopedia/ui/widgets/customWidgets.dart';

class AllLaunch extends StatefulWidget {
  AllLaunch({Key key}) : super(key: key);

  @override
  _AllLaunchState createState() => _AllLaunchState();
}

class _AllLaunchState extends State<AllLaunch>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Column(
        children: <Widget>[
          Card(
            elevation: 3,
            margin: EdgeInsets.all(0),
            child: TabBar(
              labelStyle: Theme.of(context).typography.dense.button,
              controller: _tabController,
              tabs: <Widget>[
                Text(
                  "Upcomming",
                ),
                Text("Past"),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<LaunchBloc, LaunchState>(
              builder: (context, state) {
                if (state is Loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (state is LoadedState) {
                  if (state.allLaunch == null) return NoContent();

                  return TabBarView(
                    controller: _tabController,
                    children: [
                      LaunchList(
                        list: state.allLaunch
                            .where((element) => element.upcoming)
                            .toList(),
                      ),
                      LaunchList(
                        list: state.allLaunch
                            .where((element) => !element.upcoming)
                            .toList(),
                      )
                    ],
                  );
                } else if (state is NoConnectionDragonState) {
                  return NoInternetConnection(
                    message: state.errorMessage,
                    onReload: () {
                      BlocProvider.of<LaunchBloc>(context).add(LaunchInitial());
                    },
                  );
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class LaunchList extends StatelessWidget {
  const LaunchList({Key key, this.list}) : super(key: key);
  final List<Launch> list;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) => LaunchCard(
        model: list[index],
      ),
    );
  }
}

class LaunchCard extends StatelessWidget {
  final Launch model;

  const LaunchCard({Key key, this.model}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 1,
            child: model.links != null &&
                    model.links.missionPatchSmall != null &&
                    model.links.missionPatchSmall.isNotEmpty
                ? customNetworkImage(model.links.missionPatchSmall,
                    fit: BoxFit.cover)
                : SizedBox(),
          ),
          SizedBox(
            width: 16,
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  model.missionName,
                  style: TextStyle(color: theme.textTheme.bodyText1.color),
                ).vP4,
                Text(
                  "Flight no: ${model.flightNumber}",
                  style: TextStyle(color: theme.textTheme.bodyText1.color),
                ).vP4,
                Text(
                  "Launch date: ${Utils.toformattedDate(model.launchDateLocal)}",
                  style: TextStyle(color: theme.textTheme.bodyText1.color),
                ).vP4,
                Text(
                  "Launch site: ${model.launchSite.siteName}",
                  style: TextStyle(color: theme.textTheme.bodyText1.color),
                ).vP4
              ],
            ),
          )
        ],
      ),
    );
  }
}
