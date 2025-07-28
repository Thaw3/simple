# Simple App

## Overview
Simple App is a Flutter-based application designed to monitor MQTT messages and predict AI models effortlessly. It provides a user-friendly interface for managing connections, viewing recent activity, and exploring app features.

## Features
- **Dynamic Status Display**: Real-time connection status updates.
- **Recent Activity Section**: Displays the latest activities.
- **AI Model Prediction**: Predict AI models using live camera feeds or uploaded files.
- **MQTT Monitoring**: Monitor MQTT messages and topics.

## Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/Thaw3/simple.git
   ```
2. Navigate to the project directory:
   ```bash
   cd simple
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```

## Running the App
1. Start the backend services using Docker:
   ```bash
   ./thirdparty/launch/01debug_init.sh
   ```
2.run 'MQTTX-1.12.0.AppImage' in new terminal

3. Run the Flutter app:
   ```bash
   flutter run
   ```

## Backend Services
- **Flask API**: Handles MQTT subscriptions and database interactions.
- **MariaDB**: Database for storing app data.
- **Mosquitto**: MQTT broker for message handling.

## Directory Structure
- `lib/`: Contains the Flutter app's source code.
- `thirdparty/`: Backend services and Docker configurations.
- `assets/`: Images and data files used in the app.

## Contributing
Contributions are welcome! Please fork the repository and submit a pull request.

## License
This project is licensed under the MIT License. See the LICENSE file for details.
