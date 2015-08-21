# API

### Routes

* **Devices**

    * **POST** `/devices.json {username, password, device_id, kind}`
        * `Engine:validateNewDevice`
        * &rarr; new **Device**

* **Measurements**

    * **POST** `/measurements.json {device_id, kind, value, unit}`
        * `Data:createMeasurement`
        * &rarr; new **Measurement**
