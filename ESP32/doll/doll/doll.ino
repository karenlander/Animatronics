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

static const int FLEX_PIN = 34; // Pin connected to voltage divider output
static const int FLEX_PIN2 = 35;
const int buttonPin = 21;     // the number of the pushbutton pin
const int ledPin =  13;      // the number of the LED pin

// variables will change:
int buttonState = 0;         // variable for reading the pushbutton status

const int BUFFERSIZE = 3 ;
char buf[BUFFERSIZE];
// Measure the voltage at 5V and the actual resistance of your
// 47k resistor, and enter them below:
const float VCC = 3.3; // Measured voltage of Ardunio 5V line
const float R_DIV = 40000.0; // Measured resistance of 3.3k resistor
// Upload the code, then try to adjust these values to more
// accurately calculate bend degree.
const float STRAIGHT_RESISTANCE = 37300.0; // resistance when straight
const float BEND_RESISTANCE = 90000.0; // resistance at 90 deg

FirebaseData fbdo; // Firebase Data object

FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;

unsigned long count = 0;

bool taskCompleted = false;
bool showHttpMsg = true;
bool isPlay = false;

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




void setup() {
  
  Serial.begin(9600);
  Serial.print("\n\n\n");
  connectToWifi();
  connectToFireBase();
  
  pinMode(FLEX_PIN, INPUT);
 // pinMode(FLEX_PIN2, INPUT);
    // initialize the LED pin as an output:
  //pinMode(ledPin, OUTPUT);
  // initialize the pushbutton pin as an input:
  pinMode(buttonPin, INPUT);

  server.on("/play/", HTTP_GET, playFunction);
  server.on("/stop/", HTTP_GET, stopFunction);
  server.begin();                           // Actually start the server
  Serial.println("HTTP server started");
  
}


void getFile_FB(){
    Serial.println("entered getFile_FB");

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
    sprintf(filePath, "%s%d%s", filePath1,numOfMoves,filePath2);
    Serial.printf("filePath = %s",filePath);
    
    // File name must be in 8.3 DOS format (max. 8 bytes file name and 3 bytes file extension)

    Serial.println("\nGet file...");
    if (!Firebase.getFile(fbdo, StorageType::FLASH, filePath, "/file2.txt", rtdbDownloadCallback /* callback function*/))
      Serial.println(fbdo.errorReason());

    if (fbdo.httpCode() == FIREBASE_ERROR_HTTP_CODE_OK){
      // Readout the downloaded file
      file = DEFAULT_FLASH_FS.open("/file2.txt", "r");
      int i = 0;
      while (file.available()){
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
  
    if(showHttpMsg){
      Serial.println("Puppet HTTP server waiting for requests...");
      showHttpMsg = false;
    }
    server.handleClient();                    // Listen for HTTP requests from clients
    if(isPlay) playSingleMovement();

  
}



void playFunction(){
  Serial.println("Entering playFunction");
  if (!DEFAULT_FLASH_FS.begin()){
    Serial.println("SPIFFS/LittleFS initialization failed.");
    Serial.println("For Arduino IDE, please select flash size from menu Tools > Flash size");
    return;
  }
  getFile_FB();
  file = DEFAULT_FLASH_FS.open("/file2.txt", "r");
  isPlay = true;
  server.send(200, "text/html", "play received");
}
 
 
void playSingleMovement(){
  Serial.println("Entered playSingleMovement");
  char buff[128];
  if (!file.available()){
    Serial.println();
    file.close();
    isPlay = false;
  }
  char v;
  int i = 0;
  while (file.available() && v != '\n'){
        v = file.read();
        Serial.print(v);
        //buff[i++] = v;
      }
      //buff[i] = '\0';
      Serial.println();
      //Serial.println("Line is: " + buff);
}


void stopFunction(){
  showHttpMsg = true;
  Serial.println("Entering stopFunction:");
  if(!isPlay){
    Serial.println("stop received before record");
    server.send(200, "text/html", "no record received prior");
    return;
  }
  isPlay = false;
  Serial.println("file closed");
  file.close();
  server.send(200, "text/html", "stop received");
}
