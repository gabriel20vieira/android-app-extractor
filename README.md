# Android App Extractor

**Note**: The script was originally written for powershell and ported to bash (it was not tested :))

## How to use

First grab the app name through adb

```
adb shell pm list packages
```

Second use the app name in the script

```powershell
.\extract.ps1 com.app.name
```

```bash
./extract.sh com.app.name
```

The script will extract in the following format (output ls command windows):

```powershell
Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---          05/06/2024    12:34        1405502 20240605123448.data.data.com.app.name.com.app.name.tgz
-a---          05/06/2024    12:34            195 20240605123448.data.data.com.app.name.com.app.name.tgz.md5
-a---          05/06/2024    12:34            230 20240605123448.data.data.com.app.name.com.app.name.tgz.sha256
-a---          05/06/2024    12:34            246 20240605123450.data.user_de.0.com.app.name.com.app.name.tgz
-a---          05/06/2024    12:34            200 20240605123450.data.user_de.0.com.app.name.com.app.name.tgz.md5
-a---          05/06/2024    12:34            235 20240605123450.data.user_de.0.com.app.name.com.app.name.tgz.sha256
-a---          05/06/2024    12:34        1406943 20240605123451.data.user.0.com.app.name.com.app.name.tgz
-a---          05/06/2024    12:34            197 20240605123451.data.user.0.com.app.name.com.app.name.tgz.md5
-a---          05/06/2024    12:34            232 20240605123451.data.user.0.com.app.name.com.app.name.tgz.sha256
-a---          05/06/2024    12:34       57568083 20240605123452.data.app.~~aibuAUhgCY9hXm28kYxtfg==.com.app.name-t6UuBVANfadFjTKZ7NK8bA==.base.com.app.name.tgz
-a---          05/06/2024    12:34            254 20240605123452.data.app.~~aibuAUhgCY9hXm28kYxtfg==.com.app.name-t6UuBVANfadFjTKZ7NK8bA==.base.com.app.name.tgz.md5
-a---          05/06/2024    12:34            289 20240605123452.data.app.~~aibuAUhgCY9hXm28kYxtfg==.com.app.name-t6UuBVANfadFjTKZ7NK8bA==.base.apkcom.com.app.name.tgz.sha256
```

