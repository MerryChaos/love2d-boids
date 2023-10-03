# Usage
Use sliders in top left to adjust settings.

Lock sliders by ticking the little box on the right of the sliders.
This will prevent the user from changing the value and it won't be randomized.

`Return`: reset using same settings

`Delete`: reset using random settings

`Space`: toggle pause

`F11`: toggle fullscreen

# Distributing with LÖVE

Packaging for Windows:

### 1. .love File:
Zip the entire game folder (all your .lua files, assets, etc.) and change the file extension to .love.

### 2. Creating an Executable:
Download the LÖVE binary for Windows from the official website.
Concatenate the LÖVE executable and your .love file:

```
copy /b love.exe+YourGame.love YourGame.exe.
```

You might also concatenate the dll files and license files and pack everything into a zip file.

### 3. Distribution:
You may now distribute the .exe file or the zip file to Windows users.
