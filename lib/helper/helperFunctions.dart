import 'package:shared_preferences/shared_preferences.dart';

class HelperFunctions {

  static String LoginKey = 'isLoggedIn';
  static String userNameKey = 'usernameKey';
  static String userEmailKey = 'useremailKey';
  static String userId = 'userKey';
  static String userProfilePicKey = 'userProfilePicKey';

  // saving data to shared preferences

  static Future<void> saveUserLoggedInSharedPref(bool isUserLoggedIn) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool(LoginKey, isUserLoggedIn);
  }

  static Future<void> saveUserNameSharedPref(String userName) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(userNameKey, userName);
  }

  static Future<void> saveUserEmailSharedPref(String userEmail) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(userEmailKey, userEmail);
  }

  static Future<void> saveUserIDSharedPref(String userID) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(userId, userID);
  }

  static Future<void> saveUserProfilePicSharedPref(String userProfile) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(userProfilePicKey, userProfile);
  }

  // getting data from shared preferences

  static Future<bool> getUserLoggedInSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(await sharedPreferences.getBool(LoginKey) == null){
      return false;
    }
    return await sharedPreferences.getBool(LoginKey);
  }

  static Future<String> getUserNameSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(userNameKey);
  }

  static Future<String> getUserEmailSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(userEmailKey);
  }

  static Future<String> getUserProfilePicSharedPref() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.getString(userProfilePicKey);
  }

}