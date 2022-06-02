#include <WiFi.h>
#include <FirebaseESP32.h>
#include <WiFiClient.h>
#include <WiFiMulti.h>
#include <mDNS.h>
#include <WebServer.h>
#include <Servo_ESP32.h>


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
WebServer server(80);    // Create a webserver object that listens for HTTP request on port 80


// variables will change:

///puppet vars:
const int servoCount = 3;// how many servo 
const int sensorCount = 3;// how many sensors on glove
static const int servosPins[servoCount] = {14,12,26}; // define pins here
Servo_ESP32 servos[servoCount];
int servoDegrees[servoCount] = {0,0,0};
int degShift[servoCount] = {90,0,0};


///firebase objects:
FirebaseData fbdo; // Firebase Data object
FirebaseAuth auth;
FirebaseConfig config;
fs::File file;

///flags:
bool taskCompleted = false;
bool showHttpMsg = true;
bool isPlay = false;
bool isPaused = false;






void connectToWifi() {
  Serial.print("connecting to WiFi");
  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  unsigned long startConnectTime = millis();

  while (WiFi.status() != WL_CONNECTED && millis() - startConnectTime < WIFI_TIMEOUT_MS) {
    Serial.print(".");
    delay(100);
  }

  if (WiFi.status() != WL_CONNECTED) {
    Serial.println();
    Serial.println("Connection Timed Out =[");
    //TODO: take action
    Serial.println("restarting...");
    ESP.restart();
  } else {
    Serial.println();
    Serial.print("Connected! =], IP: ");
    Serial.println(WiFi.localIP());
    Serial.println();
  }
}

void connectToFireBase() {
  Serial.print("Puppet Connecting to FireBase");
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

void attachServos(){
  Serial.println("attachServos");
  for(int i = 0; i < servoCount; ++i) {
    if(!servos[i].attach(servosPins[i])) {
        Serial.print("Servo ");
        Serial.print(i+1);
        Serial.println("attach error");
    }
  }
  Serial.println("attachServos complete");
}

void startHttpServer(){
  server.on("/play/", HTTP_GET, playLastFunction);
  server.on("/playLast/", HTTP_GET, playLastFunction);
  server.on("/stop/", HTTP_GET, stopFunction);
  server.on("/pause/", HTTP_GET, pauseFunction);
  server.begin();                           // Actually start the server
  Serial.println("Puppet HTTP server started");  
}



void setup() {

  Serial.begin(9600);
  Serial.print("\n\n\n");


  attachServos();
  
  connectToWifi();
  connectToFireBase();

  startHttpServer();


}


void getFile_FB() {
  Serial.println("entered getFile_FB");

  if (Firebase.ready() && !taskCompleted) {
    taskCompleted = true;

    const char* filePath1 = "Glove/RecordedMoves/Move";
    const char* filePath2 = "/data";
    const char* numOfMovesPath = "Glove/RecordedMoves/numOfMoves";
    char filePath[40];



    int numOfMoves = (Firebase.getInt(fbdo, F(numOfMovesPath))) ? fbdo.to<int>() : 0;
    //    Serial.printf("numOfMoves: %s\n",String(fbdo.to<int>()).c_str());
    Serial.println("numOfMoves = " + String(numOfMoves));

    if (!numOfMoves) {
      Serial.printf("Failed getting numOfMoves from FireBase: %s", fbdo.errorReason().c_str());
    }
    sprintf(filePath, "%s%d%s", filePath1, numOfMoves, filePath2);
    Serial.printf("filePath = %s", filePath);

    // File name must be in 8.3 DOS format (max. 8 bytes file name and 3 bytes file extension)

    Serial.println("\nGet file...");
    if (!Firebase.getFile(fbdo, StorageType::FLASH, filePath, "/file2.txt", rtdbDownloadCallback /* callback function*/))
      Serial.println(fbdo.errorReason());

    if (fbdo.httpCode() == FIREBASE_ERROR_HTTP_CODE_OK) {
      // Readout the downloaded file
      file = DEFAULT_FLASH_FS.open("/file2.txt", "r");
      int i = 0;
      while (file.available()) {
        char v = file.read();

        Serial.print(v);

        i++;
      }
      Serial.println();
      file.close();
      taskCompleted = false ;
    }
  }

}

void loop() {

  if (showHttpMsg) {
    Serial.println("Puppet HTTP server waiting for requests...");
    showHttpMsg = false;
  }
  server.handleClient();                    // Listen for HTTP requests from clients
  if (isPlay&&!isPaused) playSingleMovement();

}

void pauseFunction(){
  if(isPlay){
    isPaused = true;
    server.send(200, "text/html", "paused movement");
  }else{
    server.send(200, "text/html", "you sould play something first");
  }
}

void playLastFunction() { 

  Serial.println("Entering playLastFunction");
  if (!DEFAULT_FLASH_FS.begin()) {
    Serial.println("SPIFFS/LittleFS initialization failed.");
    Serial.println("For Arduino IDE, please select flash size from menu Tools > Flash size");
    return;
  }
  if(isPaused == false){
    getFile_FB();
    file = DEFAULT_FLASH_FS.open("/file2.txt", "r");
  }

  isPaused = false;
  isPlay = true;
  server.send(200, "text/html", "play received");
}

void setServos(int* degrees) {
    for(int i = 0; i < servoCount; ++i) {
        servos[i].write((degrees[i]) % 180);
    }
}

void playSingleMovement() {
  Serial.println("Entered playSingleMovement");
  String degStr[sensorCount];
  
  if (!file.available()){
    Serial.println();
    file.close();
    isPlay = false;
  }

  for(int i = 0; i < sensorCount; ++i) {
    degStr[i] = file.readStringUntil(',');
  }

  Serial.print("angles: ");
  for(int i = 0; i < servoCount; i++){
      servoDegrees[i] = degStr[i].toInt()+degShift[i];
      Serial.print("\tServo ");
      Serial.print(i+1);
      Serial.print(": ");
      Serial.print(servoDegrees[i]);
  }
  Serial.println();
  
  //Serial.println("angles:" + a1 + " " + a2);

  //int i1 = a1.toInt()+90;
  //int i2 = 0;
  //servo1.write(i1);
  setServos(servoDegrees);
  delay(25);
  
}


void stopFunction() {
  showHttpMsg = true;
  Serial.println("Entering stopFunction:");
  if (!isPlay) {
    Serial.println("stop received before play");
    server.send(200, "text/html", "you sould play something first");
    return;
  }
  isPlay = false;
  Serial.println("file closed");
  file.close();
  server.send(200, "text/html", "stop received");
}
