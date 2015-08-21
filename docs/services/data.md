# Data

The Data service stores and retrieves data about users, devices, and measurements.

## API Specification

### Resources

* **Users**
    * email(uniq?)
    * password
    * username(uniq)

* **Devices**
	* user
	* kind

* **Measurement**
	* device
	* kind
	* value
	* unit

### Methods

* **Users**
	* `validateUser(username, password)`
		* &rarr; return a **user** or `error` if the user does not exist