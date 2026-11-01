import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

int _hour = 1;
int _minute = 0;
int _bugfix = 0;

@pragma('vm:entry-point')
void aLARM() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidNotificationService.initBackground();
  await AndroidNotificationService.showActionNotification();
}

@pragma('vm:entry-point')
void aLARM2() async {

  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  await prefs.reload();
  final acknowledged = prefs.getBool('acknowledged') ?? false;

  if (acknowledged == false) {

    WidgetsFlutterBinding.ensureInitialized();
    await AndroidNotificationService.initBackground();
    await AndroidNotificationService.showActionNotification();

  }
 
}

@pragma('vm:entry-point')
void OKK(NotificationResponse response) async {
  WidgetsFlutterBinding.ensureInitialized();

  if (response.actionId == 'O_K') {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('acknowledged', true);
    await FlutterLocalNotificationsPlugin().cancel(id: 1);
  }
}


void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await AndroidAlarmManager.initialize();
  await AndroidNotificationService.init();
  
  runApp(const MyApp());

}

class AndroidNotificationService {

  static Future<void> initBackground() async {
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const settings = InitializationSettings(android: androidSettings);
  await _notificationsPlugin.initialize(settings: settings);
  }
    static final FlutterLocalNotificationsPlugin _notificationsPlugin =
        FlutterLocalNotificationsPlugin();

    // this like event receiver
    static Future<void> init() async {
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings settings = InitializationSettings(android: androidSettings);

      await _notificationsPlugin.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: OKK,
        onDidReceiveBackgroundNotificationResponse: OKK,
      );

      // how to request notification permission from android
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
              
      if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      }
    
    }



   //this is like event sender
  static Future<void> showActionNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'android_action_channel',
      'Action Notifications',
      playSound: true,
      priority: Priority.high,
      importance: Importance.max,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'O_K', // id
          'OK', //display words
          cancelNotification: true,
          showsUserInterface: false,
        ),
      ],
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(id: 1, title: 'Time to sleep!', body: 'Get ready to bed now for the most optimal rest.', notificationDetails: notificationDetails);
  }

}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {

  
  const MyHomePage({super.key, required this.title});


  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  
  
  int temp = 0;

    Future<void> _load() async{
      final prefs = await SharedPreferences.getInstance();
      
      setState(() {
        _hour = prefs.getInt('hour') ?? 1;
        _minute = prefs.getInt('min') ?? 0;

      });
      
    }
    
  void _hourIncrease() {
    setState(() {
      _hour++;
      temp = _hour - 12;
      if (_hour > 24) {
          _hour = 1;
      }
    });
  }

  void _save() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('hour', _hour);
    await prefs.setInt('min', _minute);
    await prefs.setBool('acknowledged', false);
    _set();

   

  }

  void _set() async{
    final now = DateTime.now();
    

    DateTime wakeTime;
    DateTime warningTime;

    if (_hour == 24) {
      wakeTime = DateTime(now.year, now.month, now.day, _bugfix, _minute);
    } else {
      wakeTime = DateTime(now.year, now.month, now.day, _hour, _minute);
    }

    if (wakeTime.isBefore(now)) {
      wakeTime = wakeTime.add(const Duration(days: 1));
    }
    
    

    warningTime = wakeTime.subtract(const Duration(minutes: 570));

    var targetTimeNext = warningTime.add(const Duration(hours: 1));

    const int alarmId = 1;
    const int alarmId2 = 2;
    await AndroidAlarmManager.oneShotAt(
      warningTime,
      alarmId,
      aLARM,
      exact: false,
      wakeup: true, 
    );

    await AndroidAlarmManager.oneShotAt(
      targetTimeNext,
      alarmId2,
      aLARM2,
      exact: false,
      wakeup: true, 
    );
   
  }

  



  void _hourDecrease() {
    setState(() {

      _hour--;
      
      if (_hour < 1) {
        _hour = 24;
      }
      temp = _hour - 12;
    });
  }

  void _minIncrease() {
    setState(() {
      _minute++;

      if (_minute > 59) {
        _minute = 0;
      }
    });
  }

   void _minDecrease() {
    setState(() {
      _minute--;

      if (_minute < 0) {
        _minute = 59;
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    
    return Scaffold(
      appBar: AppBar(
        
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Text(widget.title),
      ),
      body: Center(
        
        child: 
        Row(
          
          mainAxisAlignment: .center,
          children: [
            Column(
              mainAxisAlignment: .center,
              children: [
                ElevatedButton(
                  onPressed: _hourIncrease, 
                  child: Text('+')
                ),
                if (_hour < 13)
                  Text(
                    '$_hour',
                    style: Theme.of(context).textTheme.headlineMedium
                  ),
                if (_hour > 12)
                  Text(
                      '$temp',
                      style: Theme.of(context).textTheme.headlineMedium
                    ),
                ElevatedButton(
                  onPressed: _hourDecrease, 
                  child: Text('-'),
                ),
              ]
              
            ),
            
              
           

            Column(
              mainAxisAlignment: .center,
              children: [
                ElevatedButton(
                onPressed: _minIncrease, 
                child: Text('+')
                ),
              if (_minute > 9)
                Text(
                  ': $_minute',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              if (_minute < 10)
                Text(
                    ': 0$_minute',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
              ElevatedButton(
                onPressed: _minDecrease, 
                child: Text('-'),
              ),
              ],
            ),
            if (_hour > 11 && _hour < 24)
              Text(
                  'PM',
                    style: Theme.of(context).textTheme.headlineMedium,
                    ),
            if (_hour > 0 && _hour < 12 || _hour == 24)
              Text(
                  'AM',
                    style: Theme.of(context).textTheme.headlineMedium,
                    ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
        tooltip: 'Increment',
        child:  Text(
                  'Set Wake Time',
                    ),
      ),
    );
  }
}
