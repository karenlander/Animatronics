#include <WiFi.h>;
#include <WiFiClient.h>
#include <WiFiMulti.h> 
#include <mDNS.h>
#include <WebServer.h>   // Include the WebServer library

WiFiMulti wifiMulti;     // Create an instance of the ESP8266WiFiMulti class, called 'wifiMulti'

WebServer server(80);    // Create a webserver object that listens for HTTP request on port 80
const char* ssid = "Yair";
const char* password = "Ys12345678";

void setup(void){
  Serial.begin(115200);         // Start the Serial communication to send messages to the computer
  delay(10);
  Serial.println('\n');

  WiFi.begin(ssid, password);

  Serial.println("Connecting ...");
  while (WiFi.status() != WL_CONNECTED) { // Wait for the Wi-Fi to connect: scan for Wi-Fi networks, and connect to the strongest of the networks above
    delay(250);
    Serial.print('.');
  }
  Serial.println('\n');
  Serial.print("Connected to ");
  Serial.println(WiFi.SSID());              // Tell us what network we're connected to
  Serial.print("IP address:\t");
  Serial.println(WiFi.localIP());           // Send the IP address of the ESP8266 to the computer



  server.on("/play/", HTTP_GET, playFunction);
  server.on("/stop/", HTTP_GET, stopFunction); 
  server.begin();                           // Actually start the server
  Serial.println("HTTP server started");
}

void loop(void){

  server.handleClient();                    // Listen for HTTP requests from clients
}

void playFunction(){
  Serial.println("Entering play");
  server.send(200, "text/html", "play received");
}

void stopFunction(){
  Serial.println("Entering stop");
   server.send(200, "text/html", "stop received");

}
