#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WiFiMulti.h> 
#include <ESP8266mDNS.h>
#include <ESP8266WebServer.h>   // Include the WebServer library

ESP8266WiFiMulti wifiMulti;     // Create an instance of the ESP8266WiFiMulti class, called 'wifiMulti'

ESP8266WebServer server(80);    // Create a webserver object that listens for HTTP request on port 80


void setup(void){
  Serial.begin(115200);         // Start the Serial communication to send messages to the computer
  delay(10);
  Serial.println('\n');

  wifiMulti.addAP("Barreiro 3236", "igalykaren");   // add Wi-Fi networks you want to connect to

  Serial.println("Connecting ...");
  while (wifiMulti.run() != WL_CONNECTED) { // Wait for the Wi-Fi to connect: scan for Wi-Fi networks, and connect to the strongest of the networks above
    delay(250);
    Serial.print('.');
  }
  Serial.println('\n');
  Serial.print("Connected to ");
  Serial.println(WiFi.SSID());              // Tell us what network we're connected to
  Serial.print("IP address:\t");
  Serial.println(WiFi.localIP());           // Send the IP address of the ESP8266 to the computer

  if (MDNS.begin("esp8266")) {              // Start the mDNS responder for esp8266.local
    Serial.println("mDNS responder started");
  } else {
    Serial.println("Error setting up MDNS responder!");
  }

  server.on("/start/", HTTP_GET, playFunction);
  server.on("/stop/", HTTP_GET, stopFunction); 
  server.begin();                           // Actually start the server
  Serial.println("HTTP server started");
}

void loop(void){
  MDNS.update();
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
