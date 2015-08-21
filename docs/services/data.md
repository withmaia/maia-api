# Data

The Data service stores and retrieves data about users, devices, and measurements.

## API Specification

### Resources

* **Users**
    * email (unique)
    * password
    * name

* **Devices**
    * device_id (unique)
    * user_id
    * kind

* **Measurement**
    * device_id
    * kind
    * value

### Methods

* **Users**
    * `validateUser(email, password)`
        * &rarr; return a **user** or `error` if the user does not exist
