#include <WiFi.h>
#include <FirebaseESP32.h>
#include <WiFiClient.h>
#include <WiFiMulti.h>
#include <mDNS.h>
#include <WebServer.h>
#include <Servo_ESP32.h>


#include "I2Cdev.h"
#include "MPU6050_6Axis_MotionApps20.h"
//#include "MPU6050.h" // not necessary if using MotionApps include file
// Arduino Wire library is required if I2Cdev I2CDEV_ARDUINO_WIRE implementation
// is used in I2Cdev.h
#if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
    #include "Wire.h"
#endif


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
float int_closed_mouth_angle = 0;
float open_mouth_angle = 60 ;

int first_servo_starting_angle_flag = 0;
int secound_servo_starting_angle_flag = 0;
int third_servo_starting_angle_flag = 0;
float first_servo_starting_angle = 0;
float secound_servo_starting_angle = 90;
float third_servo_starting_angle = 90;
///sensor vars:
const int sensorCount = 3;// how many sensors 
static const int sensorsPins[sensorCount] = {34,12,26}; // define pins here
int prevAng[sensorCount] = {0, 90, 90};
bool isFirstAng[sensorCount] = {true, true, true};
int filterAngs[sensorCount] = {5, 10, 10};
float angW = 0.5;
float readW = 0.5;
//MPU:
MPU6050 mpu;
// MPU control/status vars
bool dmpReady = false;  // set true if DMP init was successful
uint8_t mpuIntStatus;   // holds actual interrupt status byte from MPU
uint8_t devStatus;      // return status after each device operation (0 = success, !0 = error)
uint16_t packetSize;    // expected DMP packet size (default is 42 bytes)
uint16_t fifoCount;     // count of all bytes currently in FIFO
uint8_t fifoBuffer[64]; // FIFO storage buffer
// orientation/motion vars
Quaternion q;           // [w, x, y, z]         quaternion container
VectorFloat gravity;    // [x, y, z]            gravity vector
float ypr[3];           // [yaw, pitch, roll]   yaw/pitch/roll container and gravity vector


///puppet vars:
const int servoCount = 3;// how many servo
static const int servosPins[servoCount] = {14, 12, 26}; // define pins here
//Servo servos[servoCount];
Servo_ESP32 servos[servoCount];
int servoDegrees[servoCount] = {0, 90, 90};
int degShift[servoCount] = {0, 0, 0};

///Puppet consts:
const int MOUTH_OPEN = 40;
const int MOUTH_CLOSED = 0;
const int PAN_LEFT = 160;
const int PAN_RIGHT = 20;
const int TILT_UP = 135;
const int TILT_DOWN = 45;




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
bool servoConnected = true;


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


void attachServos() {
  Serial.println("attachServos");
  for (int i = 0; i < servoCount; ++i) {
    if (!servos[i].attach(servosPins[i])) {
      Serial.print("Servo ");
      Serial.print(i + 1);
      Serial.println("attach error");
    }
  }
  Serial.println("attachServos complete");
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

void setupMPU(){
      // join I2C bus (I2Cdev library doesn't do this automatically)
    #if I2CDEV_IMPLEMENTATION == I2CDEV_ARDUINO_WIRE
        Wire.begin();
        Wire.setClock(400000); // 400kHz I2C clock. Comment this line if having compilation difficulties
    #elif I2CDEV_IMPLEMENTATION == I2CDEV_BUILTIN_FASTWIRE
        Fastwire::setup(400, true);
    #endif

    // initialize serial communication
    // (115200 chosen because it is required for Teapot Demo output, but it's
    // really up to you depending on your project)
    while (!Serial); // wait for Leonardo enumeration, others continue immediately

    // NOTE: 8MHz or slower host processors, like the Teensy @ 3.3V or Arduino
    // Pro Mini running at 3.3V, cannot handle this baud rate reliably due to
    // the baud timing being too misaligned with processor ticks. You must use
    // 38400 or slower in these cases, or use some kind of external separate
    // crystal solution for the UART timer.

    // initialize device
    Serial.println(F("Initializing I2C devices..."));
    mpu.initialize();

    // verify connection
    Serial.println(F("Testing device connections..."));
    Serial.println(mpu.testConnection() ? F("MPU6050 connection successful") : F("MPU6050 connection failed"));


    // load and configure the DMP
    Serial.println(F("Initializing DMP..."));
    devStatus = mpu.dmpInitialize();

    // supply your own gyro offsets here, scaled for min sensitivity
    mpu.setXGyroOffset(220);
    mpu.setYGyroOffset(76);
    mpu.setZGyroOffset(-85);
    mpu.setZAccelOffset(1788); // 1688 factory default for my test chip

    // make sure it worked (returns 0 if so)
    if (devStatus == 0) {
        // Calibration Time: generate offsets and calibrate our MPU6050
        mpu.CalibrateAccel(6);
        mpu.CalibrateGyro(6);
        mpu.PrintActiveOffsets();
        // turn on the DMP, now that it's ready
        Serial.println(F("Enabling DMP..."));
        mpu.setDMPEnabled(true);

        // enable Arduino interrupt detection
        Serial.print(F("Enabling interrupt detection (Arduino external interrupt "));
        Serial.println(F(")..."));
        mpuIntStatus = mpu.getIntStatus();

        // set our DMP Ready flag so the main loop() function knows it's okay to use it
        Serial.println(F("DMP ready! Waiting for first interrupt..."));
        dmpReady = true;

        // get expected DMP packet size for later comparison
        packetSize = mpu.dmpGetFIFOPacketSize();
    } else {
        // ERROR!
        // 1 = initial memory load failed
        // 2 = DMP configuration updates failed
        // (if it's going to break, usually the code will be 1)
        Serial.print(F("DMP Initialization failed (code "));
        Serial.print(devStatus);
        Serial.println(F(")"));
    }
}



void setup() {
  
  Serial.begin(115200);
  Serial.print("\n\n\n");

  setupMPU();
  attachSensors();
  attachServos();
  resetPuppet();


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

  
    if (!dmpReady) {
      Serial.println("MPU Error: DMP not initialized correctly");
      return;
    }
    if(showHttpMsg){
      Serial.println("Glove HTTP server waiting for requests...");
      showHttpMsg = false;
    }
    server.handleClient();                    // Listen for HTTP requests from clients
    if(isRecord) recordSingleMovement();


    //runTests();
}

void runTests(){
  
  Serial.println("test 1");
  setServos(servoDegrees);
  delay(100);
  Serial.println("test 2");
  servoDegrees[0]=0;
  servoDegrees[1]=90;
  servoDegrees[2]=90;
  setServos(servoDegrees);
  delay(100);
  servoDegrees[0]=40;
  servoDegrees[1]=90;
  servoDegrees[2]=90;
  setServos(servoDegrees);
  delay(100);
  servoDegrees[0]=0;
  servoDegrees[1]=90;
  servoDegrees[2]=90;
  setServos(servoDegrees);
  delay(25000);
  
}



void recordFunction(){
  first_servo_starting_angle_flag = 1;
  secound_servo_starting_angle_flag=1;
  third_servo_starting_angle_flag = 1; 
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


void resetPuppet(){
  delay(100);
  servoDegrees[0]=0;
  servoDegrees[1]=90;
  servoDegrees[2]=90;
  setServos(servoDegrees);
  delay(100);
}

 
void stopFunction(){
  resetPuppet();
  showHttpMsg = true;
  prevAng[0] = 0;
  prevAng[1] = 90;
  prevAng[2] = 90;
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
    default:
      Serial.println("sensor index: " + String(sensorIndex) + "not exists");
      return 0;
  }
}

int readFromFlex(int sensorIndex){
  int flexADC = analogRead(sensorsPins[sensorIndex]);
  float flexV = flexADC * VCC / 1023.0;
  float flexR = R_DIV * (VCC / flexV - 1.0);
    // Use the calculated resistance to estimate the sensor's
  // bend angle:
  float angle = map(flexR, STRAIGHT_RESISTANCE, BEND_RESISTANCE,0, 90.0);
  if(first_servo_starting_angle_flag){
    first_servo_starting_angle_flag = 0;
    first_servo_starting_angle = angle;
    return 0;
    }
    angle = 45 - angle - first_servo_starting_angle;
   if(angle < 0){
    return 0 ;
    }
   if(angle > 45){
    return 45;
    }
  return angle;
}

int readFromMPU(int sensorIndex){
  switch(sensorIndex){
    case 1:
    if(secound_servo_starting_angle_flag){
      secound_servo_starting_angle_flag=0;
    secound_servo_starting_angle = (ypr[0] * 180/M_PI);
    return 90;
    }if(((ypr[0] * 180/M_PI) - secound_servo_starting_angle)+90 < 0){
        return 0;
        }
        if(((ypr[0] * 180/M_PI) - secound_servo_starting_angle)+90 > 180){
          return 180;
          
          }
      return ((ypr[0] * 180/M_PI) - secound_servo_starting_angle) +90;

    case 2:
        if(third_servo_starting_angle_flag){
          third_servo_starting_angle_flag = 0 ;
   third_servo_starting_angle = (ypr[2] * 180/M_PI);
    return 90;
      }
//      if(180 - ((ypr[1] * 180/M_PI) - third_servo_starting_angle)+90 < 0){
      if(((ypr[1] * 180/M_PI) - third_servo_starting_angle)+90 < 0){

        return 0;
        }
//        if(180 - ((ypr[1] * 180/M_PI) - third_servo_starting_angle)+90 > 180){
        if(((ypr[1] * 180/M_PI) - third_servo_starting_angle)+90 > 180){

          return 180;
          
          }
  //    return (int)(180-((ypr[1] * 180/M_PI) - third_servo_starting_angle)+90)%180;
      return ((ypr[1] * 180/M_PI) - third_servo_starting_angle)+90;

    default:
      Serial.println("sensor index: " + String(sensorIndex) + "not exists");
      return 0;
      
  }
}


void recordSingleMovement(){
  if (mpu.dmpGetCurrentFIFOPacket(fifoBuffer)) {
    mpu.dmpGetQuaternion(&q, fifoBuffer);
    mpu.dmpGetGravity(&gravity, &q);
    mpu.dmpGetYawPitchRoll(ypr, &q, &gravity);
    //Serial.println("Y: " + String(ypr[0]) + "P: " + String(ypr[1]) + "R: " + String(ypr[2]));

    int SensorsAngs[sensorCount];
    for(int i = 0; i < sensorCount; ++i) {
      SensorsAngs[i] = readFromSensor(i);
      //Serial.println("1: " + String(SensorsAngs[0]) + "2: " + String(SensorsAngs[1]) + "3: " + String(SensorsAngs[2]));

      if(isFirstAng[i]){
        isFirstAng[i] = false;
        prevAng[i] = SensorsAngs[i];  
      }
      if(filterAngs[i] != 0){
        if(i == 0){ // mouth
          //prevAng[i] = prevAng[i]*angW + SensorsAngs[i]*readW;
          SensorsAngs[i] = prevAng[i]*angW + SensorsAngs[i]*readW;
        }
         if((prevAng[i] > SensorsAngs[i]) && (prevAng[i] - SensorsAngs[i] >  filterAngs[i])){
          if( prevAng[i] - filterAngs[i]<=0){
            prevAng[i] = 0 ;
            }
            else{ prevAng[i] = prevAng[i] - filterAngs[i];}
        }
        if((prevAng[i] < SensorsAngs[i]) && (SensorsAngs[i] - prevAng[i] > filterAngs[i])){
          prevAng[i] = prevAng[i] + filterAngs[i];
        
        }

        SensorsAngs[i] = prevAng[i];
      }
  
      file.print(String(SensorsAngs[i]) + ",");
      Serial.print("S" + String(i) + ": " + String(SensorsAngs[i]) + "\t");
    }

    if(servoConnected){
      setServos(SensorsAngs);
    }
    
    
    file.println();
    Serial.println();
     
    delay(25);
  }else{
    Serial.println("recordSingleMovement: mpu.dmpGetCurrentFIFOPacket(fifoBuffer) is false");
  }
   
}

void setServos(int* degrees) {

  if(degrees[0]<MOUTH_CLOSED)degrees[0]=MOUTH_CLOSED;
  if(degrees[0]>MOUTH_OPEN)degrees[0]=MOUTH_OPEN;
  
  if(degrees[1]<PAN_RIGHT)degrees[1]=PAN_RIGHT;
  if(degrees[1]>PAN_LEFT)degrees[1]=PAN_LEFT;
  
  if(degrees[2]<TILT_DOWN)degrees[2]=TILT_DOWN;
  if(degrees[2]>TILT_UP)degrees[2]=TILT_UP;
  //Serial.println();
  for (int i = 0; i < servoCount; ++i) {
    servos[i].write((degrees[i]) % 180);
    //Serial.print("SetServos S" + String(i) + ": " + String(degrees[i]) + "\t");
  }
}
