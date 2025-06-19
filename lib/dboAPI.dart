import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'DataFiles.dart';
import 'type.dart';

class dboAPI {
  static String serverIP = '';
  static int serverPort = 8000;
  String urlAddress = '';

  Map<String, String> extractError(String responseBody) {
    try {
      final body = jsonDecode(responseBody);

      final detailRaw = body['detail'];

      if (detailRaw is String) {
        final regex = RegExp(r"\{.*\}");
        final match = regex.firstMatch(detailRaw);
        if (match != null) {
          final jsonLike = match.group(0)!.replaceAll("'", '"');
          final parsed = jsonDecode(jsonLike);
          return {
            "error_code": parsed['error_code']?.toString() ?? '',
            "message": parsed['message']?.toString() ?? '',
          };
        } else {
          return {
            "error_code": '',
            "message": detailRaw,
          };
        }
      } else if (detailRaw is Map<String, dynamic>) {
        return {
          "error_code": detailRaw['error_code']?.toString() ?? '',
          "message": detailRaw['message']?.toString() ?? '',
        };
      }

      return {
        "error_code": 'Unknown Code',
        "message": 'Unknown Message.',
      };
    } catch (e) {
      return {
        "error_code": 'Exeption Error',
        "message": '$e',
      };
    }
  }

  Future<Uri?> getServerUrl(String endpoint) async {
    Map<String, dynamic>? data = await readJsonFromFile(fileType.serverConfig);
    if (data != null) {
      final serverIP = data['serverIP'];
      final serverPort = data['serverPort'];
      final urlAddress = 'http://$serverIP:$serverPort';
      final url = Uri.parse('$urlAddress$endpoint');
      print('Request URL: $url');
      return url;
    } else {
      return null;
    }
  }



  Future<bool> ping(String ip, int port, {Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
  Future<String?> discoverServerIP({int timeoutSeconds = 10}) async {
    RawDatagramSocket socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 54545);
    print('Listening for UDP broadcasts on port 54545...');

    final completer = Completer<String?>();
    Timer? timer;

    socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram? dg = socket.receive();
        if (dg != null) {
          final message = String.fromCharCodes(dg.data).trim();
          print("Received message: '$message'");
          if (message.contains('fastapi_server')) {
            final ip = dg.address.address;
            print('Server found at $ip');
            if (!completer.isCompleted) {
              completer.complete(ip);
              socket.close();
              timer?.cancel();
            }
          }
        }
      }
    });

    timer = Timer(Duration(seconds: timeoutSeconds), () {
      if (!completer.isCompleted) {
        print('Timeout waiting for UDP broadcast');
        socket.close();
        completer.complete(null);
      }
    });

    return completer.future;
  }
  Future<void> initServerDiscovery() async {
    String? ip = await discoverServerIP();
    if (ip != null) {
      urlAddress = 'http://$ip:8000';
      print("Server is at $urlAddress");
    } else {
      print("Server not found!");
    }
  }

  ApiResponseDatabase<T> handleApiResponsePost<T>(http.Response response) {
    if (response.statusCode == 200) {
      print('Post created successfully!');
      return ApiResponseDatabase<T>(
        success: objApiSuccess(message: "OK", statusCode: response.statusCode),
      );
    } else if (response.statusCode == 500) {
      Map<String, String> temp = extractError(response.body);
      return ApiResponseDatabase<T>(dbo_error: databaseError.fromJson(temp));
    } else {
      return ApiResponseDatabase<T>(
        error: objApiError(message: "Communication Error", statusCode: response.statusCode),
      );
    }
  }

  ApiResponseDatabase<List<T>> handleApiResponseGetList<T>(
      http.Response response,
      T Function(Map<String, dynamic>) fromJson,
      ) {
    // print('Status Code: ${response.statusCode}');
    // print('Response Body: ${response.body}');

    try {
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          final List<T> dataList = decoded
              .map((item) => fromJson(item as Map<String, dynamic>))
              .toList();
          return ApiResponseDatabase<List<T>>(
            data: dataList,
            success: objApiSuccess(message: "OK", statusCode: 200),
          );
        } else {
          throw FormatException("Expected a List in response");
        }
      } else if (response.statusCode == 500) {
        Map<String, String> temp = extractError(response.body);
        return ApiResponseDatabase<List<T>>(
          dbo_error: databaseError.fromJson(temp),
        );
      } else {
        return ApiResponseDatabase<List<T>>(
          error: objApiError(
            message: "Communication Error",
            statusCode: response.statusCode,
          ),
        );
      }
    } catch (e) {
      return ApiResponseDatabase<List<T>>(
        error: objApiError(message: "Parsing Error: $e", statusCode: -1),
      );
    }
  }




  Future<ApiResponseDatabase<User>> jobFetchUser(String user_name) async {
    Map<String, dynamic>? data = await readJsonFromFile(fileType.serverConfig);
    String port;
    if(data != null) {
      serverIP = data['serverIP'];
      serverPort = data['serverPort'];
      port = serverPort.toString();
    }
    else return ApiResponseDatabase<User>(
        error: objApiError(message:'Config file not found', statusCode: 0));

    final String endpoint = '/login/$user_name';
    urlAddress = 'http://$serverIP:$port';
    final Uri url = Uri.parse('$urlAddress$endpoint');
    print(url);
    try {
      final response = await http.get(url);
      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> tempData = json.decode(response.body);
        final user = User.fromJson(tempData);
        return ApiResponseDatabase<User>(data: user);
      } else {
        print("Error fetching user: ${response.body}");
        return ApiResponseDatabase<User>(
            dbo_error: databaseError.fromJson(jsonDecode(response.body)));
      }
    } catch (e) {
      print("Exception: $e");
      return ApiResponseDatabase<User>(
          error: objApiError(message:'Exception Error', statusCode: 0));
    }
  }

  Future<ApiResponseDatabase<UserWithID>> jobFetchUserWithID(String user_name) async {
    Map<String, dynamic>? data = await readJsonFromFile(fileType.serverConfig);
    String port;
    if(data != null) {
      serverIP = data['serverIP'];
      serverPort = data['serverPort'];
      port = serverPort.toString();
    }
    else return ApiResponseDatabase<UserWithID>(
        error: objApiError(message:'Config file not found', statusCode: 0));

    final String endpoint = '/login/$user_name';
    urlAddress = 'http://$serverIP:$port';
    final Uri url = Uri.parse('$urlAddress$endpoint');
    print(url);
    try {
      final response = await http.get(url);
      print("Response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> tempData = json.decode(response.body);
        final user = UserWithID.fromJson(tempData);
        return ApiResponseDatabase<UserWithID>(data: user);
      } else {
        print("Error fetching user: ${response.body}");
        return ApiResponseDatabase<UserWithID>(
            dbo_error: databaseError.fromJson(jsonDecode(response.body)));
      }
    } catch (e) {
      print("Exception: $e");
      return ApiResponseDatabase<UserWithID>(
          error: objApiError(message:'Exception Error', statusCode: 0));
    }
  }

  Future<ApiResponseDatabase<List<TaskStatus>>> jobGetTaskStatus() async {
    final url = await getServerUrl('/GetTaskStatus/');
    if (url == null) {
      return ApiResponseDatabase<List<TaskStatus>>(
        error: objApiError(message: "Config file not found", statusCode: -1),
      );
    }
    print(url);
    try {
      final response = await http.get(url);
      return handleApiResponseGetList<TaskStatus>(response,(json) => TaskStatus.fromJson(json));
    } catch (e) {
      return ApiResponseDatabase<List<TaskStatus>>(
          error: objApiError(message:'Exception: ${e.toString()}', statusCode: -1));
    }
  }

  Future<ApiResponseDatabase<carInfo>> jobGetCarInfo(String searchBy, String param) async {
    Map<String, dynamic>? data = await readJsonFromFile(fileType.serverConfig);
    String port;

    if (data != null) {
      serverIP = data['serverIP'];
      serverPort = data['serverPort'];
      port = serverPort.toString();
    } else {
      // Return ApiError instead of Map directly
      return ApiResponseDatabase<carInfo>(
          error: objApiError(message:'Config file not found', statusCode: 0));
    }

    final String endpoint = '/GetCarInfo/$searchBy/$param';
    urlAddress = 'http://$serverIP:$port';
    final Uri url = Uri.parse('$urlAddress$endpoint');
    print(url);
    try {
      final response = await http.get(url);
      print('${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> tempData = json.decode(response.body);
        final dataTemp = carInfo.fromJson(tempData);
        return ApiResponseDatabase<carInfo>(data: dataTemp);
      }
      else if (response.statusCode == 404) {
        Map<String, String> data = extractError(response.body);
        return ApiResponseDatabase<carInfo>(dbo_error: databaseError.fromJson(data));
      }
      else if (response.statusCode == 500) {
        Map<String, String> data = extractError(response.body);
        return ApiResponseDatabase<carInfo>(dbo_error: databaseError.fromJson(data));
      } else {
        return ApiResponseDatabase<carInfo>(
            error: objApiError(message:'Unexpected error', statusCode: -1));
      }
    } catch (e) {
      return ApiResponseDatabase<carInfo>(
          error: objApiError(message:'Exception: ${e.toString()}', statusCode: -1));
    }
  }

  Future<ApiResponseDatabase<carInfoFromDb>> jobGetCarInfoWithID(String searchBy, String param) async {
    Map<String, dynamic>? data = await readJsonFromFile(fileType.serverConfig);
    String port;

    if (data != null) {
      serverIP = data['serverIP'];
      serverPort = data['serverPort'];
      port = serverPort.toString();
    } else {
      // Return ApiError instead of Map directly
      return ApiResponseDatabase<carInfoFromDb>(
          error: objApiError(message:'Config file not found', statusCode: 0));
    }

    final String endpoint = '/GetCarInfo/$searchBy/$param';
    urlAddress = 'http://$serverIP:$port';
    final Uri url = Uri.parse('$urlAddress$endpoint');
    print(url);
    try {
      final response = await http.get(url);
      print('${response.body}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> tempData = json.decode(response.body);
        final dataTemp = carInfoFromDb.fromJson(tempData);
        return ApiResponseDatabase<carInfoFromDb>(data: dataTemp);
      }
      else if (response.statusCode == 404) {
        Map<String, String> data = extractError(response.body);
        return ApiResponseDatabase<carInfoFromDb>(dbo_error: databaseError.fromJson(data));
      }
      else if (response.statusCode == 500) {
        Map<String, String> data = extractError(response.body);
        return ApiResponseDatabase<carInfoFromDb>(dbo_error: databaseError.fromJson(data));
      } else {
        return ApiResponseDatabase<carInfoFromDb>(
            error: objApiError(message:'Unexpected error', statusCode: -1));
      }
    } catch (e) {
      return ApiResponseDatabase<carInfoFromDb>(
          error: objApiError(message:'Exception: ${e.toString()}', statusCode: -1));
    }
  }

  Future<ApiResponseDatabase<List<carInfo>>> jobGetAllCarInfo() async {
    Map<String, dynamic>? data = await readJsonFromFile(fileType.serverConfig);
    String port;

    if (data != null) {
      serverIP = data['serverIP'];
      serverPort = data['serverPort'];
      port = serverPort.toString();
    } else {
      // Return ApiError instead of Map directly
      return ApiResponseDatabase<List<carInfo>>(
          error: objApiError(message:'Config file not found', statusCode: 0));('Config file not found', 0);
    }

    final String endpoint = '/GetAllCarInfo/';
    urlAddress = 'http://$serverIP:$port';
    final Uri url = Uri.parse('$urlAddress$endpoint');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> tempList = json.decode(response.body);
        final List<carInfo> dataList = tempList.map((item) => carInfo.fromJson(item)).toList();
        return ApiResponseDatabase<List<carInfo>>(data: dataList);
      }
      else if (response.statusCode == 404) {
        Map<String, String> data = extractError(response.body);
        return ApiResponseDatabase<List<carInfo>>(dbo_error: databaseError.fromJson(data));
      } else if (response.statusCode == 500) {
        Map<String, String> data = extractError(response.body);
        return ApiResponseDatabase<List<carInfo>>(dbo_error: databaseError.fromJson(data));
      } else {
        return ApiResponseDatabase<List<carInfo>>(
            error: objApiError(message:'Unexpected error', statusCode: 0));
      }
    } catch (e) {
      return ApiResponseDatabase<List<carInfo>>(
          error: objApiError(message:'Exception: ${e.toString()}', statusCode: 0));
    }
  }

  Future<ApiResponseDatabase<void>> jobPostModelData(Object model, String endpoint) async {

    Uri? url = await getServerUrl(endpoint);
    if (url == null) {
      return ApiResponseDatabase<void>(
        error: objApiError(message: "Config file not found", statusCode: -1),
      );
    }


    Map<String, dynamic> jsonMap;
    try {
      jsonMap = (model as dynamic).toJson();
    } catch (e) {
      return ApiResponseDatabase<void>(
        error: objApiError(message: "Model serialization error: $e", statusCode: -2),
      );
    }

    var body = jsonEncode(jsonMap);

    final response = await http.post(url, body: body, headers: {
      'Content-Type': 'application/json',
    });

    return handleApiResponsePost<void>(response);
  }

  Future<ApiResponseDatabase<void>> jobPostCarInfo(Map<String, dynamic> carInfo) async {

    final url = await getServerUrl('/insertCarInfo/');
    if (url == null) {
      return ApiResponseDatabase<void>(
        error: objApiError(message: "Config file not found", statusCode: -1),
      );
    }
    print(url);
    var body = jsonEncode(carInfo);

    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      return handleApiResponsePost<void>(response);
    } catch (e) {
      print("Exception: $e");
      return ApiResponseDatabase<void>(
        error: objApiError(message: "Exception Error", statusCode: 0),
      );

    }
  }

  Future<ApiResponseDatabase<void>> jobPostCarRepairLog(Map<String, dynamic> problemReport) async {
    final url = await getServerUrl('/CarRepairLog/');
    if (url == null) {
      return ApiResponseDatabase<void>(
        error: objApiError(message: "Config file not found", statusCode: -1),
      );
    }
    print(url);
    var body = jsonEncode(problemReport);
    print(body);
    try {
      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      return handleApiResponsePost<void>(response);
    } catch (e) {
      print("Exception: $e");
      return ApiResponseDatabase<void>(
        error: objApiError(message: "Exception Error", statusCode: 0),
      );

    }
  }

  Future<ApiResponseDatabase<void>> jobUpdateCarInfo(int carId, Map<String, dynamic> carInfo) async {
    final url = await getServerUrl('/updateCarInfo/$carId'); // car_id در آدرس
    if (url == null) {
      return ApiResponseDatabase<void>(
        error: objApiError(message: "Config file not found", statusCode: -1),
      );
    }

    var body = jsonEncode(carInfo);
    print('body: $body');
    try {
      var response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: body,
      );
      return handleApiResponsePost<void>(response);
    } catch (e) {
      print("Exception: $e");
      return ApiResponseDatabase<void>(
        error: objApiError(message: "Exception Error", statusCode: 0),
      );
    }
  }


}
