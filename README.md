I2Ctool
=======

This tool is for probing, writing and reading the I2C bus of Jolla phone.

**Must be started as root from command line**

Other half bus is /dev/i2c-1/ which is selected by default.

On front page, you can 
- change the bus
- enable or disable the Vdd supply pin of OH (3.3V)
- start probing of selected bus
- start writing, reading mode

In writing and reading mode you give i2c device address (propably something that probe did found) e.g. `3c`

Then select mode, "write", "read", or "write then read"

For write mode, you just enter bytes to be written separated with spaces e.g. `00 c0 ff ee 12 34`

For read mode, enter number (count) of bytes to read e.g. `5`

For write then read mode, usually you enter register pointer where to read from e.g. `07` and then number of bytes to read e.g. `1`

Thats it. Hope you like it.



