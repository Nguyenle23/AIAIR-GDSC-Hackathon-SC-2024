import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

Map<String, dynamic> formatDateTime(String dateTimeString, String timeZone) {
  DateTime dateTime = DateTime.parse(dateTimeString).toLocal();

  // Convert to the specified time zone
  tz.Location location = tz.getLocation(timeZone);
  tz.TZDateTime convertedTime = tz.TZDateTime.from(dateTime, location);

  String collectedTime = DateFormat('HH:mm:ss').format(dateTime).toString();
  String dayOfWeek =
      DateFormat('EEEE', 'en_US').format(convertedTime).toString();
  String day =
      DateFormat('dd-MM-yyyy', 'en_US').format(convertedTime).toString();
  String amPm = DateFormat('a', 'en_US').format(convertedTime).toString();

  Map<String, dynamic> returnObject = {
    'collectedTime': collectedTime,
    'dayOfWeek': dayOfWeek,
    'day': day,
    'amPm': amPm,
  };

  return returnObject;
}
