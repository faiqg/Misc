Invoke-WebRequest -Uri "https://download.visualstudio.microsoft.com/download/pr/014120d7-d689-4305-befd-3cb711108212/0fd66638cde16859462a6243a4629a50/ndp48-x86-x64-allos-enu.exe" -Outfile "D:\ndp48-x86-x64-allos-enu.exe"

Start-Process -FilePath "msiexec.exe" -ArgumentList "/i D:\ndp48-x86-x64-allos-enu.exe /quiet /norestart" -Wait -Passthru -NoNewWindow
