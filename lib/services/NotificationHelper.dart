import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:fstapp/dataServices/DataService.dart';
import 'package:fstapp/pages/NewsPage.dart';
import 'package:fstapp/RouterService.dart';
import 'package:fstapp/services/DialogHelper.dart';
import 'package:fstapp/services/StorageHelper.dart';
import 'package:fstapp/services/ToastHelper.dart';
import 'package:fstapp/services/js/js_interop.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:fstapp/appConfig.dart';
import 'NavigationService.dart';

class NotificationHelper {
  static const notificationAllowedAsked = "NotificationAllowed";
  static final JSInterop jsInterop = JSInterop();

  static Future<void> logoutOneSignalWeb() async {
    if (kIsWeb) {
      await jsInterop.callMethod('logout', []);
    }
  }

  static Future<void> loginOneSignalWeb(String externalId) async {
    if (kIsWeb) {
      await jsInterop.callMethod('login', [externalId]);
    }
  }

  static Future<bool> isNotificationOnOff() async {
    var isPermissionOn = getNotificationPermission();
    var isSetupAsOn = await StorageHelper.get(notificationAllowedAsked);
    return isPermissionOn && isSetupAsOn == "true";
  }

  static bool getNotificationPermission() {
    if (kIsWeb) {
      return jsInterop.callBoolMethod('getNotificationPermission', []);
    } else {
      return OneSignal.Notifications.permission;
    }
  }

  static Future<void> optInNotifications() async {
    if (kIsWeb) {
      await jsInterop.callMethod('optIn', []);
    } else {
      await OneSignal.User.pushSubscription.optIn();
    }
  }

  static Future<void> optOutNotifications() async {
    if (kIsWeb) {
      await jsInterop.callMethod('optOut', []);
    } else {
      await OneSignal.User.pushSubscription.optOut();
    }
  }

  static Future<void> initialize() async {
    if (!AppConfig.isNotificationsSupported) {
      return;
    }

    if (kIsWeb) {
      await jsInterop.callMethod('initializeOneSignal', []);
    } else {
      OneSignal.initialize(AppConfig.oneSignalAppId);
      OneSignal.Notifications.addClickListener((event) {
        RouterService.navigateOccasion(NavigationService.navigatorKey.currentContext!, NewsPage.ROUTE);
      });
    }
    await NotificationHelper.login();
  }

  static Future<void> checkForNotificationPermission(BuildContext context) async {
    var allowed = getNotificationPermission();
    if (!allowed) {
      var wasAsked = await StorageHelper.get(notificationAllowedAsked);
      if (wasAsked == null) {
        var dialogResult = await DialogHelper.showNotificationPermissionDialog(context);
        if(!dialogResult) {
          ToastHelper.Show("Notifications have been disabled.");
          return;
        }
        var requestResult = await requestNotificationPermission();
        await StorageHelper.set(notificationAllowedAsked, requestResult.toString());
        if (requestResult) {
          ToastHelper.Show("Notifications have been allowed.");
        } else {
          ToastHelper.Show("Notifications have been disabled.");
        }
      }
    }
  }

  static Future<bool> turnNotificationOn() async {
    var currentPermission = getNotificationPermission();
    if(!currentPermission){
      currentPermission = await requestNotificationPermission();
    }
    await StorageHelper.set(notificationAllowedAsked, currentPermission.toString());
    if (currentPermission) {
      await optInNotifications();
    }
    return currentPermission;
  }

  static Future<void> turnNotificationOff() async {
    await StorageHelper.set(notificationAllowedAsked, false.toString());
    await optOutNotifications();
  }

  static Future<bool> requestNotificationPermission() async {
    if (kIsWeb) {
      return await jsInterop.callFutureBoolMethod('requestNotificationPermission', []);
    }
    return await OneSignal.Notifications.requestPermission(false);
  }

  static Future<void> login() async {
    if (!AppConfig.isNotificationsSupported || !getNotificationPermission() || !DataService.isLoggedIn()) {
      return;
    }

    if (kIsWeb) {
      await loginOneSignalWeb(DataService.currentUserId());
      return;
    }

    await OneSignal.login(DataService.currentUserId());
  }

  static Future<void> logout() async {
    if (!AppConfig.isNotificationsSupported || !DataService.isLoggedIn()) {
      return;
    }
    if (kIsWeb) {
      await logoutOneSignalWeb();
      return;
    }

    OneSignal.logout();
  }
}
