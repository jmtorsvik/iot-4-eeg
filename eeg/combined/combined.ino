#include <Filters.h>
#include <Filters/Butterworth.hpp>
#include <WiFi.h> //Wifi library
#include "esp_wpa2.h" //wpa2 library for connections to Enterprise networks
#include <SPI.h>
#include <BLEDevice.h>
#include <BLEServer.h>

#define SERVICE_UUID "fdf81135-b37f-4d16-8b22-eb4200d07ad1"
#define USERNAME_UUID "85c70960-789f-405d-aca8-d84167bd0fd9"
#define PASSWORD_UUID "1e924c7d-f95f-4468-afc8-67372dc559fc"
#define SAMPLE_RATE 256
#define BAUD_RATE 115200
#define INPUT_PIN 34

const char* ssid = "eduroam"; // Eduroam SSID
const char* host = "arduino.php5.sk"; //external server domain for HTTP connection after authentification
IPAddress server(10, 212, 173, 112);
int counter = 0;

float SIGNAL;
float SENSOR_VALUE;

static long TIMER = 0;
static unsigned long PAST = 0;

void setup() {
	// Serial connection begin
	Serial.begin(115200);
  delay(10);

  Serial.println("Starting BLE work!");
  
  BLEDevice::init("EEG_CONTROLLER_2");
  BLEServer* pServer = BLEDevice::createServer();
  BLEService* pService = pServer->createService(SERVICE_UUID);
  BLECharacteristic* usernameCharacteristic = pService->createCharacteristic(
                                         USERNAME_UUID,
                                         BLECharacteristic::PROPERTY_READ | // TODO: Delete PROPERTY_READ
                                         BLECharacteristic::PROPERTY_WRITE
                                       );
  BLECharacteristic* passwordCharacteristic = pService->createCharacteristic(
                                         PASSWORD_UUID,
                                         BLECharacteristic::PROPERTY_READ | // TODO: Delete PROPERTY_READ
                                         BLECharacteristic::PROPERTY_WRITE
                                       );

  usernameCharacteristic->setValue("");
  passwordCharacteristic->setValue("");
  pService->start();
  // BLEAdvertising *pAdvertising = pServer->getAdvertising();  // this still is working for backward compatibility
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("Characteristic defined! Now you can read it in your phone!");


  std::string usernameTest = usernameCharacteristic->getValue();
  std::string passwordTest = usernameCharacteristic->getValue();

  while(usernameTest == "" || passwordTest == ""){
    usernameTest = usernameCharacteristic->getValue();
    passwordTest = passwordCharacteristic->getValue();
    delay(500);
  }

  const std::string eapID = usernameCharacteristic->getValue().c_str();
  const std::string password = passwordCharacteristic->getValue().c_str();

  BLEDevice::deinit(true);

  Serial.println();
  Serial.print("Connecting to network: ");
  Serial.println(ssid);
  WiFi.disconnect(true);  //disconnect form wifi to set new wifi connection
  WiFi.mode(WIFI_STA); //init wifi mode

  // Example1 (most common): a cert-file-free eduroam with PEAP (or TTLS)
  const int l = eapID.length();
  const std::string username = eapID.substr(0, l - 8);

  WiFi.begin(ssid, WPA2_AUTH_PEAP, eapID.c_str(), username.c_str(), password.c_str());
  
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

// Sampling frequency
const double f_s = 256; // Hz
// Cut-off frequency (-3 dB)
const double f_c = 29.5; // Hz
// Normalized cut-off frequency
const double f_n = 2 * f_c / f_s;

auto filter = butter<4>(f_n);

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

	// Calculate elapsed time
	unsigned long present = micros();
	unsigned long interval = present - PAST;
	PAST = present;

	// Run timer
	//TIMER -= interval;

  //float signal;
  //float SENSOR_VALUE;
	// Sample
  if(client.connect(server, 4000)) {
    Serial.print("\n *** Starting Communication *** \n");
    client.println("\n *** Starting Communication *** \n");
    while(client.connected()){
      TIMER -= interval;
      //Serial.print("kake: ");
      //Serial.print(TIMER);
      //Serial.print('\n');
      if(TIMER < 0){
        TIMER += 1000000 / SAMPLE_RATE;
        //SENSOR_VALUE = ;
        SIGNAL = filter(analogRead(INPUT_PIN));
        //Serial.print("eeg: ");
        //Serial.println("jeg liker kake");
        client.println(SIGNAL);
        //Serial.println(SIGNAL);
      }
    }
  } else {
    Serial.print("\nConnection Failed\n");
  }
}

void sendToPC(float* data)
{
  byte* byteData = (byte*)(data);    // Casting to a byte pointer
  //Serial.write(byteData, 4);         // Send through Serial to the PC
}