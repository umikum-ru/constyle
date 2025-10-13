
import 'package:constyle/utils.dart';
import 'package:flutter/material.dart';
import 'model/signin.dart';
import 'widgets/loader30.dart';

String appTitle = "Бижутерия от Руслана";

String mainAddress = "https://rmari.ru";
bool geo = false;
const Color constFirstbg = Color(0xffffffff); /// цвет первого экрана
const Color mainViewBg = Color(0xffffffff); /// цвет фона webview
const Color bgcolor = Color(0xffffffff);   /// цвет фона других экранов: нативный (native=YES), запись звуков
const settingsButtonText = TextStyle(fontSize: 13, color: Color(0xff333333)); /// шрифт для кнопки "Настройки"
const nativeSettingsText = TextStyle(fontSize: 12, color: Color(0xff333333)); /// шрифт нативного экрана настроек

const Color buttonbg = Color(0xfff2be8e);   /// цвет фона кнопки
const Color buttoncolor = Color(0xff333333);   /// Цвет текста на кнопке
const styleButton = TextStyle(letterSpacing: 0.6,                  /// стиль текста на кнопке
    fontSize: 14, fontWeight: FontWeight.w400, color: buttoncolor);  /// размер шрифта 14

const Color textColor = Color(0xffff0000);   /// Цвет текста нижнего bottomBar при native=YES
String logoFile = "assets/730.jpg";
const constLoaderColor = Color(0xff645ca5); /// цвет индикатора загрузки

var firstCover = "NO";
const upTitleMarginEnable = "NO"; /// Верхний отступ - NO или YES
const backClose = "NO"; /// "YES" или "NO", если "YES" - системной кнопкой "назад" можно закрыть приложение,
/// если "NO" - то нет

/// Александр Constyle, [06.08.2024 15:08]
/// в нативном кабинете ссылки "Личные данные", "История покупок" и "Выход" зашиты на SITE /private/profile/ и
/// пр, а надо это тоже отработать как мы меняем index.php на appmode.php и /appmode/ на /appmode/.
/// Давай может сделаем на настройках это нативное меню, чтоб в config.dart можно было писать любые пункты и любые ссылки к ним?
/// Например:
/// const NativeMenuName = "Кабинет | История | Выход"
/// const NativeMenuUrl = "webview/appmode.php?profile=1 | webview/appmode.php?history=1 | webview/appmode.php?logout=1"
const nativeMenuName = {
  /// по умолчанию
  //"Кабинет": "/private/profile/",
  //"История": "/private/shophistory/",
  //"Выход": "exit"

  /// snappy (08.24)
  // "Кабинет": "/webview/appmode.php?profile=1",
  // "История": "/webview/appmode.php?history=1",
  // "Выход": "/webview/appmode.php?logout=1"

  /// бонафудс 12.24
   "Кабинет": "/appmode.php?profile=1",
   "История": "/appmode.php?history=1",
   "Выход": "/appmode.php?logout=1"
};

/// стандартное значение
///  если использовать  appModeUrl = "/appmode/id"   и   appModeUrlUserId = "/id"
///  то получится так
///  "$mainAddress/appmode/id${serverResponseData.appid}/id${serverResponseData.userid}/"
//const appModeUrl = "/appmode/id"; /// стандартное значение
//const appModeUrlUserId = "/id";
///
///  если использовать  appModeUrl = "/appmode.php?appid="   и   appModeUrlUserId = "&userid"
///  то получится так
///  "$mainAddress/appmode.php?appid=${serverResponseData.appid}&userid${serverResponseData.userid}"
// const appModeUrl = "/webview/appmode.php?appid="; /// используется на https://snappy.me
// const appModeUrlUserId = "&userid=";

 const appModeUrl = "/appmode.php?appid="; /// используется на https://бонафудс.рф
 const appModeUrlUserId = "&userid=";

String getAddressTwoMode(){
  var ret = "";
  if (appModeUrlUserId.startsWith("&"))
    ret = "$mainAddress$appModeUrl${serverResponseData.appid}$appModeUrlUserId${serverResponseData.userid}";
  else
    ret =  "$mainAddress$appModeUrl${serverResponseData.appid}$appModeUrlUserId${serverResponseData.userid}/";
  dprint("getAddressTwoMode=$ret");
  return ret;
}

// адрес для отправки QR кода, отправка координат и т.д.
//String addressAPI = "$mainAddress/index.php";            /// по умолчанию
// String addressAPI = "$mainAddress/webview/appmode.php";  /// для snappy
 String addressAPI = "$mainAddress/appmode.php";             /// для https://бонафудс.рф
setIndexPhp() {
  addressAPI = "$mainAddress/appmode.php";
}

const firebaseEnable = false; /// включить/выключить firebase
// const permissionPhoneBook = "In order for the application to download a list of your contacts, your consent to access the phone book is required. If you do not give your consent, then you can only add contacts manually, while all other functionality will be available.";
// const permissionMicrophone = "In order for the application to record sounds, your consent to access the microphone is required. If you do not give your consent, you will not be able to record audio in the application, but all other functionality will be available.";
// const permissionGps = "In order for the app to determine the delivery address based on your location, your consent to receive GPS data from your device is required. If you do not give your consent, it's okay, but you will have to manually specify the delivery address.";
// const permissionFiles = "In order to upload images or files to the application, your consent to access the sending of files is required. If you do not consent to sending files, you will not be able to upload anything to the application, but all other functionality will be available.";
const permissionPhoneBook = "Для того чтобы приложение могло загрузить список ваших контактов, требуется ваше согласие на доступ к телефонной книге. Если вы не дадите согласие, то добавлять контакты можно будет только вручную, при этом, весь остальное функционал будет доступен.";
const permissionMicrophone = "Для того чтобы приложение могло записываеть звуки, требуется ваше согласие на доступ к микрофону. Если вы не дадите согласие, то не сможете записывать звук в приложении, но весь остальное функционал будет доступен.";
const permissionGps = "Для определения адреса разрешите  доступ к геолокации";
const permissionFiles = "Для загрузки фото багажа, разрешите  доступ к Галерее";

const loadIndicatorEnable = false; /// Возможность отключать индикатор загрузки и кнопку настроек
const progressBarColorDefault = Color(0xffadc8dd); /// цвет шкалы индикатора по умолчанию
const progressBarColorError = Color(0xffff000d); /// цвет ошибки
const progressBarColorOk = Color(0xff00ff00); /// цвет зеленый (успешный)

const orientation = false; /// true принудительно горизонтальный, и может меняться за счёт ссылок и js лога
/// false как обычно - реагирует на положение устройства и может меняться за счёт ссылок и js лога

const circularIndicator = false; /// true - кружок
/// false - полоски

String addressNoInternetImage = "$mainAddress/images/appinternet.jpg";    // картинка что нет интернета
String addressNoInternetImageCache = "$mainAddress/images/appcache.jpg";    // картинка что нет в кэше
String addressAppFirst = "$mainAddress/images/appfirst.jpg";    // картинка первого экрана

//
// Кэш
//
bool showIndicators = true; // если true то показывать вверху справа индикатор кэширования и кружок
bool showNoInternetRedBox = false; // если false то не показывать сообщение "Эта сохраненная версия страницы и она..."
String fromCache = "Эта сохраненная версия страницы и она отображается из кеша. Для получения свежей версии страницы, подключите интернет.";
Color fromCacheBackgroundColor = Colors.red; // цвет фона для сообщения - "Эта сохраненная версия страницы и ..."
String noInternetImage = "assets/nointernet.jpg";
String noInternetInCache = "";
String noInternetCacheInCache = "";
int timeForGreenCircleForDeleteCache = 3; // количество секунд которые горит зеленый кружок, потом гаснет

// bool onlyOffline = false;
String noInCacheImage = "assets/noincache.png";

///////////////////////////////////

bool showBottomBar = false;
TextStyle style12W600White = const TextStyle(letterSpacing: 0.6, fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white);
Widget loaderWidget = circularIndicator ? CircularProgressIndicator(color: serverResponseData.loadcolor,) // textColor
    : Loader30(color: serverResponseData.loadcolor, size: 25);
