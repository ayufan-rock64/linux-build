# Netflix

Starting with 0.8.0rc13 it is possible to use Netflix on all **Ubuntu/armf**
desktop images using regular Chromium browser.

Due to Google policies images do not ship Widevine CDM required by Netflix
to decrypt videos. Currently, Widevine CDM is only available for **armhf**
and **Ubuntu**.

You have to install Widevine CDM with:

```bash
install_widevine_drm.sh
```

This will take between 5 to 15 mins depending on the performance of SD-card,
and your Internet connection.
