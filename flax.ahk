﻿;注意事項
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
	launcherFD := new FD_for_EC("config/launcher.fd")
	gestureFD := new FD_for_EC("config/gesture.fd")
	registerFD := new FD("config/register.fd")
	timetableFD := new FD("config/timetable.fd")
	pathFD := new FD_for_EC("config/path.fd")
	pathFD.dict := pathFD.dict["path"]
	configFD := new FD("config/config.fd")
	EvalConfig(configFD)
	timerFD := new TimerFD("config/timer.fd")
	MP := Object()
	global Pi := 3.14159265358979
	msgbox,ready
	return
}
GoSub,DefVars

return
;Gui の特殊ラベル
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
		IfExist,% pathFD.dict["screenshot"] . PictName
			break
		sleep 300
	}
	PictPath := pathFD.dict["screenshot"] . PictName
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
    if (Value == "")
        return
	else if (Value != 0)
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
RetPointsDist(M1, M2){
	return ((M1["X"] - M2["X"]) ** 2 + (M1["Y"] - M2["Y"]) ** 2) ** (1/2)
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
RetCopy(param="Value", SecondsToWait=""){
	Clip := ClipboardAll
	Clipboard := ""
	send,^c
	ClipWait, %SecondsToWait%
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
RetRLDU(Radian){
	if (15/8 < Radian or Radian <= 1/8)
		return "R"
	if (1/8 < Radian and Radian <= 3/8)
		return "BDR"
	if (3/8 < Radian and Radian <= 5/8)
		return "D"
	if (5/8 < Radian and Radian <= 7/8)
		return "BDL"
	if (7/8 < Radian and Radian <= 9/8)
		return "L"
	if (9/8 < Radian and Radian <= 11/8)
		return "BUL"
	if (11/8 < Radian and Radian <= 13/8)
		return "U"
	if (13/8 < Radian and Radian <= 15/8)
		return "BUR"
	return
}
RetMPatan2(MP1, MP2){
	return atan2(MP1["X"], MP1["Y"], MP2["X"], MP2["Y"])
}
GestureCandidate(MR, gFD){
	route := MR.route
	reg := MR.Reg
	CommandCandidate := ""
	For Key, Value in gFD.dict{
		if (InStr(Key, route) == 1){
			CommandLabel := gFD.dict[Key]["label"]
			CandiName := SubStr(Key, StrLen(route) + 1, StrLen(Key))
			CandiValue := CandiName == "" ? "" : " : "
			CandiValue .= CommandLabel
			For, Pattern, Replacement in reg
				CandiName := RegExReplace(CandiName, Pattern, Replacement)
			CommandCandidate .= CandiName . CandiValue . "`n"
		}
	}
	CommandCandidate := CommandCandidate == "" ? "None" : CommandCandidate
	return CommandCandidate
}
EvalConfig(cFD){
	for Key, Value in cFD.dict["ChangeHotkey"]{
		HotKey, IfWinActive
		for SubCommand, Parameter in Value{
			if (SubCommand == "Key")
				continue
			HotKey, %SubCommand%, %Parameter%
		}
		Value := Value["Key"]
		if (Value != "Off")
			HotKey, %Value%, %Key%
		HotKey, %Key%, Off
	}
	return
}
GetMP3TagsFunc(FilePath){
	PreCommand := "Python """ . A_ScriptDir . "\mp3_tags.py"" """ . FilePath . """"
	Tags := CmdRun(PreCommand . " get title artist album")
	Tags := StrSplit(Tags, "`n")
	return Tags
}
EditMP3TagsFunc(FilePath, Title, Artist, Albam, NewName){
	SplitPath, FilePath, FileName, FileDir
	PreCommand := "Python """ . A_ScriptDir . "\mp3_tags.py"" """ . FilePath . """"
	Command := PreCommand . " edit """ . Title . """ """ . Artist . """ """ . Albam . """"
	CmdRun(Command)
	FileMove, %FilePath%, %FileDir%\%NewName%
	return
}
GetLastUpdate(FilePath){
	FileGetTime, LU, %FilePath%, M
	return LU
}
CheckLastUpdate(FilePath, LastUpdate){
	FileGetTime, LU, %FilePath%, M
	if (LU == LastUpdate)
		return 0
	return LU
}
MakeSymbolicLink(Source, Dest){
	SplitPath, FilePath, FileName
	param := ""
	if (JudgeDir(Source))
		param := "/d"
	command := "mklink " . param . " """ . Dest . """ """ . Source . """"
	msgjoin(CmdRun(command, 0, "admin"))
	return
}
GetProcessName(){
	WinGet,AWPN,ProcessName,A
	return AWPN
}
GetProcessPath(){
	WinGet,AWPP,ProcessPath,A
	return AWPP
}
AGUIClose(GuiHwnd){
	AGui.HwndDict[GuiHwnd].close()
	return
}
AGUIEscape(GuiHwnd){
	AGui.HwndDict[GuiHwnd].escape()
	return true
}
AGuiSize(GuiHwnd){
    AGui.HwndDict[GuiHwnd].size()
    return
}
AGuiDropFiles(GuiHwnd){
    AGui.HwndDict[GuiHwnd].dropfiles()
    return
}
AGuiContextMenu(GuiHwnd){
    AGui.HwndDict[GuiHwnd].contextmenu()
    return
}
class FD{
	__New(FilePath){
		this.FilePath := FilePath
		this.Read()
		if (not(IsObject(this.dict)))
			this.dict := Object()
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
				pattern := "^\s*|\s*$"
				if (TData[1] == body){
					Data[name] := RegExReplace(body, pattern, "")
					break
				}
				K := RegExReplace(TData[0], pattern, "")
				Data[name] := K
				Text := TData[1]
			}
		}
		return Data
	}
	read(FilePath=""){
		FileGetTime, LU, % this.FilePath, M
		if (LU == this.LastUpdate)
			return 0
		this.LastUpdate := LU
		if (FilePath == "")
			FilePath := this.FilePath
		FileRead, TData, %FilePath%
		this.dict := this.ConvertText_to_FlaxDict(TData)
		return 1
	}
	write(FilePath="", dict=""){
		if (FilePath == "")
			FilePath := this.FilePath
		if (dict == "")
			dict := this.dict
		TData := this.ConvertFlaxDict_to_Text(dict)
		file := FileOpen(this.FilePath, "w", "CP65001")
		file.Write(TData)
		file.Close()
		this.read()
	}
}
class FD_for_EC extends FD{
	__New(FilePath){
		base.__New(FilePath)
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
		return
	}
	read(FilePath=""){
		if (base.read(FilePath)){
			this.fdict := DeepCopy(this.dict)
			this.normalization()
		}
	}
	write(FilePath="", dict=""){
		if (dict == "")
			dict := this.fdict
		base.write(FilePath, dict)
	}
}
class MouseRoute{
	__New(Prefix=""){
		this.LineLength := 100
		this.route := Prefix
		this.Reg := Object("BUR", Chr(0x2197), "BUL", Chr(0x2196), "BDR", Chr(0x2198), "BDL", Chr(0x2199), "U", "↑", "R", "→", "L", "←", "D", "↓")
		this.NoS := 10
		this.Index := 0
		this.MPL := Object()
		this.SMP := Object()
		this.LastDirection := ""
	}
	check(){
		RV := 0
		if (this.SMP["X"] == "")
			this.SMP := RetMousePos()
		ICE := Mod(this.Index, this.NoS) ;  Index Current End
		ILS := Mod(ICE + 1, this.NoS) ;Index Last Start
		ILE := Mod(ICE + 5, this.NoS) ;Index Last End
		ICS := Mod(ICE + 6, this.NoS) ;Index Current Start
		this.Index += 1
		this.MPL[ICE] := RetMousePos()
		if (this.LineLength <= RetPointsDist(this.MPL[ICE], this.SMP)){
			MRA := RetMPatan2(this.SMP, this.MPL[ICE]) / Pi
			this.SMP := DeepCopy(this.MPL[ICE])
			CurrentDirection := RetRLDU(MRA)
			if (CurrentDirection == this.LastDirection)
				return RV
			this.route .= CurrentDirection
			this.LastDirection := CurrentDirection
			RV := 1
		}
		MPatanL := RetMPatan2(this.MPL[ILS], this.MPL[ILE])
		MPatanC := RetMPatan2(this.MPL[ICS], this.MPL[ICE])
		diff := Abs(MPatanL - MPatanC) / Pi
		if (MPatanL != 0 and MPatanC != 0 and ((0.4 < diff and diff < 1.6) or 2.4 < diff))
			this.SMP := RetMousePos()
		return RV
	}
	getMRSymbol(){
		MRS := this.route
		for Pattern, Replacement in this.Reg
			MRS := RegExReplace(MRS, Pattern, Replacement)
		return MRS
	}
}
class TestObj{
	__New(value){
		this.value := value
	}
	__Get(name){
		if (name == "v2"){
			return this.value * 2
		}else{
			Object.__Get(this, name)
		}
	}
	__Set(name, value){
		if (name == "v2"){
			this.value := value / 3
			return
		}else{
			Object.__Set(this, name, value)
		}
	}
}
class KeyRoute extends MouseRoute{
	__New(Prefix){
		base.__New(Prefix)
		this.LastKey := ""
		this.LastKeyPressedTime := 0
		this.delay := configFD.dict["KeyGestureDelay"]
		if (this.delay == "")
			this.delay := 50
	}
	check(Key){
		if ((A_TickCount - this.LastKeyPressedTime) < this.delay){
			TempKey := "B"
			if (Key == "U" or Key == "D")
				TempKey .= Key . this.LastKey
			else
				TempKey .= this.LastKey . Key
			if (this.Reg.HasKey(TempKey)){
				this.route := SubStr(this.route, 1, StrLen(this.route) - 1) . TempKey
				this.LastKey := ""
				return
			}
		}
		this.route .= Key
		this.LastKey := Key
		this.LastKeyPressedTime := A_TickCount
	}
}
class TimerFD extends FD_for_EC{
	__New(FilePath){
		base.__New(FilePath)
		this.list_sorted_in_executing_order := Object()
		this.Set()
	}
	Set(){
		for Key, Value in this.dict{
			if (Value["status"] != "enable")
				continue
			timer_type := Value["type"]
			timer_name := Key
			if (timer_type == "timer"){
				timer_value := -Value["value"]
				SetTimer, ExecuteTimer, % timer_value
			}else if (timer_type == "alarm"){
			}
			this.list_sorted_in_executing_order[timer_value] := timer_name
		}
	}
	execute_next(){
		for Key, Value in this.list_sorted_in_executing_order{
			this.list_sorted_in_executing_order.Remove(Key, Key)
			break
		}
	}
}
class AFile{
	__New(FilePath, Encoding="CP65001"){
		SplitPath, FilePath, FileName, Dir, Extension, NameNoExt, DriveLetter
		this.FilePath := FilePath
		this.FileName := FileName
		this.Dir := Dir
		this.Extension := Extension
		this.NameNoExt := NameNoExt
		this.DriveLetter := DriveLetter
		this.Encoding := Encoding
		this.Read()
	}
	EvalDestPath(DestPath){
		SplitPath, DestPath, FileName, Dir
		if (FileName == "")
			FileName := this.FileName
		NewPath := Dir . "\" . FileName
		return NewPath
	}
	Read(){
		LU := CheckLastUpdate(this.FilePath, this.LastUpdate)
		if (LU){
			this.LastUpdate := LU
			Encoding := RegExReplace(this.Encoding, "^CP", "")
			FilePath := this.FilePath
			FileRead, Text, *P%Encoding% %FilePath%
			this.Text := Text
			return 1
		}else{
			return 0
		}
		return
	}
	TruePath(){
		return Follow_a_Link(this.FilePath)
	}
	Write(){
		file := FileOpen(this.FilePath, "w", this.Encoding)
		file.Write(this.Text)
		file.Close()
		this.LastUpdate := GetLastUpdate(this.FilePath)
		return
	}
	Rename(NewName){
		DestPath := this.Dir . "\" . NewName
		this.Move(DestPath)
		return
	}
	MakeLink(DestPath, Type="Shortcut"){
		NewPath := this.EvalDestPath(DestPath)
		if (Type == "Shortcut"){
			FileCreateShortcut, % this.FilePath, %DestPath%.lnk
		}else if (Type == "Symbolic"){
			MakeSymbolicLink(this.FilePath, NewPath)
		}
		return
	}
	Move(DestPath){
		NewPath := this.EvalDestPath(DestPath)
		FileMove, % this.FilePath, %NewPath%
		this.FilePath := NewPath
		return
	}
	Copy(DestPath, Flag="0"){
		NewPath := this.EvalDestPath(DestPath)
		FileCopy, % this.FilePath, %NewPath%, %Flag%
		NewFile := new AFile(NewPath)
		return NewFile
	}
	Delete(){
		FileDelete, % this.FilePath
		return
	}

}
class AGui{
	static HwndDict := Object()
	__New(options:="", title:=""){
		Gui, New, +HwndHwnd %options%, %title%
		this.Hwnd := Hwnd
		Gui, %Hwnd%:+LabelAGui
		AGui.HwndDict[Hwnd] := this
	}
	do(command, params*){
		Hwnd := this.Hwnd
		Gui, %Hwnd%:%command%, % params[1], % params[2], % params[3]
		return
	}
	add_agc(type, name, param="", text=""){
		this[name] := new AGuiControl(this, type, name, param, text)
		return
	}
	show(options:="", title:=""){
		this.do("show", options, title)
		return
	}
	submit(NoHide:=False){
		k := ""
		if (NoHide)
			k := "NoHide"
		this.do("submit", k)
		return
	}
	cancel(){
		this.do("Cancel")
		return
	}
	font(options:="", FontName:=""){
		this.do("Font", options, FontName)
		return
	}
	color(WindowColor:="", ControlColor:=""){
		this.do("Color", WindowColor, ControlColor)
		return
	}
	margin(x:="", y:=""){
		this.do("Margin", x, y)
		return
	}
	add_option(option){
		this.do("+" . option)
		return
	}
	remove_option(option){
		this.do("-" . option)
		return
	}
	menu(MenuName:=""){
		this.do("Menu", MenuName)
		return
	}
	hide(){
		this.do("Hide")
		return
	}
	minimize(){
		this.do("Minimize")
		return
	}
	maximize(){
		this.do("Maximize")
		return
	}
	restore(){
		this.do("Restore")
		return
	}
	flash(Off:=False){
		k := ""
		if (Off)
			k := "Off"
		this.do("Flash", k)
		return
	}
	add(ControlType, Options:="", Text:=""){
		this.do("Add", ControlType, Options, Text)
		return
	}
	close(){
		this.destroy()
		return
	}
	escape(){
		this.destroy()
		return
	}
    size(){
        return
    }
    dropfiles(){
        return
    }
    contextmenu(){
        return
    }
	destroy(){
		Hwnd := this.Hwnd
		if not (AGui.HwndDict.HasKey(Hwnd))
			return
		Gui, %Hwnd%:destroy
		AGui.HwndDict.Delete(Hwnd)
		return
	}
}
class AGuiControl{
	__New(target_gui, type, name="", param="", text=""){
		global
		name := "AGuiControlVar_" . name
		%name% := ""
		if (name == "AGuiControlVar_")
			name := ""
		target_gui.add(type, "v" . name . " " . param, text)
		this.gui := target_gui
		this.name := name
	}
	__Set(name, value){
		if (name = "value"){
			this.do("", value)
			return
		}else if (name = "method"){
			this.add_option("g" . value)
			return
		}else{
			Object.__Set(this, name, value)
		}
	}
	__Get(name){
		if (name = "value"){
			name := this.name
			value := %name%
			return %value%
		}else{
			return Object.__Get(this, name)
		}
	}
	do(sub_command, param=""){
		name := this.name
		sub_command := this.gui.Hwnd . ":" . sub_command
		GuiControl, %sub_command%, %name%, %param%
		return
	}
	text(string){
		this.do("text", string)
	}
	move(param){
		this.do("move", param)
	}
	movedraw(param){
		this.do("movedraw", param)
	}
	focus(){
		this.do("focus")
	}
	enable(){
		this.do("enable")
	}
	disable(){
		this.do("disable")
	}
	hide(){
		this.do("hide")
	}
	show(){
		this.do("show")
	}
	choose(n){
		this.do("choose", n)
	}
	choosestring(string){
		this.do("choosestring", string)
	}
	font(param){
		this.do("font", param)
	}
	add_option(option){
		this.do("+" . option)
	}
	remove_option(option){
		this.do("-" . option)
	}
}
class AGuiControlText extends AGuiControl{
	__New(target_gui){
		base.__New(target_gui, "Text")
	}
}
ExecuteTimer:
	timerFD.execute_next()
	return

;hotstring
;ホットストリング
::flaxtest::
	sleep 300
    GoSub, ::flaxedittimetable
	return
flaxguitestmethod:
	msgjoin("A")
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
	Gui, FlaxCalc:Add,Button,gFlaxCalcButtonOK Default Hidden,OK
	w := MonitorSizeX - marg - w
	h := MonitorSizeY - marg - h
	Gui, FlaxCalc:Show,X%w% Y%h%
	Return
	FlaxCalcButtonOK:
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
	clipboard := GetProcessName()
	ToolTip,% Clipboard
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
	FlaxCode_Maker := new AGui(, "FlaxCode_Maker")
	FlaxCode_Maker.Font("Meiryo UI")
	FlaxCode_Maker.Margin(10, 10)
	FlaxCode_Maker.add_agc("Text", "", , "&Clear Text")
	FlaxCode_Maker.add_agc("Edit", "CText", "W500 Multi Password*")
	FlaxCode_Maker.add_agc("Text", "", , "&Seed")
	FlaxCode_Maker.add_agc("Edit", "Seed", "W500 Password*")
    FlaxCode_Maker.add_agc("Checkbox", "UC", "Checked1", "&Uppercase")
    FlaxCode_Maker.add_agc("Checkbox", "LC", "Checked1", "&Lowercase")
    FlaxCode_Maker.add_agc("Checkbox", "NC", "Checked1", "&Number")
    FlaxCode_Maker.add_agc("Checkbox", "JC", "Checked0", "&Japanese")
    FlaxCode_Maker.add_agc("Checkbox", "AC", "Checked0", "&All")
    FlaxCode_Maker.add_agc("Text", "TOthers", , "&Others")
    FlaxCode_Maker.add_agc("Edit", "Others", "W250")
    FlaxCode_Maker.add_agc("Button", "OK", "Default", "OK")
    FlaxCode_Maker.OK.method := "MakecodeGuiOK"
    FlaxCode_Maker.remove_option("Resize")
    FlaxCode_Maker.Show("AutoSize", "FlaxCode_Maker")
	return
	MakeCodeGuiOK:
        FlaxCode_Maker.Submit()
        FlaxCode_Maker.Destroy()
		Usable =
		UpperCase = ABCDEFGHIJKLMNOPQRSTUVWXYZ
		LowerCase = abcdefghijklmnopqrstuvwxyz
		NumberChar = 0123456789
		FileRead,JapaneseChar,JapaneseChars.txt
        CText := FlaxCode_Maker.CText.value
		Loop,Parse,CText
		{
			IfInString,UpperCase,%A_LoopField%
			{
				FlaxCode_Maker.UC.value := 1
			}
			IfInString,LowerCase,%A_LoopField%
			{
				FlaxCode_Maker.LC.value := 1
			}
			IfInString,NumberChar,%A_LoopField%
			{
				FlaxCode_Maker.NC.value := 1
			}
			;K := UpperCase . LowerCase . NumberChar . Others . JapaneseChar
			;IfNotInString,K,%A_LoopField%
			;{
			;	Usable := Usable . A_LoopField
			;}
		}
		if (FlaxCode_Maker.UC.value = 1)
		{
			Usable := Usable . UpperCase
		}
		if (FlaxCode_Maker.LC.value = 1)
		{
			Usable := Usable . LowerCase
		}
		if (FlaxCode_Maker.NC.value = 1)
		{
			Usable := Usable . NumberChar
		}
		if (FlaxCode_Maker.JC.value = 1)
		{
			Usable := Usable . JapaneseChar
		}
		if (FlaxCode_Maker.AC.value = 1)
		{
			Usable := Usable . """`#!$`%&()=~|-^[@]:/.,{``}*+_?><,\;"
		}
		Usable := Usable . FlaxCode_Maker.Others.value
		Usable := RegExReplace(Usable,".","$0`n")
		sort,Usable,C U
		Usable := RegExReplace(Usable,"`n","")
		if (FlaxCode_Maker.AC.value = 1)
		{
			Usable := Usable . "`　` `n`t"
		}
		if (FlaxCode_Maker.Seed.value = "")
		{
			FlaxCode_Maker.Seed.value := CText
		}
		Crypt := MakeCodeFunc(Usable, CText, FlaxCode_Maker.Seed.value)
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
	send, %clipboard%
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
		MouseMove,460,610
		MouseMove,465,610
		sleep 300
	}
	MouseClick,L,460,610
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
    ColorViewerC := new AGui(, "ColorViewerC")
    ColorViewerV := new AGui(, "ColorViewerV")
    ColorViewerC.margin(0, 0)
    ColorViewerV.margin(0, 0)
    ColorViewerC.remove_option("Border")
    ColorViewerV.remove_option("Border")
    ColorViewerV.add_agc("Slider", "RV", "Vertical Invert Range0-255 Center Y0 X180 W40 H300 AltSubmit -BackGround")
    ColorViewerV.add_agc("Slider", "GV", "Vertical Invert Range0-255 Center Y0 X220 W40 H300 AltSubmit -BackGround")
    ColorViewerV.add_agc("Slider", "BV", "Vertical Invert Range0-255 Center Y0 X260 W40 H300 AltSubmit -BackGround")
    ColorViewerV.RV.method := "ColorSliderMoved"
    ColorViewerV.GV.method := "ColorSliderMoved"
    ColorViewerV.BV.method := "ColorSliderMoved"
    ColorViewerV.add_agc("Edit", "ColorEdit", "X0 Y281 H18 W89")
    ColorViewerV.ColorEdit.method := "ColorEdited"
    ColorViewerV.add_agc("Edit", "ColorName", "X91 Y281 H18 W89")
    ColorViewerV.add_agc("Button", "ColorOK", "Default hidden1")
    ColorViewerV.ColorOK.method := "ButtonColorOK"
    ColorViewerC.add_option("AlwaysOnTop")
    ColorViewerC.Color(Clipboard)
    ColorViewerC.Close := Func("ColorViewerClose_Escape")
    ColorViewerV.Close := Func("ColorViewerClose_Escape")
    ColorViewerC.Escape := Func("ColorViewerClose_Escape")
    ColorViewerV.Escape := Func("ColorViewerClose_Escape")
    ColorViewerC.Show("Y100 X102 H277 W177")
    ColorViewerV.Show("Y100 X100 H300 W300")
	return
    ColorViewerClose_Escape(){
        global
        ColorViewerC.Destroy()
        ColorViewerV.Destroy()
        return
    }
	ColorSliderMoved:
        ColorviewerV.Submit("NoHide")
		CV := Dec2Hex(ColorViewerV.RV.value * 16 ** 4 + ColorViewerV.GV.value * 16 ** 2 + ColorViewerV.BV.value, 6)
        ColorViewerV.ColorEdit.Text(CV)
	ColorEdited:
        ColorViewerV.Submit("NoHide")
		if (RegExMatch(ColorViewerV.ColorEdit.value, "[\da-fA-F]{6}") = 1)
		{
            ColorViewerV.RV.value := Hex2Dec(SubStr(ColorViewerV.ColorEdit.value, 1, 2))
            ColorViewerV.GV.value := Hex2Dec(SubStr(ColorViewerV.ColorEdit.value, 3, 2))
            ColorViewerV.BV.value := Hex2Dec(SubStr(ColorViewerV.ColorEdit.value, 5, 2))
            ColorViewerC.Color(ColorViewerV.ColorEdit.value)
		}
		return
	ButtonColorOK:
        ColorViewerV.Submit()
        ColorViewerC.Submit()
		Clipboard := ColorViewerV.ColorEdit.value
        ColorViewerV.Destroy()
        ColorViewerC.Destroy()
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
	timetableFD.read()
    configFD.read()
	sleep 300
	TTCellWidth = 100
	TTCellHeight = 100
	Gui, New, , FlaxTimeTable
	Gui, FlaxTimeTable:Font, MeiryoUI
	Gui, FlaxTimeTable:Margin, 50, 50
	Gui, FlaxTimeTable:+AlwaysOnTop -Border
	x := marg
	y := marg
    term := configFD.dict["CurrentClassTerm"]
    GoSub, TimeTableAddText
    DropDownText := ""
    for Key, Value in timetableFD.dict{
        DropDownText .= Key . "|"
        if (Key == term){
            DropDownText .= "|"
        }
    }
    Gui, FlaxTimeTable:Add, DropDownList, Sort VTimeTableDDLV GTimeTableChanged, %DropDownText%
	Gui, FlaxTimeTable:Show, , FlaxTimeTable
	return
    TimeTableAddText:
        Loop, 6{
            R := A_Index - 1
            Loop, 7{
                C := A_Index - 1
                x := marg + C * TTCellWidth
                y := marg + R * TTCellHeight
                Text := ""
                Loop, 4{
                    L := A_Index - 1
                    Text .= "`n" timetableFD.dict[term][R][C][L]
                }
                Gui, FlaxTimeTable:Add, Text, w%TTCellWidth% h%TTCellHeight% x%x% y%y% Border Center gOpenClassFolder vTimeTableCell%R%%C%, %Text%
            }
        }
        return
    TimeTableChangeText:
        Loop, 6{
            R := A_Index - 1
            Loop, 7{
                C := A_Index - 1
                Text := ""
                Loop, 4{
                    L := A_Index - 1
                    Text .= "`n" . timetableFD.dict[term][R][C][L]
                }
                GuiControl, , TimeTableCell%R%%C%, %Text%
            }
        }
        return
    TimeTableChanged:
        Gui, FlaxTimeTable:Submit, NoHide
        sterm := term
        term := TimeTableDDLV
        GoSub, TimeTableChangeText
        term := sterm
        return
	OpenClassFolder:
        GuiControlGet, ClassName, , %A_GuiControl%
		Loop, Parse, ClassName, `n
		{
			if (A_Index == 2)
			{
				ClassName := A_LoopField
				break
			}
		}
		ClassPath := pathFD.dict["class"] . term . "\" . ClassName
        IfNotExist, %ClassPath%
        {
            Gui, FlaxTimeTable:+OwnDialogs
            msgbox, 4, , 授業フォルダが存在しません。作成しますか？           
            ifMsgBox, Yes
            {
                FileCreateDir, %ClassPath%
            }
            else
            {
                return
            }
        }
        IfExist, %ClassPath%
        {
            Run, %ClassPath%
        }
        Gui, FlaxTimeTable:Destroy
		return
	FlaxTimeTableGuiEscape:
	FlaxTimeTableGuiClose:
		Gui, FlaxTimeTable:Destroy
		return
::flaxhanoy::
	sleep 400
	CmdRun(pathFD.dict["python"] . " Hanoy.py ")
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
::flaxeditgesture::
	sleep 400
	Gui, New, , FlaxEditGesture
	Gui, FlaxEditGesture:Font, , Meiryo UI
	Gui, FlaxEditGesture:Margin, 10, 10
	Gui, FlaxEditGesture:Add, Text, , &Gesture
	Gui, FlaxEditGesture:Add, Edit, w400 vEGesture
	Gui, FlaxEditGesture:Add, Text, vSymbol w400
	Gui, FlaxEditGesture:Add, Button, gEditGestureREC, &REC
	Gui, FlaxEditGesture:Add, Text, , &Command
	Gui, FlaxEditGesture:Add, Edit, w400 vECommand
	Gui, FlaxEditGesture:Add, Text, , &Label
	Gui, FlaxEditGesture:Add, Edit, w400 Section vELabel
	Gui, FlaxEditGesture:Add, Text, xs+0 ys+50, Mouse Button
	Gui, FlaxEditGesture:Add, Radio, vRL Checked, &LeftButton
	Gui, FlaxEditGesture:Add, Radio, vRM, &MiddleButton
	Gui, FlaxEditGesture:Add, Radio, vRR, &RightButton
	Gui, FlaxEditGesture:Add, Text, , Modifier Key
	Gui, FlaxEditGesture:Add, Checkbox, vCCtrl, &Ctrl
	Gui, FlaxEditGesture:Add, Checkbox, vCAlt, &Alt
	Gui, FlaxEditGesture:Add, Checkbox, vCShift, &Shift
	Gui, FlaxEditGesture:Add, Text, xs+200 ys+50, Computer
	Gui, FlaxEditGesture:Add, Radio, vRThi Checked, &ThisComputer
	Gui, FlaxEditGesture:Add, Radio, vRAll, &AllComputer
	Gui, FlaxEditGesture:Add, Text, , Type
	Gui, FlaxEditGesture:Add, Radio, vRLab, &Label
	Gui, FlaxEditGesture:Add, Radio, vRLoc, &LocalPath
	Gui, FlaxEditGesture:Add, Radio, vRApp, &Application
	Gui, FlaxEditGesture:Add, Radio, vRURL, &URL
	Gui, FlaxEditGesture:Add, Radio, vRLau, &Launcher
	Gui, FlaxEditGesture:Add, Button, Default gEditGestureOK, &OK
	Gui, FlaxEditGesture:-Resize
	Gui, FlaxEditGesture:Show,Autosize, FlaxEditGesture
	return
	EditGestureREC:
		RECG := 1
		MR := new MouseRoute()
		while (RECG){
			if (MR.check()){
				GuiControl, , EGesture, % MR.route
				GuiControl, , Symbol, % MR.getMRSymbol()
			}
			sleep 100
		}
		return
	EditGestureOK:
		Gui, FlaxEditGesture:Submit
		Prefix := ""
		if (RL)
			Prefix .= "LB"
		else if (RM)
			Prefix .= "MB"
		else if (RR)
			Prefix .= "RB"
		if (CCtrl)
			Prefix .= "^"
		if (CAlt)
			Prefix .= "!"
		if (CShift)
			Prefix .= "+"
		B_ComputerName := ""
		if (RThi = 1)
			B_ComputerName := A_ComputerName
		else if (RAll = 1)
			B_ComputerName := "default"
		if (RLab)
			Type := "label"
		else if (RLoc)
			Type := "LocalPath"
		else if (RApp)
			Type := "Application"
		else if (RURL)
			Type := "URL"
		else if (RLau)
			Type := "launcher"
		EGesture := Prefix . EGesture
		if (not gestureFD.fdict.HasKey(EGesture))
			gestureFD.fdict[EGesture] := Object()
		if (not gestureFD.fdict[EGesture].HasKey(B_ComputerName))
			gestureFD.fdict[EGesture][B_ComputerName] := Object()
		gestureFD.fdict[EGesture][B_ComputerName]["command"] := ECommand
		gestureFD.fdict[EGesture][B_ComputerName]["type"] := Type
		gestureFD.fdict[EGesture][B_ComputerName]["label"] := ELabel
		gestureFD.write()
		Gui, FlaxEditGesture:Destroy
		return
	FlaxEditGestureGuiEscape:
		if (RECG){
			RECG := 0
			return
		}
	FlaxEditGestureGuiClose:
		Gui, FlaxEditGesture:Destroy
		return
	return
::flaxedittimetable::
	timetableFD.read()
    pathFD.read()
    term := configFD.dict["CurrentClassTerm"]
	sleep 300
	TTCellWidth = 100
	TTCellHeight = 100
	Gui, New, , FlaxEditTimeTable
	Gui, FlaxEditTimeTable:Font, MeiryoUI
	Gui, FlaxEditTimeTable:Margin, 50, 50
	x := marg
	y := marg
	Loop, 6{
		R := A_Index - 1
		Loop, 7{
			C := A_Index - 1
			x := marg + C * TTCellWidth
			y := marg + R * TTCellHeight
			Text := ""
			Loop, 4{
				L := A_Index - 1
				Text .= "`n" timetableFD.dict[term][R][C][L]
			}
			Gui, FlaxEditTimeTable:Add, Edit, w%TTCellWidth% h%TTCellHeight% x%x% y%y% Border Center vE%R%%C% -VScroll, %Text%
		}
	}
    DropDownText := "new|"
    for Key, Value in timetableFD.dict{
        DropDownText .= Key . "|"
        if (Key == term){
            DropDownText .= "|"
        }
    }
    Gui, FlaxEditTimeTable:Add, DropDownList, Sort VETimeTableDDLV GETimeTableChanged, %DropDownText%
	Gui, FlaxEditTimeTable:Add, Button, Default gEditTimeTableOK, OK
	Gui, FlaxEditTimeTable:Show, , FlaxEditTimeTable
	return
    ETimeTableChangeText:
        Loop, 6{
            R := A_Index - 1
            Loop, 7{
                C := A_Index - 1
                Text := ""
                Loop, 4{
                    L := A_Index - 1
                    Text .= "`n" . timetableFD.dict[term][R][C][L]
                }
                GuiControl, , E%R%%C%, %Text%
            }
        }
        return
    ETimeTableChanged:
        Gui, FlaxEditTimeTable:Submit, Nohide
        if (ETimeTableDDLV == "new"){
            InputBox, new_name, , 新規プロファイル名を入力
            GuiControl, , ETimeTableDDLV, %new_name%||
        }
        sterm := term
        term := ETimeTableDDLV
        GoSub, ETimeTableChangeText
        term := sterm
        return
	EditTimeTableOK:
		Gui, FlaxEditTimeTable:Submit
        term := ETimeTableDDLV
		Loop, 6{
			R := A_Index - 1
			Loop, 7{
				C := A_Index - 1
				Text := E%R%%C%
				Text := StrSplit(Text, "`n")
                if (not timetableFD.dict.HasKey(term))
                    timetableFD.dict[term] := Object()
                if (not timetableFD.dict[term].HasKey(R))
                    timetableFD.dict[term][R] := Object()
                if (not timetableFD.dict[term][R].HasKey(C))
                    timetableFD.dict[term][R][C] := Object()
				Loop, 4{
					timetableFD.dict[term][R][C][A_Index - 1] := Text[A_Index + 1]
				}
			}
		}
        configFD.read()
        configFD.dict["CurrentClassTerm"] := term
        configFD.write()
		timetableFD.write()
	FlaxEditTimeTableGuiEscape:
	FlaxEditTimeTableGuiClose:
		Gui, FlaxEditTimeTable:Destroy
		return
	return
::flaxgetprocesspath::
	sleep 100
	clipboard := GetProcessPath()
	ToolTip,% Clipboard
	sleep 1000
	ToolTip,
	return
::flaxregisterlauncher::
    GoSub, register_launcher
    return

;hotkey
;ホットキー
+!^W::
	FlaxLauncher := new AGui(, "FlaxLauncher")
	launcherFD.read()
	Sleep 100
	NoDI := 5
	NoI := NoDI
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
	FlaxLauncher.add_agc("ComboBox", "ItemName", "W300 R5 Simple")
	FlaxLauncher.ItemName.value := candidate
	FlaxLauncher.add_option("AlwaysOnTop")
	FlaxLauncher.remove_option("Border")
	FlaxLauncher.add_option("LastFound")
	FlaxLauncher.add_agc("Edit", "HiddenEdit", "xm ym w300")
	FlaxLauncher.HiddenEdit.method := "HiddenEdited"
	FlaxLauncher.HiddenEdit.focus()
	FlaxLauncher.add_agc("Button", "OK", "Hidden Default")
	FlaxLauncher.OK.method := "LauncherOK"
	FlaxLauncher.Show("Hide")
	WinGetPos,,,w,h
	w := MonitorSizeX - marg - w
	h := MonitorSizeY - marg - h
	FlaxLauncher.Show("x" . w . " y" . h . " Hide", "FlaxProgramLauncher")
	FlaxLauncher.Show("Autosize")
	WinWaitNotActive,FlaxProgramLauncher
	FlaxLauncher.Destroy()
	Return
	LauncherOK:
		FlaxLauncher.ItemName.remove_option("AltSubmit")
		FlaxLauncher.Submit()
		FlaxLauncher.Destroy()
	LauncherUse:
		LF := False
		ItemName_val := FlaxLauncher.ItemName.value
		ItemParams := StrSplit(ItemName_val, " ")
		ItemName_val := ItemParams[1]
		LP := False
		PathParam := False
		if (ItemParams[2] == "locale")
			LP := True
		else if (ItemParams[2] == "path")
			PathParam := True
		if (RegExMatch(ItemName_val, "[a-zA-Z]:\\([^\\/:?*""<>|]+\\)*([^\\/:?*""<>|]+)?")){
			Run, %ItemName_val%
			return
		}
		if (LP){
			LF := True
		}
		ID := launcherFD.dict[ItemName_val]
		if (PathParam){
			Clipboard := ID["command"]
			ToolTip, %Clipboard%
			Sleep 1000
			ToolTip,
			return
		}
		if ((ItemCommand := ID["command"]) == ""){
			msgbox, 404 Command
			return
		}
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
				LP := RegExMatch(ItemCommand, "\\([^\\]*)$", ItemName_val)
				ItemCommand := SubStr(ItemCommand, 1, LP-1)
				Run, %ItemCommand%
				WinWaitActive, ahk_exe explorer.exe
				sendraw,% ItemName_val1
				return
			}else{
				Run, %ItemCommand%
				return
			}
		}else if (ItemType == "Label"){
            GoSub, %ItemCommand%
            return
        }
		msgbox,404 Type
		return
	HiddenEdited:
		FlaxLauncher.Submit("NoHide")
		FlaxLauncher.ItemName.Text(FlaxLauncher.HiddenEdit.value)
		FlaxLauncher.ItemName.add_option("AltSubmit")
		FlaxLauncher.Submit("NoHide")
		IoS := FlaxLauncher.ItemName.value
		FlaxLauncher.ItemName.remove_option("AltSubmit")
		if IoS is integer
			return
		FlaxLauncher.Submit("NoHide")
		GuiControl, FlaxLauncher:-AltSubmit, ItemName
		Gui, FlaxLauncher:Submit, NoHide
		candidate := ""
		NoI = 0
		For Key, Value in launcherFD.dict{
			StringGetPos, IP, Key, % FlaxLauncher.ItemName.value
			command := ""
			if (IP == 0)
				command := launcherFD.dict[Key]["command"]
			if (command != ""){
				candidate .= "|" . Key
				NoI += 1
			}
		}
		FlaxLauncher.ItemName.value := candidate
		FlaxLauncher.ItemName.Text(FlaxLauncher.HiddenEdit.value)
		return
#IfWinActive,FlaxProgramLauncher
	Tab::
	Down::
		FlaxLauncher.ItemName.add_option("AltSubmit")
		FlaxLauncher.Submit("NoHide")
		FlaxLauncher.ItemName.remove_option("AltSubmit")
		if (FlaxLauncher.ItemName.value == NoI)
			return
		if (RegExMatch(Flaxlauncher.ItemName.value, "^\d+$") != 1){
			FlaxLauncher.ItemName.Choose("|1")
			FlaxLauncher.Submit("NoHide")
			FlaxLauncher.HiddenEdit.Text(FlaxLauncher.ItemName.value)
			send,{End}
			return
		}
		FlaxLauncher.ItemName.Choose("|" . FlaxLauncher.ItemName.value + 1)
		FlaxLauncher.Submit("NoHide")
		FlaxLauncher.HiddenEdit.Text(FlaxLauncher.ItemName.value)
		send,{End}
		Return
	+Tab::
	Up::
		FlaxLauncher.ItemName.add_option("AltSubmit")
		FlaxLauncher.Submit("NoHide")
		FlaxLauncher.ItemName.remove_option("AltSubmit")
		if (FlaxLauncher.ItemName.value == 1)
			return
		if (RegExMatch(FlaxLauncher.ItemName.value, "^\d+$") != 1){
			FlaxLauncher.ItemName.choose("|1")
			FlaxLauncher.Submit("NoHide")
			FlaxLauncher.HiddenEdit.Text(FlaxLauncher.ItemName.value)
			send,{End}
			return
		}
		FlaxLauncher.ItemName.Choose("|" . FlaxLauncher.ItemName.value - 1)
		FlaxLauncher.Submit("NoHide")
		FlaxLauncher.HiddenEdit.Text(FlaxLauncher.ItemName.value)
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
		registerFD.dict[address] := Clipboard
		registerFD.write()
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
		registerFD.read()
		RegValue := registerFD.dict[address]
		Clipboard := RegExReplace(RegValue, "\\flaxnewline", "`n")
		send,^v
	}
	ToolTip,
	sleep 200
	Clipboard := ClipboardAlt
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
#If
vk1D & j::send,{down}
vk1D & k::send,{up}
vk1D & h::send,{left}
vk1D & l::send,{right}
vk1D & Space::send,{Enter}
vk1D & 1::send,6
vk1D & 2::send,7
vk1D & 3::send,8
vk1D & 4::send,9
vk1D & 5::send,0
vk1D & LButton::
    RapidButton := "LButton"
    GoSub, RapidMouse
    return
vk1D & RButton::
    RapidButton := "RButton"
    GoSub, RapidMouse
    return
vk1D & MButton::
    RapidButton := "MButton"
    GoSub, RapidMouse
    return
RapidMouse:
    if (RetKeyState("Ctrl")){
        KeepRapid := True
    }
    if (RetKeyState("Shift")){
        send, {%RapidButton% Down}
        sleep 100
        while (not RetKeyState("Esc") and not RetKeyState(RapidButton)){
            sleep 10
        }
        send, {%RapidButton% Up}
    }else{
        while ((RetKeyState(RapidButton) and RetKeyState("vk1D")) or (KeepRapid and not RetKeyState("Esc") and not RetKeyState(RapidButton))){
            sleep 10
            send, {%RapidButton%}
        }
    }
    KeepRapid := False
    return

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
	gestureFD.read()
	CommandCandidate := ""
	if (RetKeyState("LCtrl"))
		Prefix .= "^"
	if (RetKeyState("LAlt"))
		Prefix .= "!"
	if (RetKeyState("LShift"))
		Prefix .= "+"
	MR := new MouseRoute(Prefix)
	ToolTip, % GestureCandidate(MR, gestureFD)
	while (RetKeyState(Button) and RetKeyState("LWin")){
		sleep 100
		if (MR.check()){
			ToolTip, % GestureCandidate(MR, gestureFD)
		}
	}
	route := MR.route
MouseGestureExecute:
	GestureName := route
	GestureType := gestureFD.dict[GestureName]["type"]
	GestureCommand := gestureFD.dict[GestureName]["command"]
	ToolTip,
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
#G::
	KeyGestureBool := True
	LPT := 0
	KR := new KeyRoute("LB")
	ToolTip, % GestureCandidate(KR, gestureFD)
	return
#If (KeyGestureBool)
	Left::
		Key := "L"
		GoSub, KeyGestureCheck
		return
	Right::
		Key := "R"
		GoSub, KeyGestureCheck
		return
	UP::
		Key := "U"
		GoSub, KeyGestureCheck
		return
	Down::
		Key := "D"
		GoSub, KeyGestureCheck
		return
	KeyGestureCheck:
		KR.check(Key)
		ToolTip, % GestureCandidate(KR, gestureFD)
		return
	Enter::
		KeyGestureBool := False
		route := KR.route
		ToolTip,
		GoSub, MouseGestureExecute
		return
	Esc::
		KeyGestureBool := False
		ToolTip,
		return
#If


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
		send, ^]
		return
	~^+Tab::
		send, ^[
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
		CDPath := RegExReplace(GetCurrentDirectory(), "\\$", "")
		if (CDPath = "Error"){
			msgbox, パスが不正
			return
		}
		Clip := ClipboardAll
		Clipboard := Clipboard
        Loop, Parse, Clipboard, `n
        {
            LoopField := RegExReplace(A_LoopField, "\r|\n", "")
            SplitPath, LoopField, FileName
            DestPath := CDPath . "\" . FileName
            target_path_is_dir := False
            param := ""
            if (JudgeDir(LoopField)){
                target_path_is_dir := True
                param := "/d"
            }
            if (C_S_x){
                swp := LoopField
                LoopField := DestPath
                DestPath := swp
                if (target_path_is_dir){
                    FileMoveDir, %DestPath%, %LoopField%
                }else{
                    FileMove, %DestPath%, %LoopField%
                }
            }
            if (mode = "sym"){
                command := "mklink " . param . " """ . DestPath . "_sym"" """ LoopField . """"
                msgjoin(CmdRun(command, 0, "admin"))
            }else if (mode = "shr"){
                FileCreateShortcut, %LoopField%, %DestPath%.lnk
            }
        }
        if (not C_S_x){
            Clipboard := Clip
        }else{
            C_S_x := False
        }
		return
    ^+x::
        send, ^x
        C_S_x := True
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
		FilePath := RetCopy("Text", 0.1)
		if (not FilePath){
			msgjoin("パスが取得できませんでした。")
			return
		}
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
			Gui, FlaxRegisterLauncher:Add,Text,,&Name
			SplitPath, FilePath, FileName
			Gui, FlaxRegisterLauncher:Add,Edit, w800 vEName, %FileName%
			Gui, FlaxRegisterLauncher:Add,Text,,&Command
			Gui, FlaxRegisterLauncher:Add,Edit, w800 vECommand, %FilePath%
			Gui, FlaxRegisterLauncher:Add,Text,,Type
			Gui, FlaxRegisterLauncher:Add,Radio, vRApp %RCApp%, &Application
			Gui, FlaxRegisterLauncher:Add,Radio, vRLoc %RCLoc%, &LocalPath
			Gui, FlaxRegisterLauncher:Add,Radio, vRURL, &URL
			Gui, FlaxRegisterLauncher:Add,Radio, vRLab, &Label
			Gui, FlaxRegisterLauncher:Add,Text,,Computer
			Gui, FlaxRegisterLauncher:Add,Radio, vRThi Checked, &ThisComputer
			Gui, FlaxRegisterLauncher:Add,Radio, vRAll, &AllComputer
			Gui, FlaxRegisterLauncher:Add,Button,Default gRegisterLauncherOK,&OK
			Gui, FlaxRegisterLauncher:-Resize
			Gui, FlaxRegisterLauncher:Show,Autosize, FlaxRegisterLauncher
			return
			RegisterLauncherOK:
				Gui, FlaxRegisterLauncher: Submit
				B_ComputerName := ""
				if (RThi = 1)
					B_ComputerName := A_ComputerName
				else if (RAll = 1)
					B_ComputerName := "default"
				if (not launcherFD.fdict.HasKey(EName))
					launcherFD.fdict[EName] := Object()
				if (not launcherFD.fdict[EName].HasKey(B_ComputerName))
					launcherFD.fdict[EName][B_ComputerName] := Object()
				launcherFD.fdict[EName][B_ComputerName]["command"] := ECommand
				if (RApp = 1)
					EType := "Application"
				else if (RLoc = 1)
					EType := "LocalPath"
				else if (RURL = 1)
					EType := "URL"
                else if (RLab = 1)
                    EType := "Label"
				launcherFD.fdict[EName][B_ComputerName]["type"] := EType
				launcherFD.write()
				Gui, FlaxRegisterLauncher:Destroy
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
			Tags := GetMP3TagsFunc(FilePath)
			Gui, FlaxEditMp3Tags:Add, Edit, w800 vENewName gNewNameChanged, %FileName%
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
			NewNameChanged:
				Gui, FlaxEditMp3Tags:Submit, NoHide
				SplitPath, ENewName, , , , PureName
				GuiControl, FlaxEditMp3Tags:Text, ETitle, %PureName%
				return
			EditMp3TagsOK:
				Gui, FlaxEditMp3Tags:Submit
				Gui, FlaxEditMp3Tags:Destroy
				EditMP3TagsFunc(FilePath, ETitle, EArtist, EAlbam, ENewName)
				ToolTip, Done
				sleep 1000
				ToolTip,
				return
			FlaxEditMp3TagsGuiEscape:
			FlaxEditMp3TagsGuiClose:
				Gui, FlaxEditMp3Tags:Destroy
				return
#IfWinActive,ahk_exe chrome.exe
 	^+q::return
	^+w::return
#IfWinActive
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
#If
