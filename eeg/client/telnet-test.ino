#include <WiFi.h> //Wifi library
#include "esp_wpa2.h" //wpa2 library for connections to Enterprise networks
#include <SPI.h>
#include <ArduinoMqttClient.h>
#define EAP_IDENTITY "ecsvihus@ntnu.no" //if connecting from another corporation, use identity@organisation.domain in Eduroam 
#define EAP_USERNAME "ecsvihus" //oftentimes just a repeat of the identity
//#define EAP_PASSWORD "" //your Eduroam password
const char* ssid = "eduroam"; // Eduroam SSID
const char* host = "arduino.php5.sk"; //external server domain for HTTP connection after authentification
int counter = 0;
char eap_password[64];
int port = 1883;

// Enter the IP address of the server you're connecting to:
IPAddress server(10, 212, 173, 112);

const char topic[1]  = {'a'};

// NOTE: For some systems, various certification keys are required to connect to the wifi system.
//       Usually you are provided these by the IT department of your organization when certs are required
//       and you can't connect with just an identity and password.
//       Most eduroam setups we have seen do not require this level of authentication, but you should contact
//       your IT department to verify.
//       You should uncomment these and populate with the contents of the files if this is required for your scenario (See Example 2 and Example 3 below).
//const char *ca_pem = "insert your CA cert from your .pem file here";
//const char *client_cert = "insert your client cert from your .crt file here";
//const char *client_key = "insert your client key from your .key file here";

void setup() {
  Serial.begin(115200);
  delay(10);
  Serial.println();
  Serial.print("Connecting to network: ");
  Serial.println(ssid);
  WiFi.disconnect(true);  //disconnect form wifi to set new wifi connection
  WiFi.mode(WIFI_STA); //init wifi mode

  //getting password
  bool end = false;
  int in = 0;
  String text = "";
  while(!end){
      if(Serial.available() > 0) {
        in = Serial.read();
        text += (char)in;
        if(in == '\n'){
          for(int i = 0;i<text.length()-1;i++){
            eap_password[i] = text[i];
          }
          end = true;
        }
      }
    }


  // Example1 (most common): a cert-file-free eduroam with PEAP (or TTLS)
  WiFi.begin(ssid, WPA2_AUTH_PEAP, EAP_IDENTITY, EAP_USERNAME, eap_password);
  //eap_password = "";

  // Example 2: a cert-file WPA2 Enterprise with PEAP
  //WiFi.begin(ssid, WPA2_AUTH_PEAP, EAP_IDENTITY, EAP_USERNAME, EAP_PASSWORD, ca_pem, client_cert, client_key);
  
  // Example 3: TLS with cert-files and no password
  //WiFi.begin(ssid, WPA2_AUTH_TLS, EAP_IDENTITY, NULL, NULL, ca_pem, client_cert, client_key);
  
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
    counter++;
    if(counter>=60){ //after 30 seconds timeout - reset board
      ESP.restart();
    }
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address set: "); 
  Serial.println(WiFi.localIP()); //print LAN IP
}



void loop() {


  if (WiFi.status() == WL_CONNECTED) { //if we are connected to Eduroam network
    counter = 0; //reset counter
    Serial.println("Wifi is still connected with IP: "); 
    Serial.println(WiFi.localIP());   //inform user about his IP address
  }else if (WiFi.status() != WL_CONNECTED) { //if we lost connection, retry
    WiFi.begin(ssid);      
  }
  while (WiFi.status() != WL_CONNECTED) { //during lost connection, print dots
    delay(500);
    Serial.print(".");
    counter++;
    if(counter>=60){ //30 seconds timeout - reset board
    ESP.restart();
    }
  }
  
  WiFiClient client;


  //sending data  
  if(client.connect(server, 4000)) {
    String text;
    int in = 0;
    Serial.print("\n *** Starting Communication *** \n");
    client.println("\n *** Starting Communication *** \n");

    while(client.connected()){
      if(Serial.available() > 0) {
        in = Serial.read();
        text += (char)in;
        if(in == '\n'){
          client.println(text.substring(0,text.length()-1));
          Serial.print(text);
          text = "";
        }
      }
    }
  } else {
    Serial.print("\nConnection Failed\n");
  }
}
