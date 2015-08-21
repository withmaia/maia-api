# Data

The Data service stores and retrieves data about users, devices, and measurements.

## API Specification

### Resources

* **Users**
    * email
    * password
    * name

* **Devices**
    * device_id
    * user_id
    * kind

* **Measurement**
    * device_id
    * kind
    * value

### Methods

* **Users**
    * `validateUser(username, password)`
        * &rarr; return a **user** or `error` if the user does not exist
