import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import '../api/matchesofday_api.dart';
// import 'api/allmatches_api.dart';

class AllMatchPage extends StatefulWidget {
  const AllMatchPage({Key? key}) : super(key: key);

  @override
  State<AllMatchPage> createState() => _AllMatchPageState();
}

class _AllMatchPageState extends State<AllMatchPage>
    with SingleTickerProviderStateMixin {
  late DateTime selectedDate;
  // late Future<AllMatches> futureAllMatches;
  late Future<MatchesOfDay> futureMatchesOfDay;
  late AnimationController _loadingController;
  late Animation<Color?> _loadingAnimation;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    // futureAllMatches = fetchAllMatches();
    futureMatchesOfDay = fetchMatchesOfDay(
        DateFormat('yyyy-MM-dd').format(selectedDate),
        selectedDate.timeZoneOffset.toString());

    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadingAnimation = ColorTween(begin: Colors.white, end: Colors.grey[300])
        .animate(_loadingController);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (date != null) {
      setState(() {
        selectedDate = date;
        futureMatchesOfDay = fetchMatchesOfDay(
            DateFormat('yyyy-MM-dd').format(selectedDate),
            selectedDate.timeZoneOffset.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'All Matches',
          style: TextStyle(
            color: Colors.pink[800],
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Matches',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      DateFormat('dd MMM yyyy').format(selectedDate),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showDatePicker(context),
                      child: Text(
                        'Select Date',
                        style: TextStyle(color: Colors.pink[800], fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            _buildAllMatches(),
          ],
        ),
      ),
    );
  }

  Widget _buildAllMatches() {
    return FutureBuilder(
      future: futureMatchesOfDay,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return AnimatedBuilder(
                    animation: _loadingAnimation,
                    builder: (context, child) {
                      return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          color: _loadingAnimation.value,
                          child: const SizedBox(width: 300.0, height: 100.0));
                    });
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Something went wrong',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.white),
                      onPressed: () {
                        setState(() {
                          futureMatchesOfDay = fetchMatchesOfDay(
                              DateFormat('yyyy-MM-dd').format(selectedDate),
                              selectedDate.timeZoneOffset.toString());
                          // futureAllMatches = fetchAllMatches();
                        });
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(color: Colors.pink[800]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        } else if (snapshot.hasData) {
          if (snapshot.data!.matches.isEmpty) {
            return Container();
          } else {
            return Expanded(
              child: ListView.builder(
                itemCount: snapshot.data!.matches.length,
                itemBuilder: (context, index) {
                  return snapshot.data!.matches[index]['status'] == 'FINISHED'
                      ? _buildFinishedMatchItem(snapshot.data!.matches[index])
                      : ['LIVE', 'IN_PLAY', 'PAUSED']
                              .contains(snapshot.data!.matches[index]['status'])
                          ? _buildLiveMatchItem(snapshot.data!.matches[index])
                          : ['SCHEDULED', 'TIMED']
                                  .contains(
                                      snapshot.data!.matches[index]['status'])
                              ? _buildUpcomingMatchItem(
                                  snapshot.data!.matches[index])
                              : const SizedBox.shrink();
                },
              ),
            );
          }
        } else {
          return const Text('No data available',
              style: TextStyle(fontWeight: FontWeight.bold));
        }
      },
    );
  }

  Widget _buildLiveMatchItem(Map<String, dynamic> match) {
    String crestHomeUrl = 'https://corsproxy.io/?${match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl = 'https://corsproxy.io/?${match['awayTeam']['crest']}';
    Widget crestAwayWidget;

    if (crestHomeUrl.endsWith('.svg')) {
      crestHomeWidget = SvgPicture.network(
        crestHomeUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    } else {
      crestHomeWidget = Image.network(
        crestHomeUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    }

    if (crestAwayUrl.endsWith('.svg')) {
      crestAwayWidget = SvgPicture.network(
        crestAwayUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    } else {
      crestAwayWidget = Image.network(
        crestAwayUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    }

    return InkWell(
      onTap: () => {print('Matches')},
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Colors.white,
        child: SizedBox(
          width: 300.0,
          height: 100.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 105,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 55, height: 55, child: crestHomeWidget),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          match['homeTeam']['shortName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('LIVE',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[100]))
                      .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true))
                      .tint(
                          color: const Color.fromRGBO(0, 100, 0, 1),
                          delay: 2000.ms,
                          curve: Curves.easeInOut,
                          duration: 600.ms),
                  Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                        ' ${match['score']['fullTime']['home']} - ${match['score']['fullTime']['away']} ',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    width: 90,
                    height: 15,
                  )
                ],
              ),
              SizedBox(
                width: 105,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 55, height: 55, child: crestAwayWidget),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          match['awayTeam']['shortName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFinishedMatchItem(Map<String, dynamic> match) {
    String crestHomeUrl = 'https://corsproxy.io/?${match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl = 'https://corsproxy.io/?${match['awayTeam']['crest']}';
    Widget crestAwayWidget;

    if (crestHomeUrl.endsWith('.svg')) {
      crestHomeWidget = SvgPicture.network(
        crestHomeUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    } else {
      crestHomeWidget = Image.network(
        crestHomeUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    }

    if (crestAwayUrl.endsWith('.svg')) {
      crestAwayWidget = SvgPicture.network(
        crestAwayUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    } else {
      crestAwayWidget = Image.network(
        crestAwayUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    }

    return InkWell(
      onTap: () => {print('Matches')},
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Colors.white,
        child: SizedBox(
          width: 300.0,
          height: 100.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 105,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 55, height: 55, child: crestHomeWidget),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          match['homeTeam']['shortName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('FT',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey)),
                  Container(
                    padding: const EdgeInsets.fromLTRB(2, 5, 2, 5),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Text(
                        ' ${match['score']['fullTime']['home']} - ${match['score']['fullTime']['away']} ',
                        style: const TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(
                    width: 90,
                    height: 15,
                  )
                ],
              ),
              SizedBox(
                width: 105,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 55, height: 55, child: crestAwayWidget),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          match['awayTeam']['shortName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingMatchItem(Map<String, dynamic> match) {
    DateTime utcDate = DateTime.parse(match['utcDate']);
    String formattedDate = DateFormat('dd MMM yyyy').format(utcDate.toLocal());
    String formattedTime = DateFormat('HH:mm').format(utcDate.toLocal());

    String crestHomeUrl = 'https://corsproxy.io/?${match['homeTeam']['crest']}';
    Widget crestHomeWidget;
    String crestAwayUrl = 'https://corsproxy.io/?${match['awayTeam']['crest']}';
    Widget crestAwayWidget;

    if (crestHomeUrl.endsWith('.svg')) {
      crestHomeWidget = SvgPicture.network(
        crestHomeUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    } else {
      crestHomeWidget = Image.network(
        crestHomeUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    }

    if (crestAwayUrl.endsWith('.svg')) {
      crestAwayWidget = SvgPicture.network(
        crestAwayUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    } else {
      crestAwayWidget = Image.network(
        crestAwayUrl,
        width: 55,
        height: 55,
        fit: BoxFit.contain,
      );
    }

    return InkWell(
      onTap: () => {print('Upcoming Match')},
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Colors.white,
        child: SizedBox(
          width: 300.0,
          height: 100.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 105,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 55, height: 55, child: crestHomeWidget),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          match['homeTeam']['shortName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('VS',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(
                width: 105,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 55, height: 55, child: crestAwayWidget),
                    const SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          match['awayTeam']['shortName'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
