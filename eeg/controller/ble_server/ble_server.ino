#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID "fdf81135-b37f-4d16-8b22-eb4200d07ad1"
#define USERNAME_UUID "85c70960-789f-405d-aca8-d84167bd0fd9"
#define PASSWORD_UUID "1e924c7d-f95f-4468-afc8-67372dc559fc"

BLEServer* pServer;

void setup() {
  Serial.begin(9600);
  Serial.println("Starting BLE work!");
  
  BLEDevice::init("EEG_CONTROLLER_1");
  pServer = BLEDevice::createServer();
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

  usernameCharacteristic->setValue("Placeholder_Username");
  passwordCharacteristic->setValue("Placeholder_Password");
  pService->start();
  // BLEAdvertising *pAdvertising = pServer->getAdvertising();  // this still is working for backward compatibility
  BLEAdvertising* pAdvertising = BLEDevice::getAdvertising();
  pAdvertising->addServiceUUID(SERVICE_UUID);
  pAdvertising->setScanResponse(true);
  pAdvertising->setMinPreferred(0x06);  // functions that help with iPhone connections issue
  pAdvertising->setMinPreferred(0x12);
  BLEDevice::startAdvertising();
  Serial.println("Characteristic defined! Now you can read it in your phone!");
}

void loop() {
  // put your main code here, to run repeatedly:
  delay(2000);

  BLECharacteristic* usernameChar = pServer->getServiceByUUID(SERVICE_UUID)->getCharacteristic(USERNAME_UUID);
  BLECharacteristic* passwordChar = pServer->getServiceByUUID(SERVICE_UUID)->getCharacteristic(PASSWORD_UUID);
  
  String username = usernameChar->getValue().c_str();
  String password = passwordChar->getValue().c_str();
  
  Serial.print("Username: ");
  Serial.println(username);
  
  Serial.print("Password: ");
  Serial.println(password);
}
