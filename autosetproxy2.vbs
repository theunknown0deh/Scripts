On Error Resume Next

Dim strComputer
Dim objWMIService
Dim colAdapters
Dim objAdapter
Dim wshShell

Dim ipaddr
Dim dnsaddr
Dim ip
Dim count
Dim countd
Dim counton
Dim countoff

strComputer = "."

ipaddr = Array("IP1","IP2","IP3")

dnsaddr = Array("DNS1","DNS2","DNS3")

counton = 0
countoff = 0

Do While True

   Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
   Set colAdapters = objWMIService.ExecQuery ("SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPEnabled = True")
   Set wshShell = CreateObject("WScript.Shell")

   count = 0
   countd = 0

   For Each objAdapter in colAdapters
       If Not IsNull(objAdapter.IPAddress) Then

          For i = 0 To UBound(objAdapter.IPAddress)
              For Each ip In ipaddr
                  If InStr(objAdapter.IPAddress(i), ip)=1 Then count = 1
              Next

              For ii = 0 To UBound(objAdapter.DNSServerSearchOrder)
                  For Each ip In dnsaddr
                      If InStr(objAdapter.DNSServerSearchOrder(ii), ip)=1 Then countd = 1
                  Next
              Next

                 If count=1 And countd=1 And counton=0 Then
                    wshShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable", 0, "REG_DWORD"
                    wshShell.RegDelete "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\AutoConfigURL"
                    counton = 1
                    countoff = 0
                 End If

                 If countd=0 And countoff=0 Then
                    wshShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\ProxyEnable", 0, "REG_DWORD"
                    wshShell.RegWrite "HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings\AutoConfigURL", "https://url", "REG_SZ"
                    counton = 0
                    countoff = 1
                 End If
          Next
       End If

   Next
   WScript.Sleep 3000

Loop
