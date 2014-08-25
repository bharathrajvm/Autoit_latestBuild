
;*******************************************************************
;Description: SSL Overloading
;
;Purpose:
;
;Date: 18 Jun 2014 , Modified on 19 June 2014
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
;Dim $oExcel1 = _ExcelBookNew(0)

;Local $sFilePath2 = @ScriptDir & "\" & "Result.xlsx"  ;This file should already exist in the mentioned path
;Local $oExcel1 = _ExcelBookOpen($sFilePath2,0,False)

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
Local $testCaseIteration = _ExcelReadCell($oExcel, 12, 1)
Local $testCaseExecute = _ExcelReadCell($oExcel, 12, 2)
Local $testCaseName = _ExcelReadCell($oExcel, 12, 3)
Local $testCaseDescription = _ExcelReadCell($oExcel, 12, 4)
Local $JunoOrKep  = _ExcelReadCell($oExcel, 12, 5)
Local $testCaseEclipseExePath = _ExcelReadCell($oExcel, 12, 6)
;if $JunoOrKep = "Juno" Then
  ; Local $testCaseEclipseExePath = _ExcelReadCell($oExcel, 16, 6)
;Else
   ;Local $testCaseEclipseExePath = _ExcelReadCell($oExcel, 16, 7)
   ;EndIf
Local $testCaseWorkSpacePath = _ExcelReadCell($oExcel, 12, 8)
Local $testCaseProjectName = _ExcelReadCell($oExcel, 12, 9)
Local $testCaseJspName = _ExcelReadCell($oExcel, 12, 10)
Local $testCaseJspText = _ExcelReadCell($oExcel, 12, 11)
Local $testCaseAzureProjectName = _ExcelReadCell($oExcel, 12, 12)
Local $testCaseCheckJdk = _ExcelReadCell($oExcel, 12, 13)
Local $testCaseJdkPath = _ExcelReadCell($oExcel, 12, 14)
Local $testCaseCheckLocalServer = _ExcelReadCell($oExcel, 12, 15)
Local $testCaseServerPath = _ExcelReadCell($oExcel, 12, 16)
Local $testCaseServerNo = _ExcelReadCell($oExcel, 12, 17)
Local $testCaseUrl = _ExcelReadCell($oExcel, 12, 19)
Local $testCaseValidationText = _ExcelReadCell($oExcel, 12, 19)
Local $testCaseSubscription = _ExcelReadCell($oExcel, 12, 20)
Local $testCaseStorageAccount = _ExcelReadCell($oExcel, 12, 21)
Local $testCaseServiceName = _ExcelReadCell($oExcel, 12, 22)
Local $testCaseTargetOS = _ExcelReadCell($oExcel, 12, 23)
Local $testCaseTargetEnvironment = _ExcelReadCell($oExcel, 12, 24)
Local $testCaseCheckOverwrite = _ExcelReadCell($oExcel, 12, 25)
Local $testCaseJDKOnCloud = _ExcelReadCell($oExcel, 12, 28)
Local $testCaseUserName = _ExcelReadCell($oExcel, 12, 29)
Local $testCasePassword = _ExcelReadCell($oExcel, 12, 30)
Local $testcaseNewSessionJSPText = _ExcelReadCell($oExcel, 12, 31)
Local $testcaseExternalJarPath = _ExcelReadCell($oExcel, 12, 32)
Local $testcaseCertificatePath = _ExcelReadCell($oExcel, 12, 33)
_ExcelBookClose($oExcel,0)
Local $exlid = ProcessExists("excel.exe")
ProcessClose($exlid)
;*******************************************************************************



;to do - Pre validation steps


Start($testCaseName);Calling Start function from Testinc.au3 script(Custom Script file, Contains common functions that are used in other scripts)

Local $pro = ProcessExists("eclipse.exe")
If $pro > 0 Then
  Delete()
Else
 OpenEclipse($testCaseEclipseExePath,$testCaseWorkSpacePath)
 Delete()
EndIf

;Create javaProject
CreateJavaProject($testCaseProjectName)

;create JSP file
CreateJSPFile($testCaseJspName, $testCaseProjectName, $testCaseJspText)

;CreateAzurePackage
CreateAzurePackage($testCaseAzureProjectName, $testCaseCheckJdk, $testCaseJdkPath,$testCaseCheckLocalServer, $testCaseServerPath, $testCaseServerNo)


;Enable SSL Offloading
EnableSSLOffloading()

;Publish to Cloud
PublishToCloud($testCaseSubscription, $testCaseStorageAccount, $testCaseServiceName, $testCaseTargetOS, $testCaseTargetEnvironment, $testCaseCheckOverwrite, $testCaseUserName, $testCasePassword)
Sleep(20000)


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




;to do - Post validation steps


;***************************************************************
;Helper Functions
;***************************************************************




;****************************************************************
;Function to enable SSL Offloading
;***************************************************************
Func EnableSSLOffloading()
Sleep(2000)
AutoItSetOption ( "SendKeyDelay", 100)
Send("{Up}{Enter}{down}{down}{down}{APPSKEY}")
Sleep(1000)
;if $JunoOrKep = "Juno" Then
;Send("g")
;Else
;Send("e")
;EndIf
Send("e")
if $JunoOrKep = "Juno" Then
Send("{Left}{UP}{Right}{s 2}{Enter}")
Else
Send("{s}{Left}{UP}{UP}{Right}{s 2}{Enter}")
EndIf
WinWaitActive("[Title:Properties for WorkerRole1]")
ControlCommand("Properties for WorkerRole1","","[CLASSNN:Button1]","Check", "")
WinWaitActive("[Title:SSL Offloading]")
Send("{Enter}")
Send("{Tab 4}")
;Dim $hWnd = WinGetHandle("[Title:Properties for WorkerRole1]")
;MsgBox("","",$hWnd)
;Local $hToolBar = ControlGetHandle($hWnd, "", "[Text:<a>Certificates...</a>]")
;MsgBox("","",$hToolBar)
;ControlClick($hWnd,"",6424586,"left",1)
 ;MouseClick("primary",1039, 133, 1)
 Local $wnd = WinGetHandle("[Title:Properties for WorkerRole1]")
 Local $wnd1 = ControlGetHandle($wnd, "", "[CLASS:SysLink; INSTANCE:2]")
 ControlClick($wnd,"",$wnd1,"left")
WinWaitActive("[Title:Properties for MyAzureProject]")
Send("{Tab 2}")
Send("{Enter}")
WinWaitActive("[Title:Certificate]")
Send("{Tab 2}")
Send("{Enter}")
Sleep(2000)
Send($testcaseCertificatePath)
;ClipPut($testcaseCertificatePath)
Send("!O")
Send("{Tab 2}")
Send("{Enter}")
Send("{Tab}{Enter}")
Send("{Tab 3}")
Send("{Enter}")
EndFunc
;*********************************************************************

