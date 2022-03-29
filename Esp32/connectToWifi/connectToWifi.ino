#include <WiFi.h>;

const char* ssid = "Yair";
const char* password = "Ys12345678";

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  WiFi.begin(ssid, password);
  Serial.print("Connect");

  while (WiFi.status() != WL_CONNECTED){
    Serial.print(WiFi.status());
    delay(500);  
  }

  Serial.println("\nConnected to the Wifi");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  // put your main code here, to run repeatedly:
  if((WiFi.status() == WL_CONNECTED)){
    Serial.println("ping");
    delay(5000);  
    
  }else {
      Serial.println("connection lost");
  }
  

  
}
