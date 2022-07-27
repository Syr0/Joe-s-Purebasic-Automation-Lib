InitNetwork()
UsePNGImageEncoder()
ExamineDesktops()

;{ Mouse Input Simulation
Procedure Mouse_GetXPosition()
  GetCursorPos_(Mouse.POINT)
  ProcedureReturn Mouse\x
EndProcedure
Procedure Mouse_GetYPosition()
  GetCursorPos_(Mouse.POINT)
  ProcedureReturn Mouse\y
EndProcedure
Procedure Mouse_SetPosition(x,y)
  SetCursorPos_(x,y)
EndProcedure
Procedure Mouse_LClickOnPosition(x,y)
  SetCursorPos_(x,y)
  Delay(20)
  mouse_event_(#MOUSEEVENTF_LEFTDOWN,0,0,0,0)
  Delay(20)
  mouse_event_(#MOUSEEVENTF_LEFTUP,0,0,0,0)
EndProcedure  
Procedure Mouse_RClickOnPosition(x,y)
  SetCursorPos_(x,y)
  Delay(5)
  mouse_event_(#MOUSEEVENTF_RIGHTDOWN,0,0,0,0)
  Delay(5)
  mouse_event_(#MOUSEEVENTF_RIGHTUP,0,0,0,0)
EndProcedure  
Procedure Mouse_PushAndRelease(Code)
  keybd_event_(Code, 0, 0,0)
  keybd_event_(Code, 0, #KEYEVENTF_KEYUP,0)
EndProcedure
Procedure Mouse_LClickRelease()
  mouse_event_(#MOUSEEVENTF_LEFTUP,0,0,0,0)
EndProcedure
Procedure Mouse_LClickPush(Delay = 0)
  Delay(delay)
  mouse_event_(#MOUSEEVENTF_LEFTDOWN,0,0,0,0)
  Delay(delay)
EndProcedure
Procedure Mouse_LClick(Delay = 0)
  mouse_event_(#MOUSEEVENTF_LEFTDOWN,0,0,0,0)
  Delay(delay)
  mouse_event_(#MOUSEEVENTF_LEFTUP,0,0,0,0)
EndProcedure
Procedure Mouse_RClick(Delay = 0)
  mouse_event_(#MOUSEEVENTF_RIGHTDOWN,0,0,0,0)
  Delay(delay)
  mouse_event_(#MOUSEEVENTF_RIGHTUP,0,0,0,0)
EndProcedure
Procedure Mouse_RClickRelease()
  mouse_event_(#MOUSEEVENTF_RIGHTUP,0,0,0,0)
EndProcedure
Procedure Mouse_RClickPush(Delay = 0)
  Delay(delay)
  mouse_event_(#MOUSEEVENTF_RIGHTDOWN,0,0,0,0)
  Delay(delay)
EndProcedure
Procedure Mouse_wheelUp()
  in.Input
  in\type = #INPUT_MOUSE
  in\mi\dwFlags = #MOUSEEVENTF_WHEEL
  in\mi\mouseData = 120
  SendInput_(1,@in,SizeOf(input))
  Delay(10)
EndProcedure  
Procedure Mouse_wheelDown()
  in.Input
  in\type = #INPUT_MOUSE
  in\mi\dwFlags = #MOUSEEVENTF_WHEEL
  in\mi\mouseData = -120
  SendInput_(1,@in,SizeOf(input))
  Delay(10)
EndProcedure  
;}

;{ Keyboard Input Simulation
Procedure Keyboard_Push(Code)
  keybd_event_(Code,0,0,0)
  Delay(10)
EndProcedure
Procedure Keyboard_Release(Code)
  keybd_event_(Code,0,#KEYEVENTF_KEYUP,0)
EndProcedure
Procedure Keyboard_PushAndRelease(Code)
  keybd_event_(Code,0,0,0)
  Delay(20)
  keybd_event_(Code,0,#KEYEVENTF_KEYUP,0)
  Delay(20)
EndProcedure
;}

;{ Visual Output
Structure Pixels
  x.i
  y.i
  Color.i
EndStructure
Procedure MakeDesktopScreenshot()
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
Procedure Colorpick (image, *Position.POINT)
  If *Position\x < 0 Or *Position\x >= ImageWidth(image) Or *Position\y < 0 Or *Position\y >= ImageHeight(image)
    ProcedureReturn -1
  EndIf
  
  StartDrawing(ImageOutput(image))
  color = Point(*Position\x,*Position\y)
  StopDrawing()
  ProcedureReturn color
EndProcedure
Procedure PixelPatternCheck(image,List Pixels.Pixels())
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
Procedure PixelPatternThresholdCheck(image,List Pixels.Pixels(),Threshold)
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
Procedure.i FindImageColorDetail(image,RedMin,RedMax,GreenMin,GreenMax,BlueMin,BlueMax,List P.POINT())
  StartDrawing(ImageOutput(image))
  For x = 0 To ImageWidth(image)-1
    For y = 0 To ImageHeight(image)-1
      c = Point(x,y)
      If Red(c) > RedMin And Red(c) < RedMax And
         Green(c) > GreenMin And Green(c) < GreenMax And
         Blue(c) > BlueMin And Blue(c) < BlueMax
        StopDrawing()
        AddElement(P())
        P()\x = x
        P()\y = y
      EndIf
    Next
  Next
  StopDrawing()
  ProcedureReturn 0
EndProcedure
Procedure.i FindImageColor(image,Color,Threshold,List P.POINT())
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
;}

;{ OCR-Install
Procedure DownloadTesseract()
  Downloadlink.s = "https://digi.bib.uni-mannheim.de/tesseract/tesseract-ocr-w64-setup-v5.0.0-alpha.20210506.exe"
  DownloadSize = 53209536
  
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
Procedure GuidedInstaller()
  program = RunProgram(GetTemporaryDirectory()+"TesseractInstaller.exe","","",#PB_Program_Open )
  If program
    Repeat
      Delay(10)
      handle = FindWindow_(0,"Installer Language")
    Until handle > 0
    SetActiveWindow_(handle)
    Delay(200)
    ;Sprache
    Keyboard_PushAndRelease(#VK_RETURN)
    Delay(200)
    ;Empfehlung
    Keyboard_PushAndRelease(#VK_RETURN)
    ;Lizenz
    Delay(200)
    Keyboard_PushAndRelease(#VK_RETURN)
    ;Benutzer
    Delay(200)
    Keyboard_PushAndRelease(#VK_TAB)
    Keyboard_PushAndRelease(#VK_TAB)
    Keyboard_PushAndRelease(#VK_TAB)
    Keyboard_PushAndRelease(#VK_SPACE)
    Keyboard_PushAndRelease(#VK_RETURN)
    ;Packages
    Delay(200)
    Keyboard_PushAndRelease(#VK_RETURN)
    ;Pfad
    Wunschpfad.s = GetCurrentDirectory()+"Tesseract"
    SetClipboardText(Wunschpfad)
    
    ;Str+A
    Keyboard_Push(#VK_CONTROL)
    Keyboard_Push(#VK_A)
    Delay(100)
    Keyboard_Release(#VK_CONTROL)
    Keyboard_Release(#VK_A)
    Delay(100)
    ;Str+V
    Keyboard_Push(#VK_CONTROL)
    Keyboard_Push(#VK_V)
    Delay(100)
    Keyboard_Release(#VK_CONTROL)
    Keyboard_Release(#VK_V)
    Keyboard_PushAndRelease(#VK_RETURN)
    Delay(100)
    
    ;Startmenü
    Keyboard_PushAndRelease(#VK_TAB)
    Keyboard_PushAndRelease(#VK_TAB)
    Keyboard_PushAndRelease(#VK_SPACE)
    Keyboard_PushAndRelease(#VK_RETURN)
    Delay(6000)
    ;Installation
    Keyboard_PushAndRelease(#VK_RETURN)
    Delay(200)
    Keyboard_PushAndRelease(#VK_RETURN)
    Delay(200)
    
    DeleteFile(GetTemporaryDirectory()+"TesseractInstaller.exe")
    
    ProcedureReturn 1
  Else
    ProcedureReturn 0  
  EndIf
EndProcedure
;}

;{ OCR Use
Global TesseractExe.s = GetCurrentDirectory()+"Tesseract\tesseract.exe"
Global OCRMutex = CreateMutex()
Global NewMap OCRStrings.s()
Global NewMap OCRWatches()

Structure OCRStruct
  Title.s
  x.i
  y.i
  w.i
  h.i
EndStructure
Procedure OCR(*Parameter.OCRStruct)
  Uniquename.s = Str(*Parameter\x)+Str(*Parameter\y)+Str(*Parameter\h)+Str(*Parameter\w)
  img = MakeDesktopScreenshot()
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
Procedure.s SingleOCR(image,x,y,w,h)
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
Procedure.s NumberOCR(image,x,y,w,h)
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
Procedure InitReadStatusMessages(*ParameterIncoming.OCRStruct)
  ParameterInside.OCRStruct
  CopyStructure(*ParameterIncoming,ParameterInside,OCRStruct)
  Repeat
    ocr(ParameterInside)
  ForEver
EndProcedure
Procedure.s OCRStatus(Text.s)
  LockMutex(OCRMutex)
  Text.s = OCRStrings(Text)
  UnlockMutex(OCRMutex)
  
  ProcedureReturn Text
EndProcedure
Procedure StartOCRWatch(x,y,w,h,Title.s)
  Parameter.OCRStruct
  Parameter\x = x
  Parameter\y = y
  Parameter\w = w
  Parameter\h = h
  Parameter\Title = Title
  OCRWatches(Title) = CreateThread(@InitReadStatusMessages(),Parameter)
  Delay(100)
EndProcedure
Procedure StopOCRWatch(Title.s)
  KillThread(OCRWatches(Title))
  DeleteMapElement(OCRWatches(),Title)
EndProcedure
;}

;{ Network-Protocols
Structure PageNavigateReturn
  frameId.s
  loaderId.s
  errorText.s
EndStructure
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
  
  Structure WebSocket
    Frametyp.i
    FrameMemory.i
  EndStructure
  
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
;}

;{ Chrome Automation
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
EndStructure

Global Chrome_DebugPort = 9222
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
Procedure   Chrome_OpenWebSocket(TabID.s)
  Chrome\Objects(TabID)\WsConnection = WebsocketClient::OpenWebsocketConnection(Chrome\Objects(TabID)\webSocketDebuggerUrl)
  ProcedureReturn #True
EndProcedure
;}
Procedure.s Chrome_GetWebsocketResponse(connection,timeout = 0)
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
Procedure   Chrome_List()
  HttpRequest = HTTPRequestMemory(#PB_HTTP_Get, "localhost:"+Str(Chrome_DebugPort)+"/json/list")
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
Procedure   Chrome_GetVersion()
  HttpRequest = HTTPRequestMemory(#PB_HTTP_Get, "localhost:"+Str(Chrome_DebugPort)+"/json/version")
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
Procedure.s Chrome_NewTab();Returns ID
  HttpRequest = HTTPRequestMemory(#PB_HTTP_Get, "localhost:"+Str(Chrome_DebugPort)+"/json/new")
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
Procedure   Chrome_ActivateTab(TabID.s)
  HttpRequest = HTTPRequestMemory(#PB_HTTP_Get, "localhost:"+Str(Chrome_DebugPort)+"/json/activate/"+TabID)
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
Procedure   Chrome_CloseTab(TabID.s)
  HttpRequest = HTTPRequestMemory(#PB_HTTP_Get, "localhost:"+Str(Chrome_DebugPort)+"/json/close/"+TabID)
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

Procedure.i Chrome_PageNavigate(TabID.s,*Returnvalue.PageNavigateReturn,url.s,referrer.s="",transitionType.i=-1,frameId.i=-1,referrerPolicy.i=-1)
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
  Chrome_GetWebsocketResponse(Chrome\Objects(TabID)\WsConnection)
  
EndProcedure
Procedure.s Chrome_DOMenable(TabID.s,enable)
  json = CreateJSON(#PB_Any) 
  
  If enable
    params = ChromeDefaultJson(json,"DOM.enable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
  Else
    params = ChromeDefaultJson(json,"DOM.disable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
  EndIf
  
  request$ = ComposeJSON(json):FreeJSON(json)
  WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
EndProcedure
Procedure Chrome_DOMgetDocument(TabID.s,depth.i=-1,pierce.b=0) ;NOT WORKING
  json = CreateJSON(#PB_Any) 
  
  params = ChromeDefaultJson(json,"DOM.getDocument");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
  SetJSONInteger(AddJSONMember(params, "depth"), depth)
  ;   SetJSONInteger(AddJSONMember(params, "pierce"), pierce)
  
  Debug Chrome_GetWebsocketResponse(Chrome\Objects(TabID)\WsConnection,200)
  request$ = ComposeJSON(json):FreeJSON(json)
  WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
  Result$ = Chrome_GetWebsocketResponse(Chrome\Objects(TabID)\WsConnection,5000)
  Debug Result$
  nodeID = Val(StringField(Mid(Result$,FindString(Result$,"nodeId"+Chr(34)+":")+8),1,","))
  
  ProcedureReturn NodeID ; I only want the root nodeID
EndProcedure
Procedure.s Chrome_DOMgetOuterHTML(TabID.s,NodeId.i=-1,BackendNodeId=-1,RuntomeRometObjectID.i=-1)
  json = CreateJSON(#PB_Any) 
  
  params = ChromeDefaultJson(json,"DOM.getOuterHTML");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
  If NodeID > -1
    SetJSONInteger(AddJSONMember(params, "nodeId"), NodeId)
  EndIf
  
  request$ = ComposeJSON(json):FreeJSON(json)
  WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
  Debug Chrome_GetWebsocketResponse(Chrome\Objects(TabID)\WsConnection,500)
  
EndProcedure
Procedure.s Chrome_Runtimeenable(TabID.s,enable)
  json = CreateJSON(#PB_Any) 
  
  If enable
    params = ChromeDefaultJson(json,"Runtime.enable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
  Else
    params = ChromeDefaultJson(json,"Runtime.disable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
  EndIf
  request$ = ComposeJSON(json):FreeJSON(json)
  WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
EndProcedure
Procedure.s Chrome_Logenable(TabID.s,enable)
  json = CreateJSON(#PB_Any) 
  
  If enable
    params = ChromeDefaultJson(json,"Log.enable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
  Else
    params = ChromeDefaultJson(json,"Log.disable");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
  EndIf
  request$ = ComposeJSON(json):FreeJSON(json)
  WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
EndProcedure
Procedure.s Chrome_Runtimeevaluate(TabID.s,expression.s)
  If Len(expression) = 0
    ProcedureReturn ""
  EndIf
  
  json = CreateJSON(#PB_Any) 
  params = ChromeDefaultJson(json,"Runtime.evaluate");erstelle schonmal en JSON mit Requestid(ein counter) und Methode
  SetJSONString (AddJSONMember(params, "expression"), expression)
  
  request$ = ComposeJSON(json):FreeJSON(json)
  WebsocketClient::SendTextFrame(Chrome\Objects(TabID)\WsConnection,request$)
  
EndProcedure
Procedure Chrome_BrowsersetDownloadBehavior(behaviour.s,browserContextId=-1,downloadPath.s="",eventsEnabled=-1)
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
Procedure.s Chrome_GetHMTL(TabID.s)
  
  ; Bishierhin war noch alles gut. Jetzt kommt Dreck. Ausleiten des HTML als Download...
  Filename$ = "Controller_Download_Text"
  Filepath.s = GetUserDirectory(#PB_Directory_Downloads)+Filename$ +".txt"
  
  If FileSize(Filepath) > 0
    DeleteFile(Filepath)
  EndIf
  
  Chrome_Runtimeevaluate(TabID,"const data = new XMLSerializer().serializeToString(document); const a = document.createElement('a');const blob = new Blob([JSON.stringify(data)]);a.href = URL.createObjectURL(blob);a.download = '"+Filename$+"';a.click();")
  Delay(600);min 450
  
  ;Noch am schreiben?
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
Procedure Chrome_JS_ClickOnButtonByID(TabID.s,ButtonID.s)
  Chrome_Runtimeevaluate(TabID,"document.getElementById('"+ButtonID+"').click();")
EndProcedure
Procedure Chrome_JS_ClickOnButtonByClass(TabID.s,Classname.s)
  Chrome_Runtimeevaluate(TabID,"document.querySelector('."+ReplaceString(Classname," ",".")+"').click();")
EndProcedure
;}

;{ Process Control <- Warning on slowdown!
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
  PID.i
EndStructure
Structure ScanAllProcessesForClassAndTitleWithResultUIFields
  hwnd.i
  Class.s
  Text.s
EndStructure
Structure NestedList
  List Nested.ScanAllProcessesForClassAndTitleWithResultUIFields()
EndStructure
NewList Processlist.ProcessName()

Procedure KillProcess (pid)
  phandle = OpenProcess_ (#PROCESS_TERMINATE, #False, pid)
  If phandle <> #Null
    If TerminateProcess_ (phandle, 1)
      result = #True
    EndIf
    CloseHandle_ (phandle)
  EndIf
  ProcedureReturn result
EndProcedure
Procedure GetAllProcess(List Processlist.ProcessName()) 
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
            Processlist()\Name = PeekS(*SPI\ImageName\usBuffer, -1, #PB_Unicode)
          EndIf
          *SPI + *SPI\NextEntryOffset
        Wend
      EndIf
      FreeMemory(*Buffer)
    EndIf
  EndIf
EndProcedure
Procedure CloseProcessByName(filename.s);not title!
  NewList Processlist.ProcessName()
  GetAllProcess(Processlist())
  ForEach Processlist()
    If Processlist()\Name = filename
      KillProcess(Processlist()\PID)
    EndIf
  Next
EndProcedure

Procedure AllProcessAndPID()
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
            Debug RSet(Str(*SPI\ProcessId), 4, "0") + #TAB$ + PeekS(*SPI\ImageName\usBuffer, -1, #PB_Unicode)
          EndIf
          *SPI + *SPI\NextEntryOffset
        Wend
      EndIf
      FreeMemory(*Buffer)
    EndIf
  EndIf
EndProcedure
Procedure CheckRunningExe(FileName.s)
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
Procedure FindHwndByPart(Text$)
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
Procedure FocusWindow(Title.s)
  hwnd = FindWindow_(0,Title)
  SetForegroundWindow_(hwnd)
  Delay(1)
  ProcedureReturn hwnd
EndProcedure
Procedure MaxWindow(hwnd)
  SetWindowPos_(hwnd,0,-8,-31,DesktopWidth(0)+16,DesktopHeight(0)-2,0)
EndProcedure
Procedure TitleToHwnd(Title.s)
  ProcedureReturn FindWindow_(0,Title)
EndProcedure
Procedure HwndToPID(hwnd)
  PID.i
  GetWindowThreadProcessId_(hwnd, @PID)
  ProcedureReturn PID
EndProcedure

;!BEWARNED!
;These functions are hard For the AV And might 1) cause loading issues 2) trigger false-positives
Declare.s GetHwndText(hwnd.i)
Procedure ScanHwndForAllText(hWnd.i, Map Result.s(),Prefix.s = "")
  Protected nexthwnd.i, szClass.s{1024}, szText.s{2048}
  nexthwnd = GetWindow_(hwnd, #GW_CHILD | #GW_HWNDFIRST)
  While nexthwnd <> 0
    GetClassName_(nexthwnd, @szClass, SizeOf(szClass))
    GetWindowText_(nexthwnd, @szText, SizeOf(szText))
    SendMessage_(nexthwnd, #WM_GETTEXT, SizeOf(szText)/2, @szText) ; Unicode Support
    Result("hwnd: "+Str(nexthwnd) + " Class: "+ Prefix + szClass) = szText
    ScanHwndForAllText(nexthwnd,Result(),szClass+"\")
    CloseHandle_(nexthwnd)
    nexthwnd = GetWindow_(nexthwnd, #GW_HWNDNEXT)
  Wend
  
EndProcedure
Procedure cbEnumParentsWithCallback(hWnd.i, *FunctionPointer)
  Protected szClass.s{1024}, szText.s{2048}
  GetClassName_(hWnd, @szClass, SizeOf(szClass))
  GetWindowText_(hWnd, @szText, SizeOf(szText))
  CallFunctionFast(*FunctionPointer,hwnd,@szClass,@szText)
  ProcedureReturn 1
EndProcedure
Procedure cbEnumParentsWithResult(hWnd.i, *Result.NestedList)
  Protected szClass.s{1024}, szText.s{2048}
  GetClassName_(hWnd, @szClass, SizeOf(szClass))
  GetWindowText_(hWnd, @szText, SizeOf(szText))
  AddElement(*Result\Nested())
  *Result\Nested()\Class = szClass
  *Result\Nested()\hwnd = hWnd
  
  ;If the 1kb Buffer was too small, use the 100kb buffer
  If Len(szText) > 1000
    *Result\Nested()\Text =  gethwndtext(hWnd)
  Else
    *Result\Nested()\Text = szText
  EndIf
  
  ProcedureReturn 1
EndProcedure
Procedure ScanAllProcessesForClassAndTitleWithCustomFunction(*CallbackFunctionPointer)
  EnumWindows_(@cbEnumParentsWithCallback(),*CallbackFunctionPointer)
  ;{ EXAMPLE
  
  ; Procedure CallBack_EnumParents(PID,Class.s,Text.s)
  ;   Debug Str(PID)+Chr(9)+Class+": "+Text
  ; EndProcedure
  ; 
  ; ScanAllProcessesForClassAndTitle(@CallBack_EnumParents())
  ;}
EndProcedure
Procedure ScanAllProcessesForClassAndTitleWithResult(*ResultList)
  EnumWindows_(@cbEnumParentsWithResult(),*ResultList)
  ;Example
  ;   ResultList.NestedList                                   
  ;   ScanAllProcessesForClassAndTitleWithResult(@ResultList)
  ;   ForEach ResultList\Nested()
  ;     Debug Str(ResultList\Nested()\hwnd)+Chr(9)+ResultList\Nested()\Class+Chr(9)+ResultList\Nested()\Text
  ;   Next
EndProcedure

Procedure.s GetHwndText(hwnd.i) ; Supports 100kb long texts - way more then ScanHwndForClassAndText() (1kb)
  szText.s{100000}              ;100kb - Don't overflow the stack maximum on test before overflow= 514882
  SendMessage_(hwnd, #WM_GETTEXT, SizeOf(szText)/2, @szText)
  ProcedureReturn szText
EndProcedure
Procedure SearchTextOnWinUI(Text.s,ResultNr=1) ; Returns the hwnd - searches all titles, classes and content
  ResultList.NestedList
  NewMap TempResultMap.s()
  ScanAllProcessesForClassAndTitleWithResult(@ResultList)
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
      ScanHwndForAllText(ResultList\Nested()\hwnd,TempResultMap())
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

Procedure.i GetModule(ProcessId.l, ModuleName.s)
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
        ;Werte den Modulnamen aus
        Repeat
          ;Lese String aus dem Speicherbereich Me32\szModule bis zur Nullterminierung (-1) aks ASCCI
          Protected moduleName$=PeekS(@Me32\szModule, -1, #PB_Ascii)
          ;Ist der String der gesuchten Modulnamen?
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

Procedure.l PointerWalk(PID,List Offsets.q(),ModuleName$="",hProcess=-1)
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
    moduleAddress=GetModule(PID, ModuleName$)
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

;}


; CompilerIf Not #PB_Compiler_IsIncludeFile
;   Debug "Only use me by include"
; CompilerEndIf

; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 1186
; FirstLine = 54
; Folding = AAAAAAAAAAAIAAA+
; EnableThread
; EnableXP
; EnablePurifier