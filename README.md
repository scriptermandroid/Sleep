# Sleep
Sleep cycle time app made with VS Code Dart Flutter

I made this project specifically for android phones since I have an android phone, and only imported the relevant files for android running into the GitHub.

lib/main.dart is the main file for the app; that's where most of the magic happens. 

Dart is an object oriented dinosaur type of programming language so it makes even the simplest of tasks gargantuan, but the app when boiled down is pretty simple. I have buttons for adjusting the hours and minutes. You use these inputs to set a time, and press the 'set' button to confirm it. Whatever time you input, the app will count backwards 6 90min sleep cycles, so 540 minutes, and then another 30 minutes to give you a heads-up before hand. So 570 minutes before your designated wake time, you'll get a heads-up to start preparing to go to sleep. If you press OK on that notification, you're good, but if you don't, you get another one 60 minutes later, this time 5 90min sleep cycles plus a 30min heads-up before your wake up time.

The app is made to make getting well-rested sleep easier.

If seeking to run it, you will need VSCode, Flutter, Dart, and Android Studio installed.
