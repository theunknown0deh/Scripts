On Error Resume Next

Dim strComputer
Dim objWMIService
Dim colAdapters
Dim wshShell

Dim ipaddr
Dim count
Dim counton
Dim countoff

strComputer = "."

ipaddr = Array("IP1","IP2","IP3")

counton = 0
countoff = 0

Do While True

   Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
   Set colAdapters = objWMIService.ExecQuery ("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
   Set wshShell = CreateObject("WScript.Shell")

   count = 0

   For Each objAdapter in colAdapters

       If Not IsNull(objAdapter.IPAddress) Then
          For i = 0 To UBound(objAdapter.IPAddress)

              For Each ip in ipaddr
                  If InStr(objAdapter.IPAddress(i), ip)=1 Then count = 1
              Next

              If count=1 And counton=0 Then
                 wshShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable", 1, "REG_DWORD"
                 counton = 1
                 countoff = 0
              End If

              If count=0 And countoff=0 Then
                 wshShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable", 0, "REG_DWORD"
                 counton = 0
                 countoff = 1
              End If

         Next
       End If

   Next
   WScript.Sleep 2000

Loop
