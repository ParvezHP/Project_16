
import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // create credentials
  static const _credentials = r'''
  {
  "type": "service_account",
  "project_id": "financial-tracker-339116",
  "private_key_id": "d0d0cb235984c03bfdbe156c45ce2373a81fb16b",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDrXW2HdQi3Uebp\nGd6HrK6yOJmsgAuOftL2HozGf4GgqOyZ1f6s8KMWEv6fRs/TW75Zug4yIpMTTfbD\ndzXGolj3BlTp/7CBYMK3PpYlQ9X+A1/iamrDG3dPUUSw+EAlUhvLaJ3wciR3OQeS\nTFuYGz8YNurMHQ1HIar58rQsP5/BZL47iOwhEyaAs3t8F0wRrmTpek/L/QTbDX+D\ninlfkCT8Z+TUHYEbEDPWj+TF0G1+/O72W+0gRXc/nLQMg59zNHo98yhNIYg1K/78\ndAilAzTCd6fTPc2ehnm0rR96YVdORmuIvLTZIw4IY3NXxZasgqJggNNRbQ9isnnu\n1dEL79RjAgMBAAECggEAJuiQ/L2aLUP62joOkXs4ffnhXaTlRC8vDMTMHNxjP33t\nbxjzOv+k1jdZpFb+cEBQXWDmi98vVRekXXfNigK4lk2TqAM+2IR4a/aKt6pZK96+\n8R0KfSqDNLeIlYDUidbjBWNMCL21zYe9+q9ozOJkMcqSUh/TXBjyvNMkedQiwsNl\nju4fkNYhcxkSc9nm72djy5WxWyXQfjm8DJqbJfqRZrTRMnUcNDsO376rnt3zUJYd\nc3Hry1ew0RBMkRkOCxPs34bR2ANGfiHXG7pEzWEKRk5cyAnAoLq+McXS5bF9tMCM\nssN82k2+xk0CoKRyDKGX/YvgJZrbCygqNFI7jshR8QKBgQD1i0wW/R19Ovn0lh6m\n/hk2DsI91DLfuC06zfA0gsz/1oe38tCcGu/ZGuCk1gm1TLJJ80WTexO9Tv7PhCzq\nst4L40kq/+LSxLvAr6ZPX4C6eVBWurpBHNMVH18F4pxCdEYpKkXPavg+NlGEjMmg\namjkj1xTR6DMi87iYotfml+zVQKBgQD1YyqUO1ADUXrTSzDdMFsGzaP2ib5u9AmQ\n4d5TyEI8+8NZjn75Gdo+aAATtqaUUIDZbqmsXYPbqizPwMZBuH5RihJZ9Mwwa5Ad\nFmBaz1HPOZcm+pYnLDmJz5MU7PfN3QT/g6cP04XajBXJOwJTVQ9IWjIeLYyKh8v6\nTpui5j9Y1wKBgQCtGkjIJCU39e3lKjftzlEDtR/m6sP6yCLKxAhFXLkc26bOXZYH\nl03jpnkce/BYKfu++ovgTvI5kYk9zpbD1tmHU/JvJ/pGUH90deAvMMrVq1Sh7/4C\njUmaKIWa5oj2qHYV60FP2r+rTCvn4ED8oEfWaeLSqzqHOUDehE5xVamGCQKBgE11\nGwilXFFf0+SEdI0taV5RZTM6Mal2UNqx4WsS6I21bumDCGN7HJ/cVkHiwtxIORPp\nUZe+ARRCuFhv4mT2ZrE4YyiQFDAok9oKqSmhDZLa+/Jq4SDGXfc5VZUiY+pQnPZG\nyWI+g58D3xChFs/VJrjQ98b828MSsHl3fLtD8LULAoGAIfl/GW+couo/MdOhASOi\njOMRzW7+pwicuSZRAA7NjSPfw7f+kdOJxEVuD8vjNugIwx26ZU/lGH7MdRcrsCkh\n+CBlf9nv2luGhxS2rJ5nBCL+krn9D6q9uIsAemhJHJQCWUS02sNCSqepH9xUXupq\n8oyMHrbsLpOGxSPImlU8QS8=\n-----END PRIVATE KEY-----\n",
  "client_email": "trackerdft@financial-tracker-339116.iam.gserviceaccount.com",
  "client_id": "108872108604630245117",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/trackerdft%40financial-tracker-339116.iam.gserviceaccount.com"
}

  ''';

  // set up & connect to the spreadsheet
  static final _spreadsheetId = '1kEGwc107PS808CIoryzHkAsBnX505I5ZYQv7AYauSnE';
  static final _gsheets = GSheets(_credentials);
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static int numberOfTransactions = 0;
  static List<List<dynamic>> currentTransactions = [];
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    final ss = await _gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Worksheet1');
    countRows();
  }

  // count the number of notes
  static Future countRows() async {
    while ((await _worksheet!.values
            .value(column: 1, row: numberOfTransactions + 1)) !=
        '') {
      numberOfTransactions++;
    }
    // now we know how many notes to load, now let's load them!
    loadTransactions();
  }

  // load existing notes from the spreadsheet
  static Future loadTransactions() async {
    if (_worksheet == null) return;

    for (int i = 1; i < numberOfTransactions; i++) {
      final String transactionName =
          await _worksheet!.values.value(column: 1, row: i + 1);
      final String transactionAmount =
          await _worksheet!.values.value(column: 2, row: i + 1);
      final String transactionType =
          await _worksheet!.values.value(column: 3, row: i + 1);

      if (currentTransactions.length < numberOfTransactions) {
        currentTransactions.add([
          transactionName,
          transactionAmount,
          transactionType,
        ]);
      }
    }
    print(currentTransactions);
    // this will stop the circular loading indicator
    loading = false;
  }

  // insert a new transaction
  static Future insert(String name, String amount, bool _isIncome) async {
    if (_worksheet == null) return;
    numberOfTransactions++;
    currentTransactions.add([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
    await _worksheet!.values.appendRow([
      name,
      amount,
      _isIncome == true ? 'income' : 'expense',
    ]);
  }

  // CALCULATE THE TOTAL INCOME!
  static double calculateIncome() {
    double totalIncome = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'income') {
        totalIncome += double.parse(currentTransactions[i][1]);
      }
    }
    return totalIncome;
  }

  // CALCULATE THE TOTAL EXPENSE!
  static double calculateExpense() {
    double totalExpense = 0;
    for (int i = 0; i < currentTransactions.length; i++) {
      if (currentTransactions[i][2] == 'expense') {
        totalExpense += double.parse(currentTransactions[i][1]);
      }
    }
    return totalExpense;
  }
}
