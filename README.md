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

#### Using PowerShell:
```cmd
copy /b love.exe+YourGame.love YourGame.exe
```

You might also concatenate the dll files and license files and pack everything into a zip file.

### 3. Adding the .dll files
Zip the newly created .exe file with the LÖVE .dll files.

### 4. Distribution:
You can now distribute the zip file to Windows users.
