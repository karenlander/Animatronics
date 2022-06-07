#include <WiFi.h>
#include <FirebaseESP32.h>
#include <WiFiClient.h>
#include <WiFiMulti.h>
#include <mDNS.h>
#include <WebServer.h>

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

///sensor consts:
// Measure the voltage at 5V and the actual resistance of your
// 47k resistor, and enter them below:
const float VCC = 3.3; // Measured voltage of Ardunio 5V line
const float R_DIV = 40000.0; // Measured resistance of 3.3k resistor
// Upload the code, then try to adjust these values to more
// accurately calculate bend degree.
const float STRAIGHT_RESISTANCE = 37300.0; // resistance when straight
const float BEND_RESISTANCE = 90000.0; // resistance at 90 deg


///sensor vars:
const int sensorCount = 3;// how many sensors 
static const int sensorsPins[sensorCount] = {34,12,26}; // define pins here
int prevAng[sensorCount] = {0, 0, 0};
bool isFirstAng[sensorCount] = {true, true, true};
int filterAngs[sensorCount] = {5, 0, 0};


///firebase objects:
FirebaseData fbdo; // Firebase Data object
FirebaseAuth auth;
FirebaseConfig config;
fs::File file;

///flags:
bool taskCompleted = false;
bool showHttpMsg = true;
bool isRecord = false;
bool VerifySendFile = false;


void connectToWifi(){
  Serial.print("Glove Connecting to WiFi");
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



void attachSensors(){
  Serial.println("attachSensors");
  for(int i = 0; i < sensorCount; ++i) {
    pinMode(sensorsPins[i], INPUT);
  }
  Serial.println("attachSensors complete");
}

void startHttpServer(){
  server.on("/record/", HTTP_GET, recordFunction);
  server.on("/stop/", HTTP_GET, stopFunction);
  server.begin();                           // Actually start the server
  Serial.println("Glove HTTP server started");
}

void setup() {
  
  Serial.begin(9600);
  Serial.print("\n\n\n");


  attachSensors();
  
  connectToWifi();
  connectToFireBase();
  
  startHttpServer();

 
}


void sendFile(){
    Serial.println("entered sendFile");

  if (Firebase.ready() && !taskCompleted){
    taskCompleted = true;

    const char* filePath1 = "Glove/RecordedMoves/Move";
    const char* filePath2 = "/data";
    const char* numOfMovesPath = "Glove/RecordedMoves/numOfMoves";
    char filePath[40];

    
    
    int numOfMoves = (Firebase.getInt(fbdo, F(numOfMovesPath)))?fbdo.to<int>():0;
//    Serial.printf("numOfMoves: %s\n",String(fbdo.to<int>()).c_str());
    Serial.println("numOfMoves = " + String(numOfMoves));

    if(!numOfMoves){
       Serial.printf("Failed getting numOfMoves from FireBase: %s",fbdo.errorReason().c_str());  
    }   
    Serial.printf("Set %s... %s\n",numOfMovesPath, Firebase.setInt(fbdo, F(numOfMovesPath), ++numOfMoves) ? "ok" : fbdo.errorReason().c_str());
    sprintf(filePath, "%s%d%s", filePath1,numOfMoves,filePath2);
    Serial.printf("filePath = %s",filePath);
    
    // File name must be in 8.3 DOS format (max. 8 bytes file name and 3 bytes file extension)
    Serial.println("\nSet file...");
    if (!Firebase.setFile(fbdo, StorageType::FLASH, filePath, "/file1.txt", rtdbUploadCallback /* callback function*/))
      Serial.println(fbdo.errorReason());
    if(VerifySendFile){
      Serial.println("\nGet file...");
      if (!Firebase.getFile(fbdo, StorageType::FLASH, filePath, "/file2.txt", rtdbDownloadCallback /* callback function*/))
        Serial.println(fbdo.errorReason());

      if (fbdo.httpCode() == FIREBASE_ERROR_HTTP_CODE_OK){
        // Readout the downloaded file
        file = DEFAULT_FLASH_FS.open("/file2.txt", "r");
        while (file.available()){
          char v = file.read();
          Serial.print(v);
        }
        Serial.println();
        file.close();
      }
    }
    taskCompleted = false ; 
  }  
}

void loop() {
  
    if(showHttpMsg){
      Serial.println("Glove HTTP server waiting for requests...");
      showHttpMsg = false;
    }
    server.handleClient();                    // Listen for HTTP requests from clients
    if(isRecord) recordSingleMovement();

  
}



void recordFunction(){
  Serial.println("Entering recordFunction");
    if (!DEFAULT_FLASH_FS.begin()){
    Serial.println("SPIFFS/LittleFS initialization failed.");
    Serial.println("For Arduino IDE, please select flash size from menu Tools > Flash size");
    return;
  }
//   buttonState = digitalRead(buttonPin);
  
  if (DEFAULT_FLASH_FS.exists("/file1.txt")){
    DEFAULT_FLASH_FS.remove("/file1.txt");
  }
 
  file = DEFAULT_FLASH_FS.open("/file1.txt", "w");
  isRecord = true;
  server.send(200, "text/html", "record received");
  Serial.println("Entering recordSingleMovement");

}
 
void stopFunction(){
  showHttpMsg = true;
  Serial.println("Entering stopFunction");
  if(!isRecord){
    Serial.println("stop received before record");
    server.send(200, "text/html", "no record received prior");
    return;
  }
  isRecord = false;
  Serial.println("file closed");
  file.close();
  sendFile();
  server.send(200, "text/html", "stop received");
}

int readFromSensor(int sensorIndex){
  switch(sensorIndex){
    case 0: //FLEX
      return readFromFlex(sensorIndex);
    case 1:
    case 2: //MPU
      return readFromMPU(sensorIndex);
  }
}

int readFromFlex(int sensorIndex){
  int flexADC = analogRead(sensorsPins[sensorIndex]);
  float flexV = flexADC * VCC / 1023.0;
  float flexR = R_DIV * (VCC / flexV - 1.0);
    // Use the calculated resistance to estimate the sensor's
  // bend angle:
  float angle = map(flexR, STRAIGHT_RESISTANCE, BEND_RESISTANCE,0, 90.0);
  return angle;
}

int readFromMPU(int sensorIndex){
  int reading = analogRead(sensorsPins[sensorIndex]);
  return 0;
}


void recordSingleMovement(){
  int SensorsAngs[sensorCount];
  for(int i = 0; i < sensorCount; ++i) {
    SensorsAngs[i] = readFromSensor(i);
    if(isFirstAng[i]){
      isFirstAng[i] = false;
      prevAng[i] = SensorsAngs[i];  
    }
    if(filterAngs[i] != 0){
      if((prevAng[i] > SensorsAngs[i]) && (prevAng[i] - SensorsAngs[i] >  filterAngs[i])){
        prevAng[i] = prevAng[i] - filterAngs[i];
      }
      if((prevAng[i] < SensorsAngs[i]) && (SensorsAngs[i] - prevAng[i] > filterAngs[i])){
        prevAng[i] = prevAng[i] + filterAngs[i];
      } 
      SensorsAngs[i] = prevAng[i];
    }

    file.print(String(prevAng[i]) + ",");
    Serial.print("S" + String(i) + ": " + String(prevAng[i]) + "\t");
  }
  
  file.println();
  Serial.println();
   
  delay(25);
  
}




