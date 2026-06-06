@echo off
set SDKMANAGER="D:\APP PC\sdk\cmdline-tools\latest\bin\sdkmanager.bat"
set SDK_ROOT="D:\APP PC\sdk"
echo y | %SDKMANAGER% --sdk_root=%SDK_ROOT% --licenses
echo y | %SDKMANAGER% --sdk_root=%SDK_ROOT% --licenses
echo y | %SDKMANAGER% --sdk_root=%SDK_ROOT% --licenses
echo Done accepting licenses.
