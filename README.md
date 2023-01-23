# Ecolyze

The functional prototype for the TechChallenge.

This prototype sends a picture to the AWS Rekognition API. The Rekognition-Model then detects spots of bad insulation and sends the results back to the phone. The results are then displayed (See the Demo-Video for a demonstration.)
Hence, this app implements a prototypical version of the central functional analysis-feature of the targeted end product.

The app was tested on Android phones with at least Android 9 (API Level 28).

# How to run the code
Please start the AWS Rekognition service as described in the technical project description before using the app.

## 1. Option (Easy) - Run the executable on an android phone:
Download and install the [executable APK-File](app-release.apk) on your android phone (Android 9 or higher) and run it. To be able to do that you need to change your Safety Settings to allow the installation of Applications which don't stem from the Google Play Store ([see this link](https://www.heise.de/tipps-tricks/Externe-Apps-APK-Dateien-bei-Android-installieren-so-klappt-s-3714330.html)). Also PlayProtect might warn you that this app was developed by an unknown developer. This will be gone as soon as we officially register in the Google Play Store and sign the app.

## 2. Option (Harder) - Run the project in a programming environment
1. Set up a programming environment for Flutter as described in the ["Get started"-steps here](https://docs.flutter.dev/get-started/). Make sure your Android Emulator has a minimum API Level of 28.
2. Set up an AWS Rekognition Model detecting Custom Labels.
3. In lib\main.dart insert the credentials and region for your own AWS Rekognition Model 73-80.
4. Run the app on the Emulator.
## Important!
Don't forget to stop the AWS Rekognition service after you have tested the app.
# Contact
Please don't hesitate to contact us over [mail](mailto:tim.baechle@tum.de)
