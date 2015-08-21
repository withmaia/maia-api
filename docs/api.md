# API

### Routes

* **Devices**

	* **POST** `/devices.json {username, password, kind, serial}`
		* `Engine:validateNewDevice`
		* &rarr; new **Device** and http://withmaia.com/devices/<device_id>

* **Measurements**

	* **POST** `/measurements.json {device_id, kind, value, unit}`
		* `Data:createMeasurement`
		* &rarr; new **Measurement**
