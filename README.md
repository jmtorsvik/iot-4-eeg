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
  - Run (for macOS, have not tested on Windows...):
    1. Follow [this guide](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html).
    2. Connect ESP32 to PC with USB cable.
    3. Add EspressIf IDF to terminal session with `. $HOME/esp/esp-idf/export.sh` (Alternatively add `alias get_idf='. $HOME/esp/esp-idf/export.sh'` to `~/.zprofile` to run with `get_idf`).
    4. Run `idf.py set-target esp32`.
    5. Build project with `idf.py build`.
    6. Find ESP32 ports with command `ls /dev/cu.*`.
    7. Flash to ESP32 with `idf.py -p [port] flash`.
    8. Monitor ESP32 with `idf.py -p [port] monitor`.

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
