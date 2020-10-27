# Squiddy

<img src="assets/SSquid3.png" alt="LoginPage" width="200">

<a href='https://play.google.com/store/apps/details?id=app.squiddy&pcampaignid=pcampaignidMKT-Other-global-all-co-prtnr-py-PartBadge-Mar2515-1'><img alt='Get it on Google Play' src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' width="200"></a>

Squiddy is an Android/iOS client for Octopus Energy. It allows you to view energy usage by month and by day. The app will currently only get the last year of data on your account. You must also generate and use your Octopus Energy developer API key to access energy data associated with your account.

<p float="left">
    <img src="readmeImages/mainLight.png" alt="MainLight" width="200">
    <img src="readmeImages/monthLight.png" alt="monthLight" width="200">
    <img src="readmeImages/mainDark.png" alt="MainDark" width="200">
    <img src="readmeImages/monthDark.png" alt="MainDark" width="200">
</p>

## Still to-do

- [ ] Desktop/web version
- [ ] Get readings > 1 year old 
- [ ] Store readings locally, only downloading new readings 
- [ ] Estimate monthly energy usage/cost

## Help

View the [FAQ]() for help using the app.

## Issues 

If you encounter issues with the software please report them [here]().

## Building the app

The app is built and developed using [Google Flutter](https://flutter.dev/). The app has been built and tested using Flutter 1.22.0. You can use your preferred IDE or the command-line tools to build and run the application. For more detailed instructions, please consult the Flutter [online documentation](https://flutter.dev/docs).

### Clean

`flutter clean`

`flutter pub get`

### Run

*Note: building and running on iOS requires a MacOS, see Flutter documentation [https://flutter.dev/docs/deployment/ios](https://flutter.dev/docs/deployment/ios)*

`flutter run -d <DeviceName>`

### Build

Build for Android using the following command: 

`flutter build apk --release`

The app can also be build for iOS using: 

`flutter build ios --release`
