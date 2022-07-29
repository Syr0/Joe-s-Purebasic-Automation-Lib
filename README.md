# Joe-s-Purebasic-Automation-Lib
Damn useful collection of functions to automate everything. For Input Simulation, Output Requests and Analysis. 

Functions:
  Procedure **IO_Set_SetMousePos**(x,y)
  Procedure **IO_Set_LeftClick**(Delay = 0)
  Procedure **IO_Set_LeftClickDown**(Delay = 0)
  Procedure **IO_Set_LeftClickPosition**(x,y,Delay=0)
  Procedure **IO_Set_RightClick**(Delay = 0)
  Procedure **IO_Set_RightClickDown**(Delay = 0)
  Procedure **IO_Set_RightClickPosition**(x,y,Delay=0)
  Procedure **IO_Set_MouseWheelUp**(delay=10)
  Procedure **IO_Set_MouseWheelDown**(delay=10)
  Procedure **IO_Set_KeyDown**(Code,delay=0)
  Procedure **IO_Set_KeyUp**(Code,delay=0)
  Procedure **IO_Set_Key**(Code,Delay=0)
  Procedure **IO_Set_WriteText**(Text.s)
  Procedure **IO_Get_KeysDown**(List Resultslist**()
  Procedure **IO_Set_KillProcess **(pid)
  Procedure **IO_Get_AllProcess**(List Processlist.ProcessName**()
  Procedure **IO_Set_CloseProcessByName**(filename.s)
  Procedure **IO_Check_RunningExe**(FileName.s)
  Procedure **IO_Get_HwndByTitle**(Text$)
  Procedure **IO_Set_FocusWindowByTitle**(Title.s)
  Procedure **IO_Set_MaxWindow**(hwnd)
  Procedure **IO_Get_TitleToHwnd**(Title.s)
  Procedure **IO_Get_HwndToPID**(hwnd)
  Procedure **IO_Get_HwndForAllText**(hWnd.i, Map Result.s**()
  Procedure **IO_Set_EnumParentsWithCallback**(hWnd.i, *FunctionPointer)
  Procedure **IO_Get_EnumParentsWithResult**(hWnd.i, *Result.NestedList)
  Procedure **IO_Get_AllProcessClassCallback**(*CallbackFunctionPointer)
  Procedure **IO_Get_AllProcessClassResult**(*ResultList)
  Procedure.s **IO_Get_HwndText**(hwnd.i)
  Procedure **IO_Get_HwndByTextFromWinUI**(Text.s,ResultNr=1)
  Procedure **IO_Get_ModBaseAddr**(ProcessId.i, ModuleName.s)
  Procedure **IO_Get_ModBaseAddrViaDLL**(ProcessId.l, ModuleName.s)
  Procedure **IO_Get_MemAdressByModandPointerListx64**(PID,List Offsets.q**()
  Procedure **IO_Get_MemAdressByPointerListx32**(PID,ProcessExe.s,List Pointers**()
  Procedure **IO_Set_NN_CreateNet**(List NewNeuralNetwork.layer**()
  Procedure.d **IO_Set_NN_Propagade**(List Network.layer**()
  Procedure **IO_Set_NN_Savenet**(Path.s,List network.layer**()
  Procedure **IO_Set_NN_Loadnet**(Path.s,List network.layer**()
  Procedure **IO_Get_ColorFromImage **(image, *Position.POINT)
  Procedure **IO_Check_PixelPattern**(image,List Pixels.Pixels**()
  Procedure **IO_Check_PixelPatternThreshold**(image,List Pixels.Pixels**()
  Procedure **IO_Get_ImageFilterMinMax_Numerical**(image,RedMin,RedMax,GreenMin,GreenMax,BlueMin,BlueMax,List P.POINT**()
  Procedure **IO_Get_ImageFilterThreshold_Numerical**(image,Color,Threshold,List P.POINT**()
  Procedure **IO_Set_TextOnScreen**(Text.s,x,y)
  Procedure **IO_Check_Regex**(Regex.s)
  Procedure.s **IO_Get_ExtractRegexGroup**(Regex.s,Text.s,List Result.s**()
  Procedure **IO_Set_CreateMusic**(List Note.Note**()
  Procedure.s **IO_Get_DllCompilationDate**(File.s)
  Procedure **IO_Get_FilesInFolder**(Folder.s,List Results.s**()
  Procedure **IO_Set_SendICMP**(*Data,Length,IPv4.l, TimeOut=1000,MTU=1400)
  Procedure.s **IO_Get_HTML**(URl.s)
  Procedure **IO_Check_OCR**(*Parameter.OCRStruct)
  Procedure.s **IO_Check_SingleOCR**(image,x,y,w,h)
  Procedure.s **IO_Check_NumberOCR**(image,x,y,w,h)
  Procedure **IO_Check_InitReadStatusMessages**(*ParameterIncoming.OCRStruct)
  Procedure.s **IO_Get_OCRStatus**(Text.s)
  Procedure **IO_Set_OCRWatch**(x,y,w,h,Title.s)
  Procedure **IO_Set_StopOCRWatch**(Title.s)
  Procedure.s **IO_Get_Weka_Internal_ImageFilter_Extract_Features**(ArffFile.s,DatasetPath.s,Filter.s="FCTH")
  Procedure.s **IO_Get_Weka_Internal_Create_Imagefilter_Arff**(List DataSet.FileAndType**()
  Procedure.s **IO_Get_Weka_LoadImages**(List DataSet.FileAndType**()
  Procedure.s **IO_Get_Weka_Train**(DatasetArffFile.s, Classifier.s, SaveFileName.s)
  Procedure.s **IO_Get_Weka_Test**(TestDataArff.s, Classifier.s, TrainedModelFile.s)
  Procedure.d **IO_Get_uint32**(lValue.l)
  Procedure.s **IO_Get_Chrome_Response**(connection,timeout = 0)
  Procedure.i **IO_Set_Chrome_PageNavigate**(TabID.s,*Returnvalue.PageNavigateReturn,url.s,referrer.s="",transitionType.i=-1,frameId.i=-1,referrerPolicy.i=-1)
  Procedure.s **IO_Set_Chrome_DOMenable**(TabID.s,enable)
  Procedure.s **IO_Get_Chrome_DOMgetOuterHTML**(TabID.s,NodeId.i=-1,BackendNodeId=-1,RuntomeRometObjectID.i=-1)
  Procedure.s **IO_Set_Chrome_Runtimeenable**(TabID.s,enable)
  Procedure.s **IO_Set_Chrome_Logenable**(TabID.s,enable)
  Procedure.s **IO_Check_Chrome_Runtimeevaluate**(TabID.s,expression.s)
  Procedure.s **IO_Get_Chrome_HMTL**(TabID.s)
  Procedure **IO_Set_Chrome_ClickOnButtonByID**(TabID.s,ButtonID.s)
  Procedure **IO_Set_Chrome_JS_ClickOnButtonByClass**(TabID.s,Classname.s)
  Procedure **IO_Set_PythonCommand**(command.s)
  Procedure.s **IO_Get_VT_Download**(ITW.s,APIKey$)
  Procedure.s **IO_Get_VT_FileSearch**(Searchstring.s,limit.i,APIKey$)
  
  
  
![image](https://user-images.githubusercontent.com/6566797/181780275-8dad92ff-26ff-4e55-9d23-de127f84be73.png)
![image](https://user-images.githubusercontent.com/6566797/181780312-207b4b88-1a93-4207-aaba-2504d409efb7.png)
![image](https://user-images.githubusercontent.com/6566797/181780346-ef3f16fb-afb9-4cb3-a1cb-a7189d1c1322.png)
