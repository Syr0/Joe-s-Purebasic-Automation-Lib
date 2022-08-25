UsePNGImageEncoder()
UseMD5Fingerprint() 
ExamineDesktops()

;Tips
;#1 Use Ctrl+F4 to collapse all foldings
;#2 Create a Project and add this file to the project files to use autocomplete
;#3 enable the Compilerifs depending on what you need

;Contact:
;Debug "joachims"+Chr(Asc("e"))+"ster@web.de"
;Plenty of Authors on purebasic forum
;note: Yes - this is simular to the codearchive
;but I only care about external (mostly API)-stuff

;There are three different Prefixes:
;IO_Set_xxx()
;IO_Get_xxx()
;IO_Check_xx()

;--------------------------;
;     API & Windows-Libs   ;
;--------------------------;
CompilerIf 1=1
  ;{ Mouse Input Simulation
  Procedure IO_Set_SetMousePos(x,y)
    SetCursorPos_(x,y)
  EndProcedure
  
  Procedure IO_Set_LeftClick(Delay = 0)
    mouse_event_(#MOUSEEVENTF_LEFTDOWN,0,0,0,0)
    Delay(delay)
    mouse_event_(#MOUSEEVENTF_LEFTUP,0,0,0,0)
  EndProcedure
  Procedure IO_Set_LeftClickUp()
    mouse_event_(#MOUSEEVENTF_LEFTUP,0,0,0,0)
  EndProcedure
  Procedure IO_Set_LeftClickDown(Delay = 0)
    Delay(delay)
    mouse_event_(#MOUSEEVENTF_LEFTDOWN,0,0,0,0)
    Delay(delay)
  EndProcedure
  Procedure IO_Set_LeftClickPosition(x,y,Delay=0)
    SetCursorPos_(x,y)
    Delay(Delay)
    mouse_event_(#MOUSEEVENTF_LEFTDOWN,0,0,0,0)
    Delay(Delay)
    mouse_event_(#MOUSEEVENTF_LEFTUP,0,0,0,0)
  EndProcedure  
  
  Procedure IO_Set_RightClick(Delay = 0)
    mouse_event_(#MOUSEEVENTF_RIGHTDOWN,0,0,0,0)
    Delay(delay)
    mouse_event_(#MOUSEEVENTF_RIGHTUP,0,0,0,0)
  EndProcedure
  Procedure IO_Set_RightClickUp()
    mouse_event_(#MOUSEEVENTF_RIGHTUP,0,0,0,0)
  EndProcedure
  Procedure IO_Set_RightClickDown(Delay = 0)
    Delay(delay)
    mouse_event_(#MOUSEEVENTF_RIGHTDOWN,0,0,0,0)
    Delay(delay)
  EndProcedure
  Procedure IO_Set_RightClickPosition(x,y,Delay=0)
    SetCursorPos_(x,y)
    Delay(Delay)
    mouse_event_(#MOUSEEVENTF_RIGHTDOWN,0,0,0,0)
    Delay(Delay)
    mouse_event_(#MOUSEEVENTF_RIGHTUP,0,0,0,0)
  EndProcedure  
  
  Procedure IO_Set_MouseWheelUp(delay=10)
    in.Input
    in\type = #INPUT_MOUSE
    in\mi\dwFlags = #MOUSEEVENTF_WHEEL
    in\mi\mouseData = 120
    SendInput_(1,@in,SizeOf(input))
    Delay(delay)
  EndProcedure  
  Procedure IO_Set_MouseWheelDown(delay=10)
    in.Input
    in\type = #INPUT_MOUSE
    in\mi\dwFlags = #MOUSEEVENTF_WHEEL
    in\mi\mouseData = -120
    SendInput_(1,@in,SizeOf(input))
    Delay(delay)
  EndProcedure  
  ;}
  
  ;{ Keyboard Input Simulation
  Procedure IO_Set_KeyDown(Code,delay=0)
    keybd_event_(Code,0,0,0)
    Delay(delay)
  EndProcedure
  Procedure IO_Set_KeyUp(Code,delay=0)
    keybd_event_(Code,0,#KEYEVENTF_KEYUP,0)
    Delay(delay)
  EndProcedure
  Procedure IO_Set_Key(Code,Delay=0)
    keybd_event_(Code, 0, 0,0)
    Delay(Delay)
    keybd_event_(Code, 0, #KEYEVENTF_KEYUP,0)
    Delay(Delay)
  EndProcedure
  Procedure IO_Set_WriteText(Text.s)
    If FindString(Text,".")
      oldclip$ = GetClipboardText()
      SetClipboardText(Text)
      ; Yes that sucks - would need to work with postmessage_() but that needs a handle..
      IO_Set_KeyDown(#VK_LCONTROL)
      IO_Set_Key(#VK_V)
      IO_Set_KeyUp(#VK_LCONTROL)
      SetClipboardText(oldclip$)
    Else
      
      For x = 1 To Len(text)
        IO_Set_Key(Asc(Mid(text,x,1)))
      Next
    EndIf
    
  EndProcedure
  ;}
  
  ;{ Input Detection
  Procedure IO_Get_KeysDown(List Resultslist())
    ClearList(Resultslist())
    For x = 0 To 255
      If GetAsyncKeyState_(x)
        AddElement(Resultslist())
        Resultslist() = x
      EndIf
    Next
    ;Example:
    ; NewList results()
    ; Repeat
    ;   Whichkeysaredown(results())
    ;   If ListSize(results()) > 0
    ;     ForEach results()
    ;       keysdown.s +" "+results()+" +"
    ;     Next
    ;     Trim(keysdown,"+"):Trim(keysdown," ")
    ;     Debug keysdown
    ;     keysdown = ""
    ;   EndIf
    ;   
    ;   Delay(1)
    ; ForEver
    
  EndProcedure
  Procedure IO_Get_MouseX()
    GetCursorPos_(Mouse.POINT)
    ProcedureReturn Mouse\x
  EndProcedure
  Procedure IO_Get_MouseY()
    GetCursorPos_(Mouse.POINT)
    ProcedureReturn Mouse\y
  EndProcedure
  ;}
  
  ;{ InterProcessCommunication
  Procedure IO_Set_SendCommand(hwnd,wm_command)
    PostMessage_(hWnd,wm_command,0,0)
  EndProcedure
  ;}
  
  ;{ Process Control <- Warning on slowdown!
  ;{ Structures
  #SystemProcessInformation = $0005
  Structure _UNICODE_STRING Align #PB_Structure_AlignC
    usLength.w 
    usMaximumLength.w   
    usBuffer.i
  EndStructure
  Structure _SYSTEM_PROCESS_INFO Align #PB_Structure_AlignC
    NextEntryOffset.l
    NumberOfThreads.l
    Reserved.q[3]
    CreateTime.q
    UserTime.q
    KernelTime.q
    ImageName._UNICODE_STRING
    BasePriority.l
    ProcessId.i
    InheritedFromProcessId.i
  EndStructure
  Structure ProcessName
    Name.s
    Threads.i
    Path.s
    PID.i
  EndStructure
  Structure ScanAllProcessesForClassAndTitleWithResultUIFields
    hwnd.i
    Class.s
    Text.s
  EndStructure
  Structure GetAllHwndAndTitles
    Title.s
    hwnd.i
  EndStructure
  Structure NestedList
    List Nested.ScanAllProcessesForClassAndTitleWithResultUIFields()
  EndStructure;}
  NewList Processlist.ProcessName()
  
  Procedure IO_Set_KillProcess (pid)
    phandle = OpenProcess_ (#PROCESS_TERMINATE, #False, pid)
    If phandle <> #Null
      If TerminateProcess_ (phandle, 1)
        result = #True
      EndIf
      CloseHandle_ (phandle)
    EndIf
    ProcedureReturn result
  EndProcedure
  Procedure IO_Get_AllProcess(List Processlist.ProcessName())
    psapi = OpenLibrary(#PB_Any, "psapi.dll")
    #SystemProcessInformation = $0005
    Define dwlen, *Buffer, *SPI._SYSTEM_PROCESS_INFO
    NtQuerySystemInformation_(#SystemProcessInformation, 0, 0, @dwlen)
    If dwlen
      dwlen * 2
      *Buffer = AllocateMemory(dwlen)
      If *Buffer
        If NtQuerySystemInformation_(#SystemProcessInformation, *Buffer, dwlen, @dwlen) = #ERROR_SUCCESS
          *SPI = *Buffer
          While *SPI\NextEntryOffset
            If *SPI\ImageName\usBuffer
              AddElement(Processlist())
              Processlist()\PID = *SPI\ProcessId
              Processlist()\Threads = *SPI\NumberOfThreads
              
              hProcess = OpenProcess_(#PROCESS_ALL_ACCESS, 0, *SPI\ProcessId)
              If hProcess
                Name$ = Space(1024)
                CallFunction(psapi, "GetModuleFileNameExW", hProcess, 0, @Name$, Len(Name$)*2)
                CloseHandle_(hProcess)
              EndIf
              
              Processlist()\Path = Name$
              Processlist()\Name = PeekS(*SPI\ImageName\usBuffer, -1, #PB_Unicode)
              
            EndIf
            *SPI + *SPI\NextEntryOffset
          Wend
        EndIf
        FreeMemory(*Buffer)
      EndIf
    EndIf
    CloseLibrary(psapi)
  EndProcedure
  Procedure IO_Set_CloseProcessByName(filename.s);not title!
    NewList Processlist.ProcessName()
    IO_Get_AllProcess(Processlist())
    ForEach Processlist()
      If Processlist()\Name = filename
        IO_Set_KillProcess(Processlist()\PID)
      EndIf
    Next
  EndProcedure
  Procedure IO_Check_RunningExe(FileName.s)
    Protected snap.l , Proc32.PROCESSENTRY32 , dll_kernel32.l
    FileName = GetFilePart( FileName )
    dll_kernel32 = OpenLibrary (#PB_Any, "kernel32.dll")
    If dll_kernel32
      snap = CallFunction (dll_kernel32, "CreateToolhelp32Snapshot",$2, 0)
      If snap
        Proc32\dwSize = SizeOf (PROCESSENTRY32)
        If CallFunction (dll_kernel32, "Process32First", snap, @Proc32) 
          While CallFunction (dll_kernel32, "Process32Next", snap, @Proc32)
            name.s = "" : Offset = 0
            Repeat
              c = PeekA(@Proc32\szExeFile+Offset)
              name  + Chr(c)
              Offset + 1
            Until Not c
            If name=FileName
              CloseHandle_ (snap)
              CloseLibrary (dll_kernel32)
              ProcedureReturn #True
            EndIf
          Wend
        EndIf   
        CloseHandle_ (snap)
      EndIf
      CloseLibrary (dll_kernel32)
    EndIf
    ProcedureReturn #False
  EndProcedure
  Procedure IO_Get_AllHwndAndTitles(List Result.GetAllHwndAndTitles())
    Repeat
      sz = ListSize(Result())
      Repeat 
        If Flag = 0 
          hWnd = FindWindow_(0, 0) 
          Flag=1 
        Else 
          hWnd = GetWindow_(hWnd, #GW_HWNDNEXT) 
        EndIf 
        If hWnd <> 0 
          If GetWindowLong_(hWnd, #GWL_STYLE) & #WS_VISIBLE = #WS_VISIBLE
            If GetWindowLong_(hWnd, #GWL_EXSTYLE) & #WS_EX_TOOLWINDOW <> #WS_EX_TOOLWINDOW
              ret.s = Space(256) 
              GetWindowText_(hWnd, ret, 256) 
              AddElement(Result())
              Result()\Title = ret
              Result()\hwnd = hwnd
              If ret <> "" : Break : EndIf 
            EndIf 
          EndIf 
        Else 
          Flag = 0 
        EndIf 
      Until hWnd = 0 
      If sz = ListSize(Result())
        Break
      EndIf
    ForEver
    ;{ EXAMPLE
    ; NewList test.GetAllHwndAndTitles()
    ; IO_Get_AllHwndAndTitles(test())
    ; ForEach test()
    ;   Debug test()\Title
    ; Next
    ;}
    
  EndProcedure
  Procedure IO_Get_HwndByTitle(Text$)
    Repeat
      ;hWnd = FindWindowEx_(0, hWnd, @"NotePad", 0)
      hWnd = FindWindowEx_(0, hWnd, 0, 0)
      If hwnd
        cnt + 1
        title.s = Space(512)
        GetWindowText_(hWnd, @title, 512)
        If FindString(title,Text$)
          ProcedureReturn hwnd
        EndIf
      EndIf
    Until hWnd = 0
  EndProcedure
  Procedure IO_Set_FocusWindowByTitle(Title.s)
    hwnd = FindWindow_(0,Title)
    SetForegroundWindow_(hwnd)
    Delay(1)
    ProcedureReturn hwnd
  EndProcedure
  Procedure IO_Set_MaxWindow(hwnd)
    SetWindowPos_(hwnd,0,-8,-31,DesktopWidth(0)+16,DesktopHeight(0)-2,0)
  EndProcedure
  Procedure IO_Get_TitleToHwnd(Title.s)
    ProcedureReturn FindWindow_(0,Title)
  EndProcedure
  Procedure IO_Get_HwndToPID(hwnd)
    PID.i
    GetWindowThreadProcessId_(hwnd, @PID)
    ProcedureReturn PID
  EndProcedure
  
  ;!WARNING!
  ;These functions are hard for the AV and might 1) cause loading issues 2) trigger false-positives
  Declare.s IO_Get_HwndText(hwnd.i)
  Procedure IO_Get_HwndForAllText(hWnd.i, Map Result.s(),Prefix.s = "")
    Protected nexthwnd.i, szClass.s{1024}, szText.s{2048}
    nexthwnd = GetWindow_(hwnd, #GW_CHILD | #GW_HWNDFIRST)
    While nexthwnd <> 0
      GetClassName_(nexthwnd, @szClass, SizeOf(szClass))
      GetWindowText_(nexthwnd, @szText, SizeOf(szText))
      SendMessage_(nexthwnd, #WM_GETTEXT, SizeOf(szText)/2, @szText) ; Unicode Support
      Result("hwnd: "+Str(nexthwnd) + " Class: "+ Prefix + szClass) = szText
      IO_Get_HwndForAllText(nexthwnd,Result(),szClass+"\")
      CloseHandle_(nexthwnd)
      nexthwnd = GetWindow_(nexthwnd, #GW_HWNDNEXT)
    Wend
    
  EndProcedure
  Procedure IO_Set_EnumParentsWithCallback(hWnd.i, *FunctionPointer)
    Protected szClass.s{1024}, szText.s{2048}
    GetClassName_(hWnd, @szClass, SizeOf(szClass))
    GetWindowText_(hWnd, @szText, SizeOf(szText))
    CallFunctionFast(*FunctionPointer,hwnd,@szClass,@szText)
    ProcedureReturn 1
  EndProcedure
  Procedure IO_Get_EnumParentsWithResult(hWnd.i, *Result.NestedList)
    Protected szClass.s{1024}, szText.s{2048}
    GetClassName_(hWnd, @szClass, SizeOf(szClass))
    GetWindowText_(hWnd, @szText, SizeOf(szText))
    AddElement(*Result\Nested())
    *Result\Nested()\Class = szClass
    *Result\Nested()\hwnd = hWnd
    
    ;If the 1kb Buffer was too small, use the 100kb buffer
    If Len(szText) > 1000
      *Result\Nested()\Text =  IO_Get_HwndText(hWnd)
    Else
      *Result\Nested()\Text = szText
    EndIf
    
    ProcedureReturn 1
  EndProcedure
  Procedure IO_Get_AllProcessClassCallback(*CallbackFunctionPointer)
    EnumWindows_(@IO_Set_EnumParentsWithCallback(),*CallbackFunctionPointer)
    ;{ EXAMPLE
    
    ; Procedure CallBack(PID,Class.s,Text.s)
    ;   Debug Str(PID)+Chr(9)+Class+": "+Text
    ; EndProcedure
    ; 
    ; IO_Get_AllTitleProcessesClassByCallback(@CallBack())
    ;}
  EndProcedure
  Procedure IO_Get_AllProcessClassResult(*ResultList)
    EnumWindows_(@IO_Get_EnumParentsWithResult(),*ResultList)
    ;Example
    ;   ResultList.NestedList                                   
    ;   IO_Get_AllProcessClassResult(@ResultList)
    ;   ForEach ResultList\Nested()
    ;     Debug Str(ResultList\Nested()\hwnd)+Chr(9)+ResultList\Nested()\Class+Chr(9)+ResultList\Nested()\Text
    ;   Next
  EndProcedure
  
  Procedure.s IO_Get_HwndText(hwnd.i) ; Supports 100kb long texts - way more then ScanHwndForClassAndText() (1kb)
    szText.s{100000}                  ;100kb - Don't overflow the stack maximum on test before overflow= 514882
    SendMessage_(hwnd, #WM_GETTEXT, SizeOf(szText)/2, @szText)
    ProcedureReturn szText
  EndProcedure
  Procedure IO_Get_HwndByTextFromWinUI(Text.s,ResultNr=1) ; Returns the hwnd - searches all titles, classes and content
    ResultList.NestedList
    NewMap TempResultMap.s()
    IO_Get_AllProcessClassResult(@ResultList)
    Hit = 0
    ForEach ResultList\Nested()
      If Len(ResultList\Nested()\Text) = 0
        Continue
      EndIf
      If FindString(ResultList\Nested()\Text,text) Or FindString(ResultList\Nested()\Class,text)
        Hit+1
        If Hit >= ResultNr
          ProcedureReturn ResultList\Nested()\hwnd
        EndIf
        
      Else
        ;If not in title and class- maybe in content?
        IO_Get_HwndForAllText(ResultList\Nested()\hwnd,TempResultMap())
        ForEach TempResultMap()
          If FindString(TempResultMap(),text)
            Key$ = MapKey(TempResultMap())
            ;Remember: Key = "hwnd: "+Str(nexthwnd) + " Class: "
            hwnd = Val(StringField(StringField(Key$,1," Class: "),2,"hwnd: "))
            Hit+1
            If Hit >= ResultNr
              ProcedureReturn hwnd
            EndIf
            
          EndIf
        Next
        
      EndIf
    Next
  EndProcedure
  ;}
  
  ;{ Process Memory Read
  ;{ Structures
  Structure MemoryResult
    Adress.i
    Offset.i
    Type.i
    String.s
    length.i
  EndStructure;}
  Procedure IO_Get_ModBaseAddr(ProcessId.i, ModuleName.s)
    Protected handle.i
    Protected me32.MODULEENTRY32
    Protected base.i
    handle = CreateToolhelp32Snapshot_(#TH32CS_SNAPMODULE32|#TH32CS_SNAPMODULE,ProcessId)
    If Not handle = #INVALID_HANDLE_VALUE
      me32\dwSize = SizeOf(MODULEENTRY32)
      If Module32First_(handle,@me32)
        ModuleName = LCase(ModuleName)
        Repeat
          If LCase(PeekS(@me32\szModule)) = ModuleName
            base = me32\modBaseAddr
            Break
          EndIf
        Until Module32Next_(handle,@me32) = #False
      EndIf
      CloseHandle_(handle)
    EndIf
    ProcedureReturn base
  EndProcedure
  Procedure IO_Get_ModBaseAddrViaDLL(ProcessId.l, ModuleName.s)
    ;Same as IO_Get_ModBaseAddr but makes calls manually via dll instead of API
    kernel32=OpenLibrary(#PB_Any, "kernel32.dll")
    ;Handle für externen Prozess 
    Protected snapShot.i
    ;Struktur für die Eigenschaften eines Moduls
    Protected Me32.MODULEENTRY32
    ;Wenn die Library "kernel32.dll" geladen wurden
    If kernel32
      ;Rufe die Funktion ToolHelp mit der ProcessID auf. Gibt den Handle auf die Module der ProcessID
      snapShot=CallFunction(kernel32, "CreateToolhelp32Snapshot", #TH32CS_SNAPMODULE, ProcessId)
      ;falls erfolgreich
      If snapShot
        ;Bereite eine Struktur des Typs Moduleentry32 vor um die einzelnen Module nacheinander da reinzuschreiben
        ;Die Größe der Struktur wird in der Struktur festgehalten (Windows-eigen)
        Me32\dwSize=SizeOf(MODULEENTRY32)
        ;Belade die Struktur mit dem ersten Modul des Prozesses
        If CallFunction(kernel32, "Module32First", snapShot, @Me32)
          ;Werte den ModuleNamen aus
          Repeat
            ;Lese String aus dem Speicherbereich Me32\szModule bis zur Nullterminierung (-1) aks ASCCI
            Protected moduleName$=PeekS(@Me32\szModule, -1, #PB_Ascii)
            ;Ist der String der gesuchten ModuleNamen?
            If moduleName$=ModuleName
              ;Falls ja, abbruch und Baseaddresse aus der Struktur auslesen und returnen
              CloseLibrary(kernel32)
              ProcedureReturn Me32\modBaseAddr
            EndIf
            ;Sonst: Nächstes Modul bis es kein Nächstes mehr gibt.
          Until Not CallFunction(kernel32, "Module32Next", snapShot, @Me32)
        EndIf
        ;Alle Module wurden durchsucht / es wurde das richtige gefunden. Jetzt den Funktionshandle freigaben (max 4048 pro Programm)
        CloseHandle_(snapShot)
      EndIf
    EndIf
    CloseLibrary(kernel32)
    ;Wenn oben keine Baseadresse ermittelt werden konnte, gebe Null zurück
    ProcedureReturn 0
  EndProcedure
  Procedure IO_Get_MemAdressByModandPointerListx64(PID,List Offsets.q(),ModuleName$="",hProcess=-1)
    ;Wenn der Speicher einer DLL angehört statt dem eigentlichen Prozess
    ;ModuleName$ z.b. "mono.dll"
    If hProcess<=0
      hProcess = OpenProcess_(#PROCESS_ALL_ACCESS, 0, PID)
    EndIf
    If hProcess <= 0
      Debug "Cannot open Process"
      ProcedureReturn -1
    EndIf
    
    If Len(moduleAddress$) > 0
      moduleAddress=IO_Get_ModBaseAddr(PID, ModuleName$)
    EndIf
    
    FirstElement(Offsets())
    address = moduleAddress+Offsets() ; Nicht getestet, sollte klappen
    Repeat
      ReadProcessMemory_(hProcess, address , @address, 8, #IGNORE)
      If Not NextElement(Offsets())
        Break
      EndIf
    ForEver
    
    CloseHandle_(hProcess)
    ProcedureReturn PeekL(@adresse)
  EndProcedure
  Procedure IO_Get_MemAdressByPointerListx32(PID,ProcessExe.s,List Pointers())
    Protected hwnd.i
    Protected hproc.i
    Protected base.i
    Protected address.i
    
    hproc = OpenProcess_(#PROCESS_ALL_ACCESS,#False,pid)
    If hproc
      ;       Debug "hproc: 0x" + Hex(hproc)
      base = IO_Get_ModBaseAddr(pid,ProcessExe)
      
      address = base
      ForEach Pointers()
        If address
          ReadProcessMemory_(hproc,address+Pointers(),@address,4,#Null)
          If ListIndex(Pointers()) = ListSize(Pointers())-1
            CloseHandle_(hproc)
            ProcedureReturn address
          EndIf
        Else
          CloseHandle_(hproc)
          ProcedureReturn 0
        EndIf
      Next
    EndIf
  EndProcedure
  Procedure IO_Check_MemScanForValue(ProcessId,List Results.MemoryResult(), *Value, ValueType)
    
    *mbi.MEMORY_BASIC_INFORMATION = AllocateMemory(SizeOf(MEMORY_BASIC_INFORMATION))
    address=0
    
    If ValueType = #PB_String
      String$ = PeekS(*Value)
      len=Len(String$)
    ElseIf ValueType = #PB_Integer
      Value = PeekI(*value)
      Len = 4
    EndIf
    
    CompilerIf #PB_Compiler_Unicode = #True
      len * 2
    CompilerEndIf
    
    
    hProcess = OpenProcess_(#PROCESS_ALL_ACCESS, #False, ProcessId)
    
    Repeat
      result=VirtualQueryEx_(hProcess, address, *mbi, SizeOf(MEMORY_BASIC_INFORMATION))
      
      If *mbi\State = #MEM_COMMIT And *mbi\Protect <> #PAGE_READONLY And *mbi\Protect <> #PAGE_EXECUTE_READ And *mbi\Protect <> #PAGE_GUARD And *mbi\Protect <> #PAGE_NOACCESS
        sBuffer=AllocateMemory(*mbi\RegionSize)
        res=ReadProcessMemory_(hProcess, address, sBuffer, *mbi\RegionSize, @written)
        
        written - len
        If written > 0
          For x = 0 To written
            If ValueType = #PB_String
              If CompareMemory(sBuffer + x, @String$, len)
                AddElement(Results())
                results()\Adress = *mbi\BaseAddress
                results()\Offset = x
                results()\length = len
                Results()\Type = ValueType
                Results()\String = PeekS(sBuffer + x,Len)
              EndIf
            ElseIf ValueType = #PB_Integer
              If tmp=Value
                AddElement(Results())
                results()\Adress = *mbi\BaseAddress
                results()\Offset = x
                results()\length = len
                Results()\Type = ValueType
                Results()\String = Str(PeekL(sBuffer+x))
              EndIf
            EndIf
          Next
        EndIf 
        FreeMemory(sBuffer)
      EndIf
      address=*mbi\BaseAddress+*mbi\RegionSize
      
    Until result=0
    
    ;{ EXAMPLE
    ;     HWND = FindWindow_(NULL, "*Unbenannt - Editor")
    ;     GetWindowThreadProcessId_(HWND, @pid)
    ;     findString$="LOL123LOL456"
    ;     
    ;     
    ;     NewList Results.MemoryResult()
    ;     IO_Check_MemScanForValue(pid,Results(),@findString$,#PB_String)
    ;     ForEach Results()
    ;       
    ;       Debug Hex(Results()\Adress)+" + "+ Hex(Results()\Offset)
    ;       Debug Results()\String
    ;       Debug Results()\Type
    ;       
    ;     Next 
    ;}
    
  EndProcedure
  
  
  
  ;{ Util - System
  #PDH_NO_DATA = $A00007D5              ;For CPU Usage %
  #PDH_INVALID_HANDLE = $E0000BBC       ;For CPU Usage %
  
  Prototype PdhLookupPerfNameByIndex(szMachineName.s, dwNameIndex.l, *szNameBuffer, *pcchNameBufferSize)
  Global PdhLookupPerfNameByIndex.PdhLookupPerfNameByIndex, MemSize.l
  ;{ Structures
  Structure PDH_FMT_COUNTERVALUE        ;For CPU Usage %
    CStatus.l
    padding.l
    ulValueLow.l
    ulValueHigh.l
  EndStructure
  ;}
  
  Procedure.s PDH_CounterName(CoreNum.s = "_Total")
    
    ;Good Result for English: \Processor(0)\% Processor Time
    
    Define *LPTSTR, Temp.s
    
    MemSize.l = 1024 ;Global Variable
    *LPTSTR = AllocateMemory(MemSize)
    If *LPTSTR
      If CoreNum.s = "-1"
        CoreNum.s = "_Total"
      EndIf
      If PdhLookupPerfNameByIndex(#Null$, 238, *LPTSTR, @MemSize) = 0
        Temp.s = "\" + PeekS(*LPTSTR, MemSize) + "(" + CoreNum.s + ")\"
      EndIf
    EndIf
    FreeMemory(*LPTSTR)
    
    MemSize.l = 1024
    *LPTSTR = AllocateMemory(MemSize)
    If *LPTSTR
      If PdhLookupPerfNameByIndex(#Null$, 6, *LPTSTR, @MemSize) = 0
        Temp.s = Temp.s + PeekS(*LPTSTR, MemSize)
        ;Debug PeekS(*LPTSTR, MemSize)
      EndIf
    EndIf
    FreeMemory(*LPTSTR)
    
    ProcedureReturn Temp.s
    
  EndProcedure
  
  #PerformanceLib = 88 ;Temp #
  
  If OpenLibrary(#PerformanceLib, "pdh.dll")
    CompilerIf #PB_Compiler_Unicode
      PdhLookupPerfNameByIndex = GetFunction(#PerformanceLib, "PdhLookupPerfNameByIndexW")
    CompilerElse
      PdhLookupPerfNameByIndex = GetFunction(#PerformanceLib, "PdhLookupPerfNameByIndexA")
    CompilerEndIf
  EndIf 
  
  hQuery.l
  hCounter.l
  
  Procedure.s IO_Get_CpuUsage()
    RESULT.q = PdhOpenQuery_( 0, 1, @hQuery )
    NewList ProcessorUsage.l()
    CpuCount.l = CountCPUs(#PB_System_CPUs)
    For AddC.l = 0 To CpuCount - 1
      RESULT = PdhAddCounter_(hQuery, PDH_CounterName(Str(Addc)), 0, @hCounter)
      AddElement(ProcessorUsage())
      ProcessorUsage() = hCounter
      ;If result = ERROR_SUCCESS
      ;  Debug Result
      ;  Debug hCounter
      ;  Debug "Good!"
      ;  Debug "------"
      ;EndIf
    Next AddC
    
    retcode.d
    lpValue.PDH_FMT_COUNTERVALUE
    RESULT = PdhCollectQueryData_(hQuery)
    Delay(250)
    
    RESULT = PdhCollectQueryData_(hQuery)
    megaRetcode.d = 0
    ForEach ProcessorUsage()
      hCounter = ProcessorUsage()
      PdhGetFormattedCounterValue_(hCounter, $200 | $8000, @dwType.l, @lpValue)
      CopyMemory(@lpValue\ulValueLow, @retcode, 8)
      megaRetcode + retcode
    Next  
    ProcedureReturn StrF(megaRetcode / CpuCount, 1) + "%"
  EndProcedure
  ;}
  ;}
CompilerEndIf
;--------------------------;
;         Purebasic        ;
;--------------------------;
CompilerIf 1=1
  ;{ AI
  
  Structure DataSet
    Array Input.d(0)
    Array Trainingsoutput.d(0)
  EndStructure
  
  Structure Layer
    Array Neurons.d(0)
    Array Weights.d(0)
  EndStructure
  
  Structure Errors
    Array Neuron.d(0)
  EndStructure
  
  Structure NetCollect
    List NN.Layer()
    Result.d
  EndStructure
  
  Global LearnConstant.d = 0.3
  
  Procedure IO_Set_NN_CreateNet(List NewNeuralNetwork.layer(),List Params())
    position = 0
    ForEach Params()
      position +1
      AddElement(NewNeuralNetwork())
      layersize = Params()
      Dim NewNeuralNetwork()\Neurons(layersize-1)
      If position >= 2
        Dim NewNeuralNetwork()\Weights(layersize*lastlayersize-1)
        For x.l = 0 To layersize*lastlayersize-1
          NewNeuralNetwork()\Weights(x) = Random(200) / 100 -1
        Next
      EndIf
      lastlayersize = layersize
    Next
  EndProcedure
  
  Procedure.d IO_Set_NN_Propagade(List Network.layer(),*DataS.Dataset,Train=0) ;selects a random dataset entry
                                                                               ;Loading into INPUT-Layer
    FirstElement(Network())
    Neurons = ArraySize(Network()\Neurons())+1
    For x = 1 To Neurons
      Network()\Neurons(x-1) = *DataS\Input(x-1)
    Next
    oldNeurons = Neurons
    
    ;Propagade
    While NextElement(Network())
      Neurons = ArraySize(Network()\Neurons())+1
      For c = 0 To Neurons -1
        temp.d = 0
        For y = 0 To oldNeurons - 1
          PreviousElement(Network())
          neuro.d = Network()\Neurons(y)
          NextElement(Network())
          temp + neuro * Network()\Weights(y * Neurons + c)
        Next
        ;Sigmoid
        Network()\Neurons(c) = 1/(1+Exp(-temp))
      Next
      oldNeurons = Neurons
    Wend
    
    ;Error calculation
    NewList Difference.Errors()
    AddElement(Difference())
    LastElement(Network())
    Dim Difference()\Neuron(ArraySize(Network()\Neurons()))
    
    m = ArraySize(Network()\Neurons())
    For z = 0 To m
      Ergebnis_neuron_z = Network()\Neurons(z)
      Difference()\Neuron(z) = (*DataS\Trainingsoutput(z) - Network()\Neurons(z)) * (1.0 -Network()\Neurons(z))
    Next
    
    While ListIndex(Network()) > 0
      mix = ArraySize(Network()\Neurons())
      PreviousElement(Network())
      max = ArraySize(Network()\Neurons())
      
      InsertElement(Difference())
      Dim Difference()\Neuron(max)
      
      For x = 0 To max
        Fehler1.d = 0 
        NextElement(Network())
        NextElement(Difference())
        For y = 0 To mix
          Fehler1 = Fehler1 +  Difference()\Neuron(y) * Network()\Weights(x*(mix+1)+y)
        Next
        PreviousElement(Difference())
        PreviousElement(Network())
        Difference()\Neuron(x) = Network()\Neurons(x) * (1.0 - Network()\Neurons(x)) * Fehler1
      Next
    Wend
    
    ;Backpropagade
    If Train = 1
      LastElement(Difference())
      LastElement(Network())
      While ListIndex(Network()) > 0
        PreviousElement(Network())
        max = ArraySize(Network()\Neurons())
        NextElement(Network())
        mix = ArraySize(Network()\Neurons())
        For x = 0 To max
          PreviousElement(Network())
          neuro.d = Network()\Neurons(x)
          NextElement(Network())
          For y = 0 To mix
            Network()\Weights(x*(mix+1)+y) = Network()\Weights(x*(mix+1)+y) + (LearnConstant * Difference()\Neuron(y)) * neuro
          Next
        Next
        PreviousElement(Difference())
        PreviousElement(Network())
      Wend
    EndIf
    
  EndProcedure
  
  Procedure IO_Set_NN_Savenet(Path.s,List network.layer())
    json = CreateJSON(#PB_Any)
    InsertJSONList(JSONValue(json),network())
    SaveJSON(json,Path)
    FreeJSON(json)
  EndProcedure
  
  Procedure IO_Set_NN_Loadnet(Path.s,List network.layer())
    json = LoadJSON(#PB_Any,Path)
    ExtractJSONList(JSONValue(json),network())
    FreeJSON(json)
  EndProcedure
  
  ;Example
  ; NewList Neural_params()
  ; AddElement(Neural_params()) : Neural_params() = Pow(256,2)
  ; AddElement(Neural_params()) : Neural_params() = 256
  ; AddElement(Neural_params()) : Neural_params() = 128
  ; AddElement(Neural_params()) : Neural_params() = 6
  ; 
  ; NewList Neural_network.layer()
  ; CreateNet(Neural_network(),Neural_params())
  
  ;}
  
  ;{ Visual Output
  ;{ Structures
  Structure Pixels
    x.i
    y.i
    Color.i
  EndStructure
  ;}
  Prototype.i ptPrintWindow(hWnd, hdc, flags)
  Procedure IO_Get_ScreenShotMinimizedWindow(hwnd) ; Not a screen!
    OpenLibrary(1, "User32.dll")
    PrintWindow.ptPrintWindow = GetFunction(1, "PrintWindow")
    
    SetWindowLongPtr_(hwnd,#GWL_EXSTYLE,#WS_EX_LAYERED)
    SetLayeredWindowAttributes_(hwnd,0,0,#LWA_ALPHA)
    ShowWindow_(hWnd,#SW_RESTORE)
    GetWindowRect_(hWnd, r.RECT)
    width = r\right-r\left
    height = r\bottom-r\top
    
    image = CreateImage(#PB_Any, width, height, 24)
    hdc = StartDrawing(ImageOutput(image))
    Delay(10)
    PrintWindow(hWnd, hdc,0)
    StopDrawing()
    
    ShowWindow_(hWnd,#SW_HIDE)
    ShowWindow_(hWnd,#SW_MINIMIZE)
    SetWindowLongPtr_(hwnd,#GWL_EXSTYLE,#WS_EX_LAYERED)
    SetLayeredWindowAttributes_(hwnd,0,255,#LWA_ALPHA)
    ProcedureReturn image
    
  EndProcedure
  Procedure IO_Get_ScreenShotRectangle(Left.l, Top.l, Width.l, Height.l) 
    dm.DEVMODE 
    BMPHandle.l 
    srcDC = CreateDC_("DISPLAY", "", "", dm) 
    trgDC = CreateCompatibleDC_(srcDC) 
    BMPHandle = CreateCompatibleBitmap_(srcDC, Width, Height) 
    SelectObject_( trgDC, BMPHandle) 
    BitBlt_( trgDC, 0, 0, Width, Height, srcDC, Left, Top, #SRCCOPY) 
    DeleteDC_( trgDC) 
    ReleaseDC_( BMPHandle, srcDC)
    
    CaptureScreenHeight=Height
    CaptureScreenWidth=Width
    ProcedureReturn BMPHandle 
  EndProcedure 
  Procedure IO_Get_Screenshot_Window(hwnd) ; ### The Window must be visible !
    WindowSize.RECT 
    GetWindowRect_(hwnd, @WindowSize) 
    BMPHandle = IO_Get_ScreenShotRectangle(WindowSize\Left, WindowSize\Top, WindowSize\Right - WindowSize\Left, WindowSize\Bottom - WindowSize\Top) 
    Id=CreateImage(#PB_Any, WindowSize\Right - WindowSize\Left, WindowSize\Bottom - WindowSize\Top) 
    StartDrawing(ImageOutput(Id)) 
    DrawImage(BMPHandle,0,0) 
    StopDrawing()
  EndProcedure 
  Procedure IO_Get_DesktopScreenshot()
    img = CreateImage(#PB_Any,DesktopWidth(0)-40,DesktopHeight(0))
    hDC = StartDrawing(ImageOutput(img))
    If hDC
      DeskDC = GetDC_(GetDesktopWindow_())
      If DeskDC
        BitBlt_(hDC,0,0,DesktopWidth(0),DesktopHeight(0)-40,DeskDC,0,0,#SRCCOPY)
      EndIf
      ReleaseDC_(GetDesktopWindow_(),DeskDC)
    EndIf
    StopDrawing()
    ProcedureReturn img
  EndProcedure
  Procedure IO_Get_ColorFromImage (image, *Position.POINT)
    If *Position\x < 0 Or *Position\x >= ImageWidth(image) Or *Position\y < 0 Or *Position\y >= ImageHeight(image)
      ProcedureReturn -1
    EndIf
    
    StartDrawing(ImageOutput(image))
    color = Point(*Position\x,*Position\y)
    StopDrawing()
    ProcedureReturn color
  EndProcedure
  Procedure IO_Check_PixelPattern(image,List Pixels.Pixels())
    StartDrawing(ImageOutput(image))
    ForEach Pixels()
      If Not Point(Pixels()\x,Pixels()\y) = Pixels()\Color
        StopDrawing()
        ProcedureReturn 0
      EndIf
    Next
    StopDrawing()
    ProcedureReturn 1
  EndProcedure
  Procedure IO_Check_PixelPatternThreshold(image,List Pixels.Pixels(),Threshold)
    StartDrawing(ImageOutput(image))
    ForEach Pixels()
      c = Point(Pixels()\x,Pixels()\y)
      If Red(c)  +Threshold > Red(Pixels()\Color)   And Red(c)  -Threshold < Red(Pixels()\Color)   And
         Green(c)+Threshold > Green(Pixels()\Color) And Green(c)-Threshold < Green(Pixels()\Color) And
         Blue(c) +Threshold > Blue(Pixels()\Color)  And Blue(c) -Threshold < Blue(Pixels()\Color) 
      Else
        StopDrawing()
        ProcedureReturn 0
      EndIf
    Next
    StopDrawing()
    ProcedureReturn 1
  EndProcedure
  Procedure IO_Get_ImageFilterMinMax_Numerical(image,RedMin,RedMax,GreenMin,GreenMax,BlueMin,BlueMax,List P.POINT())
    StartDrawing(ImageOutput(image))
    For x = 0 To ImageWidth(image)-1
      For y = 0 To ImageHeight(image)-1
        c = Point(x,y)
        If Red(c) > RedMin And Red(c) < RedMax And
           Green(c) > GreenMin And Green(c) < GreenMax And
           Blue(c) > BlueMin And Blue(c) < BlueMax
          AddElement(P())
          P()\x = x
          P()\y = y
        EndIf
      Next
    Next
    StopDrawing()
    ProcedureReturn ListSize(p())
  EndProcedure
  Procedure IO_Get_ImageFilterThreshold_Numerical(image,Color,Threshold,List P.POINT())
    StartDrawing(ImageOutput(image))
    For x = 0 To ImageWidth(image)-1
      For y = 0 To ImageHeight(image)-1
        c = Point(x,y)
        If Red(c)  +Threshold >= Red(Color)   And Red(c)  -Threshold <= Red(Color)   And
           Green(c)+Threshold >= Green(Color) And Green(c)-Threshold <= Green(Color) And
           Blue(c) +Threshold >= Blue(Color)  And Blue(c) -Threshold <= Blue(Color) 
          AddElement(P())
          P()\x = x
          P()\y = y
        EndIf
      Next
    Next
    StopDrawing()
    ProcedureReturn ListSize(p())
  EndProcedure
  Procedure IO_Set_TextOnScreen(Text.s,x,y)
    tR.RECT
    hdc = CreateDC_("DISPLAY", 0, 0, 0) 
    If hdc
      tR\left = x 
      tR\top = y
      tR\right = x+(Len(text)*10) 
      tR\bottom = y+32 
      lCol = GetTextColor_(hdc) 
      SetTextColor_(hdc, $FF)
      DrawText_(hdc, Text, Len(Text), tR, 0 )
      SetTextColor_( hdc, lCol)
    EndIf
  EndProcedure
  ;}
  
  ;{ String-magic
  Procedure IO_Check_Regex(Regex.s)
    If CreateRegularExpression(0, Regex)
      FreeRegularExpression(0)
      ProcedureReturn 1
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  Procedure.s IO_Get_ExtractRegexGroup(Regex.s,Text.s,List Result.s())
    If CreateRegularExpression(0, Regex)
      If ExamineRegularExpression(0, Text)
        While NextRegularExpressionMatch(0)
          AddElement(Result()) : Result() = RegularExpressionGroup(0, 1)
        Wend
      EndIf
      FreeRegularExpression(0)
    EndIf
    ;  Example:
    ;   NewList test.s()
    ;   IO_Get_ExtractRegexGroup("color=(red|green|blue)","stype=bold, color=blue, margin=50",test())
    ;   ForEach Test()
    ;     Debug test()
    ;   Next
  EndProcedure
  
  ;}
  
  ;{ Audio
  
  ;{ Structures
  Structure WAVEHeader
    MagicBytes.l
    Filesize.l
    Text.q
    ChuckSize.l
    Compression.w
    Channels.w
    samplerate.l
    avBytesPerSecons.l
    BlockAlign.w
    bitPerSample.w
    dataText.l
    avBytesTotal.l
  EndStructure
  Structure Note
    StartMs.i
    DurationMs.i
    Frequency.i
  EndStructure;}
  
  Procedure IO_Set_CreateMusic(List Note.Note(),channels=1,bitrate=16,samplerate=44100)
    
    ;{ #Pb_Any Catching
    If channels = #PB_Any : channels = 1: EndIf
    If bitrate = #PB_Any : bitrate = 16: EndIf
    ;}
    
    ;{ Missing input Catching
    If ListSize(Note()) <= 0 : MessageRequester("Error","no notes given") : EndIf
    ;}
    
    ;{ Calculate Duration
    TotalDuration = 0
    ForEach Note()
      current = Note()\StartMs + Note()\DurationMs
      If TotalDuration < current
        TotalDuration = current
      EndIf
    Next
    SecUpRounded = Round(TotalDuration/1000,#PB_Round_Up)
    ;}
    
    ;{ Create a WAVE Header
    avBytesPerSec.l = channels * bitrate / 8 * samplerate  ; calculate the average bytes per second  
    
    Waveheader.Waveheader
    Waveheader\MagicBytes = $46464952 ;Backwards, LittleEndian
    Waveheader\Filesize = 36 + avBytesPerSec * SecUpRounded
    Waveheader\Text = $20746d6645564157
    Waveheader\ChuckSize = 16
    Waveheader\Compression = 1
    Waveheader\Channels = channels
    Waveheader\samplerate = samplerate
    Waveheader\avBytesPerSecons = avBytesPerSec
    Waveheader\BlockAlign = bitrate / 8 * channels
    Waveheader\bitPerSample = bitrate
    Waveheader\dataText = $61746164 ;Backwards, LittleEndian
    Waveheader\avBytesTotal = avBytesPerSec*SecUpRounded
    
    WaveHeaderSize = SizeOf(Waveheader)
    ;}
    
    ;{ Allocate Memory for the whole song
    Memory = AllocateMemory(WaveHeaderSize + SecUpRounded * samplerate * (bitrate / 8))
    ; Copy the Wave-Header to the first 44 Bytes
    CopyMemory(Waveheader,Memory,WaveHeaderSize)
    ;}
    
    ;{ Start calculating the samples
    
    Protected sample.w  ;(signed RAW data)
    
    For acttime = 1 To samplerate * SecUpRounded
      ProgressMs.f = acttime / samplerate * 1000
      For actchannel = 1 To channels  
        Sum = 0 : TempSample.f = 0
        ForEach Note()
          If ProgressMs >= Note()\StartMs And ProgressMs <= Note()\StartMs + Note()\DurationMs
            Sum +1 ; Sum of Tones for later division (normalisation)
            TempSample + Sin(2 * #PI * Note()\Frequency * acttime / samplerate)
          EndIf
        Next
        If Not sum
          Continue
        EndIf
        Sample = 32767 * (TempSample / Sum)
        PokeW(Memory + WaveHeaderSize + acttime*2 ,sample)
      Next  
    Next  
    ;}
    
    ProcedureReturn Memory
  EndProcedure
  
  ;Example
  ; NewList Notes.Note()
  ;  AddElement(Notes()) : Notes()\StartMs =   0 : Notes()\Frequency = 220 : Notes()\DurationMs = 500
  ;  AddElement(Notes()) : Notes()\StartMs = 500 : Notes()\Frequency = 420 : Notes()\DurationMs = 500
  ;  AddElement(Notes()) : Notes()\StartMs = 500 : Notes()\Frequency = 220 : Notes()\DurationMs = 3500
  ; 
  ;  Mem = IO_Set_CreateMusic(Notes())
  ;  
  ;   Sound = CatchSound(#PB_Any,Mem)
  ;   PlaySound(sound)
  ;   Delay(3000)
  ;  
  ;   FreeMemory(mem)
  
  ;}
  
  ;{ Forensics
  Procedure.s IO_Get_DllCompilationDate(File.s)
    f = ReadFile(#PB_Any,File)
    If f
      FileSeek(f,$3c)
      PE_Header_Offset.l = ReadLong(f)
      FileSeek(f,PE_Header_Offset)
      If ReadLong(f) = $00004550
        ;It's a PE-File!
        FileSeek(f,PE_Header_Offset+8)
        Timestamp.l = ReadLong(f)
        Result$ = FormatDate("%yyyy-%mm-%ddT%hh:%ii:%ssZ", Timestamp) ; zeigt das aktuelle Datum in 
      EndIf
      CloseFile(f)
    EndIf
    ProcedureReturn Result$
  EndProcedure
  ;}
  
  ;{ Util - File
  Procedure IO_Get_FilesInFolder(Folder.s,List Results.s(),recursive=1)
    d = ExamineDirectory(#PB_Any,folder,"*.")
    If Not IsDirectory(d)
      ProcedureReturn
    EndIf
    
    While NextDirectoryEntry(d)
      name$ = DirectoryEntryName(d)
      If name$ = "." Or name$ = ".."
        Continue
      EndIf
      If DirectoryEntryType(d) = #PB_DirectoryEntry_Directory
        If recursive
          IO_Get_FilesInFolder(Folder+"\"+name$,Results(),recursive)
        EndIf
        Continue
      ElseIf DirectoryEntryType(d) = #PB_DirectoryEntry_File
        AddElement(Results()) : Results() = Folder+name$
      EndIf
    Wend
    FinishDirectory(d)
  EndProcedure
  Procedure FileToBitPlane(UL,Start,Zoom)
    Pixelsize = Round(zoom / 100,#PB_Round_Nearest)
    
    fz = FileSize(filename$)
    If fz > Start
      totalbits = 200 * UL
      totalbytes = Round(totalbits / 8,#PB_Round_Up)
      
      mem = AllocateMemory(totalbits)
      
      f = OpenFile(#PB_Any,filename$)
      FileSeek(f,Start)
      ReadData(f,mem,totalbytes)
      CloseFile(f)
      
      bin.s = ""
      For x = 1 To totalbytes
        Bin + RSet(Bin(PeekA(mem+x-1)),8,"0")
      Next
      
      img = CreateImage(#PB_Any,UL*Pixelsize,200*Pixelsize)
      StartDrawing(ImageOutput(img))
      
      white = RGB(255,255,255)
      For x = 1 To UL
        For y = 0 To 199
          Box((x-1)*Pixelsize,y*Pixelsize,Pixelsize,Pixelsize,white * Val(Mid(bin,y*UL+x,1)))
        Next
      Next
      StopDrawing()
    EndIf
    ProcedureReturn img
  EndProcedure
  
  ;}
  
  ;{ Magic Bytes
  DataSection
    DocMagicBytes:
    Data.a $d0, $cf, $11, $e0, $a1
    LnkMagicBytes:
    Data.a $4C,$00,$00,$00,$01,$14,$02,$00
  EndDataSection
  ;}
  
  ;{ Network
  Procedure IO_Set_SendICMP(*Data,Length,IPv4.l, TimeOut=1000,MTU=1400)
    Protected hFile = IcmpCreateFile_()
    Protected Res 
    Protected *Out.ICMP_ECHO_REPLY = AllocateMemory(SizeOf(ICMP_ECHO_REPLY) + 32)
    
    If mtu < 33
      ProcedureReturn -1
    EndIf
    
    MTU = MTU - 32 ; Header
    MTU = MTU - 16 ; CRC (MD5-32 Bit Aber nur 16 gehen raus)
    Counter = 0
    
    Offset = 0
    While length > 0
      If Length > MTU 
        l = MTU
      Else 
        l = Length
      EndIf
      Counter =Counter +l
      
      PaketData = AllocateMemory(l+16)
      CopyMemory(*Data + Offset,PaketData,l)
      MD5$ = Fingerprint(PaketData,l,#PB_Cipher_MD5)
      For x = 0 To 15
        PokeA(PaketData+l+x,Val("$"+Mid(MD5$,1+x*2,2)))
      Next
      
      If IcmpSendEcho_(hFile, IPv4, PaketData, l+16, 0, *Out, MemorySize(*Out), TimeOut) And *Out\Status = 0
        Res = *Out\RoundTripTime
      Else
        Res = -1
      EndIf
      FreeMemory(PaketData)
      Offset = Offset + l
      length = Length - l
    Wend
    
    IcmpCloseHandle_(hFile)
    FreeMemory(*Out)
    
    ProcedureReturn Counter
  EndProcedure
  Procedure IO_Check_ReadICMPPaket(*Data,Length)
    If Length <= 16+32
      ProcedureReturn 0
    EndIf
    MD5$ = Left(Fingerprint(*Data+32,Length-16-32,#PB_Cipher_MD5),32);32 Nibble
    MD52$ = "" 
    For x = 0 To 15
      MD52$ = MD52$ + RSet(Hex(PeekA(*Data+Length-16+x)),2,"0")
    Next
    If UCase(MD5$) = UCase(MD52$)
      ShowMemoryViewer(*Data+32,length-32-16)
      ProcedureReturn 1
    EndIf
  EndProcedure
  Procedure.s IO_Get_HTML(URl.s)
    HttpRequest = HTTPRequestMemory(#PB_HTTP_Get,URLEncoder(Trim(URL)))
    If HttpRequest
      html$ = HTTPInfo(HTTPRequest, #PB_HTTP_Response) 
      FinishHTTP(HTTPRequest)
      ProcedureReturn html$
    Else
      ProcedureReturn ""
    EndIf
  EndProcedure
  ;}
  
  ;{ Common Knowledge
  Global NewMap IO_Get_MonthToNum();{
  IO_Get_MonthToNum("Januar") = 01
  IO_Get_MonthToNum("Februar") = 02
  IO_Get_MonthToNum("März") = 03
  IO_Get_MonthToNum("April") = 04
  IO_Get_MonthToNum("Mai") = 05
  IO_Get_MonthToNum("Juni") = 06
  IO_Get_MonthToNum("Juli") = 07
  IO_Get_MonthToNum("August") = 08
  IO_Get_MonthToNum("September") = 09
  IO_Get_MonthToNum("Oktober") = 10
  IO_Get_MonthToNum("November") = 11
  IO_Get_MonthToNum("Dezember") = 12;}
                                    ;}
  
CompilerEndIf
;--------------------------;
;   Using external Tools   ;
;--------------------------;
CompilerIf 1=0
  ;{ OCR-Install Tesseract
  Procedure IO_Set_DownloadTesseract()
    Downloadlink.s = "https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-v5.2.0.20220712.exe" ; Last update: 29.07.2022
    DownloadSize = 56237870
    
    Download = ReceiveHTTPFile(Downloadlink, GetTemporaryDirectory()+"TesseractInstaller.exe",#PB_HTTP_Asynchronous)
    Progresswindow = OpenWindow(#PB_Any,DesktopWidth(0)/2-100,200,200,40,"Tesseract Installation",#PB_Window_BorderLess)
    SmartWindowRefresh(Progresswindow,1)
    TextGadget(#PB_Any,0,0,200,20,"Downloading Tesseract Installer: ")
    Progressbar = ProgressBarGadget(#PB_Any,0,20,200,20,0,100)
    If Download
      Repeat
        Progress = HTTPProgress(Download)
        tempp.f =(Progress/ DownloadSize)*100
        SetGadgetState(Progressbar,tempp)
        WaitWindowEvent(1)
      Until Progress = #PB_HTTP_Success Or Progress  = #PB_HTTP_Failed
      
      If Progress = #PB_HTTP_Failed
        Goto FailedDownload
      EndIf
      
      CloseWindow(Progresswindow)
    Else
      FailedDownload:
      CloseWindow(Progresswindow)
      MessageRequester("Error","Download failed. Pls install tesseract manually.")
    EndIf
  EndProcedure
  Procedure IO_Set_GuidedTesseractInstall()
    program = RunProgram(GetTemporaryDirectory()+"TesseractInstaller.exe","","",#PB_Program_Open )
    If program
      Repeat
        Delay(10)
        handle = FindWindow_(0,"Installer Language")
      Until handle > 0
      SetActiveWindow_(handle)
      Delay(200)
      ;Sprache
      IO_Set_Key(#VK_RETURN)
      Delay(200)
      ;Empfehlung
      IO_Set_Key(#VK_RETURN)
      ;Lizenz
      Delay(200)
      IO_Set_Key(#VK_RETURN)
      ;Benutzer
      Delay(200)
      IO_Set_Key(#VK_TAB)
      IO_Set_Key(#VK_TAB)
      IO_Set_Key(#VK_TAB)
      IO_Set_Key(#VK_SPACE)
      IO_Set_Key(#VK_RETURN)
      ;Packages
      Delay(200)
      IO_Set_Key(#VK_RETURN)
      ;Pfad
      Wunschpfad.s = GetCurrentDirectory()+"Tesseract"
      SetClipboardText(Wunschpfad)
      
      ;Str+A
      IO_Set_KeyDown(#VK_CONTROL)
      IO_Set_KeyDown(#VK_A)
      Delay(100)
      IO_Set_KeyUp(#VK_CONTROL)
      IO_Set_KeyUp(#VK_A)
      Delay(100)
      ;Str+V
      IO_Set_KeyDown(#VK_CONTROL)
      IO_Set_KeyDown(#VK_V)
      Delay(100)
      IO_Set_KeyUp(#VK_CONTROL)
      IO_Set_KeyUp(#VK_V)
      IO_Set_Key(#VK_RETURN)
      Delay(100)
      
      ;Startmenü
      IO_Set_Key(#VK_TAB)
      IO_Set_Key(#VK_TAB)
      IO_Set_Key(#VK_SPACE)
      IO_Set_Key(#VK_RETURN)
      Delay(6000)
      ;Installation
      IO_Set_Key(#VK_RETURN)
      Delay(200)
      IO_Set_Key(#VK_RETURN)
      Delay(200)
      
      DeleteFile(GetTemporaryDirectory()+"TesseractInstaller.exe")
      
      ProcedureReturn 1
    Else
      ProcedureReturn 0  
    EndIf
  EndProcedure
  ;}
  
  ;{ OCR Use Tesseract
  Global TesseractExe.s = GetCurrentDirectory()+"Tesseract\tesseract.exe"
  Global OCRMutex = CreateMutex()
  Global NewMap OCRStrings.s()
  Global NewMap OCRWatches()
  
  ;{ Structures
  Structure OCRStruct
    Title.s
    x.i
    y.i
    w.i
    h.i
  EndStructure;}
  
  Procedure IO_Check_OCR(*Parameter.OCRStruct)
    Uniquename.s = Str(*Parameter\x)+Str(*Parameter\y)+Str(*Parameter\h)+Str(*Parameter\w)
    img = IO_Get_DesktopScreenshot()
    ocrimage = GrabImage(img,#PB_Any,*Parameter\x,*Parameter\y,*Parameter\w,*Parameter\h)
    If Not IsImage(ocrimage)
      ProcedureReturn 0
    EndIf
    FreeImage(img)
    SaveImage(ocrimage,GetCurrentDirectory()+Uniquename+".png",#PB_ImagePlugin_PNG)
    FreeImage(ocrimage)
    prog = RunProgram(TesseractExe,Chr(34)+GetCurrentDirectory()+Uniquename+".png"+Chr(34)+" "+Chr(34)+GetCurrentDirectory()+Uniquename+Chr(34),GetCurrentDirectory(),#PB_Program_Hide | #PB_Program_Wait)
    DeleteFile(GetCurrentDirectory()+Uniquename+".png")
    If FileSize(GetCurrentDirectory()+Uniquename+".txt") > 0
      f = ReadFile(#PB_Any,GetCurrentDirectory()+Uniquename+".txt")
      While Not Eof(f)
        ocrtext.s + ReadString(f)
      Wend
      CloseFile(f)
      DeleteFile(GetCurrentDirectory()+Uniquename+".txt")
    EndIf
    LockMutex(OCRMutex)
    OCRStrings(*Parameter\Title) = ocrtext
    UnlockMutex(OCRMutex)
    
  EndProcedure
  Procedure.s IO_Check_SingleOCR(image,x,y,w,h)
    If Not IsImage(image)
      ProcedureReturn ""
    EndIf
    
    Uniquename.s = Str(x)+Str(y)+Str(h)+Str(w)
    
    ;Bildausschnitt
    ocrimage = GrabImage(image,#PB_Any,x,y,w,h)
    SaveImage(ocrimage,GetCurrentDirectory()+Uniquename+".png",#PB_ImagePlugin_PNG)
    ;   ShowLibraryViewer("image",ocrimage)
    FreeImage(ocrimage)
    
    prog = RunProgram(TesseractExe,Chr(34)+GetCurrentDirectory()+Uniquename+".png"+Chr(34)+" "+Chr(34)+GetCurrentDirectory()+Uniquename+Chr(34)+" --psm 7",GetCurrentDirectory(),#PB_Program_Hide | #PB_Program_Wait)
    
    DeleteFile(GetCurrentDirectory()+Uniquename+".png")
    If FileSize(GetCurrentDirectory()+Uniquename+".txt") > 0
      f = ReadFile(#PB_Any,GetCurrentDirectory()+Uniquename+".txt")
      While Not Eof(f)
        ocrtext.s + ReadString(f)
      Wend
      CloseFile(f)
      DeleteFile(GetCurrentDirectory()+Uniquename+".txt")
    EndIf
    ProcedureReturn ocrtext
    
  EndProcedure
  Procedure.s IO_Check_NumberOCR(image,x,y,w,h)
    If Not IsImage(image)
      ProcedureReturn ""
    EndIf
    
    Uniquename.s = Str(x)+Str(y)+Str(h)+Str(w)
    
    ;Bildausschnitt
    ocrimage = GrabImage(image,#PB_Any,x,y,w,h)
    SaveImage(ocrimage,GetCurrentDirectory()+Uniquename+".png",#PB_ImagePlugin_PNG)
    ;   ShowLibraryViewer("image",ocrimage)
    FreeImage(ocrimage)
    
    prog = RunProgram(TesseractExe,Chr(34)+GetCurrentDirectory()+Uniquename+".png"+Chr(34)+" "+Chr(34)+GetCurrentDirectory()+Uniquename+Chr(34)+" --psm 7 nobatch digits",GetCurrentDirectory(),#PB_Program_Hide | #PB_Program_Wait)
    
    DeleteFile(GetCurrentDirectory()+Uniquename+".png")
    If FileSize(GetCurrentDirectory()+Uniquename+".txt") > 0
      f = ReadFile(#PB_Any,GetCurrentDirectory()+Uniquename+".txt")
      While Not Eof(f)
        ocrtext.s + ReadString(f)
      Wend
      CloseFile(f)
      DeleteFile(GetCurrentDirectory()+Uniquename+".txt")
    EndIf
    ProcedureReturn ocrtext
    
  EndProcedure
  Procedure IO_Check_InitReadStatusMessages(*ParameterIncoming.OCRStruct)
    ParameterInside.OCRStruct
    CopyStructure(*ParameterIncoming,ParameterInside,OCRStruct)
    Repeat
      IO_Check_OCR(ParameterInside)
    ForEver
  EndProcedure
  Procedure.s IO_Get_OCRStatus(Text.s)
    LockMutex(OCRMutex)
    Text.s = OCRStrings(Text)
    UnlockMutex(OCRMutex)
    
    ProcedureReturn Text
  EndProcedure
  Procedure IO_Set_OCRWatch(x,y,w,h,Title.s)
    Parameter.OCRStruct
    Parameter\x = x
    Parameter\y = y
    Parameter\w = w
    Parameter\h = h
    Parameter\Title = Title
    OCRWatches(Title) = CreateThread(@IO_Check_InitReadStatusMessages(),Parameter)
    Delay(100)
  EndProcedure
  Procedure IO_Set_StopOCRWatch(Title.s)
    KillThread(OCRWatches(Title))
    DeleteMapElement(OCRWatches(),Title)
  EndProcedure
  ;}
  
  ;{ Image-Classification WEKA
  
  Structure FileAndType
    Filepath.s
    Class.s ; Only needed For training. For testing, just ignore it.
  EndStructure
  
  Procedure.s Recurvsive_search(Path.s,SearchName.s)
    d = ExamineDirectory(#PB_Any,Path,"*.*")
    While NextDirectoryEntry(d)
      name$ = DirectoryEntryName(d)
      
      If name$ = "." Or name$ = ".."
        Continue
      EndIf
      
      If DirectoryEntryType(d) = #PB_DirectoryEntry_Directory
        Result$ = Recurvsive_search(Path+name$+"\",SearchName)
        If Len(Result$) > 0
          FinishDirectory(d)
          ProcedureReturn Result$
        EndIf
      ElseIf DirectoryEntryType(d) = #PB_DirectoryEntry_File
        If FindString(name$,SearchName) Or name$ = SearchName
          FinishDirectory(d)
          ProcedureReturn Path+name$
        EndIf
      EndIf
    Wend
    FinishDirectory(d)
  EndProcedure
  
  Procedure IO_Get_Weka_CheckDependencies()
    ;Get Current Weka Version
    ProgramfilesPath.s = "C:\Program Files\"
    d = ExamineDirectory(#PB_Any,ProgramfilesPath,"*.*")
    While NextDirectoryEntry(d)
      name$ = DirectoryEntryName(d)
      If FindString(name$,"Weka")
        WekaVersion$ = name$
        Break
      EndIf
    Wend
    FinishDirectory(d)
    
    VersionNr$ = RemoveString(ReplaceString(WekaVersion$,"-","."),"Weka.")
    If WekaVersion$ = ""
      MessageRequester("Error","No Weka found in Programfiles.")
      End
    EndIf
    
    ;Is Weka instlaled?
    Global WekaJarPath.s = "C:\Program Files\"+WekaVersion$+"\weka.jar"
    If FileSize(WekaJarPath) <= 0
      MessageRequester("Error","Cannot load Weka")
      End
    EndIf
    
    ;Is imageFilers installed?
    ImageFiltersPackagePath.s = GetHomeDirectory()+"wekafiles\packages\imageFilters\imageFilters.jar"
    If FileSize(ImageFiltersPackagePath) <= 0
      MessageRequester("Error","Cannot find imageFilter plugin")
    EndIf
    
    ;Where is Javaw.exe?
    
    Global javapath.s = Recurvsive_search(GetPathPart(WekaJarPath),"java.exe")
    If Len(javapath) <= 0
      MessageRequester("Error","Could not find javaw.exe in Weka's subdirectories. It should be in C:\Program Files\Weka-3-8-5\jre\zulu11.43.55-ca-fx-jre11.0.9.1-win_x64\bin\java.exe")
      End
    EndIf
  EndProcedure
  
  Procedure.s IO_Get_Weka_Internal_ImageFilter_Extract_Features(ArffFile.s,DatasetPath.s,Filter.s="FCTH") ; TODO: Filter MAGIC HAPPENS HERE!
    FeaturesFile.s = GetTemporaryDirectory()+"features.arff"
    
    Select Filter.s
      Case "PHOG"
        Filter.s = "weka.filters.unsupervised.instance.imagefilter.PHOGFilter"
      Case "FCTH"
        Filter.s = "weka.filters.unsupervised.instance.imagefilter.FCTHFilter"
    EndSelect
    
    ;Extract Features
    RunProgram(javapath," -cp "+Chr(34)+WekaJarPath+Chr(34)+" weka.Run "+Filter+" -i "+ArffFile+" -D "+DatasetPath+" -o "+FeaturesFile,GetCurrentDirectory(),#PB_Program_Open | #PB_Program_Wait | #PB_Program_Hide)
    
    ;Remove first feature-Line 'filename'
    RenameFile(FeaturesFile,GetPathPart(FeaturesFile)+"old.arff")
    Command.s = "weka.filters.unsupervised.attribute.Remove -R 1"
    RunProgram(javapath,"-cp "+Chr(34)+WekaJarPath+Chr(34)+" weka.Run "+command+" -i "+GetPathPart(FeaturesFile)+"old.arff"+" -o "+FeaturesFile,GetCurrentDirectory(),#PB_Program_Open | #PB_Program_Wait | #PB_Program_Hide)
    DeleteFile(GetPathPart(FeaturesFile)+"old.arff")
    
    ProcedureReturn FeaturesFile
    
  EndProcedure
  
  Procedure.s IO_Get_Weka_Internal_Create_Imagefilter_Arff(List DataSet.FileAndType())
    InternalArffPath.s = GetTemporaryDirectory()+"Purebasic_Weka.arff"
    
    NewMap Classes.s()
    ForEach DataSet()
      Classes(DataSet()\Class) = ""
    Next
    
    arfffile = CreateFile(#PB_Any,InternalArffPath)
    WriteStringN(arfffile,"@relation Purebasic_Automation")
    WriteStringN(arfffile,"@attribute filename string")
    WriteString(arfffile,"@attribute class {")
    first = 1
    ForEach Classes()
      If first = 0
        WriteString(arfffile,",")
      Else
        first = 0
      EndIf
      WriteString(arfffile,MapKey(Classes()))
    Next
    FreeMap(Classes())
    
    WriteStringN(arfffile,"}")
    WriteStringN(arfffile,"@data")
    ForEach DataSet()
      WriteStringN(arfffile,DataSet()\Filepath+","+DataSet()\Class)
    Next
    CloseFile(arfffile)
    
    ProcedureReturn InternalArffPath    
  EndProcedure
  
  Procedure.s IO_Get_Weka_LoadImages(List DataSet.FileAndType(), DatasetPath.s)
    InternalArff$ = IO_Get_Weka_Internal_Create_Imagefilter_Arff(DataSet())
    FeatureArff$  = IO_Get_Weka_Internal_ImageFilter_Extract_Features(InternalArff$,DatasetPath,"FCTH")
    DeleteFile(InternalArff$)
    ProcedureReturn FeatureArff$
  EndProcedure
  
  Procedure.s IO_Get_Weka_Train(DatasetArffFile.s, Classifier.s, SaveFileName.s) ; TODO: Training MAGIC HAPPENS HERE!
    Select Classifier
      Case "SupportVectorMachine"
        Command.s = "weka.classifiers.functions.SMO -C 1.0 -L 0.001 -P 1.0E-12 -N 0 -V -1 -W 1 -K "+Chr(34)+"weka.classifiers.functions.supportVector.PolyKernel -E 1.0 -C 250007"+Chr(34)+" -calibrator "+Chr(34)+"weka.classifiers.functions.Logistic -R 1.0E-8 -M -1 -num-decimal-places 4"+Chr(34)
      Case "NeuralNetwork"
        Command.s = "weka.classifiers.functions.MultilayerPerceptron -L 0.3 -M 0.2 -N 500 -V 0 -S 0 -E 20 -H a"
      Case "RandomForest"
        Command.s = "weka.classifiers.trees.RandomForest -P 100 -I 100 -num-slots 1 -K 0 -M 1.0 -V 0.001 -S 1"
    EndSelect
    
    Debug javapath+" -cp "+Chr(34)+WekaJarPath+Chr(34)+" weka.Run "+Command+" -t "+DatasetArffFile+" -d "+SaveFileName
    
    p = RunProgram(javapath," -cp "+Chr(34)+WekaJarPath+Chr(34)+" weka.Run "+Command+" -t "+DatasetArffFile+" -d "+SaveFileName,GetCurrentDirectory(),#PB_Program_Open | #PB_Program_Hide)
    If p
      While ProgramRunning(p)
        If AvailableProgramOutput(p)
          Debug ReadProgramString(p)
        EndIf
      Wend
    EndIf
    ProcedureReturn SaveFileName 
  EndProcedure
  
  Procedure.s IO_Get_Weka_Test(TestDataArff.s, Classifier.s, TrainedModelFile.s)
    If FileSize(TrainedModelFile) < 0
      MessageRequester("Error","Applied TrainingModel does not exist")
    EndIf
    
    Select Classifier
      Case "SupportVectorMachine"
        Command.s = "weka.classifiers.functions.SMO"
      Case "NeuralNetwork"
        Command.s = "weka.classifiers.functions.MultilayerPerceptron"
      Case "RandomForest"
        Command.s = "weka.classifiers.trees.RandomForest"
    EndSelect
    
    p= RunProgram(javapath," -cp "+Chr(34)+WekaJarPath+Chr(34)+" weka.Run "+Command+" -T "+TestDataArff+" -l "+TrainedModelFile+" -p 0 ",GetCurrentDirectory(),#PB_Program_Open | #PB_Program_Hide | #PB_Program_Read)
    Output$ = ""
    If p
      While ProgramRunning(p)
        If AvailableProgramOutput(p)
          Output$ + ReadProgramString(p) + Chr(13)
        EndIf
      Wend
    EndIf
    
    ProcedureReturn Output$ 
  EndProcedure
  
  NewList Datensatz.FileAndType()
  Macro AddDatensatz(ClassName,PathName)
    AddElement(Datensatz()) : Datensatz()\Class = ClassName  : Datensatz()\Filepath = PathName
  EndMacro
  
  NewList TestDataset.FileAndType()
  
  ;Example
  ;   DatasetPath.s = GetHomeDirectory()+"wekafiles\packages\imageFilters\data\butterfly_vs_owl\"
  ;   
  ;   d = ExamineDirectory(#PB_Any,DatasetPath,"*.jpg")
  ;   While NextDirectoryEntry(d)
  ;     name$ = DirectoryEntryName(d)
  ;     If name$ = "." Or name$ = ".."
  ;       Continue
  ;     EndIf
  ;     If FindString(name$,"mno")
  ;       AddDatensatz("Butterfly",name$)
  ;     ElseIf FindString(name$,"owl")
  ;       AddDatensatz("Owl",name$)
  ;     EndIf
  ;   Wend
  ;   FinishDirectory(d)
  ;   
  ;   ;Split Test-Datensatz away
  ;   OwlCounter = 0
  ;   ButterflyCounter = 0
  ;   ForEach Datensatz()
  ;     If Datensatz()\Class = "Owl" And OwlCounter < 10
  ;       OwlCounter +1
  ;     ElseIf Datensatz()\Class = "Butterfly" And ButterflyCounter < 10
  ;       ButterflyCounter+1
  ;     Else
  ;       Continue
  ;     EndIf
  ;     AddElement(TestDataset()) : TestDataset()\Class = Datensatz()\Class : TestDataset()\Filepath = Datensatz()\Filepath : DeleteElement(Datensatz())
  ;   Next
  ;   
  ; ;Start Working
  ; SaveFileName.s      = DatasetPath+"Trained.brain"
  ; ArffFile$           = IO_Get_Weka_LoadImages(Datensatz(),DatasetPath)
  ; TrainedBrainFile.s  = IO_Get_Weka_Train(ArffFile$,"RandomForest",SaveFileName)
  ; DeleteFile(ArffFile$)
  ; 
  ; TestArffFile$       = IO_Get_Weka_LoadImages(TestDataset(),DatasetPath)
  ; TestResult.s        = IO_Get_Weka_Test(TestArffFile$,"RandomForest",TrainedBrainFile)
  ; DeleteFile(TestArffFile$)
  ; 
  ; Debug TestResult
  
  ;}
  
  ;{ Network-Protocols
  ;{ Sniffing (disabled - needs wpcap.lib
  ;{ Structures
  Structure PageNavigateReturn
    frameId.s
    loaderId.s
    errorText.s
  EndStructure;}
  Global Dim IO_Get_EthernetServiceIDtoName.s(255);{
  IO_Get_EthernetServiceIDtoName(0)   = "HOPOPT"
  IO_Get_EthernetServiceIDtoName(1)   = "ICMP"
  IO_Get_EthernetServiceIDtoName(2)   = "IGMP"
  IO_Get_EthernetServiceIDtoName(3)   = "GGP"
  IO_Get_EthernetServiceIDtoName(4)   = "IP-in-IP"
  IO_Get_EthernetServiceIDtoName(5)   = "ST"
  IO_Get_EthernetServiceIDtoName(6)   = "TCP"
  IO_Get_EthernetServiceIDtoName(7)   = "CBT"
  IO_Get_EthernetServiceIDtoName(8)   = "EGP"
  IO_Get_EthernetServiceIDtoName(9)   = "IGP"
  IO_Get_EthernetServiceIDtoName(10)  = "BBN-RCC-MON"
  IO_Get_EthernetServiceIDtoName(11)  = "NVP-II"
  IO_Get_EthernetServiceIDtoName(12)  = "PUP"
  IO_Get_EthernetServiceIDtoName(13)  = "ARGUS"
  IO_Get_EthernetServiceIDtoName(14)  = "EMCON"
  IO_Get_EthernetServiceIDtoName(15)  = "XNET"
  IO_Get_EthernetServiceIDtoName(16)  = "CHAOS"
  IO_Get_EthernetServiceIDtoName(17)  = "UDP"
  IO_Get_EthernetServiceIDtoName(18)  = "MUX"
  IO_Get_EthernetServiceIDtoName(19)  = "DCN-MEAS"
  IO_Get_EthernetServiceIDtoName(20)  = "HMP"
  IO_Get_EthernetServiceIDtoName(21)  = "PRM"
  IO_Get_EthernetServiceIDtoName(22)  = "XNS-IDP"
  IO_Get_EthernetServiceIDtoName(23)  = "TRUNK-1"
  IO_Get_EthernetServiceIDtoName(24)  = "TRUNK-2"
  IO_Get_EthernetServiceIDtoName(25)  = "LEAF-1"
  IO_Get_EthernetServiceIDtoName(26)  = "LEAF-2"
  IO_Get_EthernetServiceIDtoName(27)  = "RDP"
  IO_Get_EthernetServiceIDtoName(28)  = "IRTP"
  IO_Get_EthernetServiceIDtoName(29)  = "ISO-TP4"
  IO_Get_EthernetServiceIDtoName(30)  = "NETBLT"
  IO_Get_EthernetServiceIDtoName(31)  = "MFE-NSP"
  IO_Get_EthernetServiceIDtoName(32)  = "MERIT-INP"
  IO_Get_EthernetServiceIDtoName(33)  = "DCCP"
  IO_Get_EthernetServiceIDtoName(34)  = "3PC"
  IO_Get_EthernetServiceIDtoName(35)  = "IDPR"
  IO_Get_EthernetServiceIDtoName(36)  = "XTP"
  IO_Get_EthernetServiceIDtoName(37)  = "DDP"
  IO_Get_EthernetServiceIDtoName(38)  = "IDPR-CMTP"
  IO_Get_EthernetServiceIDtoName(39)  = "TP++"
  IO_Get_EthernetServiceIDtoName(40)  = "IL"
  IO_Get_EthernetServiceIDtoName(41)  = "IPv6"
  IO_Get_EthernetServiceIDtoName(42)  = "SDRP"
  IO_Get_EthernetServiceIDtoName(43)  = "IPv6-Route"
  IO_Get_EthernetServiceIDtoName(44)  = "IPv6-Frag"
  IO_Get_EthernetServiceIDtoName(45)  = "IDRP"
  IO_Get_EthernetServiceIDtoName(46)  = "RSVP"
  IO_Get_EthernetServiceIDtoName(47)  = "GRE"
  IO_Get_EthernetServiceIDtoName(48)  = "DSR"
  IO_Get_EthernetServiceIDtoName(49)  = "BNA"
  IO_Get_EthernetServiceIDtoName(50)  = "ESP"
  IO_Get_EthernetServiceIDtoName(51)  = "AH"
  IO_Get_EthernetServiceIDtoName(52)  = "I-NLSP"
  IO_Get_EthernetServiceIDtoName(53)  = "SwIPe"
  IO_Get_EthernetServiceIDtoName(54)  = "NARP"
  IO_Get_EthernetServiceIDtoName(55)  = "MOBILE"
  IO_Get_EthernetServiceIDtoName(56)  = "TLSP"
  IO_Get_EthernetServiceIDtoName(57)  = "SKIP"
  IO_Get_EthernetServiceIDtoName(58)  = "IPv6-ICMP"
  IO_Get_EthernetServiceIDtoName(59)  = "IPv6-NoNxt"
  IO_Get_EthernetServiceIDtoName(60)  = "IPv6-Opts"
  IO_Get_EthernetServiceIDtoName(62)  = "CFTP"
  IO_Get_EthernetServiceIDtoName(64)  = "SAT-EXPAK"
  IO_Get_EthernetServiceIDtoName(65)  = "KRYPTOLAN"
  IO_Get_EthernetServiceIDtoName(66)  = "RVD"
  IO_Get_EthernetServiceIDtoName(67)  = "IPPC"
  IO_Get_EthernetServiceIDtoName(69)  = "SAT-MON"
  IO_Get_EthernetServiceIDtoName(70)  = "VISA"
  IO_Get_EthernetServiceIDtoName(71)  = "IPCU"
  IO_Get_EthernetServiceIDtoName(72)  = "CPNX"
  IO_Get_EthernetServiceIDtoName(73)  = "CPHB"
  IO_Get_EthernetServiceIDtoName(74)  = "WSN"
  IO_Get_EthernetServiceIDtoName(75)  = "PVP"
  IO_Get_EthernetServiceIDtoName(76)  = "BR-SAT-MON"
  IO_Get_EthernetServiceIDtoName(77)  = "SUN-ND"
  IO_Get_EthernetServiceIDtoName(78)  = "WB-MON"
  IO_Get_EthernetServiceIDtoName(79)  = "WB-EXPAK"
  IO_Get_EthernetServiceIDtoName(80)  = "ISO-IP"
  IO_Get_EthernetServiceIDtoName(81)  = "VMTP"
  IO_Get_EthernetServiceIDtoName(82)  = "SECURE-VMTP"
  IO_Get_EthernetServiceIDtoName(83)  = "VINES"
  IO_Get_EthernetServiceIDtoName(84)  = "TTP"
  IO_Get_EthernetServiceIDtoName(84)  = "IPTM"
  IO_Get_EthernetServiceIDtoName(85)  = "NSFNET-IGP"
  IO_Get_EthernetServiceIDtoName(86)  = "DGP"
  IO_Get_EthernetServiceIDtoName(87)  = "TCF"
  IO_Get_EthernetServiceIDtoName(88)  = "EIGRP"
  IO_Get_EthernetServiceIDtoName(89)  = "OSPF"
  IO_Get_EthernetServiceIDtoName(90)  = "Sprite-RPC"
  IO_Get_EthernetServiceIDtoName(91)  = "LARP"
  IO_Get_EthernetServiceIDtoName(92)  = "MTP"
  IO_Get_EthernetServiceIDtoName(93)  = "AX.25"
  IO_Get_EthernetServiceIDtoName(94)  = "OS"
  IO_Get_EthernetServiceIDtoName(95)  = "MICP"
  IO_Get_EthernetServiceIDtoName(96)  = "SCC-SP"
  IO_Get_EthernetServiceIDtoName(97)  = "ETHERIP"
  IO_Get_EthernetServiceIDtoName(98)  = "ENCAP"
  IO_Get_EthernetServiceIDtoName(100) = "GMTP"
  IO_Get_EthernetServiceIDtoName(101) = "IFMP"
  IO_Get_EthernetServiceIDtoName(102) = "PNNI"
  IO_Get_EthernetServiceIDtoName(103) = "PIM"
  IO_Get_EthernetServiceIDtoName(104) = "ARIS"
  IO_Get_EthernetServiceIDtoName(105) = "SCPS"
  IO_Get_EthernetServiceIDtoName(107) = "A/N"
  IO_Get_EthernetServiceIDtoName(108) = "IPComp"
  IO_Get_EthernetServiceIDtoName(109) = "SNP"
  IO_Get_EthernetServiceIDtoName(110) = "Compaq-Peer"
  IO_Get_EthernetServiceIDtoName(111) = "IPX-in-IP"
  IO_Get_EthernetServiceIDtoName(112) = "VRRP"
  IO_Get_EthernetServiceIDtoName(113) = "PGM"
  IO_Get_EthernetServiceIDtoName(115) = "L2TP"
  IO_Get_EthernetServiceIDtoName(116) = "DDX"
  IO_Get_EthernetServiceIDtoName(117) = "IATP"
  IO_Get_EthernetServiceIDtoName(118) = "STP"
  IO_Get_EthernetServiceIDtoName(119) = "SRP"
  IO_Get_EthernetServiceIDtoName(120) = "UTI"
  IO_Get_EthernetServiceIDtoName(121) = "SMP"
  IO_Get_EthernetServiceIDtoName(122) = "SM"
  IO_Get_EthernetServiceIDtoName(123) = "PTP"
  IO_Get_EthernetServiceIDtoName(124) = "IS-IS over IPv4"
  IO_Get_EthernetServiceIDtoName(125) = "FIRE"
  IO_Get_EthernetServiceIDtoName(126) = "CRTP"
  IO_Get_EthernetServiceIDtoName(127) = "CRUDP"
  IO_Get_EthernetServiceIDtoName(128) = "SSCOPMCE"
  IO_Get_EthernetServiceIDtoName(129) = "IPLT"
  IO_Get_EthernetServiceIDtoName(130) = "SPS"
  IO_Get_EthernetServiceIDtoName(131) = "PIPE"
  IO_Get_EthernetServiceIDtoName(132) = "SCTP"
  IO_Get_EthernetServiceIDtoName(133) = "FC"
  IO_Get_EthernetServiceIDtoName(134) = "RSVP-E2E-IGNORE"
  IO_Get_EthernetServiceIDtoName(135) = "Mobility Header"
  IO_Get_EthernetServiceIDtoName(136) = "UDPLite"
  IO_Get_EthernetServiceIDtoName(137) = "MPLS-in-IP"
  IO_Get_EthernetServiceIDtoName(138) = "manet"
  IO_Get_EthernetServiceIDtoName(139) = "HIP"
  IO_Get_EthernetServiceIDtoName(140) = "Shim6"
  IO_Get_EthernetServiceIDtoName(141) = "WESP"
  IO_Get_EthernetServiceIDtoName(142) = "ROHC"
  IO_Get_EthernetServiceIDtoName(143) = "Ethernet"
  IO_Get_EthernetServiceIDtoName(253) = "Use for experimentation and testing"
  IO_Get_EthernetServiceIDtoName(254) = "Use for experimentation and testing";}
  
  DeclareModule WebsocketClient
    Declare OpenWebsocketConnection(URL.s)
    Declare SendTextFrame(connection, message.s)
    Declare ReceiveFrame(connection, *MsgBuffer)
    Declare SetSSLProxy(ProxyServer.s = "", ProxyPort.l = 8182)
    
    Enumeration 1000
      #frame_text
      #frame_binary
      #frame_closing
      #frame_ping
      #frame_unknown
    EndEnumeration
    
  EndDeclareModule
  Module WebsocketClient
    
    ;TODO: Add function to send binary frame
    ;TODO: We don't support fragmetation right now
    ;TODO: We should send an closing frame, but server will also just close
    ;TODO: Support to send receive bigger frames
    debugmode = 0
    ;{ Structures
    Structure WebSocket
      Frametyp.i
      FrameMemory.i
    EndStructure;}
    
    Declare Handshake(Connection, Servername.s, Path.s)
    Declare ApplyMasking(Array Mask.a(1), *Buffer)
    
    Global Proxy_Server.s, Proxy_Port.l
    
    Macro dbg(txt)
      If Debugmode = 1
        Debug "WebsocketClient: " + FormatDate("%yyyy-%mm-%dd %hh:%ii:%ss",Date()) + " > " + txt
      EndIf
    EndMacro
    
    Procedure SetSSLProxy(ProxyServer.s = "", ProxyPort.l = 8182)
      Proxy_Server.s = ProxyServer.s
      Proxy_Port.l = ProxyPort.l
    EndProcedure
    
    Procedure OpenWebsocketConnection(URL.s)
      Protokol.s = GetURLPart(URL.s, #PB_URL_Protocol)
      Servername.s = GetURLPart(URL.s, #PB_URL_Site)
      Port.l = Val(GetURLPart(URL.s, #PB_URL_Port))
      If Port.l = 0 : Port.l = 80 : EndIf
      Path.s = GetURLPart(URL.s, #PB_URL_Path)
      If Path.s = "" : Path.s = "/" : EndIf
      
      ;InitNetwork()
      If Protokol.s = "wss" ; If we connect with encryption (https)
        If Proxy_Port
          Connection = OpenNetworkConnection(Proxy_Server.s, Proxy_Port.l, #PB_Network_TCP, 1000)
        Else
          dbg("We need an SSL-Proxy like stunnel for encryption. Configure the proxy with SetSSLProxy().")
        EndIf
      ElseIf Protokol.s = "ws"
        Connection = OpenNetworkConnection(Servername.s, Port.l, #PB_Network_TCP, 1000)
      EndIf
      
      If Connection
        If Handshake(Connection, Servername.s, Path.s)
          dbg("Connection and Handshake ok")
          ProcedureReturn Connection
        Else
          dbg("Handshake-Error")
          ProcedureReturn #False
        EndIf
      Else
        dbg("Couldn't connect")
        ProcedureReturn #False
      EndIf
    EndProcedure
    
    Procedure Handshake(Connection, Servername.s, Path.s)
      Request.s = "GET /" + Path.s + " HTTP/1.1"+ #CRLF$ +
                  "Host: " + Servername.s + #CRLF$ +
                  "Upgrade: websocket" + #CRLF$ +
                  "CONNECTION: UPGRADE" + #CRLF$ +
                  "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" + #CRLF$ +
                  "Sec-WebSocket-Version: 13" + #CRLF$ + 
                  "User-Agent: CustomWebsocketClient"+ #CRLF$ + #CRLF$
      
      SendNetworkString(Connection, Request.s, #PB_UTF8)
      *Buffer = AllocateMemory(65536)
      
      ; We wait for answer
      Repeat
        Size = ReceiveNetworkData(connection, *Buffer, 65536)
        Answer.s = Answer.s + PeekS(*Buffer, Size, #PB_UTF8)
        If FindString(Answer, #CRLF$ + #CRLF$)
          Break
        EndIf
      Until Size <> 65536
      
      Answer.s = UCase(Answer.s)
      
      ; Check answer
      If FindString(Answer.s, "HTTP/1.1 101") And FindString(Answer.s, "CONNECTION: UPGRADE") And FindString(Answer.s, "UPGRADE: WEBSOCKET")
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
    EndProcedure
    
    Procedure ApplyMasking(Array Mask.a(1), *Buffer)
      For i = 0 To MemorySize(*Buffer) - 1
        PokeA(*Buffer + i, PeekA(*Buffer + i) ! Mask(i % 4))
      Next
    EndProcedure
    
    Procedure SendTextFrame(connection, message.s)
      
      ; Put String in Buffer
      MsgLength.l = StringByteLength(message.s, #PB_UTF8)
      *MsgBuffer = AllocateMemory(MsgLength)
      PokeS(*MsgBuffer, message.s, MsgLength, #PB_UTF8|#PB_String_NoZero)
      
      dbg("Messagelength to send: " + Str(MsgLength))
      
      ; The Framebuffer, we fill with senddata
      If MsgLength <= 125
        Fieldlength = 6
      ElseIf MsgLength >= 126 And MsgLength <= 65535
        Fieldlength = 8
      Else
        Fieldlength = 14
      EndIf
      
      dbg("Fieldlength to send: " + Str(Fieldlength))
      
      
      *FrameBuffer = AllocateMemory(Fieldlength + MsgLength)
      
      ; We generate 4 random masking bytes
      Dim Mask.a(3)
      Mask(0) = Random(255,0)
      Mask(1) = Random(255,0) 
      Mask(2) = Random(255,0) 
      Mask(3) = Random(255,0) 
      
      pos = 0 ; The byteposotion in the framebuffer
      
      ; First Byte: FIN(1=finished with this Frame),RSV(0),RSV(0),RSV(0),OPCODE(4 byte)=0001(text) 
      PokeB(*FrameBuffer, %10000001) : pos + 1 ; = 129
      
      ; Second Byte: Masking(1),length(to 125bytes, else we have to extend)
      If MsgLength <= 125                                             ; Length fits in first byte
        PokeA(*Framebuffer + pos, MsgLength + 128)    : pos + 1       ; + 128 for Masking
      ElseIf MsgLength >= 126 And MsgLength <= 65535                  ; We have to extend length to third byte
        PokeA(*Framebuffer + pos, 126 + 128)          : pos + 1       ; 126 for 2 extra length bytes and + 128 for Masking
        PokeA(*FrameBuffer + pos, (MsgLength >> 8))   : pos + 1       ; First Byte
        PokeA(*FrameBuffer + pos, MsgLength)          : pos + 1       ; Second Byte
      Else                                                            ; It's bigger than 65535, we also use 8 extra bytes
        PokeA(*Framebuffer + pos, 127 + 128)          : pos + 1       ; 127 for 8 extra length bytes and + 128 for Masking
        PokeA(*Framebuffer + pos, 0)                  : pos + 1       ; 8 Bytes for payload lenght. We don't support giant packages for now, so first bytes are zero :P
        PokeA(*Framebuffer + pos, 0)                  : pos + 1
        PokeA(*Framebuffer + pos, 0)                  : pos + 1
        PokeA(*Framebuffer + pos, 0)                  : pos + 1
        PokeA(*Framebuffer + pos, MsgLength >> 24)    : pos + 1
        PokeA(*Framebuffer + pos, MsgLength >> 16)    : pos + 1
        PokeA(*Framebuffer + pos, MsgLength >> 8)     : pos + 1
        PokeA(*Framebuffer + pos, MsgLength)          : pos + 1       ; = 10 Byte
      EndIf
      ; Write Masking Bytes
      PokeA(*FrameBuffer + pos, Mask(0))              : pos + 1
      PokeA(*FrameBuffer + pos, Mask(1))              : pos + 1
      PokeA(*FrameBuffer + pos, Mask(2))              : pos + 1
      PokeA(*FrameBuffer + pos, Mask(3))              : pos + 1
      
      ApplyMasking(Mask(), *MsgBuffer)
      
      CopyMemory(*MsgBuffer, *FrameBuffer + pos, MsgLength)
      
      ;For x = 0 To 100 Step 5
      ;Debug Str(PeekA(*FrameBuffer + x)) + " | " + Str(PeekA(*FrameBuffer + x + 1)) + " | " + Str(PeekA(*FrameBuffer + x + 2)) + " | " + Str(PeekA(*FrameBuffer + x + 3)) + " | " + Str(PeekA(*FrameBuffer + x + 4))
      ;Next
      
      If SendNetworkData(connection, *FrameBuffer, Fieldlength + MsgLength) = Fieldlength + MsgLength
        dbg("Textframe send, Bytes: " + Str(Fieldlength + MsgLength))
        ProcedureReturn #True
      Else
        ProcedureReturn #False
      EndIf
      
    EndProcedure
    
    Procedure ReceiveFrame(connection, *Frametyp.WebSocket)
      *FrameBuffer = AllocateMemory(65536)
      
      Repeat
        *FrameBuffer = ReAllocateMemory(*FrameBuffer, 65536)
        Size = ReceiveNetworkData(connection, *FrameBuffer, 65536)
        ;Answer.s = Answer.s + PeekS(*FrameBuffer, Size, #PB_UTF8)
      Until Size <> 65536
      dbg("Received Frame, Bytes: " + Str(Size))
      
      *FrameBuffer = ReAllocateMemory(*FrameBuffer, Size)
      
      ;     ; debug: output any single byte
      ;     If #PB_Compiler_Debugger
      ;       For x = 0 To Size - 1 Step 1
      ;         dbg_bytes.s + Str(PeekA(*FrameBuffer + x)) + " | "
      ;       Next
      ;       dbg(dbg_bytes)
      ;     EndIf
      
      ; Getting informations about package
      If PeekA(*FrameBuffer) & %10000000 > #False
        ;dbg("Frame not fragmented")
        fragmentation.b = #False
      Else
        dbg("Frame fragmented! This not supported for now!")
        fragmentation.b = #True
      EndIf
      
      ; Check for Opcodes
      If PeekA(*FrameBuffer) = %10000001 ; Textframe
        dbg("Text frame")
        frame_typ.w = #frame_text
      ElseIf PeekA(*FrameBuffer) = %10000010 ; Binary Frame
        dbg("Binary frame")
        frame_typ.w = #frame_binary
      ElseIf PeekA(*FrameBuffer) = %10001000 ; Closing Frame
        dbg("Closing frame")
        frame_typ.w = #frame_closing
      ElseIf PeekA(*FrameBuffer) = %10001001 ; Ping
                                             ; We just answer pings
        *pongbuffer = AllocateMemory(2)
        PokeA(*pongbuffer, 138)
        PokeA(*pongbuffer+1, 0)
        SendNetworkData(connection, *pongbuffer, 2)
        dbg("Received Ping, answered with Pong")
        frame_typ.w = #frame_ping
        FreeMemory(*pongbuffer)
        FreeMemory  (*FrameBuffer)
        ProcedureReturn
      Else
        dbg("Opcode unknown")
        frame_typ.w = #frame_unknown
        FreeMemory(*FrameBuffer)
        ProcedureReturn #False
      EndIf
      
      ; Check masking
      If PeekA(*FrameBuffer + 1) & %10000000 = 128 : masking.b = #True : Else : masking.b = #False : EndIf
      
      dbg("Masking: " + Str(masking))
      
      pos.l = 1
      
      ; check size
      If PeekA(*FrameBuffer + 1) & %01111111 <= 125 ; size is in this byte
        frame_size.l = PeekA(*FrameBuffer + pos) & %01111111 : pos + 1
      ElseIf PeekA(*FrameBuffer + 1) & %01111111 >= 126 ; Size is in 2 extra bytes
        frame_size.l = PeekA(*FrameBuffer + 2) << 8 + PeekA(*FrameBuffer + 3) : pos + 2
      EndIf
      dbg("FrameSize: " + Str(frame_size.l))
      
      If masking = #True
        Dim Mask.a(3)
        Mask(0) = PeekA(*FrameBuffer + pos) : pos + 1
        Mask(1) = PeekA(*FrameBuffer + pos) : pos + 1
        Mask(2) = PeekA(*FrameBuffer + pos) : pos + 1
        Mask(3) = PeekA(*FrameBuffer + pos) : pos + 1
        
        *Frametyp\FrameMemory = ReAllocateMemory(*Frametyp\FrameMemory  ,frame_size)
        
        CopyMemory(*FrameBuffer + pos, *Frametyp\FrameMemory, frame_size)
        
        ApplyMasking(Mask(), *Frametyp\FrameMemory)
        
        FreeArray(Mask())
        
      Else
        *Frametyp\FrameMemory = ReAllocateMemory(*Frametyp\FrameMemory,frame_size+1)
        CopyMemory(*FrameBuffer + pos, *Frametyp\FrameMemory, frame_size)
      EndIf
      
      FreeMemory(*FrameBuffer)
      ProcedureReturn frame_typ
      
    EndProcedure
    
  EndModule
  
  ;{ Constants
  #MIB_IF_TYPE_OTHER = 1
  #MIB_IF_TYPE_ETHERNET = 6
  #MIB_IF_TYPE_TOKENRING = 9
  #MIB_IF_TYPE_FDDI = 15
  #MIB_IF_TYPE_PPP = 23
  #MIB_IF_TYPE_LOOPBACK = 24
  #MIB_IF_TYPE_SLIP = 28
  
  #MIB_IF_OPER_STATUS_NON_OPERATIONAL = 0
  #MIB_IF_OPER_STATUS_UNREACHABLE = 1
  #MIB_IF_OPER_STATUS_DISCONNECTED = 2
  #MIB_IF_OPER_STATUS_CONNECTING = 3
  #MIB_IF_OPER_STATUS_CONNECTED = 4
  #MIB_IF_OPER_STATUS_OPERATIONAL = 5
  
  #BROADCAST_NODETYPE = 1
  #PEER_TO_PEER_NODETYPE = 2
  #MIXED_NODETYPE = 4
  #HYBRID_NODETYPE = 8;}
                      ;{ Structures
  Structure IP_ADDR_STRING1
    NextAdapter.i
    IpAddress.a[16];IP_ADDRESS_STRING
    IpMask.a[16]   ;IP_ADDRESS_STRING
    Context.i
  EndStructure
  
  Structure FIXED_INFO1
    HostName.a[132]            ;MAX_HOSTNAME_LEN + 4
    DomainName.a[132]          ;MAX_DOMAIN_NAME_LEN + 4
    CurrentDnsServer.i
    DnsServerList.IP_ADDR_STRING1
    NodeType.l
    ScopeId.a[260]             ;MAX_SCOPE_ID_LEN + 4
    EnableRouting.l
    EnableProxy.l
    EnableDns.l
  EndStructure
  
  Structure IP_ADAPTER_INFO1
    NextAdapter.i
    ComboIndex.l
    AdapterName.a[260] ;MAX_ADAPTER_NAME_LENGTH + 4
    Description.a[132] ;MAX_ADAPTER_DESCRIPTION_LENGTH + 4
    AddressLength.l
    Address.a[8] ;MAX_ADAPTER_ADDRESS_LENGTH
    index.l
    Type.l
    DhcpEnabled.i
    CurrentIpAddress.i
    IpAddressList.IP_ADDR_STRING1
    GatewayList.IP_ADDR_STRING1
    DhcpServer.IP_ADDR_STRING1
    HaveWINS.i
    PrimaryWinsServer.IP_ADDR_STRING1
    SecondaryWinsServer.IP_ADDR_STRING1
    LeaseObtained.i
    LeaseExpires.i
  EndStructure
  
  Structure MIB_IFROW2
    StructureUnion
      Value.q
      Value2.q
    EndStructureUnion
    InterfaceIndex.l
    InterfaceGuid.a[16]
    Alias.w[257]
    Description.w[257]
    PhysicalAddressLength.l
    PhysicalAddress.a[32]
    PermanentPhysicalAddress.a[32]
    Mtu.l
    Type.l
    TunnelType.l;
    MediaType.l
    PhysicalMediumType.l
    AccessType.l
    DirectionType.l
    InterfaceAndOperStatusFlags.l
    OperStatus.l
    AdminStatus.l
    MediaConnectState.l
    NetworkGuid.a[16]
    ConnectionType.q
    TransmitLinkSpeed.q
    ReceiveLinkSpeed.q
    InOctets.q
    InUcastPkts.q
    InNUcastPkts.q
    InDiscards.q
    InErrors.q
    InUnknownProtos.q
    InUcastOctets.q
    InMulticastOctets.q
    InBroadcastOctets.q
    OutOctets.q
    OutUcastPkts.q
    OutNUcastPkts.q
    OutDiscards.q
    OutErrors.q
    OutUcastOctets.q
    OutMulticastOctets.q
    OutBroadcastOctets.q
    OutQLen.q
  EndStructure
  
  Structure MIB_IFROW
    wszName.a[512]
    dwIndex.l
    dwType.l
    dwMtu.l
    dwSpeed.l
    dwPhysAddrLen.l
    bPhysAddr.a[8]
    dwAdminStatus.l
    dwOperStatus.l
    dwLastChange.l
    dwInOctets.l
    dwInUcastPkts.l
    dwInNUcastPkts.l
    dwInDiscards.l
    dwInErrors.l
    dwInUnknownProtos.l
    dwOutOctets.l
    dwOutUcastPkts.l
    dwOutNUcastPkts.l
    dwOutDiscards.l
    dwOutErrors.l
    dwOutQLen.l
    dwDescrLen.l
    bDescr.a[256]
  EndStructure
  
  Structure MIB_IFTABLE1
    dwNumEntries.l
    table.MIB_IFROW[256]
  EndStructure
  
  Structure NetWorkInfo
    index.l
    HostName.s
    DomainName.s
    DNSIPAdd.s[11]
    nod.s
    ScopeID.s
    DNSE.s
    ProxyE.s
    RoutE.s
    Conx.s
    AdapterName.s[11]
    Type.s[11]
    Speed.s[11]
    sMTU.s[11]
    packsS.s[11]
    bytesS.s[11]
    packsR.s[11]
    bytesR.s[11]
    status.s[11]
    IPAddr.s[11]
    SubMask.s[11]
    Addr.s[11]
    Indx.s[11]
    DHCPE.s[11]
    DHCPIPAddr.s[11]
    DHCPIPMask.s[11]
    DHCPLObt.s[11]
    DHCPLExp.s[11]
    GateIPAddress.s[11]
    GateIPMask.s[11]
    HaveWINS.s[11]
    PWINSIPAddress.s[11]
    PWINSIPMask.s[11]
    SWINSIPAddress.s[11]
    SWINSIPMask.s[11]
    HWInterface.s[11]
    FilterInterface.s[11]
    HasConntectorPresent.s[11]
    PortAuthenticated.s[11]
    MediaConnected.s[11]
    Paused.s[11]
    LowPower.s[11]
    EndPoint.s[11]
  EndStructure;}
  
  Global MIB_IFTABLE.MIB_IFTABLE1
  Global GroupDemicals.s = ","
  ; Global GroupThousands.s = "."
  Global LANInfo.NetWorkInfo
  ; 
  Procedure.d IO_Get_uint32(lValue.l)
    Protected int32uint32.l
    If lValue < 0
      int32uint32 = lValue + $100000000
    Else
      int32uint32 = lValue
    EndIf
    ProcedureReturn int32uint32
  EndProcedure
  ; 
  Procedure.s c2str(num.d, demical.l=0)
    ProcedureReturn ReplaceString(StrD(num,demical), ".", GroupDemicals)
  EndProcedure
  ; 
  Procedure.s FormatByteSize(n.q)
    Protected s.s=Str(n)
    Protected len=Len(s)
    Protected ret.s
    Protected i
    
    For i=0 To len-1
      If i And Not i%3 : ret="." + ret : EndIf; "." is the greek symbol for separating thousands. Use your own.
      ret= Mid(s,len-i,1) +ret
    Next
    
    ProcedureReturn ret
  EndProcedure
  
  Procedure.s SpaceDivider(space.q)
    Protected tm.s
    Protected mt.d=space
    If mt>1000: mt / 1024:tm = " KB":EndIf
    If mt>1000: mt / 1024:tm = " MB":EndIf
    If mt>1000: mt / 1024:tm = " GB":EndIf
    If mt>1000: mt / 1024:tm = " TB":EndIf
    ProcedureReturn ReplaceString(StrD(mt,3), ".", GroupDemicals) + tm
  EndProcedure
  ; 
  Procedure.s GetRegString(hKey.l, strPath.s, strValue.s, RegType.l=2)
    Protected KeyHand.l
    Protected datatype.l
    Protected lResult.l
    Protected Dim strBuf.a(1)
    Protected lDataBufSize.l
    Protected intZeroPos.l
    Protected tempV.l
    Protected mm.l
    Protected lValueType.l
    
    RegOpenKeyEx_(hKey, strPath, 0, 1, @KeyHand)
    lResult = RegQueryValueEx_(KeyHand, strValue, 0, @lValueType, 0, @lDataBufSize)
    If lDataBufSize > 0
      Protected *Buffer = AllocateMemory(lDataBufSize)
    Else
      ProcedureReturn
    EndIf
    lResult = RegQueryValueEx_(KeyHand, @strValue, 0, @RegType, *Buffer, @lDataBufSize)
    If lResult = #ERROR_SUCCESS
      ProcedureReturn PeekS(*Buffer,-1,#PB_Unicode)
    EndIf
  EndProcedure
  ; 
  ; DisableExplicit
  ; Procedure myReleaseMutex( mMutex )
  ;     ProcedureReturn ReleaseMutex_(mMutex)
  ; EndProcedure
  ; 
  ; Procedure myLockMutex( mMutex, myWait = #INFINITE )
  ;     dwWaitResult = WaitForSingleObject_(mMutex, myWait)
  ;     Select dwWaitResult
  ;         Case #WAIT_OBJECT_0
  ;             retVal = 1
  ;         Case #WAIT_ABANDONED
  ;             retVal = 1
  ;         Case #WAIT_FAILED
  ;             retVal = 0
  ;         Case #WAIT_TIMEOUT
  ;             retVal = 0
  ;     EndSelect
  ;     ProcedureReturn retVal
  ; EndProcedure
  ; 
  ; Procedure.l myCreateMutex()
  ;     ProcedureReturn CreateMutex_(#Null, #False, #Null)
  ; EndProcedure
  ; 
  ;  - Begin code here
  Structure ether_header
    ether_dhost.a[6] ;[ETHER_ADDR_LEN];
    ether_shost.a[6] ;[ETHER_ADDR_LEN];
    ether_type.w     ;
  EndStructure
  ; 
  Structure ip
    ether_dhost.a[6];
    ether_shost.a[6];
    ether_type.w    ;
    ip_vhl.a        ;		/* header length, version */
    ip_tos.a        ;		/* type of service */
    ip_tle.w        ;		/* total length */
    ip_id.w         ;		/* identification */
    ip_off.w        ;		/* fragment offset field */
    ip_ttl.a        ;		/* time to live */
    ip_p.a          ;		  /* protocol */
    ip_sum.w        ;		/* checksum */
    ip_scr.a[4]     ;
    ip_dst.a[4]     ;
    udp_srcPort.w   ;
    udp_destPort.w  ;
    udp_length.w    ;
    udp_chksum.w    ;
  EndStructure
  ; 
  ; 
  ; Structure pcap_addr
  ;   *next.pcap_addr
  ;   *addr.SOCKADDR
  ;   *netmask.SOCKADDR
  ;   *broadaddr.SOCKADDR
  ;   *dstaddr.SOCKADDR
  ; EndStructure
  ; 
  Structure pcap_if_t
    *nextStruct
    *szDevName
    *szDescription
    *addressesptr
    flags.i
  EndStructure
  ; 
  Structure pcap_pkthdr
    ts.TIMEVAL
    caplen.i
    len.i
  EndStructure
  ; 
  ; Structure bpf_insn
  ;   code.w
  ;   jt.a
  ;   jf.a
  ;   k.i
  ; EndStructure
  ; 
  ; Structure bpf_program
  ;   bflen.i
  ;   *bf_insns.bpf_insn
  ; EndStructure
  ; 
  Structure myAdapters
    deviceName.s
    deviceDescription.s
    *addresses.pcap_addr
  EndStructure
  ; 
  Structure EasyIpHead
    IP_Sender.s
    IP_Receiver.s
    Ether_MAC_Sender.s
    Ether_MAC_Receiver.s
    IP_Protocol.i
    *DataBuffer
    DataBufferLength.i
  EndStructure
  ; 		
  ; ; _CDecl 
  ; ImportC "wpcap.lib"
  ;   pcap_findalldevs.i(*lpPcap_if_t, *szerrbuf)
  ;   pcap_open_live.l(*deviceName, snaplen.i, promisc.i, to_ms.i, *errorBuffer)
  ;   pcap_compile.i(*pcap_t, *fp.bpf_program, *str, optimize.i, netmask.i)
  ;   pcap_setfilter.i(*pcap_t, *fp.bpf_program)
  ;   pcap_freecode(*fp.bpf_program)
  ;   pcap_loop.i(*pcap_t, cnt.i, *lpFnCallBack, *lpUser)
  ;   pcap_breakloop(*fp.bpf_program)
  ;   pcap_close(*fp.bpf_program)
  ;   ;pcap_next.l(*pcap_t, *header.pcap_pkthdr)
  ;   ;got_packet(args.a,*header.pcap_pkthdr,packet.l);
  ; EndImport
  ; 
  ; Declare PacketIncomeCallback(Packet.i)
  ;}
  ; Procedure getAllAdapters( List adpt.myAdapters() )
  ;   errorBuffer.s = Space(256)
  ;   *pcap_if_t_ptr.pcap_if_t
  ;   If pcap_findalldevs(@*pcap_if_t_ptr, @errorBuffer) = -1
  ;     MessageBox_(0, errorBuffer, "Error finding adapters...", #MB_OK|#MB_ICONERROR)
  ;     ProcedureReturn 0
  ;   EndIf
  ;   ClearList(adpt())
  ;   ResetList(adpt())
  ;   
  ;   Repeat
  ;     AddElement(adpt())
  ;     l = MemoryStringLength(*pcap_if_t_ptr\szDevName,#PB_UTF8| #PB_ByteLength)
  ;     adpt()\deviceName = PeekS(*pcap_if_t_ptr\szDevName,l,#PB_UTF8)
  ;     l = MemoryStringLength(*pcap_if_t_ptr\szDescription,#PB_UTF8| #PB_ByteLength)
  ;     adpt()\deviceDescription = PeekS(*pcap_if_t_ptr\szDescription,l,#PB_UTF8)
  ;     If *pcap_if_t_ptr\addressesptr > 0
  ;       adpt()\addresses = PeekL(*pcap_if_t_ptr\addressesptr)
  ;     EndIf
  ;     *pcap_if_t_ptr.pcap_if_t = *pcap_if_t_ptr\nextStruct
  ;   Until *pcap_if_t_ptr = 0
  ;   
  ;   ProcedureReturn ListSize(adpt())
  ; EndProcedure
  
  Procedure PacketIncomeCallback(*Packet.EasyIpHead)
    PrintN("----------------")
    PrintN("Protocol: "+IO_Get_EthernetServiceIDtoName(*Packet\IP_Protocol))
    Select *Packet\IP_Protocol
      Case 1 :
        intresting = ReadICMPPaket(*Packet\DataBuffer,*Packet\DataBufferLength) ; ICMP
      Case 6                                                                    ;TCP
      Case 17                                                                   ; UDP
    EndSelect
    If intresting
      ConsoleColor(10,0)
      PrintN("Source IP: " + ipFrom)
      PrintN("Destination IP: " + ipTo)
      PrintN("IPv" + Str(ipVersion))
    Else
      ConsoleColor(7,0)
    EndIf
    
    PrintN("----------------------------------------------")
    For x = 0 To *Packet\DataBufferLength-1
      hex$ = RSet(Hex(PeekA(*Packet\DataBuffer+x)),2,"0") +" "
      Print(hex$)
      If x> 1 And (x+1)%16 = 0
        PrintN("")
      EndIf
    Next
    PrintN("")
    ConsoleColor(7,0)
  EndProcedure
  
  ; _CDecl
  ProcedureC pktProcessProc( *useless, *pkthdr.pcap_pkthdr, *pktData )
    myTime = *pkthdr\ts\tv_sec
    *ipInfo.ip = *pktData
    totalLength = ntohs_(*ipInfo\ip_tle)
    ipVersion = (*ipInfo\ip_vhl >> 4)
    PaketLength = PeekL(*pkthdr+8)
    
    ipFrom.s = StrU(*ipInfo\ip_dst[0],#PB_Ascii) + "."
    ipFrom.s + StrU(*ipInfo\ip_dst[1],#PB_Ascii) + "."
    ipFrom.s + StrU(*ipInfo\ip_dst[2],#PB_Ascii) + "."
    ipFrom.s + StrU(*ipInfo\ip_dst[3],#PB_Ascii)
    
    ipTo.s = StrU(*ipInfo\ip_scr[0],#PB_Ascii) + "."
    ipTo.s + StrU(*ipInfo\ip_scr[1],#PB_Ascii) + "."
    ipTo.s + StrU(*ipInfo\ip_scr[2],#PB_Ascii) + "."
    ipTo.s + StrU(*ipInfo\ip_scr[3],#PB_Ascii)
    
    ;   MacFrom.s = RSet(Hex(PeekA(*ipInfo\ether_dhost[0])),2,"0")+":"
    ;   MacFrom.s + RSet(Hex(PeekA(*ipInfo\ether_dhost[1])),2,"1")+":"
    ;   MacFrom.s + RSet(Hex(PeekA(*ipInfo\ether_dhost[2])),2,"2")+":"
    ;   MacFrom.s + RSet(Hex(PeekA(*ipInfo\ether_dhost[3])),2,"3")+":"
    ;   MacFrom.s + RSet(Hex(PeekA(*ipInfo\ether_dhost[4])),2,"4")+":"
    ;   MacFrom.s + RSet(Hex(PeekA(*ipInfo\ether_dhost[5])),2,"5")
    
    ;   MacTo.s = RSet(Hex(PeekA(*ipInfo\ether_shost[0])),2,"0")+":"
    ;   MacTo.s + RSet(Hex(PeekA(*ipInfo\ether_shost[1])),2,"1")+":"
    ;   MacTo.s + RSet(Hex(PeekA(*ipInfo\ether_shost[2])),2,"2")+":"
    ;   MacTo.s + RSet(Hex(PeekA(*ipInfo\ether_shost[3])),2,"3")+":"
    ;   MacTo.s + RSet(Hex(PeekA(*ipInfo\ether_shost[4])),2,"4")+":"
    ;   MacTo.s + RSet(Hex(PeekA(*ipInfo\ether_shost[5])),2,"5")
    ;   
    *peekAddr = *pktData + SizeOf(ether_header)
    If totalLength > 1
      PaketDaten.EasyIpHead\DataBuffer = AllocateMemory(totalLength)
      CopyMemory(*pktData,PaketDaten\DataBuffer,totalLength)
      PaketDaten\IP_Protocol = *ipInfo\ip_p
      PaketDaten\DataBufferLength = PaketLength
      PaketDaten\IP_Receiver = ipTo
      PaketDaten\IP_Sender = ipFrom
      ;     PaketDaten\Ether_MAC_Sender = MacFrom
      ;     PaketDaten\Ether_MAC_Receiver = MacTo
      
      PacketIncomeCallback(PaketDaten)
    EndIf
  EndProcedure
  
  Structure startMonitorStructure
    adName.s
    stopMonSemaphore.l
    mainIpAddress.s
    *fp
  EndStructure
  
  
  
  ; Procedure monitorNetwork(*sms.startMonitorStructure )
  ;  adapterName.s = *sms\adName
  ;  myMonSemaphore = *sms\stopMonSemaphore
  ;  mainIPAddress.s = *sms\mainIpAddress
  ;  *fp = pcap_open_live(@adapterName, 65536, 1, 1000, @pcapOpenErrorBuffer.s)
  ;  *sms\fp = *fp
  ;  If (*fp)
  ;   If Trim(mainIPAddress) <> ""
  ;     myFilter.s = "ip host " + mainIPAddress
  ;     filterProgram.bpf_program
  ;     If pcap_compile(*fp, @filterProgram, @myFilter, 0, 0) <> -1
  ;       If pcap_setfilter(*fp, @filterProgram) <> -1
  ;         pcap_freecode(@filterProgram)
  ;       Else
  ;         MessageBox_(0, "pcap_setfilter() Failed.", "Error!", #MB_ICONERROR|#MB_OK)
  ;       EndIf
  ;     Else
  ;       MessageBox_(0, "pcap_complie() Failed.", "Error!", #MB_ICONERROR|#MB_OK)
  ;     EndIf
  ;   EndIf
  ;   
  ;   iCode = pcap_loop(*fp, -1, @pktProcessProc(), #Null)
  ;   Select iCode
  ;     Case 0
  ;       Debug "Successfully quit pcap_loop!"
  ;     Case -1
  ;       Debug "Error: " + pcapOpenErrorBuffer
  ;     Case -2
  ;       Debug "pcap_breakloop() called!"
  ;     Default
  ;       Debug "Not quite sure why we exited with a code of: " + Str(iCode)
  ;   EndSelect
  ;   
  ;    SignalSemaphore(myMonSemaphore)
  ;    pcap_close(*fp)
  ;  Else
  ;   SignalSemaphore(myMonSemaphore)
  ;   MessageBox_(WindowID(myWindow), "AdapterName: " + adapterName.s, "pcap_open_live() Failed", #MB_ICONERROR|#MB_OK)
  ;  EndIf
  ; EndProcedure
  
  Procedure IO_Set_ActivateEthernetModule()
    Protected lBufferLength
    Protected hMod.i = LoadLibrary_("iphlpapi.dll")
    Protected lErrors = GetAdaptersInfo_(0, @lBufferLength)
    Protected i,ii
    Protected aaa.s
    Protected CardsFound.i = lBufferLength/SizeOf(IP_ADAPTER_INFO1)
    Dim IP_ADAPTER_INFO.IP_ADAPTER_INFO1(CardsFound)
    lErrors = GetAdaptersInfo_(@IP_ADAPTER_INFO(0), @lBufferLength)
    If lErrors <> #ERROR_SUCCESS: MessageRequester("Error","GetAdaptersInfo_() error."): ProcedureReturn: EndIf
    Protected lBufferPos.l
    For i=0 To CardsFound-1
      LANInfo\AdapterName[i] = PeekS(@IP_ADAPTER_INFO(i)\Description,-1,#PB_Ascii)
      If LANInfo\AdapterName[i] = ""
        aaa.s = PeekS(@IP_ADAPTER_INFO(i)\AdapterName,-1,#PB_Ascii)
        For ii=0 To 100
          If GetRegString(#HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVErsion\NetworkCards\" + Str(ii), "ServiceName") = aaa
            LANInfo\AdapterName[i] = GetRegString(#HKEY_LOCAL_MACHINE, "SOFTWARE\Microsoft\Windows NT\CurrentVErsion\NetworkCards\" + Str(ii), "Description")
          EndIf
        Next
      EndIf
    Next
    Protected tmp.s
    Protected tmp2.d
    Protected lSize.l
    lErrors = GetIfTable_(@MIB_IFTABLE, @lSize, 0)
    lSize = SizeOf(MIB_IFTABLE1)
    lErrors = GetIfTable_(@MIB_IFTABLE, @lSize, 0)
    If MIB_IFTABLE\dwNumEntries <> 0
      Protected GetIfTables.i = MIB_IFTABLE\dwNumEntries; we need to know how many are the tables to retrieve them.
    EndIf
    
    Dim If_entry.MIB_IFROW2(GetIfTables - 1)
    
    If OSVersion() >= #PB_OS_Windows_Vista
      Protected If_entry2.MIB_IFROW2
      Protected Lib_iphlpapi = OpenLibrary(#PB_Any,"iphlpapi.dll")
      If Lib_iphlpapi<> 0
        Protected GetIfEntry=GetFunction(Lib_iphlpapi,"GetIfEntry2")
      EndIf
      CloseLibrary(Lib_iphlpapi)
      For ii=1 To GetIfTables
        If_entry2\InterfaceIndex = ii
        CallFunctionFast(GetIfEntry, @If_entry2)
        CopyMemory(@If_entry2, @If_entry(ii-1),SizeOf(MIB_IFROW2))
        ClearStructure(@If_entry2, MIB_IFROW2)
      Next
    Else
      Protected If_entry1.MIB_IFROW
      For ii=1 To GetIfTables
        IF_entry1\dwIndex = ii
        GetIfEntry_(@If_entry1)
        CopyMemory(@If_entry1\bDescr, @If_entry(ii-1)\Description, 256)
        CopyMemory(@If_entry1\bPhysAddr, @If_entry(ii-1)\PhysicalAddress, 8)
        If_entry(ii-1)\AdminStatus = If_entry1\dwAdminStatus
        If_entry(ii-1)\InterfaceIndex = If_entry1\dwIndex
        If_entry(ii-1)\InDiscards = If_entry1\dwInDiscards
        If_entry(ii-1)\InNUcastPkts = If_entry1\dwInNUcastPkts
        If_entry(ii-1)\InOctets = If_entry1\dwInOctets
        If_entry(ii-1)\InUcastPkts = If_entry1\dwInUcastPkts
        If_entry(ii-1)\Mtu = If_entry1\dwMtu
        If_entry(ii-1)\OperStatus = If_entry1\dwOperStatus
        If_entry(ii-1)\OutNUcastPkts = If_entry1\dwOutNUcastPkts
        If_entry(ii-1)\OutOctets = If_entry1\dwOutOctets
        If_entry(ii-1)\OutUcastPkts = If_entry1\dwOutUcastPkts
        If_entry(ii-1)\TransmitLinkSpeed = If_entry1\dwSpeed
      Next
    EndIf
    
    Protected xx = 0
    Dim FIXED_INFO.FIXED_INFO1(9)
    lBufferLength = SizeOf(FIXED_INFO1)*9
    lErrors = GetNetworkParams_(@FIXED_INFO(), @lBufferLength)
    For i=0 To 9
      With FIXED_INFO(i)
        If \HostName = 0:Break:EndIf
        Protected IP_ADDR_STRING.IP_ADDR_STRING1
        LANInfo\HostName = PeekS(@\Hostname,-1,#PB_Ascii)
        LANInfo\DomainName = PeekS(@\DomainName,-1,#PB_Ascii)
        If \EnableDns = 1:  LANInfo\DNSE = "Yes": Else: LANInfo\DNSE = "No": EndIf
        LANInfo\DNSIPAdd[xx] = PeekS(@\DnsServerList\IpAddress,-1,#PB_Ascii)
        Protected lNext.l = \DnsServerList\NextAdapter
        Protected aa.l
        While aa.l=0
          If lNext <> 0
            If IsBadReadPtr_(lNext, SizeOf(IP_ADDR_STRING1)) = #False
              MoveMemory(@lNext, @IP_ADDR_STRING, SizeOf(IP_ADDR_STRING1))
            EndIf
            If lNext <> IP_ADDR_STRING\NextAdapter
              lNext = IP_ADDR_STRING\NextAdapter
              xx = xx + 1
              ;PURIFIER BUG?
              LANInfo\DNSIPAdd[xx] = PeekS(@IP_ADDR_STRING\IpAddress[0],-1,#PB_Ascii)
              Debug LANInfo\DNSIPAdd[xx]
            Else
              aa=1
            EndIf
          Else
            aa=1
          EndIf
        Wend
        Select \NodeType
          Case #BROADCAST_NODETYPE: LANInfo\nod = "Broadcast"
          Case #PEER_TO_PEER_NODETYPE: LANInfo\nod = "Peer To Peer"
          Case #MIXED_NODETYPE: LANInfo\nod = "Mixed"
          Case #HYBRID_NODETYPE: LANInfo\nod = "Hybrid"
          Default: LANInfo\nod = "Unknown " + Str(\NodeType)
        EndSelect
        LANInfo\ScopeID = ReplaceString(PeekS(@\ScopeId[0],-1,#PB_Ascii), Chr(0), "")
        If \EnableProxy = 1: LANInfo\ProxyE = "Yes": Else: LANInfo\ProxyE = "No": EndIf
        If \EnableRouting = 1:  LANInfo\RoutE = "Yes": Else: LANInfo\RoutE = "No": EndIf
      EndWith
    Next
    
    For i = 0 To CardsFound-1
      With IP_ADAPTER_INFO(i)
        Select \Type
          Case #MIB_IF_TYPE_OTHER: LANInfo\Type[i] = "Other"
          Case #MIB_IF_TYPE_ETHERNET: LANInfo\Type[i] = "Ethernet"
          Case #MIB_IF_TYPE_TOKENRING: LANInfo\Type[i] = "Tokenring"
          Case #MIB_IF_TYPE_FDDI: LANInfo\Type[i] = "FDDI"
          Case #MIB_IF_TYPE_PPP: LANInfo\Type[i] = "PPP"
          Case #MIB_IF_TYPE_LOOPBACK: LANInfo\Type[i] = "Loopback"
          Case #MIB_IF_TYPE_SLIP: LANInfo\Type[i] = "Slip"
          Default: LANInfo\Type[i] = "Unknown " + Str(\Type)
        EndSelect
        For ii = 0 To GetIfTables-1
          If PeekS(@If_entry(ii)\Description,-1,#PB_Unicode) = LANInfo\AdapterName[i]
            tmp2 = IO_Get_uint32(If_entry(ii)\TransmitLinkSpeed): tmp = " bit"
            If tmp2 >= 1000:  tmp2 = tmp2 / 1000: tmp = " Kbit": EndIf
            If tmp2 >= 1000:  tmp2 = tmp2 / 1000: tmp = " Mbit": EndIf
            If tmp2 >= 1000:  tmp2 = tmp2 / 1000: tmp = " Gbit": EndIf
            LANInfo\Speed[i] = c2str(tmp2,2) + tmp
            LANInfo\sMTU[i] = Str(If_entry(ii)\Mtu) + " bytes"
            LANInfo\packsS[i] = FormatByteSize(If_entry(ii)\OutNUcastPkts + If_entry(ii)\OutUcastPkts)
            
            tmp = FormatByteSize(If_entry(ii)\OutOctets)
            If tmp = "":  tmp = "0": EndIf
            If If_entry(ii)\OutOctets > 1024
              tmp + "  ( " + SpaceDivider(If_entry(ii)\OutOctets) + " )"
              If Right(tmp,6) = GroupDemicals + "000 )":tmp=Left(tmp,Len(tmp)-6) + " )": EndIf
            EndIf
            LANInfo\bytesS[i] = tmp
            LANInfo\packsR[i] = FormatByteSize(If_entry(ii)\InNUcastPkts + If_entry(ii)\InUcastPkts)
            
            tmp = FormatByteSize(If_entry(ii)\InOctets)
            If tmp = "":  tmp = "0": EndIf
            If (If_entry(ii)\InOctets) > 1024
              tmp + "  ( " + SpaceDivider(If_entry(ii)\InOctets) + " )"
              If Right(tmp,6) = GroupDemicals + "000 )":tmp=Left(tmp,Len(tmp)-6) + " )": EndIf
            EndIf
            LANInfo\bytesR[i] = tmp
            
            If OSVersion() >= #PB_OS_Windows_Vista; data came from GetIfTable2_()
              Select If_entry(ii)\OperStatus
                Case 1: LANInfo\status[i] = "Operational"
                Case 2: LANInfo\status[i] = "Disconnected"
                Case 3: LANInfo\status[i] = "Testing"
                Case 4: LANInfo\status[i] = "Unknown"
                Case 5: LANInfo\status[i] = "Waiting to become operational"
                Case 6: LANInfo\status[i] = "Disconnected - Some component is not present"
                Case 7: LANInfo\status[i] = "Disconnected - one or more of lower-layer interfaces are down"
                Default: LANInfo\status[i] = "Unknown " + c2str(IO_Get_uint32(If_entry(ii)\OperStatus),0)
              EndSelect
            Else; data came from GetIfTable_()
              Select If_entry(ii)\OperStatus
                Case #MIB_IF_OPER_STATUS_NON_OPERATIONAL: LANInfo\status[i] = "Non operational"
                Case #MIB_IF_OPER_STATUS_UNREACHABLE: LANInfo\status[i] = "Unreachable"
                Case #MIB_IF_OPER_STATUS_DISCONNECTED: LANInfo\status[i] = "Disconnected"
                Case #MIB_IF_OPER_STATUS_CONNECTING: LANInfo\status[i] = "Connecting"
                Case #MIB_IF_OPER_STATUS_CONNECTED: LANInfo\status[i] = "Connected"
                Case #MIB_IF_OPER_STATUS_OPERATIONAL: LANInfo\status[i] = "Operational"
                Default: LANInfo\status[i] = "Unknown " + c2str(IO_Get_uint32(If_entry(ii)\OperStatus),0)
              EndSelect    
            EndIf
            If OSVersion() >= #PB_OS_Windows_Vista; data came from GetIfTable2_()
              If If_entry(ii)\InterfaceAndOperStatusFlags & 1 = 1
                LANInfo\HWInterface[i] = "Yes"
              Else
                LANInfo\HWInterface[i] = "No"
              EndIf
              
              If (If_entry(ii)\InterfaceAndOperStatusFlags >> 1) & 1 = 1
                LANInfo\FilterInterface[i] = "Yes"
              Else
                LANInfo\FilterInterface[i] = "No"
              EndIf
              ;Debug (If_entry(ii)\InterfaceAndOperStatusFlags >> 2) & 1
              If (If_entry(ii)\InterfaceAndOperStatusFlags >> 2) & 1 = 1
                LANInfo\HasConntectorPresent[i] = "Yes"
              Else
                LANInfo\HasConntectorPresent[i] = "No"
              EndIf
              
              If (If_entry(ii)\InterfaceAndOperStatusFlags >> 3) & 1 = 1
                LANInfo\PortAuthenticated[i] = "No"
              Else
                LANInfo\PortAuthenticated[i] = "Yes"
              EndIf
              
              If (If_entry(ii)\InterfaceAndOperStatusFlags >> 4) & 1 = 1
                LANInfo\MediaConnected[i] = "No"
              Else
                LANInfo\MediaConnected[i] = "Yes"
                If If_entry(ii)\MediaConnectState = 1
                  LANInfo\MediaConnected[i] + " (connector is plugged in)"
                ElseIf If_entry(ii)\MediaConnectState = 2
                  LANInfo\MediaConnected[i] + " (connector is not plugged in)"
                EndIf
              EndIf
              
              If (If_entry(ii)\InterfaceAndOperStatusFlags >> 5) & 1 = 1
                LANInfo\Paused[i] = "Yes"
              Else
                LANInfo\Paused[i] = "No"
              EndIf
              
              If (If_entry(ii)\InterfaceAndOperStatusFlags >> 6) & 1 = 1
                LANInfo\LowPower[i] = "Yes"
              Else
                LANInfo\LowPower[i] = "No"
              EndIf
              
              If (If_entry(ii)\InterfaceAndOperStatusFlags >> 7) & 1 = 1
                LANInfo\EndPoint[i] = "Yes"
              Else
                LANInfo\EndPoint[i] = "No"
              EndIf
            EndIf
            Break
          EndIf
        Next   
        LANInfo\IPAddr[i] = PeekS(@\IpAddressList\IpAddress,-1,#PB_Ascii)
        LANInfo\SubMask[i] = PeekS(@\IpAddressList\IpMask,-1,#PB_Ascii)
        tmp = ""
        Protected lIncrement.l
        If Len(PeekS(@\AdapterName,-1,#PB_Ascii)) >= \AddressLength
          For lIncrement = 0 To \AddressLength-1
            tmp = tmp + RSet(Hex(\Address[lIncrement] & $FF),2,"0")
          Next lIncrement
          tmp = RSet(tmp,12,"0")
          tmp = Left(tmp, 2) + ":" + Mid(tmp, 3, 2) + ":" + Mid(tmp, 5, 2) + ":" + Mid(tmp, 7, 2) + ":" + Mid(tmp, 9, 2) + ":" + Mid(tmp, 11, 2)
          LANInfo\Addr[i] = tmp
        EndIf
        LANInfo\Indx[i] = (c2str(IO_Get_uint32(\Index),0))
        Protected TZResult
        If \DhcpEnabled = 1:  LANInfo\DHCPE[i] = "Yes": Else: LANInfo\DHCPE[i] = "No": EndIf
        LANInfo\DHCPIPAddr[i] = PeekS(@\DhcpServer\IpAddress,-1,#PB_Ascii)
        LANInfo\DHCPIPMask[i] = PeekS(@\DhcpServer\IpMask,-1,#PB_Ascii)
        If \LeaseObtained > 10000
          tmp = FormatDate("%dd/%mm/%yyyy , %hh:%ii:%ss",AddDate( 1/1/1970,#PB_Date_Second, \LeaseObtained))
          LANInfo\DHCPLObt[i] = FormatDate("%dd/%mm/%yyyy , %hh:%ii:%ss",AddDate( ParseDate("%dd/%mm/%yyyy , %hh:%ii:%ss",tmp),#PB_Date_Minute,-TZResult ))
        Else
          LANInfo\DHCPLObt[i] = "NotAvailable"
        EndIf
        If \LeaseExpires > 10000
          tmp = FormatDate("%dd/%mm/%yyyy , %hh:%ii:%ss",AddDate( 1/1/1970,#PB_Date_Second, \LeaseExpires))
          LANInfo\DHCPLExp[i] = FormatDate("%dd/%mm/%yyyy , %hh:%ii:%ss",AddDate( ParseDate("%dd/%mm/%yyyy , %hh:%ii:%ss",tmp),#PB_Date_Minute,-TZResult))
        Else
          LANInfo\DHCPLExp[i] = "NotAvailable"
        EndIf
        
        CopyMemory(@\IpAddressList,@IP_ADDR_STRING,SizeOf(IP_ADDR_STRING1))
        For ii=0 To 100
          If IP_ADDR_STRING\NextAdapter <> 0
            If IsBadReadPtr_(@IP_ADDR_STRING\NextAdapter, SizeOf(IP_ADDR_STRING1)) = #False
              MoveMemory(@IP_ADDR_STRING\NextAdapter, @IP_ADDR_STRING, SizeOf(IP_ADDR_STRING1))
            EndIf
          Else
            Break
          EndIf
        Next
        LANInfo\GateIPAddress[i] = PeekS(@\GatewayList\IpAddress,-1,#PB_Ascii)
        LANInfo\GateIPMask[i] = PeekS(@\GatewayList\IpMask,-1,#PB_Ascii)
        If \HaveWINS = 1:  LANInfo\HaveWINS[i] = "Yes": Else: LANInfo\HaveWINS[i] = "No": EndIf
        LANInfo\PWINSIPAddress[i] = PeekS(@\PrimaryWinsServer\IpAddress,-1,#PB_Ascii)
        LANInfo\PWINSIPMask[i] = PeekS(@\PrimaryWinsServer\IpMask,-1,#PB_Ascii)
        LANInfo\SWINSIPAddress[i] = PeekS(@\SecondaryWinsServer\IpAddress,-1,#PB_Ascii)
        LANInfo\SWINSIPMask[i] = PeekS(@\SecondaryWinsServer\IpMask,-1,#PB_Ascii)
      EndWith
    Next
  EndProcedure
  
  Procedure.s IO_Get_GatewayNIC()
    Protected i
    IO_Set_ActivateEthernetModule()
    For i=0 To 10
      If LANInfo\AdapterName[i] <> "" And  LANInfo\status[i] = "Operational"
        If LANInfo\GateIPAddress[i] <> "0.0.0.0"
          ProcedureReturn LANInfo\AdapterName[i]
        EndIf
      EndIf
    Next
  EndProcedure
  
  
  
  
  ; Procedure StartSniff()
  ;   sms.startMonitorStructure
  ;   
  ;   OpenConsole()
  ;   EnableGraphicalConsole(1)
  ;   sms\adName = IO_Get_GatewayNIC()
  ;   sms\stopMonSemaphore = CreateSemaphore()
  ;   sms\mainIpAddress = "127.0.0.1"
  ;   monitoringActive = CreateThread(@monitorNetwork(), @sms)
  ;   ProcedureReturn sms
  ; EndProcedure
  
  ; Procedure EndSniff(*sms.startMonitorStructure)
  ;   pcap_breakloop(*sms\fp)
  ; EndProcedure
  
  ;}
  
  ;{ Chrome Automation
  ;NOTE: Start Chrome with debug mode on to use these functions:
  ;chrome.exe --remote-debugging-port=9222
  
  
  ;{ Structures
  Structure WebSocket
    Frametyp.i
    FrameMemory.i
  EndStructure
  
  Structure co
    description.s
    devtoolsFrontendUrl.s
    title.s
    type.s
    url.s
    webSocketDebuggerUrl.s
    WsConnection.i
  EndStructure
  Structure vs
    Browser.s
    ProtocolVersion.s
    UserAgent.s
    V8Version.s
    WebKitVersion.s
    webSocketDebuggerUrl.s
  EndStructure
  
  Structure All
    Map Objects.co()
    Version.vs
    RequestId.i
  EndStructure;}
  
  
  Global IO_Get_Chrome_DebugPort = 9222
  Global Chrome.All
  
  ;{ Internal Functions
  Procedure   ChromeDefaultObjectAdd(JsonObject)
    If JSONType(JsonObject) = #PB_JSON_Object 
      id.s = GetJSONString(GetJSONMember(JsonObject,"id"))
      Chrome\Objects(id)\description =  GetJSONString(GetJSONMember(JsonObject,"description"))
      Chrome\Objects(id)\devtoolsFrontendUrl =  GetJSONString(GetJSONMember(JsonObject,"devtoolsFrontendUrl"))
      Chrome\Objects(id)\title =  GetJSONString(GetJSONMember(JsonObject,"title"))
      Chrome\Objects(id)\type =  GetJSONString(GetJSONMember(JsonObject,"type"))
      Chrome\Objects(id)\url =  GetJSONString(GetJSONMember(JsonObject,"url"))
      Chrome\Objects(id)\webSocketDebuggerUrl =  GetJSONString(GetJSONMember(JsonObject,"webSocketDebuggerUrl"))
    EndIf
  EndProcedure
  Procedure   ChromeDefaultJson(json.i,Method.s)
    mainobj = SetJSONObject(JSONValue(json))
    SetJSONInteger(AddJSONMember(mainobj, "id"), Chrome\RequestId) : Chrome\RequestId = Chrome\RequestId+1
    SetJSONString(AddJSONMember(mainobj, "method"), Method)
    params = AddJSONMember(mainobj,"params")
    SetJSONObject(params)
    ProcedureReturn params
  EndProcedure
  Procedure   IO_Get_Chrome_OpenWebSocket(TabID.s)
    Chrome\Objects(TabID)\WsConnection = WebsocketClient::OpenWebsocketConnection(Chrome\Objects(TabID)\webSocketDebuggerUrl)
    ProcedureReturn #True
  EndProcedure
  ;}
  Procedure.s IO_Get_Chrome_Response(connection,timeout = 0)
    p = ElapsedMilliseconds()
    Packet$ = ""
    Repeat
      Delay(1)
      If connection
        NetworkEvent = NetworkClientEvent(connection)
        Select NetworkEvent
          Case #PB_NetworkEvent_Data
            Frametyp.Websocket\FrameMemory = AllocateMemory(1)
            Frametyp\Frametyp = WebsocketClient::ReceiveFrame(connection,@Frametyp)
            If Frametyp\Frametyp = WebsocketClient::#frame_text
              Packet$ + PeekS(Frametyp\FrameMemory,MemoryStringLength(Frametyp\FrameMemory,#PB_UTF8)-1,#PB_UTF8)
            ElseIf Frametyp\Frametyp = WebsocketClient::#frame_binary
              Debug "Received Binaryframe"
            EndIf
            FreeMemory(Frametyp\FrameMemory)
            p = ElapsedMilliseconds()
          Case #PB_NetworkEvent_Disconnect
            ProcedureReturn ""
          Case #PB_NetworkEvent_None
            If Len(Packet$) > 0
              If Not timeout
                ProcedureReturn Packet$
              EndIf
            EndIf
        EndSelect
      Else
        Debug "Connection lost?"
        Break
      EndIf
    Until ElapsedMilliseconds() - p > timeout And timeout > 0
    ProcedureReturn Packet$
  EndProcedure
  
  ;HTTP-Endpoints
  Procedure   IO_Get_Chrome_List()
    HttpRequest = HTTPRequestMemory(#PB_HTTP_Get, "localhost:"+Str(IO_Get_Chrome_DebugPort)+"/json/list")
    If HttpRequest
      Response$ = HTTPInfo(HTTPRequest, #PB_HTTP_Response)
      FinishHTTP(HTTPRequest)
    Else
      ProcedureReturn -1
    EndIf
    json = ParseJSON(#PB_Any,Response$)
    If json
      If JSONType(JSONValue(json)) = #PB_JSON_Array
        For i = 0 To JSONArraySize(JSONValue(json)) - 1
          Element = GetJSONElement(JSONValue(json), i)
          ChromeDefaultObjectAdd(Element)
        Next
      EndIf
      FreeJSON(json)
    EndIf
  EndProcedure
  Procedure   IO_Get_Chrome_Version()
    HttpRequest = HTTPRequestMemory(#PB_HTTP_Get, "localhost:"+Str(IO_Get_Chrome_DebugPort)+"/json/version")
    If HttpRequest
      Response$ = HTTPInfo(HTTPRequest, #PB_HTTP_Response)
      FinishHTTP(HTTPRequest)
    Else
      ProcedureReturn -1
    EndIf
    
    json = ParseJSON(#PB_Any,Response$)
    If json
      value = JSONValue(json)
      If JSONType(value) = #PB_JSON_Object
        Chrome\Version\Browser=  GetJSONString(GetJSONMember(value,"Browser"))
        Chrome\Version\ProtocolVersion=  GetJSONString(GetJSONMember(value,"Protocol-Version"))
        Chrome\Version\UserAgent=  GetJSONString(GetJSONMember(value,"User-Agent"))
        Chrome\Version\V8Version=  GetJSONString(GetJSONMember(value,"V8-Version"))
        Chrome\Version\WebKitVersion=  GetJSONString(GetJSONMember(value,"WebKit-Version"))
        Chrome\Version\webSocketDebuggerUrl=  GetJSONString(GetJSONMember(value,"webSocketDebuggerUrl"))
      EndIf
    EndIf
    FreeJSON(json)
  EndProcedure
  Procedure.s IO_Set_Chrome_NewTab();Returns ID
    HttpRequest = HTTPRequestMemory(#PB_HTTP_Get, "localhost:"+Str(IO_Get_Chrome_DebugPort)+"/json/new")
    If HttpRequest
      Response$ = HTTPInfo(HTTPRequest, #PB_HTTP_Response)
      FinishHTTP(HTTPRequest)
    Else
      ProcedureReturn ""
    EndIf
    json = ParseJSON(#PB_Any,Response$)
    If json
      ChromeDefaultObjectAdd(JSONValue(json))
      FreeJSON(json)
    EndIf
    ProcedureReturn MapKey(Chrome\Objects())
  EndProcedure
  Procedure   IO_Set_Chrome_ActivateTab(TabID.s)
    HttpRequest = HTTPRequestMemory(#PB_HTTP_Get, "localhost:"+Str(IO_Get_Chrome_DebugPort)+"/json/activate/"+TabID)
    If HttpRequest
      Response$ = HTTPInfo(HTTPRequest, #PB_HTTP_Response)
      FinishHTTP(HTTPRequest)
    Else
      ProcedureReturn -1
    EndIf
    If Response$ = "Target activated"
      ProcedureReturn 1
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  Procedure   IO_Set_Chrome_CloseTab(TabID.s)
    HttpRequest = HTTPRequestMemory(#PB_HTTP_Get, "localhost:"+Str(IO_Get_Chrome_DebugPort)+"/json/close/"+TabID)
    If HttpRequest
      Response$ = HTTPInfo(HTTPRequest, #PB_HTTP_Response)
      FinishHTTP(HTTPRequest)
    Else
      ProcedureReturn -1
    EndIf
    If Response$ = "Target is closing"
      ProcedureReturn 1
    Else
      ProcedureReturn 0
    EndIf
  EndProcedure
  
  ;Chrome Debug API
  Procedure.i IO_Set_Chrome_PageNavigate(TabID.s,*Returnvalue.PageNavigateReturn,url.s,referrer.s="",transitionType.i=-1,frameId.i=-1,referrerPolicy.i=-1)
    json = CreateJSON(#PB_Any) 
    params = ChromeDefaultJson(json,"Page.navigate");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
    
    ;Page.navigate Parameters
    SetJSONString(AddJSONMember(params, "url"), url)
    If Len(referrer ) > 0  : SetJSONString(AddJSONMember(params, "referrer"), referrer) :EndIf
    If transitionType > 0  : SetJSONInteger(AddJSONMember(params, "transitionType"), transitionType) :EndIf
    If frameId > 0  : SetJSONInteger(AddJSONMember(params, "frameId"), frameId) :EndIf
    If referrerPolicy > 0  : SetJSONInteger(AddJSONMember(params, "referrerPolicy"), referrerPolicy) :EndIf
    request$ = ComposeJSON(json):FreeJSON(json)
    ;Hau raus die Scheisse
    WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
    IO_Get_Chrome_Response(Chrome\Objects(TabID)\WsConnection)
    
  EndProcedure
  Procedure.s IO_Set_Chrome_DOMenable(TabID.s,enable)
    json = CreateJSON(#PB_Any) 
    
    If enable
      params = ChromeDefaultJson(json,"DOM.enable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
    Else
      params = ChromeDefaultJson(json,"DOM.disable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
    EndIf
    
    request$ = ComposeJSON(json):FreeJSON(json)
    WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
  EndProcedure
  Procedure   IO_Get_Chrome_DOMgetDocument(TabID.s,depth.i=-1,pierce.b=0) ;NOT WORKING
    json = CreateJSON(#PB_Any) 
    
    params = ChromeDefaultJson(json,"DOM.getDocument");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
    SetJSONInteger(AddJSONMember(params, "depth"), depth)
    ;   SetJSONInteger(AddJSONMember(params, "pierce"), pierce)
    
    Debug IO_Get_Chrome_Response(Chrome\Objects(TabID)\WsConnection,200)
    request$ = ComposeJSON(json):FreeJSON(json)
    WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
    Result$ = IO_Get_Chrome_Response(Chrome\Objects(TabID)\WsConnection,5000)
    Debug Result$
    nodeID = Val(StringField(Mid(Result$,FindString(Result$,"nodeId"+Chr(34)+":")+8),1,","))
    
    ProcedureReturn NodeID ; I only want the root nodeID
  EndProcedure
  Procedure.s IO_Get_Chrome_DOMgetOuterHTML(TabID.s,NodeId.i=-1,BackendNodeId=-1,RuntomeRometObjectID.i=-1)
    json = CreateJSON(#PB_Any) 
    
    params = ChromeDefaultJson(json,"DOM.getOuterHTML");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
    If NodeID > -1
      SetJSONInteger(AddJSONMember(params, "nodeId"), NodeId)
    EndIf
    
    request$ = ComposeJSON(json):FreeJSON(json)
    WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
    Debug IO_Get_Chrome_Response(Chrome\Objects(TabID)\WsConnection,500)
    
  EndProcedure
  Procedure.s IO_Set_Chrome_Runtimeenable(TabID.s,enable)
    json = CreateJSON(#PB_Any) 
    
    If enable
      params = ChromeDefaultJson(json,"Runtime.enable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
    Else
      params = ChromeDefaultJson(json,"Runtime.disable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
    EndIf
    request$ = ComposeJSON(json):FreeJSON(json)
    WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
  EndProcedure
  Procedure.s IO_Set_Chrome_Logenable(TabID.s,enable)
    json = CreateJSON(#PB_Any) 
    
    If enable
      params = ChromeDefaultJson(json,"Log.enable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
    Else
      params = ChromeDefaultJson(json,"Log.disable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
    EndIf
    request$ = ComposeJSON(json):FreeJSON(json)
    WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
  EndProcedure
  Procedure.s IO_Check_Chrome_Runtimeevaluate(TabID.s,expression.s)
    If Len(expression) = 0
      ProcedureReturn ""
    EndIf
    
    json = CreateJSON(#PB_Any) 
    params = ChromeDefaultJson(json,"Runtime.evaluate");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
    SetJSONString (AddJSONMember(params, "expression"), expression)
    
    request$ = ComposeJSON(json):FreeJSON(json)
    WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
    
  EndProcedure
  Procedure   IO_Set_Chrome_BrowserDownloadBehavior(behaviour.s,browserContextId=-1,downloadPath.s="",eventsEnabled=-1)
    ;Not working?
    If Len(behaviour) = 0
      ProcedureReturn 0
    EndIf
    
    json = CreateJSON(#PB_Any) 
    params = ChromeDefaultJson(json,"Browser.setDownloadBehavior");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
    SetJSONString (AddJSONMember(params, "behaviour"), behaviour)
    If browserContextId > -1 : SetJSONInteger (AddJSONMember(params, "browserContextId"), browserContextId):EndIf
    If Len(downloadPath) > -1 : SetJSONString (AddJSONMember(params, "downloadPath"), downloadPath):EndIf
    If eventsEnabled > -1 : SetJSONInteger (AddJSONMember(params, "eventsEnabled"), eventsEnabled):EndIf
    
    request$ = ComposeJSON(json):FreeJSON(json)
    
  EndProcedure
  Procedure.s IO_Get_Chrome_HMTL(TabID.s)
    
    ;Warning This uses Javascript and can be detected by the website!
    Filename$ = "Controller_Download_Text"
    Filepath.s = GetUserDirectory(#PB_Directory_Downloads)+Filename$ +".txt"
    
    If FileSize(Filepath) > 0
      DeleteFile(Filepath)
    EndIf
    
    IO_Check_Chrome_Runtimeevaluate(TabID,"const data = new XMLSerializer().serializeToString(document); const a = document.createElement('a');const blob = new Blob([JSON.stringify(data)]);a.href = URL.createObjectURL(blob);a.download = '"+Filename$+"';a.click();")
    Delay(600);min 450
    
    
    Repeat
      Delay(10)
      f = ReadFile(#PB_Any,Filepath)
    Until f
    content$ = ReadString(f,#PB_UTF8,FileSize(Filepath))
    
    CloseFile(f)
    DeleteFile(Filepath)
    ProcedureReturn content$
  EndProcedure
  
  ;Javascript for Chrome
  Procedure IO_Set_Chrome_ClickOnButtonByID(TabID.s,ButtonID.s)
    IO_Check_Chrome_Runtimeevaluate(TabID,"document.getElementById('"+ButtonID+"').click();")
  EndProcedure
  Procedure IO_Set_Chrome_JS_ClickOnButtonByClass(TabID.s,Classname.s)
    IO_Check_Chrome_Runtimeevaluate(TabID,"document.querySelector('."+ReplaceString(Classname," ",".")+"').click();")
  EndProcedure
  ;}
  
  ;{ Util - Python
  Procedure IO_Set_PythonCommand(command.s)
    Protected python, error.s
    output.s = ""
    
    python = RunProgram("python","-u "+command, "", #PB_Program_Open | #PB_Program_Read | #PB_Program_Error)
    If program$
      WriteProgramStringN(python,program$)
    EndIf
    
    Repeat 
      If AvailableProgramOutput(python)
        output.s + ReadProgramString(python) + Chr(10)
        output = Trim(output)
      EndIf
      error = ReadProgramError(python)
      While error
        output + error + Chr(13)
        error = ReadProgramError(python)
      Wend
      If Len(output)>0
        Debug output
        output = ""
      EndIf
    Until Not ProgramRunning(python)
    
  EndProcedure
  ;}
  
  ;{ Util - Scraper
  Global NewMap IO_Get_Countrycode.s();{
  IO_Get_Countrycode("Australia") ="au"	
  IO_Get_Countrycode("Austria") ="as"	
  IO_Get_Countrycode("Belgium") ="bg"	
  IO_Get_Countrycode("Brazil") ="br"	
  IO_Get_Countrycode("Canada") ="ca"	
  IO_Get_Countrycode("Cyprus (Anglicized)") ="cyen"	
  IO_Get_Countrycode("Cyprus (Greek)") ="cygk"	
  IO_Get_Countrycode("Czech Republic") ="cz"	
  IO_Get_Countrycode("Denmark") ="dk"	
  IO_Get_Countrycode("Estonia") ="ee"	
  IO_Get_Countrycode("Finland") ="fi"	
  IO_Get_Countrycode("France") ="fr"	
  IO_Get_Countrycode("Germany") ="gr"	
  IO_Get_Countrycode("Greenland") ="gl"	
  IO_Get_Countrycode("Hungary") ="hu"	
  IO_Get_Countrycode("Iceland") ="is"	
  IO_Get_Countrycode("Italy") ="it"	
  IO_Get_Countrycode("Netherlands") ="nl"	
  IO_Get_Countrycode("New Zealand") ="nz"	
  IO_Get_Countrycode("Norway") ="no"	
  IO_Get_Countrycode("Poland") ="pl"	
  IO_Get_Countrycode("Portugal") ="pt"	
  IO_Get_Countrycode("Slovenia") ="sl"	
  IO_Get_Countrycode("South Africa") ="za"	
  IO_Get_Countrycode("Spain") ="sp"	
  IO_Get_Countrycode("Sweden") ="sw"	
  IO_Get_Countrycode("Switzerland") ="sz"	
  IO_Get_Countrycode("Tunisia") ="tn"	
  IO_Get_Countrycode("United Kingdom") ="uk"	
  IO_Get_Countrycode("United States") ="us"	
  IO_Get_Countrycode("Uruguay") ="uy"	
  ;}
  Procedure.s GenerateFakeName(Countrycode.s,mwquota.f=0.5,minAge=19,maxAge=85) ; Online: fakenamegenerator.com
    NameParse = CreateRegularExpression(#PB_Any,"<div class="+Chr(34)+"address.>\r?\n\s+<h3>([^<]+)<\/h3>")
    url.s = "https://www.fakenamegenerator.com/advanced.php?t=country&n%5B%5D="+Countrycode+"&gen="+Str(mwquota*100)+"&age-min="+Str(minAge)+"&age-max="+Str(maxAge)+""
    HttpRequest = HTTPRequestMemory(#PB_HTTP_Get, url)
    If HttpRequest
      response$ = HTTPInfo(HTTPRequest, #PB_HTTP_Response)
      FinishHTTP(HTTPRequest)
    Else
      Debug "Request creation failed"
    EndIf
    
    ExamineRegularExpression(NameParse,response$)
    While NextRegularExpressionMatch(NameParse)
      name$ = RegularExpressionGroup(NameParse,1)
    Wend
    ProcedureReturn name$
  EndProcedure
  ;}
  
  ;{ Util - Virustotal
  Procedure.s IO_Get_VT_Download(ITW.s,APIKey$)
    NewMap Header$()
    Header$("Content-Type") = "plaintext"
    Header$("UserAgent") = "Firefox 54.0"
    Header$("Accept") = "application/json"
    Header$("x-apikey") = APIKey$
    
    HttpRequest = HTTPRequest(#PB_HTTP_Get, "https://www.virustotal.com/api/v3/files/"+ITW+"/download_url", "", 0, Header$())
    If HttpRequest
      Response$ = HTTPInfo(HTTPRequest, #PB_HTTP_Response)
      DownloadLink$ = StringField(Response$,4,Chr(34))
      Download = ReceiveHTTPFile(DownloadLink$, GetCurrentDirectory()+ITW,#PB_HTTP_Asynchronous)
      
      FinishHTTP(HTTPRequest)
    EndIf
    
    ProcedureReturn GetCurrentDirectory()+ITW
  EndProcedure
  Procedure.s IO_Get_VT_FileSearch(Searchstring.s,limit.i,APIKey$)
    NewMap Header$()
    Header$("Content-Type") = "plaintext"
    Header$("UserAgent") = "Firefox 54.0"
    Header$("Accept") = "application/json"
    Header$("x-apikey") = APIKey$
    If limit > 0
      limitstring.s = "&descriptors_only=true&limit="+Str(limit)
    EndIf
    HttpRequest = HTTPRequest(#PB_HTTP_Get, "https://www.virustotal.com/api/v3/intelligence/search?query="+Searchstring+limitstring, "", 0, Header$())
    
    If HttpRequest
      Response$ = HTTPInfo(HTTPRequest, #PB_HTTP_Response)
      FinishHTTP(HTTPRequest)
    EndIf
    
    Response$ = StringField(Response$,2,Chr(34)+"data"+Chr(34)+": [")
    Response$ = StringField(Response$,1,Chr(34)+"links"+Chr(34)+": {")
    
    ID.s = "" : ReturnID.s = ""
    For x = 1 To CountString(Response$,Chr(34)+"id"+Chr(34)+": "+Chr(34))
      ID =  StringField(Response$,1+x,Chr(34)+"id"+Chr(34)+": "+Chr(34))
      id = StringField(id,1,Chr(34))
      ReturnID.s  = ReturnID + ID + ","
    Next
    
    ProcedureReturn RTrim(ReturnID,",")
    
  EndProcedure
  
  ;}
  
CompilerEndIf

CompilerIf Not #PB_Compiler_IsIncludeFile
  Debug "Only use me as include"
CompilerEndIf
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 940
; FirstLine = 24
; Folding = AAAAAAAAAggAAAAAAAAAAAAAAAAAAA-
; EnableThread
; EnableXP
; EnablePurifier