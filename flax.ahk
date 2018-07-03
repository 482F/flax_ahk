;注意事項
;エンコーディングについて
;AutoHotkey Scriptファイル自体のエンコーディングはUTF-8(signature)、
;読み込むiniファイルのエンコーディングはSJISでないと日本語を認識できない
;
;変数などの扱いについて
;K = String、K := "String"とした場合、変数「K」の中身は文字列「String」となる。
;K = %String%、K := Stringとした場合、変数「K」の中身は変数「String」の中身となる。
;K =% L + M、K := L + Mとした場合、変数「K」の中身は変数「L」、「M」の中身の和となる。
;関数Func(K, L)に関して、引数K、Lは"基本的に"変数名として扱われる。文字列を直接引数にしたい場合は"String"などを指定する。
;コマンドCommand,K,Lに関して、引数K、Lは"大抵"(絶対でなく)文字列「K」、「L」として扱われる。変数を引数にしたい場合は%K%などを指定する。
;
;クラスについて
;class TestClass{
;	__New(Var1, Var2){
;		this.Var1 := Var1
;		this.Var2 := Var2
;	}
;	Method1(Var3, Var4){
;		return this.Var1 + this.Var2 + this.Var3 + this.Var4
;	}
;}






;環境設定
#Hotstring C ?
#Persistent
#KeyHistory 500
#InstallKeybdHook
#InstallMouseHook
#UseHook On
#NoEnv
AutoTrim,off
SetWorkingDir,%A_ScripdDir%
SetTitleMatchMode,2
SendMode,InputThenPlay
;初期変数
DefVars:
{
	marg := 50
	flaxmode = normal
	flaxmoviemode = False
	ALCmode = Select
	copymode = normal
	FIFOClip := Object()
	editmode = normal
	StringReplace,ComputerName,A_ComputerName,-
	WINDOWSO3L7BIOscreenshotdir = C:\Users\admin\Pictures\screenshot\
	LauncherFD := new FD_for_EC("launcher.fd")
	FileGetTime,gestureLastUpdate,MouseGesture.ini,M
	FileGetTime,registerLastUpdate,register.ini,M
	FileRead,ColorList,colorlist.txt
	FileRead,TimeTable,TimeTable.txt
	MP := Object()
	global Pi := 3.14159265358979
	msgbox,ready
;	SetTimer,DefaultLoop,1000
	return
}
GoSub,DefVars

;ループ部分
DefaultLoop:
{
sleep 1000
	alarmcheck()
	return
}
return
;Gui の特殊ラベル
GuiClose:
GuiEscape:
	Gui,Destroy
	return
GuiDropFiles:
	ifWinExist,VirtualFolder
		GoSub,VirtualFolderDropFiles
	return
GuiSize:
	ifWinExist,VirtualFolder
		GoSub,VirtualFolderSize
	return

;function
;関数
RevStr(Str){
	Loop,Parse,Str
	{
		RetStr := A_LoopField . RetStr
	}
	return,RetStr
}
EvalLogic(Formula){
	Formula := RegExReplace(Formula,"\s","")
	BP := RetCorBracket(Formula)
	if (BP["S"] != "")
	{
		BV := RetCorBracketSplit(Formula)
		return EvalLogic(BV[0] . EvalLogic(BV[1]) . BV[2])
	}
	StringGetPos,K,Formula,not
	if K != -1
	{
		if (SubStr(Formula,K + 4,1) == 1)
			L = 0
		else
			L = 1
		return EvalLogic(SubStr(Formula,1,K) . L . SubStr(Formula,K + 5,StrLen(Formula)))
	}
	StringGetPos,K,Formula,imp
	if K != -1
	{
		return EvalLogic(SubStr(Formula,1,K - 1) . "not" . SubStr(Formula,K,1) . "or" . SubStr(Formula,K + 4, StrLen(Formula)))
	}
	StringGetPos,K,Formula,and
	if K != -1
	{
		StringMid,K1,Formula,K,,L
		StringMid,K2,Formula,K+4
		return (EvalLogic(K1) == 1 and EvalLogic(K2) == 1)
	}
	StringGetPos,K,Formula,or
	if K != -1
	{
		StringMid,K1,Formula,K,,L
		StringMid,K2,Formula,K+3
		return (EvalLogic(K1) == 1 or EvalLogic(K2) == 1)
	}
	return Formula
}
EvalForm(Formula,mode="normal"){
	Formula := RegExReplace(Formula,"\s","")
	StringLeft,K,Formula,1
	if (K == "f")
	{
		StringTrimLeft,Formula,Formula,1
		return EvalForm(Formula,"frac")
	}
	if (mode == "normal")
	{
		if Formula is number
		{
			return Formula
		}
		BP := RetCorBracket(Formula)
		BV := RetCorBracketSplit(Formula)
		If (BV[1] != "")
		{
			return EvalForm(BV[0] . EvalForm(BV[1]) . BV[2])
		}
		StringGetPos,K,Formula,+
		If K <> -1
		{
			StringMid,K1,Formula,K,,L
			StringMid,K2,Formula,K+2
			return EvalForm(K1) + EvalForm(K2)
		}
		StringGetPos,K,Formula,-
		If K <> -1
		{
			StringMid,K1,Formula,K,,L
			StringMid,K2,Formula,K+2
			return EvalForm(K1) - EvalForm(K2)
		}
		StringGetPos,K,Formula,*
		If K <> -1
		{
			StringMid,K1,Formula,K,,L
			StringMid,K2,Formula,K+2
			return EvalForm(K1) * EvalForm(K2)
		}
		StringGetPos,K,Formula,/
		If K <> -1
		{
			StringMid,K1,Formula,K,,L
			StringMid,K2,Formula,K+2
			return EvalForm(K1) / EvalForm(K2)
		}
		StringGetPos,K,Formula,^
		If K <> -1
		{
			StringMid,K1,Formula,K,,L
			StringMid,K2,Formula,K+2
			return EvalForm(K1) ** EvalForm(K2)
		}
		return Error
	}
	else if(mode == "frac")
	{
		sign = 0
		K := RegExMatch(Formula,"^\d*\/\d*$")
		if (K == 1)
		{
			K := RetAoT(Formula,"/",0)
			G := RetGCF(K[0],K[1])
			return round(K[0] / G) . "/" . round(K[1] / G)
		}
		StringGetPos,K,Formula,+
		if (K != -1)
		{
			L := RetAoT(Formula,"+",0)
			sign := 1
		}
		StringGetPos,K,Formula,-
		if (K != -1)
		{
			L := RetAoT(Formula,"-",0)
			sign := -1
		}
		if (sign == 1 or sign == -1)
		{
			K1 := RetAoT(EvalForm(L[0],mode),"/",0)
			K2 := RetAoT(EvalForm(L[1],mode),"/",0)
			L := RetLCM(K1[1], K2[1])
			K1[0] := K1[0] / K1[1] * L
			K2[0] := K2[0] / K2[1] * L
			K1[0] := K1[0] + K2[0] * sign
			return EvalForm(round(K1[1]) . "/" . L,mode)
		}
		StringGetPos,K,Formula,*
		if (K != -1)
		{
			L := RetAoT(Formula,"*",0)
			K1 := RetAoT(EvalForm(L[0],mode),"/",0)
			K2 := RetAoT(EvalForm(L[1],mode),"/",0)
			return EvalForm(round(K1[0] * K2[0]) . "/" . round(K1[1] * K2[1]),mode)
		}
	}
	return
}
IME_GetConvMode(WinTitle="A"){
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
			VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
			NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
							 ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}
		return DllCall("SendMessage"
					, UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
					, UInt, 0x0283  ;Message : WM_IME_CONTROL
					,  Int, 0x001   ;wParam  : IMC_GETCONVERSIONMODE
					,  Int, 0)	  ;lParam  : 0
}
IME_SetConvMode(ConvMode,WinTitle="A"){
	ControlGet,hwnd,HWND,,,%WinTitle%
	if	(WinActive(WinTitle))	{
		ptrSize := !A_PtrSize ? 4 : A_PtrSize
		VarSetCapacity(stGTI, cbSize:=4+4+(PtrSize*6)+16, 0)
		NumPut(cbSize, stGTI,  0, "UInt")   ;	DWORD   cbSize;
		hwnd := DllCall("GetGUIThreadInfo", Uint,0, Uint,&stGTI)
				 ? NumGet(stGTI,8+PtrSize,"UInt") : hwnd
	}
	return DllCall("SendMessage"
		  , UInt, DllCall("imm32\ImmGetDefaultIMEWnd", Uint,hwnd)
		  , UInt, 0x0283	  ;Message : WM_IME_CONTROL
		  ,  Int, 0x002	   ;wParam  : IMC_SETCONVERSIONMODE
		  ,  Int, ConvMode)   ;lParam  : CONVERSIONMODE
}
alarmcheck(){
	IniRead,alarmlist,alarm.ini
	Loop,Parse,alarmlist,`n
	{
		sleep 100
		IniRead,alarmday,alarm.ini,%A_LoopField%,day
		IniRead,alarmtime,alarm.ini,%A_LoopField%,time
		IniRead,alarmtype,alarm.ini,%A_LoopField%,type
		IniRead,alarmcommand,alarm.ini,%A_LoopField%,command
		IniRead,alarmparam,alarm.ini,%A_LoopField%,param
		IniRead,alarmdone,alarm.ini,%A_LoopField%,done
		IniRead,alarmdelete,alarm.ini,%A_LoopField%,delete
		IniRead,alarmenabled,alarm.ini,%A_LoopField%,enabled
		if (alarmday == "everyday" or alarmday == A_YYYY . "/" . A_MM . "/" . A_DD and alarmenabled == "True")
		{
			if (alarmtime == A_Hour . ":" . A_Min)
			{
				if (alarmdone = "False")
				{
					if (alarmtype == "run")
					{
						run,%alarmcommand%
						IniWrite,True,alarm.ini,%A_LoopField%,done
						msgbox,%A_LoopField%
					}
					else if (alrmtype == "msg")
					{
						msgbox,%A_LoopField%
					}
					if (alarmdelete == "True")
					{
						IniDelete,alarm.ini,%A_LoopField%
					}
					else if (alarmdelete == "once")
					{
						IniWrite,False,alrm.ini,%A_LoopField%,enabled
					}
				}
			}
			else
			{
				IniWrite,False,alarm.ini,%A_LoopField%,done
			}
		}
	}
	return
}
retpath(name){
	if (A_ComputerName = "WINDOWS-O3L7BIO")
	{
		if (name = "screenshot")
			return "C:\Users\admin\Pictures\screenshot\"
		if (name = "document")
			return "E:\document\"
		if (name = "picture")
			return "C:\Users\admin\Pictures\"
		if (name = "music")
			return "E:\document\MUSIC\"
		if (name = "class")
			return "E:\document\授業\2年春\"
		if (name = "download")
			return "D:\download\"
		if (name = "python.exe")
			return "C:\software\Python\python-3.6.0\python.exe"
		if (name = "gvim")
			return "D:\utl\vim80-kaoriya-win64\gvim.exe"
	}
	else if (A_ComputerName = "FLAXEN-PC")
	{
		if (name = "screenshot")
			return "Z:\ライブラリ\ピクチャ\pcscreenshot\"
		if (name = "document")
			return "C:\Users\Flaxen\Documents\"
		if (name = "picture")
			return "Z:\ライブラリ\ピクチャ\"
		if (name = "music")
			return "Z:\ライブラリ\ミュージック\"
		if (name = "download")
			return "Z:\Downloads\"
		if (name = "python.exe")
			return "C:\Software\Python\python\python.exe"
		if (name = "gvim")
			return "H:\Date\vim80-kaoriya-win64\gvim.exe"
	}
	else if (A_ComputerName = "DESKTOP-AEDD2O7")
	{
		if (name = "gvim")
			return "D:\utl\vim80-kaoriya-win64\gvim.exe"	
	}
	return
}
proofreadingratwikireg(Text,Rule){
	StringGetPos,BR,Text,\begin{flaxconstant}
	StringGetPos,ER,Text,\end{flaxconstant}
	msgjoin(text)
	If (BR != -1 and ER != -1)
	{
		StringLen,Len,Text
		StringMid,TText,Text,1,% BR
		StringMid,MText,Text,% BR + 21,% ER - (BR + 20)
		StringMid,BText,Text,% ER + 19,% Len
		TText := proofreadingratwikireg(TText,Rule)
		BText := proofreadingratwikireg(BText,Rule)
		Text := TText . MText . BText
		return Text
	}
	else
	{
		;msgbox,% Text
		Loop,Parse,Rule,`n
		{
			LoopField = %A_LoopField%:::flaxdelimiter:::
			StringReplace,LoopField,LoopField,`n,:::flaxnewline:::,All
			StringReplace,LoopField,LoopField,:::flaxdelimiter:::,`n,All
			StringSplit,NowRule,LoopField,`n
			NowRule1 := "S)" . NowRule1
			StringReplace,NowRule2,NowRule2,\n,`n,All
			StringReplace,LoopField,LoopField,:::flaxnewline:::,`n,All
			Text := RegExReplace(Text,NowRule1,NowRule2)
			;msgbox,% Text "`n" NowRule1 "`n" NowRule2
		}
		return Text
	}
	return
}
screenshot(SX,SY,EX,EY,destination,Flag=2){
	while True
	{
		send,{Ctrl down}{Shift down}{F12 down}
		sleep 500
		send,{F12 up}{Shift up}{Ctrl up}
		WinGetPos,X,Y,W,H,A
		if (X = "" and Y = "")
			break
	}
	CoordMode,Mouse,Screen
	MouseClickDrag,L,%SX%,%SY%,%EX%,%EY%
	sleep 100
	MouseClick,L,% EX - 15,% EY + 25
	CoordMode,Mouse,Relative
	PictName = %A_Now%%A_TickCount%.png
	WinWaitActive,ahk_exe SnapCrab.exe
	while True
	{
		send,!n
		sleep 100
		sendraw,%PictName%
		sleep 200
		ControlGetText,NamedName,Edit1,ahk_exe SnapCrab.exe
		if (NamedName = PictName)
			break
	}
	send,!s
	while True
	{
		IfExist,% retpath("screenshot") . PictName
			break
		sleep 300
	}
	PictPath := retpath("screenshot") . PictName
	FileMove,%PictPath%,%destination%,%Flag%
	return
}
NumToAlp(Num){
	if (26 < Num)
	{
		return "ERROR"
	}
	return Chr(Num + 96)
}
RetCorBracket(Str,Index=1,Offset=0, Target="()"){
	Target_B := SubStr(Target, 1, 1)
	Target_E := SubStr(Target, 2, 1)
	StringGetPos,BSP,Str,%Target_B%,L%Index%,%Offset%
	SSP := BSP
	Index = 1
	while (True)
	{
		StringGetPos,BEP,Str,%Target_E%,,% SSP + 1
		StringGetPos,SSP,Str,%Target_B%,,% SSP + 1
		if (SSP < BEP and SSP != -1)
		{
			Index += 1
			continue
		}
		else if (BEP != -1)
		{
			Index -= 1
			SSP := BEP
			if (Index = 0)
			{
				return Object("S", BSP, "E", BEP)
			}
			continue
		}
		return
	}
}
RetCorBracketSplit(Str,Index=1,Offset=0, Target="()"){
	BP := RetCorBracket(Str, Index, Offset, Target)
	return Object(0, SubStr(Str,1,BP["S"]), 1, SubStr(Str,BP["S"] + 2, BP["E"] - BP["S"] - 1), 2, SubStr(Str,BP["E"] + 2,StrLen(Str)))
}
JoinStr(params*){
	for index,param in params
		str .= AlignDigit(A_Index, 3) . "  :  " . param . "`n"
	return SubStr(str, 1, -StrLen("`n"))
}
AlignDigit(Value, NoD){
	Loop,% NoD - StrLen(Value)
	{
		Value := "0" . Value
	}
	return Value
}
MsgJoin(Strs*){
	Msg := JoinStr(Strs*)
	Msgbox,% Msg
}
RetFuncArgument(Str,FuncName,Index=1,Offset=0){
	StringGetPos,FP,Str,%FuncName%,L%Index%,%Offset%
	AP := RetCorBracket(Str,Index,FP)
	if (FP + StrLen(FuncName) == AP["S"])
	{
		AV := RetCorBracketSplit(Str,Index,FP)
		return StrSplit(AV[1],"`,")
	}
	return
}
RetAoT(Str,Target,Length=1,Index=1,Offset=0){
	StringGetPos,TP,Str,%Target%,L%Index%,%Offset%
	FSP := TP - Length + 1
	LengthB := Length
	if ((TP + 1 < Length) or (Length == 0))
	{
		Length := TP
		LengthB := StrLen(Str)
	}
	return Object(0,SubStr(Str,TP - Length + 1,Length),1,SubStr(Str,TP + StrLen(Target) + 1,LengthB))
}
RetObjIndex(Value, Obj*){
	for K in Obj
	{
		if (K == Value)
			return A_Index
	}
	return "Error"
}
SearchPrime(Limit){
	Primes := Object()
	if (2 <= Limit)
		Primes[1] := 2
	if (3 <= Limit)
		Primes[2] := 3
	NN = 3
	IoP = 3
	while True
	{
		NN += 2
		if (Limit < NN)
			break
		for K, Prime in Primes
		{
			if ((NN ** 2 < Prime) or (Mod(NN,Prime) == 0))
			{
				NF = 1
				break
			}
		}
		if (NF)
		{
			NF = 0
			continue
		}
		Primes[IoP] := NN
		IoP += 1
	}
	return Primes
}
RetGCF(K, L){
	if (K < L)
	{
		Swap := K
		K := L
		L := Swap
	}
	if (K - L == 0)
	{
		return K
	}
	else
	{
		return RetGCF(K - L, L)
	}
	return
}
RetLCM(K, L){
	G := RetGCF(K, L)
	SetFormat,Float,0.0
	G := K * L / G
	SetFormat,Float,0.5
	return G
}
FillStr(Str, NoD, Char, RL="L"){
	if (RL == "L")
	{
		Loop,% NoD - StrLen(Str)
			Str := Char . Str
	}
	else (RL == "R")
	{
		Loop,% NoD - StrLen(Str)
			Str := Str . Char
	}
	return Str
}
Hex2Dec(Value, NoD=0){
	K := Object(0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, "A", 10, "B", 11, "C", 12, "D", 13, "E", 14, "F", 15)
	L := 0
	Loop,Parse,Value
	{
		RMN := StrLen(Value) - A_Index
		L +=  K[A_LoopField] * 16 ** RMN
	}
	return FillStr(L, NoD, 0)
}
Dec2Hex(Value, NoD=0){
	K := Object(0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, "A", 11, "B", 12, "C", 13, "D", 14, "E", 15, "F")
	if (Value != 0)
		return FillStr(Dec2Hex(Value // 16, NoC) . K[mod(Value, 16)], NoD, 0)
	return
}
MsgVars(VarList){
	Str := ""
	Loop,Parse,VarList,`,
	{
		Str .= A_Index . " : " . A_LoopField . " > " . %A_LoopField% . "`n"
	}
	msgbox,%Str%
	return
}
CmdRun(Command,msg=1, auth="normal"){
	K := ClipboardAll
	Clipboard := ""
	if (auth = "normal")
		auth := ""
	else if (auth = "admin")
		auth := "*RunAs "
	runwait,% auth . comspec . " /c " . Command . " 2>&1 | clip & exit",,Hide
	Clipwait,5
	if (ErrorLevel and msg)
		msgbox,Error
	else if (not(ErrorLevel)){
		L := Clipboard
		Clipboard := K
		return L
	}
	return
}
RetMousePos(){
	MouseGetPos,X,Y
	return Object("X", X, "Y", Y)
}
RetPointsDist(X1, Y1, X2, Y2){
	return ((X1 - X2) ** 2 + (Y1 - Y2) ** 2) ** (1 / 2)
}
RetKeyState(KeyName,Mode="P"){
	GetKeyState,K,%KeyName%,%Mode%
	return K == "D" ? 1 : 0
}
atan2(X1, Y1, X2, Y2){
	if (X1 == X2)
	{
		if (Y1 < Y2)
			K := Pi / 2
		else if (Y2 < Y1)
			K := 3 * Pi / 2
		else
			K := 0
	}
	else
	{
		K := ATan((Y2 - Y1) / (X2 - X1))
		if (X2 < X1)
		{
			K += Pi
		}
		else if (Y2 < Y1)
		{
			K += 2 * Pi
		}
	}
	return K
}
IniReadFunc(FileName, Section="", Key="", ComputerName=""){
	if (ComputerName == "" and Key != "")
		ComputerName := A_ComputerName
	IniRead,K,%FileName%,%Section%,% ComputerName . Key
	if (K == "ERROR")
		IniRead,K,%FileName%,%Section%,default%Key%
	if (K == "ERROR")
		IniRead,K,%FileName%,%Section%,%Key%
	return K
}
IniCheckAndRead(ByRef OutputVar, FileName, Section="", Key="", ComputerName="", ByRef LastUpdate=""){
	FileGetTime,LastUpdateA,%FileName%,M
	msgjoin(LastUpdate, LastUpdateA)
	if (LastUpdate == "" or LastUpdate != LastUpdateA)
	{
		OutputVar := IniReadFunc(FileName, Section, Key, ComputerName)
		LastUpdate := LastUpdateA
		msgbox,A
	}
	return
}
ToolSplash(Text=""){
	if (Text == ""){
		SplashImage,Off
		return
	}
	MouseGetPos,X,Y
	WinGetPos,WX,WY,,,a
	X += WX
	Y += WY
	SplashImage,,B FM10 X%X% Y%Y%,,%Text%
	return
}
JoinObj(Obj, Depth=0){
	if not(IsObject(Obj))
		return Obj
	for Key, Value in Obj{
		IoI := A_Index
		Loop,% Depth{
			if (IoI == 1)
				continue
			Str .= "     "
		}
		Str .= Key . " : " . JoinObj(Value, Depth + 1) . "`n"
	}
	return Str
}
RetAllMatch(Target, Pattern){
	AllMatch := Object()
	Pos := 0
	while (True){
		CurMatch := Object()
		Pos := RegExMatch(Target, Pattern, Match)
		if (Pos == 0)
			break
		while (True){
			if (Match%A_Index% == "")
				break
			CurMatch[A_Index] := Match%A_Index%
		}
		AllMatch[A_index] := CurMatch
		Target := RegExReplace(Target, ".*?" . Pattern,"" , , 1)
	}
	return AllMatch
}
KeyDown(Key, Second){
	send,{%Key% down}
	CalledTime := A_TickCount
	EscFlag := False
	while (True){
		if ((Second * 1000) < (A_TickCount - CalledTime) or RetKeyState("Esc"))
			break
		sleep 1000
	}
	send,{%Key% up}
	return
}
RetNCKey(Obj, Key){
	if (Obj[Key] == "")
		return Key
	while (True){
		if (Obj[Key . A_Index] == "")
			return Key . A_Index
	}
}
RetMaxDepth(Obj, Depth=1){
	MaxDepth := Depth
	for Key, Value in Obj{
		if (IsObject(Value)){
			K := RetMaxDepth(Value, Depth + 1)
			if MaxDepth < K
				MaxDepth := K
		}
	}
	return MaxDepth
}
SolveObj(Obj){
	msgbox,% JoinObj(Obj)
	if (IsObject(Obj))
		return Obj
	RObj := Object()
	for Key, Value in Obj{
			RObj[RetNCKey(RObj, Key)] := Value
	}
	return SolveObj(RObj)
}
JudgePath(Path){
	return RegExMatch(Path, "^([a-zA-Z]:\\([^\\/:?*""<>|]+\\)*)([^\\/:?*""<>|]+)?$")
}
SolvePath(Path){
	RegExMatch(Path, "([a-zA-Z]:\\([^\\/:?*""<>|]+\\)*)([^\\/:?*""<>|]+)?", APath)
	K := Object()
	K["Path"] := APath1
	K["Name"] := APath3
	return K
}
RapidButton(Button){
	while (not RetKeyState("Esc"))
		send, %Button%
}
RetCopy(param="Value"){
	Clip := ClipboardAll
	Clipboard := ""
	send,^c
	ClipWait
	if (param = "Text")
		Clipboard := Clipboard
	Var := Clipboard
	Clipboard := Clip
	return Var
}
GetCurrentDirectory(){
	WinGetTitle, CDPath, A
	if (JudgePath(CDPath) == 0){
		return "Error"
	}
	return CDPath
}
JudgeDir(Path){
	return (InStr(FileExist(Path), "D") != 0)
}
PythonRun(Path, msg=1, auth="normal", args*){
	command := "python " . Path . " "
	for arg in args
	{
		command .= arg . " "
	}
	return CmdRun(command, msg, auth)
}
Follow_a_Link(Path){
	While (RegExMatch(Path, "\.lnk$") != 0){
		FileGetShortcut, %Path%, FilePath
		Path := FilePath
	}
	return Path
}
DeepCopy(Array, Objs=0){
	if !Objs
		Objs := Object()
	Obj := Array.Clone()
	Objs[&Array] := Obj
	For Key, Value in Obj{
		if (IsObject(Value))
			Obj[Key] := Objs[&Value] ? Objs[&Value] : DeepCopy(Value, Objs)
	}
	return Obj
}
msgobj(obj){
	msgjoin(joinobj(obj))
	return
}
class FD{
	__New(FilePath){
		this.FilePath := FilePath
		this.Read()
		FileGetTime, LU, % this.FilePath, M
		this.LastUpdate := LU
	}
	ConvertFlaxDict_to_Text(Dict, Depth=0){
		if not(IsObject(Dict))
			return Dict
		for Key, Value in Dict{
			IoI := A_Index
			Loop,% Depth{
				Str .= "`t"
			}
			Str .= Key . "=" . this.ConvertFlaxDict_to_Text(Value, Depth + 1) . "`n"
		}
		Str := "[`n" . Str
		Loop,% Depth - 1{
			Str .= "`t"
		}
		Str .= "]"
		if (Depth == 0){
			StringTrimLeft, Str, Str, 2
			StringTrimRight, Str, Str, 1
		}
		return Str
	}
	ConvertText_to_FlaxDict(Text){
		if (InStr(Text, "=") == 0)
			return Text
		Data := Object()
		while (True){
			if (InStr(Text, "=") == 0)
				break
			TData := RetAoT(Text, "=", 0)
			name := RegExReplace(TData[0], "\s")
			body := TData[1]
			if (SubStr(body, 1, 1) == "["){
				TData := RetCorBracketSplit(body, 1, 0, "[]")
				Data[name] := this.ConvertText_to_FlaxDict(TData[1])
				Text := TData[2]
			}else{
				TData := RetAoT(body, "`n", 0)
				if (TData[1] == body){
					Data[name] := body
					break
				}
				K := TData[0]
				Data[name] := K
				Text := TData[1]
			}
		}
		return Data
	}
	read(FilePath=""){
		FileGetTime, LU, % this.FilePath, M
		if (LU == this.LastUpdate)
			return
		this.LastUpdate := LU
		if (FilePath == "")
			FilePath := this.FilePath
		FileRead, TData, %FilePath%
		this.dict := this.ConvertText_to_FlaxDict(TData)
		return
	}
	write(FilePath="", dict=""){
		if (FilePath == "")
			FilePath := this.FilePath
		msgjoin(joinobj(dict))
		if (dict == "")
			dict := this.dict
		msgjoin(joinobj(dict))
		TData := this.ConvertFlaxDict_to_Text(dict)
		file := FileOpen(this.FilePath, "w", "CP65001")
		file.Write(TData)
	}
}
class FD_for_EC extends FD{
	__New(FilePath){
		base.__New(FilePath)
		this.fdict := DeepCopy(this.dict)
		this.normalization()
	}
	getItemDict(ItemName){
		RD := Object()
		FID := this.dict[ItemName]
		for Key, Value in FID["default"]{
			RD[Key] := Value
		}
		for Key, Value in FID[A_ComputerName]{
			RD[Key] := Value
		}
		return RD
	}
	normalization(){
		for Key, Value in this.dict{
			ID := this.getItemDict(Key)
			this.dict[Key] := ID
		}
	}
	write(FilePath="", dict=""){
		if (dict == "")
			dict := this.fdict
		base.write(FilePath, dict)
	}
}


;hotstring
;ホットストリング
::flaxtest::
	sleep 300
	launcherFD.fdict["testname"] := Object()
	launcherFD.fdict["testname"]["default"] := Object()
	launcherFD.fdict["testname"]["default"]["command"] := "testcommand"
	launcherFD.fdict["testname"]["default"]["type"] := "testtype"
	msgjoin(joinobj(launcherFD.fdict["editlauncher"]))
	launcherFD.write()
	return
::flaxcalc::
	Sleep 100
	;Gui,Destroy
	Gui, New, , FlaxCalc
	SysGet,MonitorSizeX,0
	SysGet,MonitorSizeY,1
	Gui, FlaxCalc:Add,Edit,vFormula W300
	Gui, FlaxCalc:+AlwaysOnTop -Border
	Gui, FlaxCalc:Show,Hide
	Gui, FlaxCalc:+LastFound
	WinGetPos,,,w,h
	Gui, FlaxCalc:Add,Button,Default Hidden,OK
	w := MonitorSizeX - marg - w
	h := MonitorSizeY - marg - h
	Gui, FlaxCalc:Show,X%w% Y%h%
	Return
	ButtonOK:
		Gui, FlaxCalc:Submit
		Formula := EvalForm(Formula)
		Send,%Formula%
		Gui, FlaxCalc:Destroy
		Return
	FlaxCalcGuiClose:
	FlaxCalcGuiEscape:
		Gui, FlaxCalc:Destroy
		return
::flaxrapidlb::
	flaxrapidlbState = 0
	while 1
	{
		Send,{LButton}
		if flaxrapidlbState
		{
			Break
		}
		sleep 100
	}
	return
::flaxwindowsetgame::
	X := A_ScreenWidth - 1280
	WinMove,A,,X,0,1280,720
	return
::flaxwindowsetmovie::
	W := A_ScreenWidth - 1280
	H := A_ScreenHeight - 720
	Y := 720
	WinMove,A,,0,Y,W,H
	return
::flaxwindowalwaysontop::
	WinSet,AlwaysOnTop,Toggle,A
	return
::flaxwindowdisable::
	WinSet,Disable,,A
	return
::flaxwindowenable::
	WinSet,Enable,,A
	return
::flaxwindowmoviemode::
	if (flaxmoviemode = "False")
	{
		W := A_ScreenWidth - 1280
		H := A_ScreenHeight - 720
		Y := 720
		WinMove,A,,0,Y,W,H
		WinSet,AlwaysOnTop,Toggle,A
		WinSet,Style,-0x00400000,A
		WinGet,flaxmoviemode,ID,A
	}
	else
	{
		WinRestore,ahk_id %ID%
		WinSet,AlwaysOnTop,Toggle,A
		WinSet,Style,+0x00400000,A
		flaxmoviemode = False
	}
	return
::flaxtime::
	FormatTime,NowTime,,HH:mm
	send,% NowTime
	return
::flaxdate::
	FormatTime,Today,,yyyy/MM/dd
	send,% Today
	return
::flaxday::
	FormatTime,Day,,ddd
	send,% Day
	return
~Esc::
	flaxrapidlbState = 1
	return
::flaxsuspend::
	Suspend,On
	Suspend,Off
	return
::flaxspy::
	sleep 100
	Run,.\AU3_Spy.exe
	return
::flaxgetprocessname::
	sleep 100
	WinGet,AWPN,ProcessName,A
	clipboard = %AWPN%
	ToolTip,% AWPN
	sleep 1000
	ToolTip,
	return
::flaxmonitoroff::
	sleep 100
	run,open "C:\Windows\System32\scrnsave.scr"
	return
::flaxreload::
	sleep 100
	Reload
	Return
::flaxexit::
	sleep 100
	ExitApp
	Return
::flaxeditscript::
	sleep 100
	Edit
	Return
::flaxkeyhistory::
	sleep 100
	KeyHistory
	Return
::flaxlisthotkeys::
	sleep 100
	ListHotkeys
	return
::flaxlistlines::
	sleep 100
	listlines
	return
::flaxlistvars::
	sleep 100
	listvars
	return
::flaxmodevim::
	flaxmode = vim
	return
::flaxmodenormal::
	flaxmode = normal
	return
::flaxcopymodefifo::
	copymode = FIFO
	Clipboard =
	return
::flaxcopymodenormal::
	copymode = normal
	return
::flaxeditmode::
	input,editmode,I *,{Enter},
	return
::flaxmakecodegui::
	sleep 100
	Gui, New, , FlaxCode_Maker
	Gui, FlaxCode_Make:Font,,Meiryo UI
	Gui, FlaxCode_Make:Margin,10,10
	Gui, FlaxCode_Make: -Border +ToolWindow
	Gui, FlaxCode_Make:Add,Text,,&Clear Text
	Gui, FlaxCode_Make:Add,Edit,W500 Multi Password* vCText
	Gui, FlaxCode_Make:Add,Text,,&Seed
	Gui, FlaxCode_Make:Add,Edit,W500 Password* vSeed
	Gui, FlaxCode_Make:Add,Checkbox,Checked1 vUC,&Uppercase
	Gui, FlaxCode_Make:Add,Checkbox,Checked1 vLC,&Lowercase
	Gui, FlaxCode_Make:Add,Checkbox,Checked1 vNC,&Number
	Gui, FlaxCode_Make:Add,Checkbox,Checked0 vJC,&Japanese
	Gui, FlaxCode_Make:Add,Checkbox,Checked0 vAC, &All
	Gui, FlaxCode_Make:Add,Text,,&Others
	Gui, FlaxCode_Make:Add,Edit,W250 vOthers
	Gui, FlaxCode_Make:Add,Button,Default gMakeCodeGuiOK,OK
	Gui, FlaxCode_Make:-Resize
	Gui, FlaxCode_Make:Show,Autosize,flaxCode_Maker
	; WinWaitNotActive,flaxCode_Maker
	; Gui, FlaxCode_Make:Destroy
	return
	FlaxCode_MakeGuiClose:
	FlaxCode_MakeGuiEscape:
		Gui, FlaxCode_Make:Destroy
		return
	MakeCodeGuiOK:
		Gui, FlaxCode_Make:Submit
		Gui, FlaxCode_Make:Destroy
		Usable =
		UpperCase = ABCDEFGHIJKLMNOPQRSTUVWXYZ
		LowerCase = abcdefghijklmnopqrstuvwxyz
		NumberChar = 0123456789
		FileRead,JapaneseChar,JapaneseChars.txt
		Loop,Parse,CText
		{
			IfInString,UpperCase,%A_LoopField%
			{
				UC := 1
			}
			IfInString,LowerCase,%A_LoopField%
			{
				LC := 1
			}
			IfInString,NumberChar,%A_LoopField%
			{
				NC := 1
			}
			;K := UpperCase . LowerCase . NumberChar . Others . JapaneseChar
			;IfNotInString,K,%A_LoopField%
			;{
			;	Usable := Usable . A_LoopField
			;}
		}
		if (UC = 1)
		{
			Usable := Usable . UpperCase
		}
		if (LC = 1)
		{
			Usable := Usable . LowerCase
		}
		if (NC = 1)
		{
			Usable := Usable . NumberChar
		}
		if (JC = 1)
		{
			Usable := Usable . JapaneseChar
		}
		if (AC = 1)
		{
			Usable := Usable . """`#!$`%&()=~|-^[@]:/.,{``}*+_?><,\;"
		}
		Usable := Usable . Others
		Usable := RegExReplace(Usable,".","$0`n")
		sort,Usable,C U
		Usable := RegExReplace(Usable,"`n","")
		if (AC = 1)
		{
			Usable := Usable . "`　` `n`t"
		}
		if (Seed = "")
		{
			Seed := CText
		}
		Crypt := MakeCodeFunc(Usable, CText, Seed)
		SendRaw,%Crypt%
		return
::flaxmakecode::
	sleep 100
	RetShuffleList(StrList,Seed)
	{
		StrListLen := StrLen(StrList)
		Random,,%Seed%
		Loop,%StrListLen%
		{
			Random,Rand,0,% StrLen(StrList) - 1
			ShuffleList := ShuffleList . SubStr(StrList,Rand + 1,1)
			StringLeft,StrListL,StrList,%Rand%
			StringRight,StrListR,StrList,% StrLen(StrList) - Rand - 1
			StrList := % StrListL . StrListR
		}
		return,ShuffleList
	}
	RetRand(Min="",Max="")
	{
		Random,Rand,%Min%,%Max%
		return,Rand
	}
	ThroughRot(RotF,RotB,Char,Offset)
	{
		Pos := InStr(RotF,Char,true) + Offset
		Len := StrLen(RotF)
		if (Pos <= 0)
		{
			Pos += Len
		}
		else if (Len < Pos)
		{
			Pos -= Len
		}
		return,SubStr(RotB,Pos,1)
	}
	input,CText,I *,{Enter},
	Crypt =
	LClist = abcdefghijklmnopqrstuvwxyz
	UClist = ABCDEFGHIJKLMNOPQRSTUVWXYZ
	Nlist = 0123456789
	StrList := LClist . UClist . Nlist
	Seed := CText
	Crypt := MakeCodeFunc(StrList,CText,Seed)
	Send,%Crypt%
	return
	MakeCodeFunc(StrList,CText,Seed)
	{
		Len := StrLen(StrList)
		Random,,%Seed%
		Loop,Parse,Seed
		{
			Random,K
			K := K + Asc(A_LoopField) + Len
			Random,,%K%
		}
		Random,Seed
		plugF := RetShuffleList(StrList,Seed)
		Random,Seed
		plugB := RetShuffleList(StrList,Seed)
		Random,Seed
		rot1F := RetShuffleList(StrList,Seed)
		Random,Seed
		rot1B := RetShuffleList(StrList,Seed)
		Random,Seed
		rot2F := RetShuffleList(StrList,Seed)
		Random,Seed
		rot2B := RetShuffleList(StrList,Seed)
		Random,Seed
		rot3F := RetShuffleList(StrList,Seed)
		Random,Seed
		rot3B := RetShuffleList(StrList,Seed)
		Random,Seed
		RrotF := RetShuffleList(StrList,Seed)
		RrotB := RevStr(RrotF)
		Random,rot1Off,1,%Len%
		Random,rot2Off,1,%Len%
		Random,rot3Off,1,%Len%
		Loop,Parse,Ctext
		{
			Char := A_LoopField
			Char := ThroughRot(plugF,plugB,Char,0)
			Char := ThroughRot(rot1F,rot1B,Char,rot1Off)
			Char := ThroughRot(rot2F,rot2B,Char,rot2Off)
			Char := ThroughRot(rot3F,rot3B,Char,rot3Off)
			Char := ThroughRot(RrotF,RrotB,Char,0)
			Char := ThroughRot(rot3B,rot3F,Char,-rot3Off)
			Char := ThroughRot(rot2B,rot2F,Char,-rot2Off)
			Char := ThroughRot(rot1B,rot1F,Char,-rot1Off)
			Char := ThroughRot(plugB,plugF,Char,0)
			Crypt := Crypt . Char
			if (rot1Off = Len)
			{
				rot1Off = 1
				if (rot2Off = Len)
				{
					rot2Off = 1
					if (rot3Off = Len)
					{
						rot3Off = 1
					}
					else
					{
						rot3Off += 1
					}
				}
				else
				{
					rot2Off += 1
				}
			}
			else
			{
				rot1Off += 1
			}
		}
		return,Crypt
	}
::flaxsendclip::
	send,% clipboard
	return
::flaxrestartexplorer::
	Process,Close,explorer.exe
	while (ErrorLevel != 0)
	{
		sleep 100
		Process,Close,explorer.exe
	}
	run,explorer.exe
	return
::flaxalc::
	sleep 100
	run,https://alc.k.hosei.ac.jp/anet2/
	input,editmode,I * V,{Enter},
	sleep 500
	MouseMove,461,594
	while True
	{
		if (A_Cursor = "Unknown")
			break
		MouseMove,460,594
		MouseMove,461,594
		sleep 300
	}
	MouseClick,L,461,594
	sleep 500
	send, {Tab 15}
	sleep 500
	send, {Enter}
	sleep 500
	send,^w
	send,^w
	run,https://alc.k.hosei.ac.jp/anet2/course/spw/spw_ov/spwEntry.aspx
	return
::flaxregalias::
	Input,seed,I,{Enter}
	K := Clipboard
	if (seed = "")
	{
		runwait,%comspec% /c regalias | clip,,Hide
		StringLen,Len,Clipboard
		StringLeft,Clipboard,Clipboard,% Len - 2
	}
	else
	{
		runwait,%comspec% /c regalias %seed% | clip,,Hide
		StringGetPos,Pos,Clipboard,%A_Space%
		StringLeft,Clipboard,Clipboard,%Pos%
	}
	send,%clipboard%
	Clipboard := K
	return
::flaxproofreadingratwiki::
	sleep 200
	PreProofreadingRule =
	(
\[(.*?)\]:::flaxdelimiter:::\begin{flaxconstant}[$1]\end{flaxconstant}
\{\{pre(.*?)\}\}:::flaxdelimiter:::\begin{flaxconstant}{{pre$1}}\end{flaxconstant}
\"\"([^\n]*)\n:::flaxdelimiter:::\begin{flaxconstant}""$1\n\end{flaxconstant}
)
	ProofreadingRule =
	(
。\n:::flaxdelimiter:::\n
([^\s\t\n\[\(\{\<。、])([\[\(\{\<]):::flaxdelimiter:::$1 $2
([\]\)\}\>])([^\s\t\n\]\)\}\>。、]):::flaxdelimiter:::$1 $2
\n(([!\*])\2*+)([^\s\2]):::flaxdelimiter:::\n$1 $3
\!+ ([^\n]*?)\n[\n\t\s]*[\*\!]:::flaxdelimiter::::::flaxerror:::
!!! [^\n]*?(\n[^!\n][^\n]*?|\n)*?(\n\![^\!]):::flaxdelimiter:::$2:::flaxerror:::
[^\*]\* [^\n]*?(\n[^*\n][^\n]*?|\n)*?(\n\*\*\*):::flaxdelimiter::::::flaxerror:::
!+ ([^\n]*?)(\n[^!\*\n][^\n]*?|\n)*?(\n\*\*\*?):::flaxdelimiter::::::flaxerror:::
:::flaxerror::::::flaxdelimiter:::\n\n\n\n\n\n\n\n\n\n\n\n\n\nERROR\nERROR\nERROR\nERROR\nERROR\nERROR\nERROR\nERROR\nERROR\nERROR\nERROR\nERROR\nERROR\nERROR\nERROR\nERROR\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
)
	Gui, New, , FlaxProofreadintRatWiki
	Gui, FlaxProofreadintRatWiki:Font,,Meiryo UI
	Gui, FlaxProofreadintRatWiki:Margin,10,10
	Gui, FlaxProofreadintRatWiki:Add,Edit,W500 R20 Multi vBText
	Gui, FlaxProofreadintRatWiki:Add,Edit,W500 R20 ys+0 Multi vAText
	Gui, FlaxProofreadintRatWiki:Add,Button,Default gproofreadingratwikiOK,&Encode
	Gui, FlaxProofreadintRatWiki:-Resize
	Gui, FlaxProofreadintRatWiki:Show,Autosize,ProofreadingRatWiki
	return
	proofreadingratwikiOK:
		Gui, FlaxProofreadintRatWiki:Submit,NoHide
		BText := proofreadingratwikireg(BText,PreProofreadingRule)
		BText := proofreadingratwikireg(BText,ProofreadingRule)
		GuiControl,Text,AText,%BText%
		return
::flaxcsvmaker::
	sleep 200
	RetCellHwnd(R,C)
	{
		Lab := NumToAlp(R+1)NumToAlp(C+1)"hwnd"
		Lab = % %Lab%
		return Lab
	}
	XAV = 135
	YAV = 23
	LastRP = 0
	LastCP = 0
	Gui, New, , FlaxCSVMaker
	Gui, FlaxCSVMaker:Font,,Meiryo UI
	Gui, FlaxCSVMaker:Margin,0,0
	Gui, FlaxCSVMaker:Add,Edit, vaa Hwndaahwnd
	Gui, FlaxCSVMaker:Add,Button,Default gcsvmakerOK Hidden,&Make
	Gui, FlaxCSVMaker:-Resize
	Gui, FlaxCSVMaker:Show,Autosize X50 Y50,CSVMaker
	return
	FlaxCSVMakerGuiClose:
	FlaxCSVMakerGuiEscape:
		Gui, FlaxCSVMaker:Destroy
		return
	csvmakerOK:
		Gui, FlaxCSVMaker:Submit,NoHide
		CSVtext =
		Loop,% LastRP / YAV + 1
		{
			R := A_Index
			Loop,% LastCP / XAV + 1
			{
				Lab := NumToAlp(R)NumToAlp(A_Index)
				Lab = % %Lab%
				CSVText := CSVText . "," . Lab
			}
			CSVText := CSVText . "`n"
		}
		Clipboard := CSVText
		Clipboard := RegExReplace(Clipboard,"\n,|^,", "`n")
		return
#IfWinActive,CSVMaker
	^Right::
	ExpandC:
		ControlGetFocus,ACPNN
		GuiControlGet,ACP,FlaxCSVMaker:Pos,%ACPNN%
		if (ACPX = LastCP)
		{
			LastCP := LastCP + XAV
			Loop,% (LastRP + YAV) / YAV
			{
				ypos := (A_Index - 1) * YAV
				Lab := Chr(A_Index + 96)Chr(LastCP / XAV + 97)
				Try
					Gui, FlaxCSVMaker:Add,Edit,x%LastCP% y%ypos% v%Lab% Hwnd%Lab%hwnd
				GuiControl,FlaxCSVMaker:Show,%Lab%
				GuiControl,FlaxCSVMaker:Enable,%Lab%
			}
		}
		Gui, FlaxCSVMaker:Show,Autosize,CSVMaker
		Lab := Chr((ACPY + YAV) / YAV + 96)Chr((ACPX + YAV) / XAV + 98)"hwnd"
		Lab = % %Lab%
		ControlFocus,,ahk_id %Lab%
		return
	^Down::
	ExpandR:
		ControlGetFocus,ACPNN
		GuiControlGet,ACP, FlaxCSVMaker:Pos,%ACPNN%
		if (ACPY = LastRP)
		{
			LastRP := LastRP + YAV
			Loop,% (LastCP + XAV) / XAV
			{
				xpos := (A_Index - 1) * XAV
				Lab := Chr(LastRP / YAV + 97)Chr(A_Index + 96)
				Try
					Gui, FlaxCSVMaker:Add,Edit,x%xpos% y%LastRP% v%Lab% Hwnd%Lab%hwnd
				GuiControl, FlaxCSVMaker:Show,%Lab%
				GuiControl, FlaxCSVMaker:Enable,%Lab%
			}
		}
		Gui, FlaxCSVMaker:Show,Autosize,CSVMaker
		Lab := Chr((ACPY + YAV) / YAV + 97)Chr((ACPX + XAV) / XAV + 96)"hwnd"
		Lab = % %Lab%
		ControlFocus,,ahk_id %Lab%
		return
	^Left::
		Gui, FlaxCSVMaker:Submit,NoHide
		ControlGetFocus,ACPNN
		GuiControlGet,ACP, FlaxCSVMaker:Pos,%ACPNN%
		if (ACPX = 0)
			return
		EmpFlag = 1
		Lab := RetCellHwnd(ACPY / YAV,ACPX / XAV - 1)
		ControlFocus,,ahk_id %Lab%
		if (ACPX = LastCP)
		{
			Loop,% (LastRP + YAV) / YAV
			{
				Lab := NumToAlp(A_Index)NumToAlp(LastCP / XAV + 1)
				Lab = % %Lab%
				if (Lab != "")
				{
					EmpFlag = 0
					break
				}
			}
			if (EmpFlag)
			{
				Loop,% (LastRP + YAV) / YAV
				{
					Lab := NumToAlp(A_Index)NumToAlp(LastCP / XAV + 1)
					GuiControl, FlaxCSVMaker:Hide,%Lab%
					GuiControl, FlaxCSVMaker:Disable,%Lab%
				}
				LastCP := LastCP - XAV
				Gui, FlaxCSVMaker:Show,Autosize,CSVMaker
			}
		}
		return
	^Up::
		Gui, FlaxCSVMaker:Submit,NoHide
		ControlGetFocus,ACPNN
		GuiControlGet,ACP, FlaxCSVMaker:Pos,%ACPNN%
		if (ACPY = 0)
			return
		EmpFlag = 1
		Lab := RetCellHwnd(ACPY / YAV - 1,ACPX / XAV)
		ControlFocus,,ahk_id %Lab%
		if (ACPY = LastRP)
		{
			Loop,% (LastCP + XAV) / XAV
			{
				Lab := NumToAlp(LastRP / YAV + 1)NumToAlp(A_Index)
				Lab = % %Lab%
				if (Lab != "")
				{
					EmpFlag = 0
					break
				}
			}
			if (EmpFlag)
			{
				Loop,% (LastCP + XAV) / XAV
				{
					Lab := NumToAlp(LastRP / YAV + 1)NumToAlp(A_Index)
					GuiControl, FlaxCSVMaker:Hide,%Lab%
					GuiControl, FlaxCSVMaker:Disable,%Lab%
				}
				LastRP := LastRP - YAV
				Gui, FlaxCSVMaker:Show,Autosize,CSVMaker
			}
		}
		return
	Tab::
		ControlGetFocus,ACPNN
		GuiControlGet,ACP, FlaxCSVMaker:Pos,%ACPNN%
		if (ACPX = LastCP)
		{
			ACPX := -XAV
			if (ACPY = LastRP)
				ACPY := 0
			else
				ACPY := ACPY + YAV
		}
		ACH := RetCellHwnd(ACPY / YAV,ACPX / XAV + 1)
		ControlFocus,,ahk_id %ACH%
		return
	Enter::
		ControlGetFocus,ACPNN
		GuiControlGet,ACP, FlaxCSVMaker:Pos,%ACPNN%
		if (ACPY = LastRP)
		{
			ACPY := -YAV
			if (ACPX = LastCP)
				ACPX = 0
			else
				ACPX := ACPX + XAV
		}
		ACH := RetCellHwnd(ACPY / YAV + 1,ACPX / XAV)
		ControlFocus,,ahk_id %ACH%
		return
	+Tab::
		ControlGetFocus,ACPNN
		GuiControlGet,ACP, FlaxCSVMaker:Pos,%ACPNN%
		if (ACPX = 0)
		{
			ACPX := LastCP + XAV
			if (ACPY = 0)
				ACPY := LastRP
			else
				ACPY := ACPY - YAV
		}
		ACH := RetCellHwnd(ACPY / YAV, ACPX / XAV - 1)
		ControlFocus,,ahk_id %ACH%
		return
	+Enter::
		ControlGetFocus,ACPNN
		GuiControlGet,ACP, FlaxCSVMaker:Pos,%ACPNN%
		if (ACPY = 0)
		{
			ACPY := LastRP + YAV
			if (ACPX = 0)
				ACPX := LastCP
			else
				ACPX := ACPX - XAV
		}
		ACH := RetCellHwnd(ACPY / YAV - 1,ACPX / XAV)
		ControlFocus,,ahk_id %ACH%
		return
	^Enter::
		GoSub,csvmakerOK
		return
	^+v::
		CSVText := clipboard
		Loop,Parse,CSVText,`n
		{
			R := A_Index
			if (LastRP / YAV + 1 < R)
				GoSub,ExpandR
			Loop,Parse,A_LoopField,`,
			{
				if (LastCP / XAV + 1 < A_Index)
					GoSub,ExpandC
				Lab := NumToAlp(R)NumToAlp(A_Index)
				GuiControl, FlaxCSVMaker:Text,%Lab%,%A_LoopField%
			}
		}
		return
#IfWinActive
::flaxcolorviewer::
	sleep 300
	Gui,New,,colorviewerC
	Gui,New,,colorviewerV
	gui,margin,0,0
	Gui, colorviewerV: -Border +ToolWindow
	Gui, colorviewerC:-Border +ToolWindow
	Gui, colorviewerV:Add,Slider,vRV gColorSliderMoved Vertical Invert Range0-255 Center Y0 X180 W40 H300 AltSubmit -BackGround
	Gui, colorviewerV:Add,Slider,vGV gColorSliderMoved Vertical Invert Range0-255 Center Y0 X220 W40 H300 AltSubmit -BackGround
	Gui, colorviewerV:Add,Slider,vBV gColorSliderMoved Vertical Invert Range0-255 Center Y0 X260 W40 H300 AltSubmit -BackGround
	Gui, colorviewerV:Add,Edit,vColorEdit gColorEdited X0 Y281 H18 W89
	Gui, colorviewerV:Add,Edit,vColorName X91 Y281 H18 W89
	Gui, colorviewerV:Add,Button,Default hidden1,ColorOK
	Gui, colorviewerC:+AlwaysOnTop
	Gui, colorviewerC:Color,%Clopboard%
	Gui, colorviewerC:Show,Y100 X102 H277 W177
	Gui, colorviewerV:Show,Y100 X100 H300 W300
	; WinWaitNotActive,colorviewerV
	; Gui, colorviewerV:Destroy
	; Gui, colorviewerC:Destroy
	return
	colorviewerCGuiEscape:
	colorviewerVGuiEscape:
	colorviewerCGuiClose:
	colorviewerVGuiClose:
		Gui, colorviewerC:Destroy
		Gui, colorviewerV:Destroy
		return
	ColorSliderMoved:
		gui, colorviewerV:submit,NoHide
		CV := Dec2Hex(RV * 16 ** 4 + GV * 16 ** 2 + BV, 6)
		GuiControl,colorviewerV:, ColorEdit,%CV%
	ColorEdited:
		gui, colorviewerV:submit,nohide
		if (RegExMatch(ColorEdit, "[\da-fA-F]{6}") = 1)
		{
			GuiControl, colorviewerV:,RV,% Hex2Dec(SubStr(ColorEdit,1,2))
			GuiControl, colorviewerV:,GV,% Hex2Dec(SubStr(ColorEdit,3,2))
			GuiControl, colorviewerV:,BV,% Hex2Dec(SubStr(ColorEdit,5,2))
			Gui, colorviewerC:Color,%ColorEdit%
			if (RegExMatch(ColorList,"\n([^,\n]*)," . ColorEdit,NearColorName) != 0)
				GuiControl, colorviewerV:,ColorName,%NearColorName%
		}
		return
	ButtonColorOK:
		Gui, colorviewerV:Submit
		Clipboard := ColorEdit
		return
::flaxpickcolor::
MouseGetPos,X,Y
	PixelGetColor,Col,%X%,%Y%,Slow RGB
	StringRight,Col,Col,6
	Clipboard := Col
	return
::flaxsendcompname::
	sleep 300
	send,%A_ComputerName%
	return
::flaxgetDfromurllist::
	Loop,Read,Z:\Ggame\漫画\未分類\URLlist.txt
	{
		GetDoujinAntena(A_LoopReadLine)
	}
	msgbox,完了
	return
::flaxcountstrlen::
	sleep 300
	msgbox,% StrLen(Clipboard)
	return
::flaxevallogic::
	Sleep 100
	Gui, New, , FlaxEvalLogic
	SysGet,MonitorSizeX,0
	SysGet,MonitorSizeY,1
	Gui, FlaxEvalLogic:Add,Edit,vFormula W300
	Gui, FlaxEvalLogic:+AlwaysOnTop -Border
	Gui, FlaxEvalLogic:Show,Hide
	Gui, FlaxEvalLogic:+LastFound
	WinGetPos,,,w,h
	Gui, FlaxEvalLogic:Add,Button,Default Hidden gevallogicOK,OK
	w := MonitorSizeX - marg - w
	h := MonitorSizeY - marg - h
	Gui, FlaxEvalLogic:Show,X%w% Y%h%
	Return
	FlaxEvalLogicGuiEscape:
	FlaxEvalLogicGuiClose:
		Gui, FlaxEvalLogic:Destroy
		return
	evallogicOK:
		Gui, FlaxEvalLogic:Submit
		Formula := EvalLogic(Formula)
		Send,%Formula%
		Gui, FlaxEvalLogic:Destroy
		Return
::flaxmaketruthtable::
	sleep 300
	Gui, New, , FlaxMakeTruthTable
	SysGet,MonitorSizeX,0
	SysGet,MonitorSizeY,1
	Gui, FlaxMakeTruthTable:Add,Edit,vFormula W300
	Gui, FlaxMakeTruthTable:+AlwaysOnTop -Border
	Gui, FlaxMakeTruthTable:Show,Hide
	Gui, FlaxMakeTruthTable:+LastFound
	WinGetPos,,,w,h
	Gui, FlaxMakeTruthTable:Add,Button,Default Hidden gmaketruthtableOK,OK
	w := MonitorSizeX - marg - w
	h := MonitorSizeY - marg - h
	Gui, FlaxMakeTruthTable:Show,X%w% Y%h%
	Return
	maketruthtableOK:
		Gui, FlaxMakeTruthTable:Submit
		Clipboard := ""
		Formula := StrSplit(Formula,"`,")
		Chrs := Object()
		While (A_Index < Formula.MaxIndex())
		{
			Chrs[A_Index] := Formula[A_Index]
			Clipboard := Clipboard . "`," . Chrs[A_Index]
		}
		Clipboard := Clipboard . "`n"
		Formula := Formula[Formula.MaxIndex()]
		Loop,% 2 ** Chrs.MaxIndex()
		{
			IoL := A_Index
			NFormula := Formula
			for Chr in Chrs
			{
				NFormula := RegExReplace(NFormula,"(?<!\w)" . Chrs[Chr] . "(?!\w)",Mod((IoL - 1) // 2 ** (A_Index - 1),2))
				Clipboard := Clipboard . "`," . Mod((IoL - 1) // 2 ** (A_Index - 1),2)
			}
			Clipboard := Clipboard . "`," . EvalLogic(NFormula) . "`n"
		}
		Clipboard := RegExReplace(Clipboard,"\n,|^,", "`n")
		Gui, FlaxMakeTruthTable:Destroy
		Return
::flaxscreensaver::
	Gui,Add,Button,vScreenButton
	Gui,Show,W1000 H500
	while true
	{
		sleep 1/60
		MouseGetPos,MouseX,MouseY
		GuiControl,Move,ScreenButton,X%MouseX% Y%MouseY%
	}
	return
::flaxfifo::
	IoFWP := 0
	IoFRP := 0
	copymode := copymode == "FIFO" ? "normal" : "FIFO"
	ToolTip,% "copymode : " . copymode
	sleep 1000
	ToolTip,
	return
::flaxcomputername::
	send,% A_ComputerName
	return
::flaxminesweeperauto::
	AF := "True"
::flaxminesweeper::
	sleep 400
	PythonRun("minesweeper.py", AF)
	AF := "False"
	return
::flaxvirtualfolder::
	sleep 300
	Gui, New, , FlaxVirtualFolder
	Gui, FlaxVirtualFolder:Font,,Meiryo UI
	Gui, FlaxVirtualFolder:+Resize
	Gui, FlaxVirtualFolder:Margin,10,10
	Gui, FlaxVirtualFolder:Add,ListView,VVirtualFolderListView GVirtualFolderListViewEdited AltSubmit W600 H300,Title|Path
	LV_ModifyCol(1,300)
	LV_ModifyCol(2,"AutoHdr")
	Gui, FlaxVirtualFolder:Add,DropDownList,VVirtualFolderDropDownList GVirtualFolderDropDownListChanged,Make Link||Rename
	Gui, FlaxVirtualFolder:Add,Text,VVirtualFolderDPathText yp+0 x+50 Section,Dist Path
	Gui, FlaxVirtualFolder:Add,Text,VVirtualFolderRuleText xs ys hidden, Rule
	Gui, FlaxVirtualFolder:Add,Edit,VVirtualFolderDPathEdit ys xs+80 W300
	Gui, FlaxVirtualFolder:Add,Edit,VVirtualFolderRuleEdit ys+0 xs+80 hidden W300
	Gui, FlaxVirtualFolder:Add,Button,GVirtualFolderConfirmPressed,&Confirm
	VirtualFolderFileList := ""
	Gui, FlaxVirtualFolder:Show,Autosize,VirtualFolder
	return
	VirtualFolderListViewEdited:
		if (A_GuiEvent == "K" and A_EventInfo == "46"){
			while (LV_GetNext() != 0){
				LV_Delete(LV_GetNext())
			}
		}
		return
	FlaxVirtualFolderGuiDropFiles:
	VirtualFolderDropFiles:
		Loop,Parse,A_GuiEvent,`n
		{
			if (InStr(VirtualFolderFileList, A_LoopField) == 0){
				VirtualFolderFileList .= A_LoopField . "`n"
				Path := SolvePath(Follow_a_Link(A_LoopField))
				LV_Add(, Path["Name"], Path["Path"])
			}
		}
		return
	FlaxVirtualFolderGuiSize:
	VirtualFolderSize:
		return
		w := A_GuiWidth - 20
		h := A_GuiHeight - 20
		GuiControl, FlaxVirtualFolder:Move,VirtualFolderListView,W%w% H%h%
		return
	VirtualFolderDropDownListChanged:
		Gui, FlaxVirtualFolder:Submit,NoHide
		If (VirtualFolderDropDownList == "Rename"){
			GuiControl, FlaxVirtualFolder:show,VirtualFolderRuleText
			GuiControl, FlaxVirtualFolder:show,VirtualFolderRuleEdit
			GuiControl, FlaxVirtualFolder:hide,VirtualFolderDPathText
			GuiControl, FlaxVirtualFolder:hide,VirtualFolderDPathEdit
		}else If (VirtualFolderDropDownList == "Make Link"){
			GuiControl, FlaxVirtualFolder:hide,VirtualFolderRuleText
			GuiControl, FlaxVirtualFolder:hide,VirtualFolderRuleEdit
			GuiControl, FlaxVirtualFolder:show,VirtualFolderDPathText
			GuiControl, FlaxVirtualFolder:show,VirtualFolderDPathEdit
		}
		return
	VirtualFolderConfirmPressed:
		Gui, FlaxVirtualFolder:Submit,NoHide
		If (VirtualFolderDropDownList == "Rename"){

		}else If (VirtualFolderDropDownList == "Make Link"){
			If (JudgePath(VirtualFolderDPathEdit) != 0){
				FileCreateDir, %VirtualFolderDPathEdit%
				Loop,% LV_GetCount()
				{
					LV_GetText(Name, A_Index, 1)
					LV_GetText(Path, A_Index, 2)
					Path .= Name
					DPath := VirtualFolderDPathEdit . "\" . Name . ".lnk"
					FileCreateShortcut,%Path%, %DPath%
				}
			}
		}
		msgbox,done
		return
	FlaxVirtualFolderGuiEscape:
	FlaxVirtualFolderGuiClose:
		Gui, FlaxVirtualFolder:Destroy
		return
::flaxconnectratwifi::
	msgjoin(CmdRun("netsh wlan connect name=RAT-WIRELESS-A", 0))
	return
::flaxtimetable::
	sleep 300
	TTCellWidth = 100
	TTCellHeight = 100
	Gui, New, , FlaxTimeTable
	Gui, FlaxTimeTable:Font, MeiryoUI
	Gui, FlaxTimeTable:Margin, 50, 50
	Gui, FlaxTimeTable:+AlwaysOnTop -Border
	x := marg
	y := marg
	Loop, Parse, TimeTable, `n
	{
		Text := ""
		Loop, Parse, A_LoopField, `,
		{
			Text .= "`n" . A_LoopField
		}
		Gui, FlaxTimeTable:Add, Text, w%TTCellWidth% h%TTCellHeight% x%x% y%y% Border Center gOpenClassFolder, %Text%
		if mod(A_Index, 6) == 0{
			x += TTCellWidth
			y := marg
		}else{
			y += TTCellHeight
		}
	}
	Gui, FlaxTimeTable:Show, , FlaxTimeTable
	WinWaitNotActive,FlaxTimeTable
	Gui, FlaxTimeTable:Destroy
	return
	OpenClassFolder:
		Loop, Parse, A_GuiControl, `n
		{
			if (A_Index == 2)
			{
				ClassName := A_LoopField
				break
			}
		}
		ClassPath := retpath("class") . ClassName
		Run, %ClassPath%
		return
	FlaxTimeTableGuiEscape:
	FlaxTimeTableGuiClose:
		Gui, FlaxTimeTable:Destroy
		return
::flaxhanoy::
	sleep 400
	CmdRun(retpath("python.exe") . " Hanoy.py ")
	return
::flaxtransparent::
	sleep 400
	if (flaxtransparent_k != 50){
		WinSet, Transparent, 50, A
		flaxtransparent_k := 50
	}else{
		flaxtransparent_k := 255
		WinSet, Transparent, OFF, A
	}
	return


;hotkey
;ホットキー
+!^W::
	Gui, New, , FlaxLauncher FlaxLauncher:
	launcherFD.read()
	Sleep 100
	NoDI = 5
	candidate := ""
	SysGet,MonitorSizeX,0
	SysGet,MonitorSizeY,1
	For Key, Value in launcherFD.dict{
		if (Value.command != "")
			candidate .= Key . "|"
		else
			continue
		if (NoDI < A_Index)
			break
	}
	Gui, FlaxLauncher:Add,ComboBox,vItemName W300 R5 Simple HwndLauncherComboHwnd, %candidate%
	Gui, FlaxLauncher:+AlwaysOnTop -Border
	Gui, FlaxLauncher:Show,Hide
	Gui, FlaxLauncher:+LastFound
	Gui, FlaxLauncher:+ToolWindow
	WinGetPos,,,w,h
	Gui, FlaxLauncher:Add,Button,Default Hidden gLauncherOK,OK
	w := MonitorSizeX - marg - w
	h := MonitorSizeY - marg - h
	Gui, FlaxLauncher:Show,X%w% Y%h% Hide,FlaxProgramLauncher
	Gui, FlaxLauncher:Add,Edit,vHiddenEdit gHiddenEdited
	GuiControl, FlaxLauncher:Focus,HiddenEdit
	Gui, FlaxLauncher:Show
	WinWaitNotActive,FlaxProgramLauncher
	Gui, FlaxLauncher:Destroy
	Return
	LauncherOK:
		GuiControl, FlaxLauncher:-AltSubmit,ItemName
		Gui, FlaxLauncher:Submit
		Gui, FlaxLauncher:Destroy
	LauncherUse:
		LF := False
		ItemParams := StrSplit(ItemName, " ")
		ItemName := ItemParams[1]
		LP := RegExMatch(ItemName, "_locale$")
		if (RegExMatch(ItemName, "[a-zA-Z]:\\([^\\/:?*""<>|]+\\)*([^\\/:?*""<>|]+)?")){
			Run, %ItemName%
			return
		}
		if (LP != 0){
			ItemName := SubStr(ItemName, 1, LP-1)
			LF := True
		}
		ID := launcherFD.dict[ItemName]
		ItemCommand := ID["command"]
		for Key, Value in ItemParams{
			if (A_Index == 1)
				continue
			ItemCommand := RegExReplace(ItemCommand, "\$P" . A_Index - 1 . "\$", Value)
		}
		ItemCommand := RegExReplace(ItemCommand, "\$P\d+\$", "")
		ItemType := ID["type"]
		if (ItemType = "Application"){
			ItemParam := ID["param"]
			if (ItemParam != "")
			{
				ItemCommand := ItemCommand . " " . ItemParam
			}
		}
		if (ItemType = "URL" or ItemType = "LocalPath" or ItemType = "Application"){
			if (LF and ItemType != "URL"){
				LP := RegExMatch(ItemCommand, "\\([^\\]*)$", ItemName)
				ItemCommand := SubStr(ItemCommand, 1, LP-1)
				Run, %ItemCommand%
				WinWaitActive, ahk_exe explorer.exe
				sendraw,% ItemName1
			}else{
				Run, %ItemCommand%
			}
		}
		if (ItemType = ""){
			msgbox,404
		}
		return
	HiddenEdited:
		Gui, FlaxLauncher:Submit,NoHide
		GuiControl, FlaxLauncher:Text,ItemName,%HiddenEdit%
		GuiControl, FlaxLauncher:+AltSubmit,ItemName
		Gui, FlaxLauncher:Submit,NoHide
		IoS := ItemName
		GuiControl, FlaxLauncher:-AltSubmit,ItemName
		if IoS is integer
			return
		Gui, FlaxLauncher:Submit,NoHide
		candidate := ""
		NoI = 0
		For Key, Value in launcherFD.dict{
			StringGetPos, IP, Key, %ItemName%
			if (IP == 0){
				candidate .= "|" . Key
				NoI += 1
			}
		}
		GuiControl, FlaxLauncher:,ItemName,%candidate%
		GuiControl, FlaxLauncher:Text,ItemName,%HiddenEdit%
		return
	FlaxLauncherGuiEscape:
	FlaxLauncherGuiClose:
		Gui, FlaxLauncher:Destroy
		return
#IfWinActive,FlaxProgramLauncher
	Tab::
	Down::
		GuiControl, FlaxLauncher:+AltSubmit,ItemName
		Gui, FlaxLauncher:Submit,NoHide
		GuiControl, FlaxLauncher:-AltSubmit,ItemName
		if (ItemName == NoI)
			return
		if ItemName is not integer
		{
			GuiControl, FlaxLauncher:Choose,ItemName,|1
			Gui, FlaxLauncher:Submit,NoHide
			GuiControl, FlaxLauncher:Text,HiddenEdit,%ItemName%
			send,{End}
			return
		}
		GuiControl, FlaxLauncher:Choose,ItemName,% "|"ItemName + 1
		Gui, FlaxLauncher:Submit,NoHide
		GuiControl, FlaxLauncher:Text,HiddenEdit,%ItemName%
		send,{End}
		Return
	+Tab::
	Up::
		GuiControl, FlaxLauncher:+AltSubmit,ItemName
		Gui, FlaxLauncher:Submit,NoHide
		GuiControl, FlaxLauncher:-AltSubmit,ItemName
		if (ItemName == 1)
			return
		if ItemName is not integer
		{
			GuiControl, FlaxLauncher:Choose,ItemName,|1
			Gui, FlaxLauncher:Submit,NoHide
			GuiControl, FlaxLauncher:Text,HiddenEdit,%ItemName%
			send,{End}
			return
		}
		GuiControl, FlaxLauncher:Choose,ItemName,% "|"ItemName - 1
		Gui, FlaxLauncher:Submit,NoHide
		GuiControl, FlaxLauncher:Text,HiddenEdit,%ItemName%
		send,{End}
		Return
#IfWinActive
~^Enter::
	K := IME_GetConvMode()
	IfWinActive,ahk_exe gvim.exe
		return
	IfWinActive,ahk_exe mattermost.exe
		return
	if (K <> 0)
	{
		Send,{End}
		sleep 100
		send,{Enter}
	}
	return
~^+Enter::
	K := IME_GetConvMode()
	if (K <> 0)
	{
		Send,{Home}
		sleep 100
		send,{Enter}
		send,{Up}
	}
	return
+Volume_Down::
	SoundGet,CVol
	CVol := CVol - 1
	SoundSet,%CVol%
	return
+Volume_Up::
	SoundGet,CVol
	CVol := CVol + 1
	SoundSet,%CVol%
	return
^Volume_Down::
	SoundGet,CVol
	CVol := CVol - 5
	SoundSet,%CVol%
	return
^Volume_Up::
	SoundGet,CVol
	CVol := CVol + 5
	SoundSet,%CVol%
	return
!+M::
^Volume_Mute::
	WinGetActiveTitle,ATitle
	Run,C:\Windows\System32\SndVol.exe,,Min,VolID
	WinWait,ahk_exe SndVol.exe
	ControlGet,TagCont,Hwnd,,%ATitle% のミュート,ahk_exe SndVol.exe
	ControlClick,,ahk_id %TagCont%,,LEFT,1,NA
	Process,Close,SndVol.exe
	return
^#c::
	ClipboardAlt := ClipboardAll
	Clipboard := ""
	ToolTip,^#c
	send,^c
	GoSub,RegisterInput
	return
^#x::
	ClipboardAlt := ClipboardAll
	ToolTip,^#x
	send,^x
	GoSub,RegisterInput
	Return
RegisterInput:
	Input,address,I,{Enter}
	ClipWait, 1
	Clipboard := RegExReplace(Clipboard, "\r\n", "\flaxnewline")
	if (address != ""){
		IniWrite,%Clipboard%,register.ini,General,%address%
	}
	ToolTip,
	Clipboard := ClipboardAlt
	return
^#v::
	ClipboardAlt := ClipboardAll
	Clipboard := ""
	ToolTip,^#v
	Input,address,I,{Enter}
	if (address != ""){
		IniRead,RegValue,register.ini,General,%address%,
		if (RegValue != "ERROR")
		{
			Clipboard := RegExReplace(RegValue, "\\flaxnewline", "`n")
			send,^v
		}
	}
	ToolTip,
	sleep 200
	Clipboard := ClipboardAlt
	return
+#Right::
	WinRestore, A
	WinMove, A, ,% A_ScreenWidth / 2, 0, % A_ScreenWidth / 2, % A_ScreenHeight
	return
+#Left::
	WinRestore, A
	WinMove, A, , 0, 0, % A_ScreenWidth / 2, % A_ScreenHeight
	return
+#Up::
	WinRestore, A
	WinGetActiveStats, Title, Width, Height, X, Y
	if ((Y == 0) and (Height == A_ScreenHeight / 2)){
		WinMaximize, A
	}else{
		WinMove, A, , %X%, 0, Width, % A_ScreenHeight / 2
	}
	return
+#Down::
	WinRestore, A
	WinGetActiveStats, Title, Width, Height, X, Y
	WinMove, A, , %X%, % A_ScreenHeight / 2, Width, % A_ScreenHeight / 2
	return
+#Space::
	Menu, WindowResizer, Add, 1280x720, Resize
	Menu, WindowResizer, Add, 1160x800, Resize
	Menu, WindowResizer, Add, 1920x1080, Resize
	Menu, WindowResizer, Show, %A_GuiX%, %A_GuiY%
	WinGetActiveStats, Title, Width, Height, X, Y
	return
	Resize:
		WinRestore, A
		Size := StrSplit(A_ThisMenuItem, "x")
		WinMove, A, , %X%, %Y%, % Size[1], % Size[2]
		return
+#m::
	MoveFlag := True
	WinGetActiveStats, Title, Width, Height, X, Y
	CoordMode, Mouse, Screen
	MouseMove, % X + Width / 2, % Y - 10
	while (MoveFlag){
		MouseGetPos, MX, MY
		WinMove, %Title%, , % MX - Width / 2, % MY - 10, %Width%, %Height%
		sleep 100
		tooltip, MoveMode
	}
	CoordMode, Mouse, Relativem
	tooltip,
	return
#If (MoveFlag)
	Right::
		MouseMove, 10, 0, , R
		return
	Left::
		MouseMove, -10, 0, , R
		return
	Up::
		MouseMove, 0, -10, , R
		return
	Down::
		MouseMove, 0, 10, , R
		return
	LButton::
	Esc::
	Enter::
		MoveFlag := False
		return
#If (True)
vk1Dsc07B & j::send,{down}
vk1Dsc07B & k::send,{up}
vk1Dsc07B & h::send,{left}
vk1Dsc07B & l::send,{right}
vk1Dsc07B & Space::send,{Enter}
vk1Dsc07B & 1::send,6
vk1Dsc07B & 2::send,7
vk1Dsc07B & 3::send,8
vk1Dsc07B & 4::send,9
vk1Dsc07B & 5::send,0

#^l::send,^#{Right}
#^h::send,^#{Left}
*#RButton::
	Prefix := "RB"
	Button := "RButton"
	GoSub,MouseGestureCheck
	return
*#LButton::
	Prefix := "LB"
	Button := "LButton"
	GoSub,MouseGestureCheck
	return
*#MButton::
	Prefix := "MB"
	Button := "MButton"
	GoSub,MouseGestureCheck
	return
MouseGestureCheck:
	MouseRoute := ""
	CommandCandidate := ""
	LastNEWS := ""
	Reg := Object("BNE", Chr(0x2197), "BNW", Chr(0x2196), "BSE", Chr(0x2198), "BSW", Chr(0x2199), "N", "↑", "E", "→", "W", "←", "S", "↓")
	if (RetKeyState("LCtrl"))
		Prefix .= "^"
	if (RetKeyState("LAlt"))
		Prefix .= "!"
	if (RetKeyState("LShift"))
		Prefix .= "+"
	IniRead,CommandList,MouseGesture.ini
	Loop,Parse,CommandList,`n
	{
		if (InStr(A_LoopField, Prefix . MouseRoute) == 1)
		{
			CommandTargetWindow := IniReadFunc("MouseGesture.ini", A_LoopField, "targetwindow")
			CommandLabel := IniReadFunc("MouseGesture.ini", A_LoopField, "label")
			if ((WinActive(CommandTargetWindow) != 0 or CommandTargetWindow == "ERROR") and CommandValue != "ERROR")
			{
				CandiName := SubStr(A_LoopField, StrLen(Prefix) + StrLen(MouseRoute) + 1, StrLen(A_LoopField))
				CandiValue := CandiName == "" ? "" : " : "
				CandiValue .= CommandLabel
				For, Pattern, Replacement in Reg
					CandiName := RegExReplace(CandiName, Pattern, Replacement)
				CommandCandidate .= CandiName . CandiValue . "`n"
			}
		}
	}
	CommandCandidate := CommandCandidate == "" ? "None" : CommandCandidate
	ToolTip,% CommandCandidate
	LineLength := 100
	NMP := RetMousePos()
	SMP := Object()
	SMP["X"] := NMP["X"]
	SMP["Y"] := NMP["Y"]
	NMP := Object()
	RetNEWS(Radian){ ;NS が画面の座標の関係で入れ替わっているので注意
		if (15/8 < Radian or Radian <= 1/8)
			return "E"
		if (1/8 < Radian and Radian <= 3/8)
			return "BSE"
		if (3/8 < Radian and Radian <= 5/8)
			return "S"
		if (5/8 < Radian and Radian <= 7/8)
			return "BSW"
		if (7/8 < Radian and Radian <= 9/8)
			return "W"
		if (9/8 < Radian and Radian <= 11/8)
			return "BNW"
		if (11/8 < Radian and Radian <= 13/8)
			return "N"
		if (13/8 < Radian and Radian <= 15/8)
			return "BNE"
		return
	}
	RetMPatan2(MP1, MP2){
		return atan2(MP1["X"], MP1["Y"], MP2["X"], MP2["Y"])
	}
	while (RetKeyState(Button) and RetKeyState("LWin"))
	{
		ILD := Mod(A_Index, 10)
		M9 := Mod(ILD + 1, 10)
		M5 := Mod(ILD + 5, 10)
		M4 := Mod(ILD + 6, 10)
		sleep 100
		NMP[ILD] := RetMousePos()
		if (LineLength <= RetPointsDist(NMP[ILD]["X"], NMP[ILD]["Y"], SMP["X"], SMP["Y"]))
		{
			MRA := atan2(SMP["X"], SMP["Y"], NMP[ILD]["X"], NMP[ILD]["Y"]) / Pi
			SMP["X"] := NMP[ILD]["X"]
			SMP["Y"] := NMP[ILD]["Y"]
			NowNEWS := RetNEWS(MRA)
			if (NowNEWS == LastNEWS)
			{
				continue
			}
			MouseRoute .= NowNEWS
			LastNEWS := NowNEWS
			CommandCandidate := ""
			Loop,Parse,CommandList,`n
			{
				if (InStr(A_LoopField, Prefix . MouseRoute) == 1)
				{
					CommandTargetWindow := IniReadFunc("MouseGesture.ini", A_LoopField, "targetwindow")
					CommandLabel := IniReadFunc("MouseGesture.ini", A_LoopField, "label")
					if ((WinActive(CommandTargetWindow) != 0 or CommandTargetWindow == "ERROR") and CommandValue != "ERROR")
					{
						CandiName := SubStr(A_LoopField, StrLen(Prefix) + StrLen(MouseRoute) + 1, StrLen(A_LoopField))
						CandiValue := CandiName == "" ? "" : " : "
						CandiValue .= CommandLabel
						For, Pattern, Replacement in Reg
							CandiName := RegExReplace(CandiName, Pattern, Replacement)
						CommandCandidate .= CandiName . CandiValue . "`n"
					}
				}
			}
			CommandCandidate := CommandCandidate == "" ? "None" : CommandCandidate
			ToolTip,%CommandCandidate%
		}
		MPatan95 := RetMPatan2(NMP[M9], NMP[M5])
		MPatan4I := RetMPatan2(NMP[M4], NMP[ILD])
		K := (Abs(RetMPatan2(NMP[M9], NMP[M5]) - RetMPatan2(NMP[M4], NMP[ILD])) / Pi)
		;ToolTip,% JoinStr(RetMPatan2(NMP[M9], NMP[M5]) / Pi, RetMPatan2(NMP[M4], NMP[ILD]) / Pi, NMP[M4]["X"], NMP[M4]["Y"], NMP[ILD]["X"], NMP[ILD]["Y"], M9, M5, M4, ILD)
		;ToolTip,% JoinStr(K, MPatan4I, Mpatan95)
		if ((MPatan4I == 0 or MPatan95 == 0))
			continue
		if ((0.4 < K and K < 1.6) or 2.4 < K)
		{
			SMP := RetMousePos()
		}
	}
	GestureName := Prefix . MouseRoute
	GestureType := IniReadFunc("MouseGesture.ini", GestureName, "type")
	ToolTip,
	if (GestureType != "ERROR")
		GestureCommand := IniReadFunc("MouseGesture.ini", GestureName, "command")
	if (GestureType == "label")
		GoSub,%GestureCommand%
	else if (GestureType == "LocalPath")
		Run,% GestureCommand
	else if (GestureType == "Application")
		Run,% GestureCommand
	else if (GestureType == "URL")
		Run,% GestureCommand
	else if (GestureType == "launcher")
	{
		ItemName := GestureCommand
		GoSub, LauncherUse
	}
	return
	ShiftToLeftDesktop:
		send,#^{Left}
		return
	ShiftToLeftDesktopWithActiveWindow:
		send,#^+h
		return
	ShiftToLeftDesktopOnlyActiveWindow:
		send,#+h
		return
	ShiftToRightDesktop:
		send,#^{Right}
		return
	ShiftToRightDesktopWithActiveWindow:
		send,#^+l
		return
	ShiftToRightDesktopOnlyActiveWindow:
		send,#+l
		return
	CreateNewDesktop:
		send,#^d
		return
	CreateNewDesktopWithActiveWindow:
		send,#^+d
		return
	BreakCurrentDesktop:
		send,#^w
		return
#Enter::send,^+{Enter}
^+!c::send,!+,
^+!d::send,!+.
^+!r::send,!+l
;AppsKey::RAlt
;vkF2sc070::RWin


#IfWinActive ahk_exe excel.exe
	^Tab::
		send,^{PgDn}
		return
	^+Tab::
		send,^{PgUp}
		return
#IfWinActive ahk_exe texworks.exe
	+Enter::
		send,{End}{U+005C}{U+005C}{Enter}
		return
	::flaxbracket::
		input,bracket,I *,{Enter},
		StringLeft,bracketL,bracket,1
		StringRight,bracketR,bracket,1
		sendraw,$\left
		send,% bracketL
		sendraw,\right
		send,% bracketR . "$"
		send,{Left 8}
		return
#IfWinActive ahk_exe LINE.exe
	^E::
		send,+{Right}
		return
#IfWinActive ahk_exe PotPlayerMini.exe
	!Right::
		send,{Media_Next}
	!Left::
		send,{Media_Prev}
	Space::
		send,{Media_Play_Pause}
#IfWinActive ALC NetAcademy2 Student
	ALCProbDefine:
		ALCSYP = 287
		ALCEYP = 791
		ALCYAV = 36
		ALCSXP = 638
		ALCEXP = 1011
		ALCXAV = 373
		ALCGXP = 988
		ALCGYP = 839
		ALCNoV = 15
		return
	RetPosList(ALCSYP,ALCYAV,ALCNoV)
	{
		K = 0
		PosList = %ALCSYP%
		ALCNoV := ALCNoV - 1
		Loop %ALCNoV%
		{
			K += 1
			L := ALCSYP + ALCYAV * K
			PosList .= "_" . L
		}
		return %PosList%
	}
	Down::
		Gosub,ALCProbDefine
		MouseGetPos,PX,PY
		PosList := RetPosList(ALCSYP,ALCYAV,ALCNoV)
		tagstr = %ALCSXP%_%ALCEXP%
		StringGetPos,PYE,PosList,%PY%
		StringGetPos,PXE,tagstr,%PX%
		if (PX = ALCGXP and PX = ALCGYP)
		{
			MouseMove,%ALCEXP%,%ALCSYP%
		}
		else if (PXE != -1 and PY = ALCEYP)
		{
			MouseMove,%ALCGXP%,%ALCGYP%
		}
		else if (PXE != -1 and PYE != -1)
		{
			MouseMove,0,%ALCYAV%,,R
		}
		else
		{
			MouseMove,%ALCEXP%,%ALCSYP%
		}
		return
	Up::
		Gosub,ALCProbDefine
		MouseGetPos,PX,PY
		PosList := RetPosList(ALCSYP,ALCYAV,ALCNoV)
		tagstr = %ALCSXP%_%ALCEXP%
		StringGetPos,PYE,PosList,%PY%
		StringGetPos,PXE,tagstr,%PX%
		if (PXE != -1 and PY = ALCSYP)
		{
			MouseMove,%ALCGXP%,%ALCGYP%
		}
		else if (PX = ALCGXP and PY = ALCGYP)
		{
			MouseMove,%ALCEXP%,%ALCEYP%
		}
		else if (PXE != -1 and PYE != -1)
		{
			MouseMove,0,-%ALCYAV%,,R
		}
		else
		{
			MouseMove,%ALCEXP%,%ALCSYP%
		}
		return
	Left::
		Gosub,ALCProbDefine
		MouseGetPos,PX,PY
		PosList := RetPosList(ALCSYP,ALCYAV,ALCNoV)
		StringGetPos,PYE,PosList,%PY%
		if (PX = ALCGXP and PY = ALCGYP)
		{
			MouseMove,%ALCSXP%,%ALCEYP%
		}
		else if (PX = ALCEXP and PYE != -1)
		{
			MouseMove,-%ALCXAV%,0,,R
		}
		else if (PX != ALCSXP)
		{
			MouseMove,%ALCSXP%,%ALCSYP%
		}
		return
	Right::
		Gosub,ALCProbDefine
		MouseGetPos,PX,PY
		PosList := RetPosList(ALCSYP,ALCYAV,ALCNoV)
		StringGetPos,PYE,PosList,%PY%
		if (PX = ALCGXP and PY = ALCGYP)
		{
		}
		else if (PX = ALCSXP and PYE != -1)
		{
			MouseMove,%ALCXAV%,0,,R
		}
		else if (PX != ALCEXP)
		{
			MouseMove,%ALCEXP%,%ALCSYP%
		}
		return
	~Enter::
		Gosub,ALCProbDefine
		MouseGetPos,PX,PY
		if (PX = ALCEXP)
		{
			Click,L,,,4
		}
		else if (PX = ALCSXP)
		{
			Send,{LButton down}
			MouseMove,%ALCXAV%,0,,R
			Send,{LButton up}
			MouseMove,-%ALCXAV%,0,,R
		}
		else if (PX = ALCGXP)
		{
			Click
		}
		return
	+Enter::
		Gosub,ALCProbDefine
		K = 0
		MouseMove,%ALCEXP%,%ALCSYP%
		Loop,14
		{
			MouseMove,%ALCEXP%,% (ALCSYP + ALCYAV * A_Index)
			Send,{LButton down}
			MouseMove,%ALCEXP%,%ALCSYP%
			Send,{LButton up}
			sleep 100tton
		}
		return
	^Enter::
		msgbox,Start
		alcblacklist()
		{
			IMageSearch,FX,FY,479,359,773,567,*100 C:\Users\admin\Pictures\screenshot\alc\alcblacklist.png
			If (ErrorLevel = 0)
			{
				sleep 100
				send,{Enter}
				sleep 100
			}
			return
		}
		FileDelete,C:\Users\admin\Pictures\screenshot\alc*.png
		MSRSX = 340
		MSRSY = 218
		MSREX = 1055
		MSREY = 285
		SWSRSX = 171
		SWSRSY = 242
		SWSREX = 338
		SWSREY = 300
		SRSX = 330
		SRSY = 250
		SREX = 1100
		SREY = 400
		While True
		{
			GetKeyState,GKS,1,P
			If (GKS = "D")
			{
				Msgbox,Suspending
			}
			MouseMove,1139,211
			sleep 200
			MouseMove,1139,201
			alcblacklist()

			ImageSearch,FX,FY,%SWSRSX%,%SWSRSY%,%SWSREX%,%SWSREY%,*100 C:\Users\admin\Pictures\screenshot\alc\alcwrong.png
			if (ErrorLevel = 0)
			{
				send,{Enter}
			}
			ImageSearch,FX,FY,%MSRSX%,%MSRSY%,%MSREX%,%MSREX%,*100 C:\Users\admin\Pictures\screenshot\alc\alccorrectselect.png
			if (ErrorLevel = 0)
			{
				Mode = correctselect
			}
			else
			{
				ImageSearch,FX,FY,%MSRSX%,%MSRSY%,%MSREX%,%MSREX%,*100 C:\Users\admin\Pictures\screenshot\alc\alctypesort.png
				if (ErrorLevel = 0)
				{
					Mode = typesort
				}
				else
				{
					ImageSearch,FX,FY,%MSRSX%,%MSRSY%,%MSREX%,%MSREX%,*100 C:\Users\admin\Pictures\screenshot\alc\alcmeanselect.png
					if (ErrorLevel = 0)
					{
						Mode = meanselect
					}
					else
					{
						ImageSearch,FX,FY,%MSRSX%,%MSRSY%,%MSREX%,%MSREX%,*100 C:\Users\admin\Pictures\screenshot\alc\alctypesort2.png
						if (ErrorLevel = 0)
						{
							Mode = typesort
						}
						else
						{
							ImageSearch,FX,FY,63,209,138,269,*100 C:\Users\admin\Pictures\screenshot\alc\alclastest.png
							if (ErrorLevel = 0)
							{
								Mode = lastest
							}
							else
							{
								;msgbox,notfound
								continue
							}
						}
					}
				}
			}
			;msgbox,A%Mode%
			sleep 500
			if (Mode = "typesort")
			{
				FileName = 404
				Loop,C:\Users\admin\Pictures\screenshot\alctypesort*str.png
				{
					ImageSearch,FX,FY,%SRSX%,%SRSY%,%SREX%,%SREY%,*100 %A_LoopFileFullPath%
					if (ErrorLevel = 0)
					{
						StringLen,Len,A_LoopFileName
						StringMid,FileName,A_LoopFileName,12,% Len - 18
						Break
					}
				}
				if (FileName != 404)
				{
					sleep 300
					send,% FileName
					sleep 200
					send,{Enter}
				}
				else
				{
					;send,^+{F12}
					sleep 300
					screenshot(345,270,1048,330,retpath("screenshot") . "alctypesort.png")
					;CoordMode,Mouse,Screen
					;MouseMove,345,270
					;sleep 100
					;send,{LButton down}
					;sleep 100
					;MouseMove,1048,330
					;sleep 100
					;send,{LButton up}
					;sleep 300
					;MouseClick,L,1030,360
					;sleep 500
					;send,!n
					;sleep 100
					;send,alctypesort
					;sleep 300
					;send,{Enter}
					sleep 500
					MouseClick,L,609,190
					sleep 300
					send,{Enter}
					sleep 500
					alcblacklist()
					sleep 500
					CoordMode,Mouse,Relative
					sleep 300
					MouseClick,L,635,334
					sleep 300
					MouseClick,L,635,334
					sleep 300
					send,^c
					sleep 500
					string := Clipboard
					FileMoveDir,C:\Users\admin\Pictures\screenshot\alctypesort.png,C:\Users\admin\Pictures\screenshot\alctypesort%string%str.png,R
					send,{Enter}
				}
			}
			else if (Mode = "lastest")
			{
				sleep 300
				MouseClick,L,986,836
				sleep 500
				MouseClick,L,864,695
				sleep 500
				MouseClick,L,975, 886
				sleep 500
				MouseClick,L,977, 891
				sleep 500
				FileDelete,C:\Users\admin\Pictures\screenshot\alc*.png
			}
			else
			{
				FileName = 404
				Loop,C:\Users\admin\Pictures\screenshot\alc%Mode%*str.png
				{
					ImageSearch,FX,FY,%SRSX%,%SRSY%,%SREX%,%SREY%,*100 %A_LoopFileFullPath%
					if (ErrorLevel = 0)
					{
						;msgbox,% A_LoopFileName
						sleep 500
						StringLen,ModeLen,Mode
						StringLen,Len,A_LoopFileName
						StringMid,FileName,A_LoopFileName,% ModeLen + 4,% Len - (ModeLen + 10)
						Break
					}
				}
				;msgbox,filename%FileName%
				sleep 500
				if (FileName != 404)
				{
					ImageSearch,FX,FY,437,356,1054,594,*100 C:\Users\admin\Pictures\screenshot\alc%Mode%%FileName%*correct.png
					If (ErrorLevel = 0)
					{
						MouseClick,L,%FX%,%FY%
					}
					else
					{
						Loop,C:\Users\admin\Pictures\screenshot\alc%Mode%%FileName%*.png
						{
							ImageSearch,FX,FY,437,356,1054,620,*100 %A_LoopFileFullPath%
							If (ErrorLevel = 0)
							{
								MouseClick,L,%FX%,%FY%
								ImageSearch,FX,FY,%SWSRSX%,%SWSRSY%,%SWSREX%,%SWSREY%,*100 C:\Users\admin\Pictures\screenshot\alc\alc%Mode%wrong.png
								if (ErrorLevel = 0)
								{
									FileDelete,C:\Users\admin\Pictures\screenshot\alc%Mode%1.png
									MouseClick,L,635,334
									sleep 100
									MouseClick,L,635,334
									send,^c
									sleep 500
									string := Clipboard
									FileMoveDir,C:\Users\admin\Pictures\screenshot\alc%Mode%str.png,C:\Users\admin\Pictures\screenshot\alc%Mode%%string%str.png,R
									FileMoveDir,C:\Users\admin\Pictures\screenshot\alc%Mode%2.png,C:\Users\admin\Pictures\screenshot\alc%Mode%%string%2.png,R
									FileMoveDir,C:\Users\admin\Pictures\screenshot\alc%Mode%3.png,C:\Users\admin\Pictures\screenshot\alc%Mode%%string%3.png,R
									send,{Enter}
								}
								else
								{
									FileDelete,C:\Users\admin\Pictures\screenshot\alc%Mode%2.png
									FileDelete,C:\Users\admin\Pictures\screenshot\alc%Mode%3.png
									FileMoveDir,C:\Users\admin\Pictures\screenshot\alc%Mode%1.png,C:\Users\admin\Pictures\screenshot\alc%Mode%%string%correct.png,R
								}
								Break
							}
							else
							{
								FileDelete,%A_LoopFileFullPath%
								StringLen,Len,A_LoopFileName
								StringMid,FilePath,A_LoopFileName,1,% Len - 5
								;msgbox,%FilePath%
								sleep 500
								BFilePath := FilePath . "3.png"
								AFilePath := FilePath . "correct.png"
								FileMoveDir,%BFilePath%,%AFilePath%
								break
							}
						}
					}
				}
				else
				{
					screenshot(345,270,1048,330,retpath("screenshot") . "alc" . Mode . "str.png")
					;send,^+{F12}
					;sleep 300
					;CoordMode,Mouse,Screen
					;MouseMove,345,270
					;sleep 100
					;send,{LButton down}
					;sleep 100
					;MouseMove,1048,330
					;sleep 100
					;send,{LButton up}
					;sleep 300
					;MouseClick,L,1030,360
					;sleep 500
					;send,!n
					;sleep 100
					;send,alc%Mode%str
					;sleep 100
					;send,{Enter}
					sleep 500
					MouseMove,1139,211
					MouseClick,
					sleep 500
					screenshot(443,363,1033,410,retpath("screenshot") . "alc" . Mode . "1.png")
					;send,^+{F12}
					;sleep 500
					;MouseMove,443,363
					;sleep 100
					;send,{LButton down}
					;sleep 100
					;MouseMove,1033,410
					;sleep 100
					;send,{LButton up}
					;sleep 300
					;MouseClick,L,1013,440
					;sleep 500
					;send,!n
					;sleep 100
					;send,alc%Mode%1
					;sleep 100
					;send,{Enter}
					sleep 500
					MouseMove,1139,211
					mouseclick,L,1139,211
					sleep 500
					screenshot(443,446,1032,493,retpath("screenshot") . "alc" . Mode . "2.png")
					;send,^+{F12}
					;sleep 500
					;MouseMove,443,446
					;sleep 100
					;send,{LButton down}
					;;;sleep 100
					;MouseMove,1032,493
					;sleep 100
					;send,{LButton up}
					;sleep 300
					;MouseClick,L,1012,523
					;sleep 500
					;send,!n
					;sleep 100
					;send,alc%Mode%2
					;sleep 100
					;send,{Enter}
					sleep 500
					MouseMove,1139,211
					sleep 500
					mouseclick,L,1139,211
					screenshot(440,537,1032,572,retpath("screenshot") . "alc" . Mode . "3.png")
					;send,^+{F12}
					;sleep 500
					;MouseMove,440,537
					;sleep 100
					;send,{LButton down}
					;sleep 100
					;MouseMove,1032,582
					;sleep 100
					;send,{LButton up}
					;sleep 300
					;MouseClick,L,1013,602
					;sleep 500
					;send,!n
					;sleep 100
					;send,alc%Mode%3
					;sleep 100
					;send,{Enter}
					sleep 500
					mouseclick,L,1139,211
					CoordMode,Mouse,Relative
					;msgbox,save
					sleep 300
					MouseClick,L,615,399
					sleep 600
					alcblacklist()
					sleep 600
					ImageSearch,FX,FY,%SWSRSX%,%SWSRSY%,%SWSREX%,%SWSREY%,*100 C:\Users\admin\Pictures\screenshot\alc\alc%Mode%wrong.png
					if (ErrorLevel = 0)
					{
						FileDelete,C:\Users\admin\Pictures\screenshot\alc%Mode%1.png
						MouseClick,L,635,334
						sleep 100
						MouseClick,L,635,334
						send,^c
						sleep 500
						string := Clipboard
						FileMoveDir,C:\Users\admin\Pictures\screenshot\alc%Mode%str.png,C:\Users\admin\Pictures\screenshot\alc%Mode%%string%str.png,R
						FileMoveDir,C:\Users\admin\Pictures\screenshot\alc%Mode%2.png,C:\Users\admin\Pictures\screenshot\alc%Mode%%string%2.png,R
						FileMoveDir,C:\Users\admin\Pictures\screenshot\alc%Mode%3.png,C:\Users\admin\Pictures\screenshot\alc%Mode%%string%3.png,R
						send,{Enter}
					}
					else
					{
						FileDelete,C:\Users\admin\Pictures\screenshot\alc%Mode%2.png
						FileDelete,C:\Users\admin\Pictures\screenshot\alc%Mode%3.png
						Tick := A_TickCount
						FileMoveDir,C:\Users\admin\Pictures\screenshot\alc%Mode%1.png,C:\Users\admin\Pictures\screenshot\alc%Mode%%Tick%correct.png,R
						FileMoveDir,C:\Users\admin\Pictures\screenshot\alc%Mode%str.png,C:\Users\admin\Pictures\screenshot\alc%Mode%%Tick%str.png,R
					}
				}
			}
			Mode =
		}
		return
#IfWinActive,ahk_exe eclipse.exe
	::flaxexclude::
		sleep 100
		Send,!{Enter}
		WinWait,のプロパティー
		Send,C
		sleep 500
		Send,{Enter}
		sleep 500
		ControlSend,ビルドからリソースを除外,{Space}
		Send,{Enter}
		return
	^Tab::
		send,^{PgDn}
		return
	^+Tab::
		send,^{PgUp}
		return
	F5::
		send,!r
		send,s
		send,{Enter}
		return
#IfWinActive,ahk_exe explorer.exe
	~^Tab::
	sleep 400
	send,!q
	return
	~^+Tab::
	sleep 400
	send,!q
	send,+{Tab}
	return
	^+c::
		Clipboard := ""
		send,^c
		ClipWait
		Clipboard := Clipboard
		Clipboard := Follow_a_Link(Clipboard)
		return
	!v::
		mode := "sym"
		GoSub, MakeLink
		return
	^+v::
		mode := "shr"
		GoSub, MakeLink
		return
	MakeLink:
		CDPath := GetCurrentDirectory()
		if (CDPath = "Error"){
			msgbox, パスが不正
			return
		}
		Clip := ClipboardAll
		Clipboard := Clipboard
		SplitPath, Clipboard, FileName
		DestPath := CDPath . "\" . FileName
		if (mode = "sym"){
			DestPath .= "_sym"f
			param := ""
			if (JudgeDir(Clipboard)){
				param := "/d"
			}
			command := "mklink " . param . " """ . DestPath . """ """ Clipboard . """"
			msgjoin(CmdRun(command, 0, "admin"))
		}else if (mode = "shr"){
			DestPath .= ".lnk"
			FileCreateShortcut, %Clipboard%, %DestPath%
		}
		Clipboard := Clip
		return
	^t::
		run,::{20D04FE0-3AEA-1069-A2D8-08002B30309D}
		return
	^n::
		WinGetTitle,DestPath,A
		if (RegExMatch(DestPath,"[A-Z]:\\([^\/:*?<>|]*\\)*") == 0)
		{
			msgbox, パスが不正
			return
		}
		MenuName := ""
		Loop,CreateNew\*
		{
			MenuName .= A_LoopFileName . "`n"
		}
		Sort,MenuName,C
		Loop,Parse,MenuName,`n
		{
			if (RegExMatch(A_LoopField, "^([^.]*)(\.[^.]*)$", MenuName) == 0)
				continue
			if (MenuName2 == ".folder")
				MenuName2 := "Folder"
			Menu,CreateNew,Add,%MenuName2%%MenuName1%,createnew
		}
		Menu,CreateNew,Show,%A_GuiX%,%A_GuiY%
		Menu,CreateNew,DeleteAll
		return
		createnew:
			NNN := 0
			RegExMatch(A_ThisMenuItem,"^([^)]*)(\(\&.\))$", MenuName)
			if (MenuName1 == "Folder")
			{
				MenuName1 := "\"
			}
			While (true)
			{
				NNN += 1
				IfNotExist,%DestPath%\New%NNN%%MenuName1%
				{
					if (MenuName1 == "\")
					{
						Path := DestPath . "\New" . NNN
						FileCreateDir,%Path%
						break
					}
					Path := DestPath . "\New" . NNN . MenuName1
					FileCopy,CreateNew\%MenuName2%%MenuName1%,%Path%
					break
				}
			}
			return
	^r::
		FilePath := RetCopy("Text")
		Menu, ExpMenu, Add, Launcher に登録(&R), register_launcher
		Menu, ExpMenu, Add, プログラムから開く(&P), open_with
		Menu, ExpMenu, Add, MP3 のタグを編集(&M), editmp3tags
		Menu, ExpMenu, Show, %A_GuiX%, %A_GuiY%
		Menu, ExpMenu, DeleteAll
		return
		register_launcher:
			RCLoc := ""
			RCApp := ""
			if (InStr(FileExist(FilePath), "D") != 0){
				type := "LocalPath"
				RCLoc := "Checked"
			}else{
				type := "Application"
				RCApp := "Checked"
			}
			sleep 100
			Gui, New, , FlaxRegisterLauncher
			Gui, FlaxRegisterLauncher:Font,,Meiryo UI
			Gui, FlaxRegisterLauncher:Margin,10,10
			Gui, FlaxRegisterLauncher: -Border +ToolWindow
			Gui, FlaxRegisterLauncher:Add,Text,,&Name
			SplitPath, FilePath, FileName
			Gui, FlaxRegisterLauncher:Add,Edit, w800 vEName, %FileName%
			Gui, FlaxRegisterLauncher:Add,Text,,&Command
			Gui, FlaxRegisterLauncher:Add,Edit, w800 vECommand, %FilePath%
			Gui, FlaxRegisterLauncher:Add,Text,,Type
			Gui, FlaxRegisterLauncher:Add,Radio, vRApp %RCApp%, &Application
			Gui, FlaxRegisterLauncher:Add,Radio, vRLoc %RCLoc%, &LocalPath
			Gui, FlaxRegisterLauncher:Add,Radio, vRURL, &URL
			Gui, FlaxRegisterLauncher:Add,Text,,Computer
			Gui, FlaxRegisterLauncher:Add,Radio, vRThi Checked, &ThisComputer
			Gui, FlaxRegisterLauncher:Add,Radio, vRAll, &AllComputer
			Gui, FlaxRegisterLauncher:Add,Button,Default gRegisterLauncherOK,&OK
			Gui, FlaxRegisterLauncher:-Resize
			Gui, FlaxRegisterLauncher:Show,Autosize, FlaxRegisterLauncher
			WinWaitNotActive, FlaxRegisterLauncher
			Gui, FlaxRegisterLauncher:Destroy
			return
			RegisterLauncherOK:
				Gui, FlaxRegisterLauncher: Submit
				B_ComputerName := ""
				if (RThi = 1)
					B_ComputerName := A_ComputerName
				else if (RAll = 1)
					B_ComputerName := "default"
				IniWrite, %ECommand%, launcher.ini, %EName%, %B_ComputerName%command
				if (RApp = 1)
					EType := "Application"
				else if (RLoc = 1)
					EType := "LocalPath"
				else if (RURL = 1)
					EType := "URL"
				IniWrite, %EType%, launcher.ini, %EName%, %B_ComputerName%type
				return
			FlaxRegisterLauncherGuiEscape:
			FlaxRegisterLauncherGuiClose:
				Gui, FlaxRegisterLauncher:Destroy
				return
			open_with:
				msgjoin("未実装")
				return
		editmp3tags:
			Gui, New, , FlaxEditMp3Tags
			Gui, FlaxEditMp3Tags:Font, , Meiryo UI
			Gui, FlaxEditMp3Tags:Margin, 10, 10
			Gui, FlaxEditMp3Tags:-Border
			Gui, FlaxEditMp3Tags:Add, Text, , &NewName
			SplitPath, FilePath, FileName, FileDir
			PreCommand := "Python """ . A_ScriptDir . "\mp3_tags.py"" """ . FilePath . """"
			Tags := CmdRun(PreCommand . " get title artist album")
			Tags := StrSplit(Tags, "`n")
			Gui, FlaxEditMp3Tags:Add, Edit, w800 vENewName, %FileName%
			Gui, FlaxEditMp3Tags:Add, Text, , &Title
			Gui, FlaxEditMp3Tags:Add, Edit, w800 vETitle, % Tags[1]
			Gui, FlaxEditMp3Tags:Add, Text, , &Artist
			Gui, FlaxEditMp3Tags:Add, Edit, w800 vEArtist, % Tags[2]
			Gui, FlaxEditMp3Tags:Add, Text, , &Albam
			Gui, FlaxEditMp3Tags:Add, Edit, w800 vEAlbam, % Tags[3]
			Gui, FlaxEditMp3Tags:Add, Button, Default gEditMp3TagsOK, &OK
			Gui, FlaxEditMp3Tags:-Resize
			Gui, FlaxEditMp3Tags:Show, Autosize, FlaxEditMp3Tags
			return
			EditMp3TagsOK:
				Gui, FlaxEditMp3Tags:Submit
				Command := PreCommand . " edit """ . ETitle . """ """ . EArtist . """ """ . EAlbam . """"
				CmdRun(Command)
				FileMove, %FilePath%, %FileDir%\%ENewName%
				Gui, FlaxEditMp3Tags:Destroy
				ToolTip, Done
				sleep 1000
				ToolTip,
				return
			FlaxEditMp3TagsGuiEscape:
			FlaxEditMp3TagsGuiClose:
				Gui, FlaxEditMp3Tags:Destroy
				return
#IfWinActive,ahk_exe chrome.exe
	GetDoujinAntena(URL)
			{
				run,% URL
				while (True)
				{
					sleep 300
					WinGetTitle,FName,A
					if (RegExMatch(FName,"同人あんてな") != 0)
						break
				}
				send,^w
				FName := RegExReplace(FName,"(.*)\-同人あんてな(.*)","$1.zip")
				Name := RegExReplace(URL,"http://.*id=(.*)","$1")
				BURL := URL
				URL := RegExReplace(URL,"http://","http://cdn.")
				URL := RegExReplace(URL,"(page|dl1).php\?id=(.*)","zip/$2.zip")
				run,% URL
				Path := retpath("download") . Name . ".zip"
				while (True)
				{
					sleep 1000
					if (A_Index = 1800)
					{
						FileAppend,% FName . "," . URL . "`n",Z:\Ggame\漫画\未分類\Error.txt
						return
					}
					if (FileExist(Path))
						break
				}
				DestPath := "Z:\Ggame\漫画\未分類\" . FName
				FileMove,%Path%,%DestPath%,1
				return
			}
 	^+q::return
	^+w::return
	^+Enter::
		send,!d
		sleep 200
		send,^c
		sleep 200
		URL := Clipboard
		GetDoujinAntena(URL)
		return
#IfWinActive ahk_exe Doukutsu.exe
	x::
		drapidflag = True
		while (drapidflag = "True")
		{
			send,{x down}
			sleep 50
			send,{x up}
			sleep 50
		}
		return
	x up::
		drapidflag = False
		return
	Left::,
	Down::.
	Right::/
	Up::l
#IfWinActive Terraria.exe
	XButton2::e
	XButton1::m
#IfWinActive
#If (flaxmode = "vim")
{
}
#If (copymode = "FIFO")
{
	^c::
		Clipboard := ""
		send,^c
		GoSub,FIFOInput
		return
	^x::
		Clipboard := ""
		send,^x
		GoSub,FIFOInput
		return
	FIFOInput:
		ClipWait
		FIFOClip[IoFWP] := Clipboard
		IoFWP += 1
		return
	^v::
		Clipboard := FIFOClip[IoFRP]
		send,^v
		IoFRP += IoFWP == IoFRP + 1 ? 0 : 1
		return
}
#If (editmode = "C++")
{
}
#If (True)
