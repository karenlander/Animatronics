#include <WiFi.h>
#include <FirebaseESP32.h>

#include <addons/TokenHelper.h> // Provide the token generation process info.
#include <addons/RTDBHelper.h> // Provide the RTDB payload printing info and other helper functions.


/* 1.  WiFi credentials */
#define WIFI_SSID "Yair"
#define WIFI_PASSWORD "Ys12345678"
#define WIFI_TIMEOUT_MS 20000



/* 2.  API Key */
#define API_KEY "AIzaSyCW8P63p2VubYJT-iebpYebgv9eYXK-9V8"



/* 3.  RTDB URL */
#define DATABASE_URL "https://animatronics-5ab94-default-rtdb.firebaseio.com/" 



/* 4. user Email and password that alreadey registerd or added in project */
#define USER_EMAIL "yair.sanes@gmail.com"
#define USER_PASSWORD "ESP32test"



FirebaseData fbdo; // Firebase Data object

FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;

unsigned long count = 0;

bool taskCompleted = false;

fs::File file;

void connectToWifi(){
  Serial.print("connecting to WiFi");
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  unsigned long startConnectTime = millis();

  while(WiFi.status()!=WL_CONNECTED && millis()-startConnectTime < WIFI_TIMEOUT_MS){
    Serial.print(".");
    delay(100);
  }

  if(WiFi.status()!=WL_CONNECTED){
    Serial.println();
    Serial.println("Connection Timed Out =[");
    //TODO: take action
    Serial.println("restarting...");
    ESP.restart();
  }else{
    Serial.println();
    Serial.print("Connected! =], IP: ");
    Serial.println(WiFi.localIP());
    Serial.println();
  }
}

void connectToFireBase(){
  Serial.print("connecting to FireBase");
  Serial.printf("Firebase Client v%s\n\n", FIREBASE_CLIENT_VERSION);
  
  config.api_key = API_KEY;
  
  auth.user.email = USER_EMAIL;
  auth.user.password = USER_PASSWORD;

  config.database_url = DATABASE_URL;

  config.token_status_callback = tokenStatusCallback;
  // Or use legacy authenticate method
  // config.signer.tokens.legacy_token = "<database secret>";

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
  Firebase.setDoubleDigits(5);

}


void createFile(){
  if (!DEFAULT_FLASH_FS.begin())
  {
    Serial.println("SPIFFS/LittleFS initialization failed.");
    Serial.println("For Arduino IDE, please select flash size from menu Tools > Flash size");
    return;
  }
    
    // Delete demo files
  if (DEFAULT_FLASH_FS.exists("/file1.txt"))
    DEFAULT_FLASH_FS.remove("/file1.txt");

  if (DEFAULT_FLASH_FS.exists("/file2.txt"))
    DEFAULT_FLASH_FS.remove("/file2.txt");

  const char* text1 = "hello,world!\n";
  const char* text2 = "this is a file from the fire base\n";
  const char* text3 = "same line ";
  const char* text4 = "same line \n";
  const char* text5 = "different line \n";

  file = DEFAULT_FLASH_FS.open("/file1.txt", "w");
  
  file.print(text1);
  file.print(text2);
  file.print(text3);
  file.print(text4);
  file.print(text4);
  file.print(text5);

  file.close();
  
}


// The Firebase download callback function
void rtdbDownloadCallback(RTDB_DownloadStatusInfo info)
{
  if (info.status == fb_esp_rtdb_download_status_init)
  {
    Serial.printf("Downloading file %s (%d) to %s\n", info.remotePath.c_str(), info.size, info.localFileName.c_str());
  }
  else if (info.status == fb_esp_rtdb_download_status_download)
  {
    Serial.printf("Downloaded %d%s\n", (int)info.progress, "%");
  }
  else if (info.status == fb_esp_rtdb_download_status_complete)
  {
    Serial.println("Download completed\n");
  }
  else if (info.status == fb_esp_rtdb_download_status_error)
  {
    Serial.printf("Download failed, %s\n", info.errorMsg.c_str());
  }
}



// The Firebase upload callback function
void rtdbUploadCallback(RTDB_UploadStatusInfo info)
{
  if (info.status == fb_esp_rtdb_upload_status_init)
  {
    Serial.printf("Uploading file %s (%d) to %s\n", info.localFileName.c_str(), info.size, info.remotePath.c_str());
  }
  else if (info.status == fb_esp_rtdb_upload_status_upload)
  {
    Serial.printf("Uploaded %d%s\n", (int)info.progress, "%");
  }
  else if (info.status == fb_esp_rtdb_upload_status_complete)
  {
    Serial.println("Upload completed\n");
  }
  else if (info.status == fb_esp_rtdb_upload_status_error)
  {
    Serial.printf("Upload failed, %s\n", info.errorMsg.c_str());
  }
}




void setup() {
  
  Serial.begin(9600);
  connectToWifi();
  connectToFireBase();
  createFile();

  
}


//void sendVariables(){
// if (Firebase.ready() && (millis() - sendDataPrevMillis > 15000 || sendDataPrevMillis == 0))
//  {
//    sendDataPrevMillis = millis();
//
//    Serial.printf("Set bool... %s\n", Firebase.setBool(fbdo, F("/test/bool"), count % 2 == 0) ? "ok" : fbdo.errorReason().c_str());
//
//    Serial.printf("Get bool... %s\n", Firebase.getBool(fbdo, FPSTR("/test/bool")) ? fbdo.to<bool>() ? "true" : "false" : fbdo.errorReason().c_str());
//
//    bool bVal;
//    Serial.printf("Get bool ref... %s\n", Firebase.getBool(fbdo, F("/test/bool"), &bVal) ? bVal ? "true" : "false" : fbdo.errorReason().c_str());
//
//    Serial.printf("Set int... %s\n", Firebase.setInt(fbdo, F("/test/int"), count) ? "ok" : fbdo.errorReason().c_str());
//
//    Serial.printf("Get int... %s\n", Firebase.getInt(fbdo, F("/test/int")) ? String(fbdo.to<int>()).c_str() : fbdo.errorReason().c_str());
//
//    int iVal = 0;
//    Serial.printf("Get int ref... %s\n", Firebase.getInt(fbdo, F("/test/int"), &iVal) ? String(iVal).c_str() : fbdo.errorReason().c_str());
//
//    Serial.printf("Set float... %s\n", Firebase.setFloat(fbdo, F("/test/float"), count + 10.2) ? "ok" : fbdo.errorReason().c_str());
//
//    Serial.printf("Get float... %s\n", Firebase.getFloat(fbdo, F("/test/float")) ? String(fbdo.to<float>()).c_str() : fbdo.errorReason().c_str());
//
//    Serial.printf("Set double... %s\n", Firebase.setDouble(fbdo, F("/test/double"), count + 35.517549723765) ? "ok" : fbdo.errorReason().c_str());
//
//    Serial.printf("Get double... %s\n", Firebase.getDouble(fbdo, F("/test/double")) ? String(fbdo.to<double>()).c_str() : fbdo.errorReason().c_str());
//
//    Serial.printf("Set string... %s\n", Firebase.setString(fbdo, F("/test/string"), "Hello World!") ? "ok" : fbdo.errorReason().c_str());
//
//    Serial.printf("Get string... %s\n", Firebase.getString(fbdo, F("/test/string")) ? fbdo.to<const char *>() : fbdo.errorReason().c_str());
//
//    // For the usage of FirebaseJson, see examples/FirebaseJson/BasicUsage/Create_Edit_Parse.ino
//    FirebaseJson json;
//
//
//    File file = SPIFFS.open("/test.txt", FILE_READ);
//
//    if(!file){
//     Serial.println("There was an error opening the file for reading");
//    }else{
//      Serial.printf("Set File... %s\n", Firebase.set(fbdo, F("/test/File"), file) ? "ok" : fbdo.errorReason().c_str());
//      Serial.printf("Get File... %s\n", Firebase.get(fbdo, F("/test/File")) ? fbdo.to<const char *>() : fbdo.errorReason().c_str());
//      file.close();
//    }
//    if (count == 0)
//    {
//      json.set("value/round/" + String(count), F("cool!"));
//      json.set(F("vaue/ts/.sv"), F("timestamp"));
//      Serial.printf("Set json... %s\n", Firebase.set(fbdo, F("/test/json"), json) ? "ok" : fbdo.errorReason().c_str());
//    }
//    else
//    {
//      json.add(String(count), "smart!");
//      Serial.printf("Update node... %s\n", Firebase.updateNode(fbdo, F("/test/json/value/round"), json) ? "ok" : fbdo.errorReason().c_str());
//    }
//
//    Serial.println();
//
//    count++;
//  }  
//}


void sendFile(){
  
  if (Firebase.ready() && !taskCompleted)
  {
    taskCompleted = true;

    // File name must be in 8.3 DOS format (max. 8 bytes file name and 3 bytes file extension)


    Serial.println("\nGet file...");
    if (!Firebase.getFile(fbdo, StorageType::FLASH, "test2/file/data", "/file2.txt", rtdbDownloadCallback /* callback function*/))
      Serial.println(fbdo.errorReason());

    if (fbdo.httpCode() == FIREBASE_ERROR_HTTP_CODE_OK)
    {
      // Readout the downloaded file
      file = DEFAULT_FLASH_FS.open("/file2.txt", "r");
      int i = 0;

      while (file.available())
      {
        char v = file.read();

        Serial.print(v);
        i++;
      }

      Serial.println();
      file.close();
    }
  }
  
}

void loop() {

  sendFile();


}
