;*******************************************************************
;Description: ACS+SESSION AFFINITY
;
;Purpose:
;

;Author: Ganesh
;Company: Brillio
;*********************************************************************

;********************************************
;Include Standard Library

;*******************************************
#include <Constants.au3>
#include <Excel.au3>
#include <MsgBoxConstants.au3>
#include <Array.au3>
#include <IE.au3>
#include <Clipboard.au3>
#include <Date.au3>
#include <GuiListView.au3>
#include <GUIConstantsEx.au3>
#include <GuiTreeView.au3>
#include <GuiImageList.au3>
#include <WindowsConstants.au3>
#include <MsgBoxConstants.au3>
#include <GuiTreeView.au3>
#include <File.au3>
#include <GuiToolbar.au3>
#include <Testinc.au3>
;******************************************

;***************************************************************
;Initialize AutoIT Key delay
;****************************************************************
AutoItSetOption ( "SendKeyDelay", 400)

;******************************************************************
;Reading test data from xls
;To do - move helper function
;******************************************************************
;Open xls
Local $sFilePath1 =  @ScriptDir & "\" & "TestData.xlsx";This file should already exist in the mentioned path
Local $oExcel = _ExcelBookOpen($sFilePath1,0,True)



;Check for error
If @error = 1 Then
    MsgBox($MB_SYSTEMMODAL, "Error!", "Unable to Create the Excel Object")
    Exit
ElseIf @error = 2 Then
    MsgBox($MB_SYSTEMMODAL, "Error!", "File does not exist")
    Exit
 EndIf

 ; Reading xls data into variables
;to do - looping to get the data from desired row of xls
;to do - looping to get the data from desired row of xls
Local $testCaseIteration = _ExcelReadCell($oExcel, 17, 1)
Local $testCaseExecute = _ExcelReadCell($oExcel, 17, 2)
Local $testCaseName = _ExcelReadCell($oExcel, 17, 3)
Local $testCaseDescription = _ExcelReadCell($oExcel, 17, 4)
Local $JunoOrKep  = _ExcelReadCell($oExcel, 17, 5)
Local $testCaseEclipseExePath = _ExcelReadCell($oExcel, 17, 6)
;if $JunoOrKep = "Juno" Then
  ; Local $testCaseEclipseExePath = _ExcelReadCell($oExcel, 16, 6)
;Else
   ;Local $testCaseEclipseExePath = _ExcelReadCell($oExcel, 16, 7)
   ;EndIf
Local $testCaseWorkSpacePath = _ExcelReadCell($oExcel, 17, 8)
Local $testCaseProjectName = _ExcelReadCell($oExcel, 17, 9)
Local $testCaseJspName = _ExcelReadCell($oExcel, 17, 10)
Local $testCaseJspText = _ExcelReadCell($oExcel, 17, 11)
Local $testCaseAzureProjectName = _ExcelReadCell($oExcel, 17, 12)
Local $testCaseCheckJdk = _ExcelReadCell($oExcel, 17, 13)
Local $testCaseJdkPath = _ExcelReadCell($oExcel, 17, 14)
Local $testCaseCheckLocalServer = _ExcelReadCell($oExcel, 17, 15)
Local $testCaseServerPath = _ExcelReadCell($oExcel, 17, 16)
Local $testCaseServerNo = _ExcelReadCell($oExcel, 17, 17)
Local $testCaseUrl = _ExcelReadCell($oExcel, 17, 19)
Local $testCaseValidationText = _ExcelReadCell($oExcel, 17, 19)
Local $testCaseSubscription = _ExcelReadCell($oExcel, 17, 20)
Local $testCaseStorageAccount = _ExcelReadCell($oExcel, 17, 21)
Local $testCaseServiceName = _ExcelReadCell($oExcel, 17, 22)
Local $testCaseTargetOS = _ExcelReadCell($oExcel, 17, 23)
Local $testCaseTargetEnvironment = _ExcelReadCell($oExcel, 17, 24)
Local $testCaseCheckOverwrite = _ExcelReadCell($oExcel, 17, 25)
Local $testCaseJDKOnCloud = _ExcelReadCell($oExcel, 17, 28)
Local $testCaseUserName = _ExcelReadCell($oExcel, 17, 29)
Local $testCasePassword = _ExcelReadCell($oExcel, 17, 30)
Local $testcaseNewSessionJSPText = _ExcelReadCell($oExcel, 17, 31)
Local $testcaseExternalJarPath = _ExcelReadCell($oExcel, 17, 32)
Local $testcaseCertificatePath = _ExcelReadCell($oExcel, 17, 33)
Local $testcaseACSLoginUrlPath = _ExcelReadCell($oExcel, 17, 34)
Local $testcaseACSserverUrlPath = _ExcelReadCell($oExcel, 17, 35)
Local $testcaseACSCertiPath = _ExcelReadCell($oExcel, 17, 36)
Local $testcaseCloud = _ExcelReadCell($oExcel, 17, 37)
_ExcelBookClose($oExcel,0)
Local $exlid = ProcessExists("excel.exe")
ProcessClose($exlid)
;*******************************************************************************


Start($testCaseName);Calling Start function from Testinc.au3 script(Custom Script file, Contains common functions that are used in other scripts)

Local $pro = ProcessExists("eclipse.exe")
If $pro > 0 Then
  Delete()
Else
 OpenEclipse($testCaseEclipseExePath,$testCaseWorkSpacePath)
 Delete()
EndIf


;Creating Java Project
CreateJavaProject($testCaseProjectName)

;Configure
Configure()
Sleep(3000)

;Creating JSP file and insert code
CreateSessionJSPFile()

;CreateAzurePackage
CreateAzurePackage($testCaseAzureProjectName, $testCaseCheckJdk, $testCaseJdkPath,$testCaseCheckLocalServer, $testCaseServerPath, $testCaseServerNo)


If  $testcaseCloud = 1  Then

PublishToCloud($testCaseSubscription, $testCaseStorageAccount, $testCaseServiceName, $testCaseTargetOS, $testCaseTargetEnvironment, $testCaseCheckOverwrite, $testCaseUserName, $testCasePassword)
Sleep(20000)
;Wait for 10 min RDP screen
;Sleep(720000)

For $i = 8 to 1 Step - 1
   Local $wnd = WinGetHandle("Java EE - MyHelloWorld/WebContent/index.jsp - Eclipse")
   Local $wnd1 = ControlGetHandle($wnd, "", "[CLASS:msctls_progress32]")
   Local $syslk = ControlCommand($wnd, "", $wnd1,"IsVisible", "")
If $i = 1 and $syslk = 0 Then
   $cls = "-----Time Out!-----"
   Close($cls)
   Exit
Else
      ;Send("{Enter}")
		 If $syslk = 0 Then
			;Check RDP and Open excel
			CheckRDPConnection()
			Sleep(10000)
			;Check for published key word in Azure activity log and update excel
			ValidateTextAndUpdateExcel($testCaseProjectName, $testCaseValidationText)
			sleep(7000)
			$cls = 1
			Close($cls)
   ;Exit
		 Else
			Sleep(120000)
		 EndIf
EndIf
Next

Else
   Sleep(3000)
   Send("{UP}")
   Local $wnd = WinGetHandle('[CLASS:SWT_Window0]')
   Local $htoolBar =  ControlGetHandle($wnd, '','[CLASS:ToolbarWindow32; INSTANCE:15]')
   Sleep(3000)
   _GUICtrlToolbar_ClickIndex($htoolBar, 0,"Left")
EndIf




;**************************************Configuring***************************************************
Func Configure()
   ;Configuring
Send("{APPSKEY}")
Send("B")
Send("{Right}")
Send("c")
Send("{Tab 3}")
Send("l")
Send("!a")
Send("!n")
Send("{Tab 6}")
Send("^a {Delete}")
AutoItSetOption ( "SendKeyDelay", 50)
Send($testcaseACSLoginUrlPath)
AutoItSetOption ( "SendKeyDelay", 400)
Send("{Tab}")
AutoItSetOption ( "SendKeyDelay", 50)
Send($testcaseACSserverUrlPath)
AutoItSetOption ( "SendKeyDelay", 400)
Send("{tab 2} {Enter}")
AutoItSetOption ( "SendKeyDelay", 50)
Send($testcaseACSCertiPath)
AutoItSetOption ( "SendKeyDelay", 400)
Send("{Enter}")
Send("{Tab 3}{Space}{Tab}{Space}{Enter}{Tab 2}{Enter}")
Sleep(2000)
Send("{Enter}")
Send("!{F4}")
;Send("{Enter}")
EndFunc

;***************************************************************
;Function to create JSP file and insert code
;***************************************************************
Func CreateSessionJSPFile()
sleep(3000)
Send("{APPSKEY}")
AutoItSetOption ( "SendKeyDelay", 100)
Send("{down}")
Send("{RIGHT}")
Send("{down 14}")
Send("{enter}")
Send($testCaseJspName)
Send("!f")
Local $temp = "Java EE - " & $testCaseProjectName & "/WebContent/" & $testCaseJspName & " - Eclipse"
Sleep(3000)
WinWaitActive($temp)

; Calling the Winchek Function
Local $funame, $cntrlname
$cntrlname =  "Java EE - " & $testCaseProjectName & "/WebContent/" & $testCaseJspName & " - Eclipse"
$funame = "CreateJSPFile"
wincheck($funame,$cntrlname)

Send("^a")
Send("{Backspace}")
ClipPut($testCaseJspText)
Send("^v")
Send("^+s")

;create newsession.jsp
MouseClick("primary",105, 395, 1)
Send("{APPSKEY}")
Sleep(1000)
Send("n")
Send("{down 14}")
Send("{enter}")
Send("newsession.jsp")
Send("!f")
Local $temp = "Java EE - " & $testCaseProjectName & "/WebContent/" & $testCaseJspName & " - Eclipse"
#comments-start
if $JunoOrKep = "Juno" Then
Local $temp = "Java EE - " & $testCaseProjectName & "/WebContent/" & $testCaseJspName & " - Eclipse"
Else
   Local $temp = "Web - " & $testCaseProjectName & "/WebContent/" & $testCaseJspName & " - Eclipse"
   EndIf
   #comments-end
Sleep(2000)
Send("^a")
Send("{Backspace}")
ClipPut($testcaseNewSessionJSPText)
Send("^v")
AutoItSetOption ( "SendKeyDelay", 400)
Send("^+s")
;MouseClick("primary", 74, 114, 1)

EndFunc
;******************************************************************


