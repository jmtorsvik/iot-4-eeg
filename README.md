# iot-4-eeg

This project is part of the NTNU-course [TFE4852](https://www.ntnu.no/eit/tfe4852-barekraftig-iot)

Our goal is to make EEG more sustainable using IoT.

## Solution and structure

Our solution monitors EEG waves at home and sends the data to an external server for further processing. 

It consists of two main modules described below.

### Home EEG-system (`/eeg/`)
Two sub-modules:
- EEG controller (`/eeg/controller/`)
  - Has connection to a server through home network.
  - Receives EEG data from electrodes. 
  - Sends EEG data to the server.
- Connection application (`/eeg/connection_app/`)
  - Used for setting up the EEG controller.
  - Connects to the controller on initial setup.
  - Sends necessary network information for connecting EEG controller to home network.
  - Run in debug mode:
    1. Set up environment by following [this guide](https://docs.flutter.dev/get-started/install).
    2. Start either Android or iOS emulator.
    3. Run `cd eeg/connection_app`.
    4. Run `flutter run`.

### Server (`/server/`)
- Exists somewhere outside home network.
- Receives EEG data from EEG system.
- Processes the data.
