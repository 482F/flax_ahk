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
#MaxThreadsPerHotkey 10
#UseHook On
#NoEnv
#Warn UseUnsetGlobal
#Warn UseUnsetLocal
AutoTrim,off
SetWorkingDir,%A_ScriptDir%
SetTitleMatchMode,2
;初期変数
DefVars:
{
	marg := 50
    C_S_x := False
    KeyGestureBool := False
    MoveFlag := False
	flaxmoviemode := False
	copymode := "normal"
	FIFOClip := Object()
	launcherFD := new FD_for_EC("config/launcher.fd")
	gestureFD := new FD_for_EC("config/gesture.fd")
	registerFD := new FD("config/register.fd")
	timetableFD := new FD("config/timetable.fd")
	pathFD := new FD_for_EC("config/path.fd")
	pathFD.dict := pathFD.dict["path"]
	configFD := new FD("config/config.fd")
	EvalConfig(configFD)
	timerFD := new TimerFD("config/timer.fd")
    remotedesktopFD := new FD_for_EC("config/remotedesktop.fd")
	MP := Object()
	global Pi := 3.14159265358979
    rapid_mode := "normal"
    rapid_mode_tt := new ATooltip(, , , 500)
    rapid_delay := configFD.dict["rapid", "delay"]
    gesture_tt := new ATooltip()
    if (rapid_delay == ""){
        rapid_delay := 10
    }
    number_of_cmd := 0
	msgbox,ready
	return
}
GoSub,DefVars

return

#Include includes\.flax_func.ahk
#Include includes\.flax_class.ahk


;hotstring
;ホットストリング
::flaxtest::
    msgjoin(cmdrun("dir"))
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
::flaxsuspend::
	Suspend,On
	Suspend,Off
	return
::flaxspy::
	sleep 100
	Run,.\tools\AU3_Spy.exe
	return
::flaxgetprocessname::
	sleep 100
	clipboard := GetProcessName()
    ATooltip.display(Clipboard, , , 1000)
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
::flaxcopymodefifo::
	copymode = FIFO
	Clipboard =
	return
::flaxcopymodenormal::
	copymode = normal
	return
::flaxmakecodegui::
	sleep 100
    configFD.read()
	FlaxCode_Maker := new AGui(, "FlaxCode_Maker")
    FlaxCode_Maker.read_font("makecodegui")
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
		FileRead,JapaneseChar, includes\JapaneseChars.txt
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
        ShuffleList := ""
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
        Crypt := ""
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
    ATooltip.display("copymode: " . copymode, , , 1000)
	return
::flaxcomputername::
	send,% A_ComputerName
	return
::flaxminesweeperauto::
	AF := "True"
::flaxminesweeper::
	sleep 400
	PythonRun("tools\minesweeper.py", AF)
	AF := "False"
	return
::flaxvirtualfolder::
	sleep 300
    configFD.read()
    VirtualFolder := new AGui(, "VirtualFolder")
    VirtualFolder.dropfiles := Func("VirtualFolderDropFiles")
    VirtualFolder.size := Func("VirtualFolderSize")
    VirtualFolder.read_font("virtualfolder")
	VirtualFolder.add_option("Resize")
	VirtualFolder.Margin("10", "10")
	VirtualFolder.add_agc("ListView", "ListView", "AltSubmit w600 h300", "path|name")
    VirtualFolder.ListView.method := "VirtualFolderListViewEdited"
	VirtualFolder.ListView.LV_ModifyCol(1,0)
	VirtualFolder.ListView.LV_ModifyCol(2,"AutoHdr")
    VirtualFolder.add_agc("DropDownList", "DropDownList", , "Make Link||Rename|Modify Shortcut")
    VirtualFolder.DropDownList.method := "VirtualFolderDropDownListChanged"
    VirtualFolder.add_agc("Text", "DPathLabel", "yp+0 x+50 Section", "Dist Path")
	VirtualFolder.add_agc("Text", "PatternLabel", "xs ys hidden", "Rule")
    VirtualFolder.add_agc("Text", "ReplacementLabel", "xs ys+30 hidden", "Replacement")
	VirtualFolder.add_agc("Edit", "DPathEdit", "ys xs+80 w300")
	VirtualFolder.add_agc("Edit", "PatternEdit", "ys+0 xs+80 hidden w300")
    VirtualFolder.add_agc("Edit", "ReplacementEdit", "ys+30 xs+80 hidden w300")
    VirtualFolder.ReplacementEdit.method := "VirtualFolderRenameEdited"
    VirtualFolder.PatternEdit.method := "VirtualFolderRenameEdited"
	VirtualFolder.add_agc("Button", "Confirm", , "&Confirm")
    VirtualFolder.Confirm.method := "VirtualFolderConfirmPressed"
    VirtualFolder.show("AutoSize", "VirtualFolder")
	return
	VirtualFolderListViewEdited:
		if (A_GuiEvent == "K" and A_EventInfo == "46"){
			while (LV_GetNext() != 0){
				LV_Delete(LV_GetNext())
			}
		}
		return
    VirtualFolderDropFiles(){
        global VirtualFolder
        VirtualFolder.submit("NoHide")
        files_list := ""
        Loop, % VirtualFolder.ListView.LV_GetCount()
        {
            files_list .= VirtualFolder.ListView.LV_GetText(A_Index) . "`n"
        }
		Loop,Parse,A_GuiEvent,`n
		{
            if (InStr(files_list, A_LoopField) != 0){
                continue
            }
            Path := SolvePath(Follow_a_Link(A_LoopField))
            if (VirtualFolder.DropDownList.value == "Rename"){
                LV_Add(, A_LoopField, Path["Name"], RegExReplace(Path["Name"], VirtualFolder.PatternEdit.value, VirtualFolder.ReplacementEdit.value))
            }else if (VirtualFolder.DropDownList.value == "Make Link"){
                LV_Add(, A_LoopField, Path["Name"])
            }else if (VirtualFolder.DropDownList.value == "Modify Shortcut"){
                FileGetShortcut, %A_LoopField%, ctarget
                LV_Add(, A_LoopField, ctarget, ctarget)
            }
		}
		return
    }
    VirtualFolderRenameEdited(){
        global VirtualFolder
        VirtualFolder.submit("NoHide")
        Loop,% LV_GetCount()
        {
            LV_GetText(cname, A_Index, 2)
            ename := RegExReplace(cname, VirtualFolder.PatternEdit.value, VirtualFolder.ReplacementEdit.value)
            LV_Modify(A_Index, , , , ename)
        }
    }
    VirtualFolderSize(){
        global VirtualFolder
		w := A_GuiWidth - 20
		h := A_GuiHeight - 100
        VirtualFolder.ListView.Move("w" . w . " h" . h)
        VirtualFolder.DropDownList.Move("y" . A_GuiHeight - 80)
        VirtualFolder.DPathLabel.Move("x" . A_GuiWidth - 400 . " y" . A_GuiHeight - 80)
        VirtualFolder.PatternLabel.Move("x" . A_GuiWidth - 400 . " y" . A_GuiHeight - 80)
        VirtualFolder.ReplacementLabel.Move("x" . A_GuiWidth - 400 . " y" . A_GuiHeight - 50)
        VirtualFolder.DPathEdit.Move("x" . A_GuiWidth - 320 . " y" . A_GuiHeight - 80)
        VirtualFolder.PatternEdit.Move("x" . A_GuiWidth - 320 . " y" . A_GuiHeight - 80)
        VirtualFolder.ReplacementEdit.Move("x" . A_GuiWidth - 320 . " y" . A_GuiHeight - 50)
        VirtualFolder.Confirm.Move("x" . A_GuiWidth - 100 . " y" . A_GuiHeight - 25)
		return
    }
	VirtualFolderDropDownListChanged(_, mode){
        global VirtualFolder
        if (mode == "Normal"){
            VirtualFolder.submit("NoHide")
            mode := VirtualFolder.DropDownList.value
        }
		If (mode == "Rename"){
            VirtualFolder.DPathLabel.Hide()
			VirtualFolder.DPathEdit.Hide()
            VirtualFolder.PatternEdit.value := ""
            VirtualFolder.ReplacementEdit.value := ""
            VirtualFolder.PatternLabel.Show()
            VirtualFolder.PatternEdit.Show()
            VirtualFolder.ReplacementLabel.Show()
            VirtualFolder.ReplacementEdit.Show()
            while (VirtualFolder.ListView.LV_DeleteCol(3)){
                sleep, 10
            }
            VirtualFolder.ListView.LV_ModifyCol(2, 300, "CurrentName")
            VirtualFolder.ListView.LV_InsertCol(3, "AutoHdr", "ChangedName")
            VirtualFolderRefreshList()
		}else If (mode == "Make Link"){
            VirtualFolder.PatternLabel.Hide()
            VirtualFolder.PatternEdit.Hide()
            VirtualFolder.ReplacementLabel.Hide()
            VirtualFolder.ReplacementEdit.Hide()
            VirtualFolder.DPathEdit.value := ""
            VirtualFolder.DPathLabel.Show()
			VirtualFolder.DPathEdit.Show()
            while (VirtualFolder.ListView.LV_DeleteCol(3)){
                sleep, 10
            }
            VirtualFolder.ListView.LV_ModifyCol(2, "AutoHdr", "Name")
		}else if (mode == "Modify Shortcut"){
            VirtualFolderDropDownListChanged("", "Rename")
            VirtualFolder.ListView.LV_ModifyCol(2, , "CurrentTarget")
            VirtualFolder.ListView.LV_ModifyCol(3, , "ChangedTarget")
            VirtualFolderRefreshList()
        }
		return
    }
	VirtualFolderConfirmPressed:
        VirtualFolder.submit("NoHide")
		If (VirtualFolder.DropDownList.value == "Rename"){
            Loop, % VirtualFolder.ListView.LV_GetCount()
            {
                Path := VirtualFolder.ListView.LV_GetText(A_Index, 1)
                new_name := VirtualFolder.ListView.LV_GetText(A_Index, 3)
                DPath := SolvePath(Path)["Path"] . new_name
                if (judgedir(Path)){
                    FileMoveDir, %Path%, %DPath%
                }else{
                    FileMove, %Path%, %DPath%
                }
                VirtualFolder.ListView.LV_Modify(A_Index, , DPath, new_name, new_name)
            }
            VirtualFolderRenameEdited()
		}else If (VirtualFolder.DropDownList.value == "Make Link"){
			If (JudgePath(VirtualFolder.DPathEdit.value) != 0){
				FileCreateDir, %VirtualFolderDPathEdit%
				Loop,% LV_GetCount()
				{
					LV_GetText(Name, A_Index, 2)
					LV_GetText(Path, A_Index, 1)
					DPath := VirtualFolder.DPathEdit.value . "\" . Name . ".lnk"
					FileCreateShortcut,%Path%, %DPath%
				}
			}
		}else if (VirtualFolder.DropDownList.value == "Modify Shortcut"){
            Loop,% LV_GetCount()
            {
                path := VirtualFolder.ListView.LV_GetText(A_Index, 1)
                etarget := VirtualFolder.ListView.LV_GetText(A_Index, 3)
                FileCreateShortcut, %etarget%, %path%
                VirtualFolder.ListView.LV_Modify(A_Index, path, etarget, etarget)
            }
            VirtualFolderRenameEdited()
        }
		msgbox,done
		return
    VirtualFolderRefreshList(){
        global VirtualFolder
        count := VirtualFolder.ListView.LV_GetCount()
        if (VirtualFolder.DropDownList.value == "Rename"){
            Loop, % count
            {
                name := SolvePath(VirtualFolder.ListView.LV_GetText(A_Index, 1))["Name"]
                VirtualFolder.ListView.LV_Modify(A_Index, , , name, name)
            }
        }else if (VirtualFolder.DropDownList.value == "Make Link"){
            Loop, % count
            {
                name := SolvePath(VirtualFolder.ListView.LV_GetText(A_Index, 1))["Name"]
                VirtualFolder.ListView.LV_Modify(A_Index, , , name, name)
            }
        }else if (VirtualFolder.DropDownList.value == "Modify Shortcut"){
            Loop, % count
            {
                path := VirtualFolder.ListView.LV_GetText(A_Index, 1)
                FileGetShortcut, %path%, ctarget
                VirtualFolder.ListView.LV_Modify(A_Index, , , ctarget, ctarget)
            }
        }
    }
::flaxconnectratwifi::
	msgjoin(CmdRun("netsh wlan connect name=RAT-WIRELESS-A", 0))
	return
::flaxtimetable::
	timetableFD.read()
    configFD.read()
    timetablePos := timetable_current_cell_pos()
	sleep 300
	TTCellWidth = 100
	TTCellHeight = 100
    TimeTable := new AGui(, "TimeTable")
    TimeTable.contextmenu := Func("timetable_open_URL")
    TimeTable.read_font("timetable")
    TimeTable.Margin("50", "50")
    TimeTable.add_option("AlwaysOnTop")
    TimeTable.remove_option("Border")
	x := marg
	y := marg
    term := configFD.dict["CurrentClassTerm"]
    GoSub, TimeTableAddText
    DropDownText := ""
    for Key, Value in timetableFD.dict{
        if (Key != "template")
            DropDownText .= Key . "|"
        if (Key == term){
            DropDownText .= "|"
        }
    }
    TimeTable.add_agc("DropDownList", "TimeTableDDLV", "Sort xp-40 y+10", DropDownText)
    TimeTable.TimeTableDDLV.method := "TimeTableChanged"
    TimeTable.add_agc("GroupBox", "GroupBox", "BackgroundTrans")
    timetable_move_groupbox(timetablePos)
    TimeTable.Show("AutoSize", "FlaxTimeTable")
	return
    timetable_current_cell_pos(){
        global
        pos := Object()
        pos.r := 0
        pos.c := 0
        FormatTime, CurrentTime, , HHmm
        FormatTime, CurrentDay, , WDay
        pos.c := CurrentDay - 1
        for key, value in configFD.dict["ClassTime"]{
            if (value <= CurrentTime){
                pos.r := key
            }else{
                break
            }
        }
        return pos
    }
    timetable_open_URL(r="", c=""){
        global
        if r is not integer
        {
            clicked_r := SubStr(A_GuiControl, 29, 1)
        }else{
            clicked_r := r
        }
        if c is not integer
        {
            clicked_c := SubStr(A_GuiControl, 30, 1)
        }else{
            clicked_c := c
        }
        run, % timetableFD.dict[term][clicked_r][clicked_c]["URL"]
        TimeTable.Destroy()
        return
    }
    timetable_move_groupbox(Pos){
        global
        x := marg + Pos.c * TTCellWidth + 5
        y := marg + Pos.r * TTCellHeight
        TimeTable.GroupBox.movedraw("x" . x . " y" . y . " h" . TTCellHeight - 3 . " w" . TTCellWidth - 8)
        return
    }
    TimeTableAddText:
        Loop, 7{
            C := A_Index - 1
            Loop, 6{
                R := A_Index - 1
                x := marg + C * TTCellWidth
                y := marg + R * TTCellHeight
                Text := ""
                Loop, 4{
                    L := A_Index - 1
                    Text .= "`n" timetableFD.dict[term][R][C][L]
                }
                TimeTable.add_agc("Text", "TimeTableCell" . R . C, "w" . TTCellWidth . " h" . TTCellHeight . " x" . x . " y" . y . " Border Center", Text)
                TimeTable["TimeTableCell" . R . C].method := "ClickClassCell"
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
                TimeTable["TimeTableCell" . R . C].value := Text
            }
        }
        return
    TimeTableChanged:
        TimeTable.Submit("NoHide")
        sterm := term
        term := TimeTable.TimeTableDDLV.value
        GoSub, TimeTableChangeText
        return
    ClickClassCell:
        ClassName := ""
	OpenClassFolder:
        if (ClassName == ""){
            GuiControlGet, ClassName, , %A_GuiControl%
            Loop, Parse, ClassName, `n
            {
                if (A_Index == 2)
                {
                    ClassName := A_LoopField
                    break
                }
            }
        }
		ClassPath := pathFD.dict["class"] . term . "\" . ClassName
        ClassName := ""
        IfNotExist, %ClassPath%
        {
            TimeTable.add_option("OwnDialogs")
            msgbox, 4, , 授業フォルダが存在しません。作成しますか？           
            ifMsgBox, Yes
            {
                TimeTable.Destroy()
                FileCreateDir, %ClassPath%
            }
            else
            {
                return
            }
        }
        TimeTable.Destroy()
        IfExist, %ClassPath%
        {
            Run, %ClassPath%
        }
		return
    #IfWinActive, FlaxTimeTable
        W::
        K::
        Up::
            if (0 < timetablePos.r){
                timetablePos.r -= 1
                timetable_move_groupbox(timetablePos)
            }
            return
        S::
        J::
        Down::
            if (timetablePos.r < 5){
                timetablePos.r += 1
                timetable_move_groupbox(timetablePos)
            }
            return
        A::
        H::
        Left::
            if (0 < timetablePos.c){
                timetablePos.c -= 1
                timetable_move_groupbox(timetablePos)
            }
            return
        D::
        L::
        Right::
            if (timetablePos.c < 6){
                timetablePos.c += 1
                timetable_move_groupbox(timetablePos)
            }
            return
        Enter::
        Space::
            ClassName := timetableFD.dict[term][timetablePos.r][timetablePos.c][0]
            GoSub, OpenClassFolder
            return
        ^Enter::
        ^Space::
            timetable_open_URL(timetablePos.r, timetablePos.c)
            return
        !Up::
            TimeTable.TimeTableDDLV.add_option("AltSubmit")
            TimeTable.submit("NoHide")
            TimeTable.TimeTableDDLV.remove_option("AltSubmit")
            previous_item_index := TimeTable.TimeTableDDLV.value - 1
            if (previous_item_index < 1){
                return
            }
            TimeTable.TimeTableDDLV.choose("|" . previous_item_index)
            return
        !Down::
            TimeTable.TimeTableDDLV.add_option("AltSubmit")
            TimeTable.submit("NoHide")
            TimeTable.TimeTableDDLV.remove_option("AltSubmit")
            next_item_index := TimeTable.TimeTableDDLV.value + 1
            TimeTable.TimeTableDDLV.choose("|" . next_item_index)
            return
    #IfWinActive
::flaxhanoy::
	sleep 400
	CmdRun(pathFD.dict["python"] . " tools\Hanoy.py ")
	return
::flaxtransparent::
	sleep 400
    transparent_gui := new AGui(, "transparent_gui")
    winget, ID, ID, A
    transparent_gui.ID := ID
    winset, alwaysontop, on, ahk_id %ID%
    transparent_gui.close := Func("transparent_gui_close")
    transparent_gui.escape := Func("transparent_gui_close")
    transparent_gui.add_option("AlwaysOnTop")
    transparent_gui.remove_option("Border")
    transparent_gui.add_option("LastFound")
    transparent_gui.add_agc("Slider", "Slider", "Vertical Invert Range0-255 H300 Center AltSubmit -BackGround")
    transparent_gui.add_agc("Button", "OK", "Default Hidden")
    transparent_gui.OK.method := "transparent_gui_OK"
    transparent_gui.Slider.method := "transparent_gui_slider"
    transparent_gui.show("Hide")
	SysGet,MonitorSizeX,0
	SysGet,MonitorSizeY,1
	WinGetPos, , , w, h
	w := MonitorSizeX - marg - w
	h := MonitorSizeY - marg - h
	transparent_gui.Show("x" . w . " y" . h . " Hide", "transparent_gui")
    transparent_gui.remove_option("LastFound")
    transparent_gui.show("AutoSize")
	return
    transparent_gui_OK(){
        global transparent_gui
        ID := transparent_gui.ID
        transparent_gui.destroy()
        winset, alwaysontop, off, ahk_id %ID%
        return
    }
    transparent_gui_slider(){
        global transparent_gui
        transparent_gui.submit("NoHide")
        value := transparent_gui.Slider.value 
        ID := transparent_gui.ID
        winset, transparent, %value%, ahk_id %ID%
        return
    }
    transparent_gui_close(){
        global transparent_gui
        ID := transparent_gui.ID
        winset, transparent, 255, ahk_id %ID%
        transparent_gui_OK()
        return
    }
::flaxeditgesture::
	sleep 400
    configFD.read()
    gestureFD.read()
    EditGesture := new AGui(, "EditGesture")
    EditGesture.escape := Func("EditGestureEscape")
    EditGesture.read_font("editgesture")
    EditGesture.Margin("10", "10")
    EditGesture.add_agc("Text", "GestureLabel", , "&Gesture")
    EditGesture.add_agc("Edit", "EGesture", "w400")
    EditGesture.add_agc("Text", "SymbolLabel", "w400")
    EditGesture.add_agc("Button", "RECButton", , "&REC")
    EditGesture.RECButton.method := "EditGestureREC"
    EditGesture.add_agc("Text", "CommandLabel", , "&Command")
    EditGesture.add_agc("Edit", "ECommand", "w400")
    EditGesture.add_agc("Text", "LabelLabel", , "&Label")
    EditGesture.add_agc("Edit", "ELabel", "w400 Section")
    EditGesture.add_agc("Text", "MBLabel", "xs+0 ys+50", "Mouse Button")
    EditGesture.add_agc("Radio", "RL", "Checked", "&LeftButton")
    EditGesture.add_agc("Radio", "RM", , "&MiddleButton")
    EditGesture.add_agc("Radio", "RR", , "&RightButton")
    EditGesture.add_agc("Text", "ModifierKeyLabel", , "Modifier Key")
    EditGesture.add_agc("Checkbox", "CCtrl", , "&Ctrl")
    EditGesture.add_agc("Checkbox", "CAlt", , "&Alt")
    EditGesture.add_agc("Checkbox", "CShift", , "&Shift")
    EditGesture.add_agc("Text", "ComputerLabel", "xs+200 ys+50", "Computer")
    EditGesture.add_agc("Radio", "RThi", "Checked", "&ThisComputer")
    EditGesture.add_agc("Radio", "RAll", "Checked", "&AllComputer")
    EditGesture.add_agc("Text", "TypeLabel", , "Type")
    EditGesture.add_agc("Radio", "RLab", , "&Label")
    EditGesture.add_agc("Radio", "RLoc", , "&LocalPath")
    EditGesture.add_agc("Radio", "RApp", , "&Application")
    EditGesture.add_agc("Radio", "RURL", , "&URL")
    EditGesture.add_agc("Radio", "RLau", , "&Launcher")
    EditGesture.add_agc("Button", "OKButton", "Default", "&OK")
    EditGesture.OKButton.method := "EditGestureOK"
    EditGesture.remove_option("Resize")
    EditGesture.show("Autosize", "FlaxEditGesture")
	return
	EditGestureREC:
		RECG := 1
		MR := new MouseRoute()
		while (RECG){
			if (MR.check()){
                EditGesture.EGesture.value := MR.route
                EditGesture.SymbolLabel.value := MR.getMRSymbol()
			}
			sleep 100
		}
		return
	EditGestureOK:
        EditGesture.Submit()
		Prefix := ""
		if (EditGesture.RL.value)
			Prefix .= "LB"
		else if (EditGesture.RM.value)
			Prefix .= "MB"
		else if (EditGesture.RR.value)
			Prefix .= "RB"
		if (EditGesture.CCtrl.value)
			Prefix .= "^"
		if (EditGesture.CAlt.value)
			Prefix .= "!"
		if (EditGesture.CShift.value)
			Prefix .= "+"
		B_ComputerName := ""
		if (EditGesture.RThi.value = 1)
			B_ComputerName := A_ComputerName
		else if (EditGesture.RAll.value = 1)
			B_ComputerName := "default"
		if (EditGesture.RLab.value)
			Type := "label"
		else if (EditGesture.RLoc.value)
			Type := "LocalPath"
		else if (EditGesture.RApp.value)
			Type := "Application"
		else if (EditGesture.RURL.value)
			Type := "URL"
		else if (EditGesture.RLau.value)
			Type := "launcher"
		Gesture := Prefix . EditGesture.EGesture.value
        gestureFD.fdict[Gesture, B_ComputerName, "command"] := EditGesture.ECommand.value
		gestureFD.fdict[Gesture, B_ComputerName, "type"] := Type
		gestureFD.fdict[Gesture, B_ComputerName, "label"] := EditGesture.ELabel.value
		gestureFD.write()
        EditGesture.Destroy()
		return
    EditGestureEscape(){
        global
        if (RECG){
            RECG := 0
        }
        return
    }
::flaxedittimetable::
	timetableFD.read()
    configFD.read()
    pathFD.read()
    term := configFD.dict["CurrentClassTerm"]
	sleep 300
	TTCellWidth = 100
	TTCellHeight = 100
    EditTimeTable := new AGui(, "EditTimeTable")
    EditTimeTable.read_font("edittimetable")
    EditTimeTable.Margin("50", "50")
	x := marg
	y := marg
	Loop, 7{
		C := A_Index - 1
		Loop, 6{
			R := A_Index - 1
			x := marg + C * TTCellWidth
			y := marg + R * TTCellHeight
			Text := ""
			Loop, 4{
				L := A_Index - 1
				Text .= "`n" timetableFD.dict[term][R][C][L]
			}
            EditTimeTable.add_agc("Text", "T" . R . C, "w" . TTCellWidth . " h" . TTCellHeight . " x" . x . " y" . y . " Border Center", Text)
            EditTimeTable["T" . R . C].method := "ett_cell_clicked"
		}
	}
    DropDownText := "new|"
    for Key, Value in timetableFD.dict{
        DropDownText .= Key . "|"
        if (Key == term){
            DropDownText .= "|"
        }
    }
    EditTimeTable.add_agc("DropDownList", "ETimeTableDDLV", "Sort xp-40 y+10", DropDownText)
    EditTimeTable.ETimeTableDDLV.method := "ETimeTableChanged"
    EditTimeTable.add_agc("Button", "EditTimeTableOK", "y+10", "OK")
    EditTimeTable.EditTimeTableOK.method := "EditTimeTableOK"
    EditTimeTable.add_agc("Button", "EditTimeTableDelete","y+10" , "Delete")
    EditTimeTable.EditTimeTableDelete.method := "EditTimeTableDelete"
    EditTimeTable.add_agc("groupbox", "groupbox", "w0 h0")

    x := marg * 2 + TTCellWidth * 7
    y := marg

    EditTimeTable.add_agc("text", "tfil", "x" . x . " y" . y . " section", "1st line")
    EditTimeTable.add_agc("edit", "efil", "xs+100 ys+0")
    EditTimeTable.add_agc("text", "tsel", "xs+0 ys+30 section", "2nd line")
    EditTimeTable.add_agc("edit", "esel", "xs+100 ys+0")
    EditTimeTable.add_agc("text", "tthl", "xs+0 ys+30 section", "3rd line")
    EditTimeTable.add_agc("edit", "ethl", "xs+100 ys+0")
    EditTimeTable.add_agc("text", "tfol", "xs+0 ys+30 section", "4th line")
    EditTimeTable.add_agc("edit", "efol", "xs+100 ys+0")
    EditTimeTable.add_agc("text", "turl", "xs+0 ys+30 section", "url")
    EditTimeTable.add_agc("edit", "eurl", "xs+100 ys+0")

    EditTimeTable.efil.method := "ett_edit_edited"
    EditTimeTable.esel.method := "ett_edit_edited"
    EditTimeTable.ethl.method := "ett_edit_edited"
    EditTimeTable.efol.method := "ett_edit_edited"

    EditTimeTable.current_cell := Object()
    EditTimeTable.current_cell.r := 0
    EditTimeTable.current_cell.c := 0
    ett_move_groupbox(EditTimeTable.current_cell)
    EditTimeTable.Show("", "FlaxEditTimeTable")
	return
    ett_edit_edited(){
        global EditTimeTable
        global timetableFD
        EditTimeTable.submit("nohide")
        term := EditTimeTable.ETimeTableDDLV.value
        fil := EditTimeTable.efil.value
        sel := EditTimeTable.esel.value
        thl := EditTimeTable.ethl.value
        fol := EditTimeTable.efol.value
        url := EditTimeTable.eurl.value
        r := EditTimeTable.current_cell.r
        c := EditTimeTable.current_cell.c
        timetableFD.dict[term, r, c, 0] := fil
        timetableFD.dict[term, r, c, 1] := sel
        timetableFD.dict[term, r, c, 2] := thl
        timetableFD.dict[term, r, c, 3] := fol
        timetableFD.dict[term, r, c, URL] := url

        text := "`n" . fil . "`n" . sel . "`n" . thl . "`n" . fol

        EditTimeTable["T" . r . c].value := text
        ett_move_groupbox(EditTimeTable.current_cell)
    }
    ett_cell_clicked(varname=""){
        global EditTimeTable
        global timetableFD
        EditTimeTable.submit("nohide")
        if (RegExMatch(varname, "^T\d\d$") != 1){
            varname := substr(a_guicontrol, 16, 3)
        }
        r := substr(varname, 2, 1)
        c := substr(varname, 3, 1)
        target_cell := EditTimeTable[varname]
        term := EditTimeTable.ETimeTableDDLV.value
        EditTimeTable.current_cell.r := r
        EditTimeTable.current_cell.c := c
        values := timetableFD.dict[term, r, c]

        EditTimeTable.efil.value := values[0]
        EditTimeTable.esel.value := values[1]
        EditTimeTable.ethl.value := values[2]
        EditTimeTable.efol.value := values[3]
        EditTimeTable.eurl.value := values[4]

        ett_move_groupbox(EditTimeTable.current_cell)
        return
    }
    ett_move_groupbox(Pos){
        global EditTimeTable
        global TTCellWidth
        global TTCellHeight
        global marg
        x := marg + Pos.c * TTCellWidth + 5
        y := marg + Pos.r * TTCellHeight
        EditTimeTable.GroupBox.movedraw("x" . x . " y" . y . " h" . TTCellHeight - 3 . " w" . TTCellWidth - 8)
        return
    }
    ETimeTableChangeText:
        Loop, 7{
            C := A_Index - 1
            Loop, 6{
                R := A_Index - 1
                Text := ""
                Loop, 4{
                    L := A_Index - 1
                    Text .= "`n" . timetableFD.dict[term][R][C][L]
                }
                EditTimeTable["T" . R . C].value := Text
            }
        }
        return
    ETimeTableChanged:
        EditTimeTable.Submit("NoHide")
        DDLV_value := EditTimeTable.ETimeTableDDLV.value
        if (EditTimeTable.ETimeTableDDLV.value == "new"){
            if (not timetableFD.dict.HasKey("template")){
                msgbox, テンプレートが見つかりませんでした。`n先にテンプレートを作成してください。
                new_name := "template"
            }else{
                InputBox, new_name, , 新規プロファイル名を入力
            }
            EditTimeTable.ETimeTableDDLV.value := new_name . "||"
            DDLV_value := "template"
        }
        sterm := term
        term := DDLV_value
        GoSub, ETimeTableChangeText
        term := sterm
        return
	EditTimeTableOK:
        EditTimeTable.Submit()
        sterm := term
        term := EditTimeTable.ETimeTableDDLV.value
        configFD.read()
        if (term == "template")
            term := sterm
        configFD.dict["CurrentClassTerm"] := term
        configFD.write()
		timetableFD.write()
        return
    EditTimeTableDelete:
        EditTimeTable.Submit("NoHide")
        term := EditTimeTable.ETimeTableDDLV.value
        msgbox, 4, , プロファイル "%term%" を削除します。よろしいですか？
        ifMsgBox, Yes
        {
            timetableFD.dict.Delete(term)
            EditTimeTable.Destroy()
        }
        return
    #IfWinActive FlaxEditTimeTable
        ^Up::
            if (0 < EditTimeTable.current_cell.r){
                EditTimeTable.current_cell.r -= 1
                ett_cell_clicked("T" . EditTimeTable.current_cell.r . EditTimeTable.current_cell.c)
            }
            return
        ^Down::
            if (EditTimeTable.current_cell.r < 5){
                EditTimeTable.current_cell.r += 1
                ett_cell_clicked("T" . EditTimeTable.current_cell.r . EditTimeTable.current_cell.c)
            }
            return
        ^Right::
            if (EditTimeTable.current_cell.c < 6){
                EditTimeTable.current_cell.c += 1
                ett_cell_clicked("T" . EditTimeTable.current_cell.r . EditTimeTable.current_cell.c)
            }
            return
        ^Left::
            if (0 < EditTimeTable.current_cell.c){
                EditTimeTable.current_cell.c -= 1
                ett_cell_clicked("T" . EditTimeTable.current_cell.r . EditTimeTable.current_cell.c)
            }
            return
    #IfWinActive 
::flaxgetprocesspath::
	sleep 100
	clipboard := GetProcessPath()
    ATooltip.display(Clipboard, , , 1000)
	return
::flaxregisterlauncher::
    FilePath := ""
    GoSub, register_launcher
    return
::flaxsetupmousepad::
    SetKeyDelay, 100, 10
    MouseClick, L, 88, 107
    send, !z
    MouseClick, L, 74, 124
    send, !t
    MouseClick, L, 52, 142
    MouseClick, L, 74, 159
    MouseClick, L, 116, 175
    send, {Tab}{Home}
    MouseClick, L, 119, 190
    send, {Tab}{Home}
    MouseClick, L, 55, 272
    MouseClick, L, 104, 288
    send, !l
    MouseClick, L, 75, 305
    MouseClick, L, 96, 305
    send, !e
    MouseClick, L, 114, 318
    MouseClick, L, 361, 101
    MouseClick, L, 144, 336
    MouseClick, L, 361, 101
    MouseClick, L, 135, 349
    MouseClick, L, 348, 129
    MouseClick, L, 129, 369
    MouseClick, L, 375, 116
    MouseClick, L, 147, 382
    SetKeyDelay, 10, -1
    send, {Tab}{Right 30}{Down 10}
    send, {Tab}{Left 30}{Down 10}
    send, !a
    send, {Esc}
    SetKeyDelay, 10, -1
    return    
::flaxregtest::
    reg_test()
    return
::flaxmakeonetimepass::
    configFD.read()
    otp_input := new AGui(, "otp_input")
    otp_input.read_font("makeonetimepass")
    otp_input.add_agc("text", "name_label", "", "名前")
    otp_input.add_agc("edit", "name", "w100")
    otp_input.add_agc("text", "password_label", "", "パスワード")
    otp_input.add_agc("edit", "password", "w100 Password*")
	otp_input.add_agc("Button", "OK", "Hidden Default")
	otp_input.OK.method := "otp_input_ok"
    otp_input.show("AutoSize")
    return
    otp_input_ok(){
        global configFD
        global otp_input
        configFD.read()
        otp_input.submit("NoHide")
        otp_keys := configFD.dict["onetime_password"]
        otp_key := otp_keys[otp_input.name.value]
        if (otp_key == ""){
            msgjoin("Invalid name.")
            return
        }
        otp_pkey := MakeCodeFunc("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", otp_key, otp_input.password.value)
        otp_input.destroy()
        otp_pass := CmdRun("wsl oathtool --totp -d 6 --time-step-size=30s --base32 " . otp_pkey)
        Clipboard := otp_pass
        return
    }
::flaxregisteronetimepass::
    configFD.read()
    otp_register := new AGui(, "otp_register")
    otp_register.read_font("registeronetimepass")
    otp_register.add_agc("text", "name_label", "", "名前")
    otp_register.add_agc("edit", "name", "w100")
    otp_register.add_agc("text", "key_label", "", "シークレット キー")
    otp_register.add_agc("edit", "key", "w100 Password*")
    otp_register.add_agc("text", "password_label", "", "パスワード")
    otp_register.add_agc("edit", "password", "w100 Password*")
	otp_register.add_agc("Button", "OK", "Hidden Default")
	otp_register.OK.method := "otp_register_ok"
    otp_register.show("AutoSize")
    return
    otp_register_ok(){
        global otp_register
        global configFD
        configFD.read()
        otp_register.submit("NoHide")
        if (otp_register.name.value == "" or otp_register.key.value == ""){
            msgjoin("Invalid name or key.")
            return
        }
        otp_ckey := MakeCodeFUnc("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789", otp_register.key.value, otp_register.password.value)
        configFD.dict["onetime_password"][otp_register.name.value] := otp_ckey
        otp_register.destroy()
        configFD.write()
        return
    }
::flaxremotedesktop::
    global remotedesktopFD
    global pathFD
    remotedesktopFD.read()
    pathFD.read()
    target_tt := new ATooltip("input target name")
    target_tt.display()
    target_name := new AInput()
    target_name.input_mode("on")
    While (target_name.ErrorLevel != "EndKey:Enter"){
        toolstr := ""
        target_name.input()
        if (target_name.ErrorLevel == "EndKey:Escape"){
            target_tt.hide()
            target_name.input_mode("off")
            return
        }
        toolstr .= target_name.str . "`n"
        for key, value in remotedesktopFD.dict{
            if (InStr(key, target_name.str) == 1 and value.haskey("target")){
                toolstr .= key . "`n"
            }
        }
        target_tt.str := toolstr
        target_tt.display()
    }
    target_name.input_mode("off")
    target_name := target_name.str
    target := remotedesktopFD.dict[target_name]
    target_tt.hide()
    if (target == ""){
        return
    }
    if (target.command.mode != ""){
        if (target.command.mode == "wsl"){
            command := "cmd.exe /c wsl bash --login -c ""ssh " . target.command.main . " & read"""
        }else if (target.command.mode == "putty"){
            putty_path := pathFD.dict["putty"]
            if (putty_path == ""){
                msgjoin("Please set putty path in path.fd")
                return
            }
            command := putty_path . " -load """ . target.command.main . """"
        }else{
            command := target.command.main
        }
        run, %command%
    }
    run, % "mstsc /v:" .  target.target
	return
::flaxregisterremotedesktop::
    rrd_gui := new AGui(, "register remotedesktop")
    rrd_gui.read_font("registerremotedesktop")
    rrd_gui.Margin("10", "10")
    rrd_gui.add_agc("Text", "NameLabel", , "&Name (ex. my_desktop)")
    rrd_gui.add_agc("Edit", "ename", "w800")
    rrd_gui.add_agc("Text", "TargetLabel", , "&Target (ex. localhost:13389)")
    rrd_gui.add_agc("Edit", "etarget", "w800")
    rrd_gui.add_agc("Text", "CMLabel", , "command mode")
    rrd_gui.add_agc("Radio", "Rcommand", "Checked", "&cmd")
    rrd_gui.add_agc("Radio", "Rputty", , "&Putty")
    rrd_gui.add_agc("Radio", "Rwsl", , "&WSL")
    rrd_gui.Rcommand.method := "rrd_gui_radio_method"
    rrd_gui.Rputty.method := "rrd_gui_radio_method"
    rrd_gui.Rwsl.method := "rrd_gui_radio_method"
    rrd_gui.add_agc("Text", "CommandLabel", , "&Command (ex. ssh -L 13389:localhost:3389 192.168.1.2)")
    rrd_gui.add_agc("Edit", "ecommand", "w800")
    rrd_gui.add_agc("Text", "ComputerLabel", , "Computer")
    rrd_gui.add_agc("Radio", "RThi", "Checked", "&ThisComputer")
    rrd_gui.add_agc("Radio", "RAll", , "&AllComputer")
    rrd_gui.add_agc("Button", "OK", "Default", "&OK")
    rrd_gui.OK.method := "rrd_guiOK"
    rrd_gui.remove_option("Resize")
    rrd_gui.show("Autosize", "register remotedesktop")
    return
    rrd_gui_radio_method:
        rrd_gui.submit("nohide")
        text := "&Command (ex. "
        if (rrd_gui.rcommand.value == 1){
            text .= "ssh -L 13389:localhost:3389 192.168.1.2)"
        }else if (rrd_gui.rputty.value == 1){
            text .= "putty's session name)"
        }else if (rrd_gui.rwsl.value == 1){
            text .= "hostname in wsl .ssh/config)"
        }
        rrd_gui.commandlabel.value := text
        return
    rrd_guiOK:
        rrd_gui.Submit()
        B_ComputerName := ""
        mode := ""
        if (rrd_gui.RThi.value = 1)
            B_ComputerName := A_ComputerName
        else if (rrd_gui.RAll.value = 1)
            B_ComputerName := "default"
        if (rrd_gui.rcommand.value == 1){
            mode := ""
        }else if (rrd_gui.rputty.value == 1){
            mode .= "putty"
        }else if (rrd_gui.rwsl.value == 1){
            mode .= "wsl"
        }
        EName := rrd_gui.EName.value
        remotedesktopFD.fdict[EName, B_ComputerName, "command", "main"] := rrd_gui.ECommand.value
        remotedesktopFD.fdict[EName, B_ComputerName, "command", "mode"] := mode
        remotedesktopFD.fdict[EName, B_ComputerName, "target"] := rrd_gui.Etarget.value
        remotedesktopFD.write()
        rrd_gui.Destroy()
        return

    return
;hotkey
;ホットキー
+!^W::
    configFD.read()
    search_method := configFD.dict["launcher", "search_method"]
    if (search_method == "prefix"){
        search_method := Func("is_zero")
    }else if (search_method == "partial"){
        search_method := Func("is_not_minus_one")
    }else{
        msgjoin("launcher.search_method in config.fd is invalid.")
        return
    }
	FlaxLauncher := new AGui(, "FlaxLauncher")
    FlaxLauncher.read_font("launcher")
	launcherFD.read()
	Sleep 100
	NoDI := 5
	NoI := NoDI
    LIoS := 0
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
    pos := configFD.dict["launcher", "pos"]
	WinGetPos,,,w,h
    x := MonitorSizeX - marg - w
    y := MonitorSizeY - marg - h
    if (pos == "center"){
        x := (MonitorSizeX - w) / 2
        y := (MonitorSizeY - h) / 2
    }else if (pos.x != "" and pos.y != ""){
        x := pos.x
        y := pos.y
    }
	FlaxLauncher.Show("x" . x . " y" . y . " Hide", "FlaxProgramLauncher")
	FlaxLauncher.Show("Autosize")
	WinWaitNotActive,FlaxProgramLauncher
	FlaxLauncher.Destroy()
	Return
	LauncherOK:
		FlaxLauncher.ItemName.remove_option("AltSubmit")
		FlaxLauncher.Submit()
		FlaxLauncher.Destroy()
        ItemName := FlaxLauncher.ItemName.value
	LauncherUse:
		LF := False
		ItemParams := StrSplit(ItemName, " ")
		ItemName := ItemParams[1]
		LP := False
		PathParam := False
		if (ItemParams[2] == "locale")
			LP := True
		else if (ItemParams[2] == "path")
			PathParam := True
		if (RegExMatch(ItemName, "[a-zA-Z]:\\([^\\/:?*""<>|]+\\)*([^\\/:?*""<>|]+)?")){
			Run, %ItemName%
			return
		}
		if (LP){
			LF := True
		}
		ID := launcherFD.dict[ItemName]
		if (PathParam){
			Clipboard := ID["command"]
            ATooltip.display(Clipboard, , , 1000)
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
        ItemWD := ID["working_dir"]
        if (ItemWD == "" and ItemType != "URL"){
            SplitPath, ItemCommand, , ItemWD
        }
		if (ItemType = "URL" or ItemType = "LocalPath" or ItemType = "Application"){
			if (LF and ItemType != "URL"){
				LP := RegExMatch(ItemCommand, "\\([^\\]*)$", ItemName)
				ItemCommand := SubStr(ItemCommand, 1, LP-1)
				Run, %ItemCommand%
				WinWaitActive, ahk_exe explorer.exe
				sendraw,% ItemName
				return
			}else{
				Run, %ItemCommand%, %ItemWD%
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
        if ((IoS == 1) or (abs(LIoS - IoS) == 1)){
            LIoS := IoS
            return
        }
		FlaxLauncher.Submit("NoHide")
		candidate := ""
		NoI = 0
		For Key, Value in launcherFD.dict{
			StringGetPos, IP, Key, % FlaxLauncher.ItemName.value
			command := ""
            if (search_method.call(IP)){
                command := launcherFD.dict[Key]["command"]
			}
            if (command != ""){
				candidate .= "|" . Key
				NoI += 1
			}
		}
		FlaxLauncher.ItemName.value := candidate
		FlaxLauncher.ItemName.Text(FlaxLauncher.HiddenEdit.value)
        if IoS is integer
        {
            LIoS := 1
        }else{
            LIoS := IoS
        }
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
    process_name := GetProcessName()
    nircmd_mute(process_name, 2)
	return
!Volume_Up::
    process_name := GetProcessName()
    nircmd_mute(process_name, 0)
    return
!Volume_Down::
    process_name := GetProcessName()
    nircmd_mute(process_name, 1)
    return
^#c::
	ClipboardAlt := ClipboardAll
	Clipboard := ""
    register_name_tt := new ATooltip("input register name")
    register_name_tt.display()
	send,^c
	GoSub,RegisterInput
	return
^#x::
	ClipboardAlt := ClipboardAll
    register_name_tt := new ATooltip("input register name")
    register_name_tt.display()
	send,^x
	GoSub,RegisterInput
	Return
^#e::
	ClipboardAlt := ClipboardAll
    register_name_tt := new ATooltip("input register name")
    register_name_tt.display()
	GoSub, RegisterInput
    return
RegisterInput:
    reg_name := new AInput()
    reg_name.input_mode("on")
    While (reg_name.ErrorLevel != "Endkey:Enter"){
        reg_name.input()
        if (reg_name.ErrorLevel == "EndKey:Escape"){
            register_name_tt.hide()
            reg_name.input_mode("off")
            return
        }
        if (reg_name.str == "")
            str := "input register name"
        else
            str := reg_name.str
        register_name_tt.str := str
        register_name_tt.display()
    }
    reg_name.input_mode("off")
    reg_name := reg_name.str
	ClipWait, 1
	Clipboard := RegExReplace(Clipboard, "\r\n", "\flaxnewline")
	if (reg_name != ""){
		registerFD.dict[reg_name] := Clipboard
		registerFD.write()
	}
    register_name_tt.hide()
	Clipboard := ClipboardAlt
	return
^#v::
    reg_value := input_reg_name()
	ClipboardAlt := ClipboardAll
	Clipboard := ""
    Clipboard := reg_value
    Clipwait
    send,^v
	Clipboard := ClipboardAlt
    return
^#r::
    reg_value := input_reg_name()
    Clipboard := reg_value
    return
input_reg_name(){
    global registerFD
    registerFD.read()
    register_name_tt := new ATooltip("input register name")
    register_name_tt.display()
    reg_name := new AInput()
    reg_name.input_mode("on")
    While (reg_name.ErrorLevel != "EndKey:Enter"){
        toolstr := ""
        reg_name.input()
        if (reg_name.ErrorLevel == "EndKey:Escape"){
            register_name_tt.hide()
            reg_name.input_mode("off")
            return
        }
        toolstr .= reg_name.str . "`n"
        for key, value in registerFD.dict{
            if (InStr(key, reg_name.str) == 1){
                if (10 < StrLen(value)){
                    value := SubStr(value, 1, 10) . "..."
                }
                toolstr .= key . ": " . value . "`n"
            }
        }
        register_name_tt.str := toolstr
        register_name_tt.display()
    }
    reg_name.input_mode("off")
    reg_name := reg_name.str
    reg_value := registerFD.dict[reg_name]
    reg_value := RegExReplace(reg_value, "\\flaxnewline", "`n")
    register_name_tt.hide()
	return reg_value
}
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
    movemode_tt := new ATooltip("MoveMode")
	WinGetActiveStats, Title, Width, Height, X, Y
	CoordMode, Mouse, Screen
	MouseMove, % X + Width / 2, % Y - 10
	while (MoveFlag){
		MouseGetPos, MX, MY
		WinMove, %Title%, , % MX - Width / 2, % MY - 10, %Width%, %Height%
		sleep 100
        movemode_tt.display()
	}
	CoordMode, Mouse, Relativem
    movemode_tt.hide()
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
vk1D & r::
    str := "mode: "
    if (rapid_mode == "normal"){
        rapid_mode := "rapid"
        str .= "rapid"
    }else if (rapid_mode == "rapid"){
        rapid_mode := "auto_rapid"
        str .= "auto rapid"
    }else if (rapid_mode == "auto_rapid"){
        rapid_mode := "press"
        str .= "press"
    }else if (rapid_mode == "press"){
        rapid_mode := "normal"
        str .= "normal"
    }
    rapid_mode_tt.str := str
    rapid_mode_tt.display()
    return
#If (rapid_mode != "normal")
    ~LButton::
    ~RButton::
        rapid_flag := False
        return
    LButton & RButton::
        rapid_mouse("L", rapid_mode)
        return
    RButton & LButton::
        rapid_mouse("R", rapid_mode)
        return
    ~Esc::
        rapid_flag := False
        return
    LButton & RButton up::
    RButton & LButton up::
        if (rapid_mode == "rapid")
            rapid_flag := False
        return
#If
rapid_mouse(button, mode){
    global rapid_flag
    global rapid_delay
    rapid_flag := True
    if (mode == "press"){
        rapid_mouse_press_tt := new ATooltip("start")
        rapid_mouse_press_tt.display()
        KeyWait, LButton, 
        KeyWait, RButton, 
        rapid_mouse_press_tt.hide()
        click, %button%, , , , , D
        while (rapid_flag){
            sleep, 100
        }
        click, %button%, , , , , U
    }else{
        while (rapid_flag){
            click, %button%, , , , ,
            sleep, %rapid_delay%
        }
    }
    return
}

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
    gesture_tt := new ATooltip()
	CommandCandidate := ""
	if (RetKeyState("LCtrl"))
		Prefix .= "^"
	if (RetKeyState("LAlt"))
		Prefix .= "!"
	if (RetKeyState("LShift"))
		Prefix .= "+"
	MR := new MouseRoute(Prefix)
    gesture_tt.str := GestureCandidate(MR, gestureFD)
    gesture_tt.display()
	while (RetKeyState(Button) and RetKeyState("LWin")){
		sleep 100
		if (MR.check()){
			gesture_tt.str := GestureCandidate(MR, gestureFD)
            gesture_tt.display()
		}
	}
	route := MR.route
MouseGestureExecute:
	GestureName := route
	GestureType := gestureFD.dict[GestureName]["type"]
	GestureCommand := gestureFD.dict[GestureName]["command"]
    gesture_tt.hide()
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
    gestureFD.read()
	KeyGestureBool := True
	LPT := 0
	KR := new KeyRoute("LB")
	gesture_tt.str := GestureCandidate(KR, gestureFD)
    gesture_tt.display()
	return
#If (KeyGestureBool)
	Left::
    h::
    a::
		Key := "L"
		GoSub, KeyGestureCheck
		return
	Right::
    l::
    d::
		Key := "R"
		GoSub, KeyGestureCheck
		return
	UP::
    k::
    w::
		Key := "U"
		GoSub, KeyGestureCheck
		return
	Down::
    j::
    s::
		Key := "D"
		GoSub, KeyGestureCheck
		return
	KeyGestureCheck:
		KR.check(Key)
		gesture_tt.str := GestureCandidate(KR, gestureFD)
        gesture_tt.display()
		return
	Enter::
    Space::
		KeyGestureBool := False
		route := KR.route
        gesture_tt.hide()
		GoSub, MouseGestureExecute
		return
	Esc::
		KeyGestureBool := False
        gesture_tt.hide()
		return
#If
^!+#F1::
    ; G3
    return
^!+#F2::
    ; G4
    return
^!+#F3::
    ; G5
    send, {Silent}^+T
    return
^!+#F4::
    ; G6
    return
^!+#F5::
    ; G7
    return
^!+#F6::
    ; G9
    return
^!+#F7::
    ; G13
    return
^!+#F8::
    ; G2
    return
vk1D & PrintScreen::
    name := "screenshot\" . A_Now . A_TickCount . ".png"
    screenshot_full(name)
    return



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
                overwrite_flag = 0
                if (fileexist(LoopField) != ""){
                    msgbox, 4, , 同名のファイルが存在します。`nファイルを置き換えますか？
                    IfMsgBox, Yes
                    {
                        overwrite_flag = 1
                    }
                }
                if (target_path_is_dir){
                    FileMoveDir, %DestPath%, %LoopField%, %overwrite_flag%
                }else{
                    FileMove, %DestPath%, %LoopField%, %overwrite_flag%
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
        name := solvepath(filepath).name
        if (regexmatch(name, "\d{4}_\d{2}_\d{2}(\..*)?")){
            ext := retallmatch(name, "(\..*)")[1][1]
            name := regexreplace(name, "_|\..*$")
            EnvAdd, name, 7, Days
            name := SubStr(name, 1, 8)
            name := SubStr(name, 1, 4) . "_" . SubStr(name, 5, 2) . "_" . SubStr(name, 7, 2) . ext
            Menu, ExpMenu, Add, %name% にコピーする (&D), copy_after_seven_days
        }
        if (InStr(FileExist(FilePath), "D") != 0){
            Menu, ExpMenu, add, フォルダ内の MP3 のタグを編集(&M), editmp3stags
        }else if (SubStr(FilePath, StrLen(FilePath) - 3, 4) == ".mp3"){
            Menu, ExpMenu, Add, MP3 のタグを編集(&M), editmp3tags
        }
		Menu, ExpMenu, Show, %A_GuiX%, %A_GuiY%
		Menu, ExpMenu, DeleteAll
		return
        editmp3stags:
            EditMP3sTags := new AGui(, "EditMP3sTags")
            configFD.read()
            EditMP3sTags.Editing := False
            EditMP3sTags.read_font("editmp3stags")
            EditMP3sTags.add_option("Resize")
            EditMP3sTags.add_agc("ListView", "Na_ListView", "Grid w300 h500 NoSortHdr gMP3sLV AltSubmit")
            EditMP3sTags.Na_ListView.remove_option("ReadOnly")
            EditMP3sTags.Na_ListView.remove_option("HScroll")
            LV_InsertCol(1, 297, "Name")
            EditMP3sTags.add_agc("ListView", "Ti_ListView", "Grid w300 h500 x+0 NoSortHdr gMP3sLV AltSubmit")
            EditMP3sTags.Ti_ListView.remove_option("ReadOnly")
            EditMP3sTags.Ti_ListView.remove_option("HScroll")
            LV_InsertCol(1, 297, "Title")
            EditMP3sTags.add_agc("ListView", "Ar_ListView", "Grid w200 h500 x+0 NoSortHdr gMP3sLV AltSubmit")
            EditMP3sTags.Ar_ListView.remove_option("ReadOnly")
            EditMP3sTags.Ar_ListView.remove_option("HScroll")
            LV_InsertCol(1, 197, "Artist")
            EditMP3sTags.add_agc("ListView", "Al_ListView", "Grid w200 h500 x+0 NoSortHdr gMP3sLV AltSubmit")
            EditMP3sTags.Al_ListView.remove_option("ReadOnly")
            EditMP3sTags.Al_ListView.remove_option("HScroll")
            LV_InsertCol(1, 197, "Album")
            EditMP3sTags.add_agc("Button", "OKButton", "Default Hidden gEditMP3sOK")
            EditMP3sTags.dict := Object()
            EditMP3sTags.add_agc("Progress", "Progress", "Backgroundwhite x20 y515 w200 h20 border")
            EditMP3sTags.show("AutoSize")
            Loop, %FilePath%\*.mp3, 0, 1
            {
                Name := RegExReplace(A_LoopFileName, "\.mp3$", "")
                Path := A_LoopFileFullPath
                Tags := GetMP3TagsFunc(Path)
                Title := Tags[1]
                Artist := Tags[2]
                Album := Tags[3]
                EditMP3sTags.dict[A_Index, "Name"] := Name
                EditMP3sTags.dict[A_Index, "Path"] := Path
                EditMP3sTags.dict[A_Index, "Title"] := Title
                EditMP3sTags.dict[A_Index, "Artist"] := Artist
                EditMP3sTags.dict[A_Index, "Album"] := Album
                ifWinNotExist, EditMP3sTags
                    break
                EditMP3sTags.Na_ListView.LV_Add(, Name)
                EditMP3sTags.Ti_ListView.LV_Add(, Title)
                EditMP3sTags.Ar_ListView.LV_Add(, Artist)
                EditMP3sTags.Al_ListView.LV_Add(, Album)
            }
            return
            EditMP3sOK(){
                global EditMP3sTags
                EditMP3sTags.Progress.do(, 1)
                NoEM := 0
                MD := Object()
                Loop, % EditMP3sTags.Na_ListView.LV_GetCount()
                {
                    n_Name := EditMP3sTags.Na_ListView.LV_GetText(A_Index, 1)
                    n_Title := EditMP3sTags.Ti_ListView.LV_GetText(A_Index, 1)
                    n_Artist := EditMP3sTags.Ar_ListView.LV_GetText(A_Index, 1)
                    n_Album := EditMP3sTags.Al_ListView.LV_GetText(A_Index, 1)
                    Name := EditMP3sTags.dict[A_Index]["Name"]
                    Path := EditMP3sTags.dict[A_Index]["Path"]
                    Title := EditMP3sTags.dict[A_Index]["Title"]
                    Artist := EditMP3sTags.dict[A_Index]["Artist"]
                    Album := EditMP3sTags.dict[A_Index]["Album"]
                    EditMP3sTags.dict[A_Index]["Name"] := n_Name
                    EditMP3sTags.dict[A_Index]["Title"] := n_Title
                    EditMP3sTags.dict[A_Index]["Artist"] := n_Artist
                    EditMP3sTags.dict[A_Index]["Album"] := n_Album
                    if (n_Name == Name and n_Title == Title and n_Artist == Artist and n_Album == Album)
                        continue
                    NoEM += 1
                    MD[NoEM, "Name"] := n_Name . ".mp3"
                    MD[NoEM, "Path"] := Path
                    MD[NoEM, "title"] := n_Title
                    MD[NoEM, "artist"] := n_Artist
                    MD[NoEM, "album"] := n_Album
                }
                For Key, Value in MD{
                    result := EditMP3TagsFunc(Value["Path"], Value, Value["Name"])
                    if (result != ""){
                        msgjoin("Error", result)
                        return
                    }
                    SplitPath, % Value["Path"], FileName, FileDir
                    EditMP3sTags.dict[Key]["Path"] := FileDir . "\" . Value["Name"]
                    EditMP3sTags.Progress.do(, (A_Index / NoEM) * 100)
                }
                msgjoin("Done")
            }
            MP3sLV(){
                global EditMP3sTags
                global PF
                if (A_GuiEvent == "I" and InStr(ErrorLevel, "S", true) and EditMP3sTags.current_selected_row != A_EventInfo){
                    EditMP3sTags.Na_ListView.LV_Modify(0, "Select0 Focus0")
                    EditMP3sTags.Ti_ListView.LV_Modify(0, "Select0 Focus0")
                    EditMP3sTags.Ar_ListView.LV_Modify(0, "Select0 Focus0")
                    EditMP3sTags.Al_ListView.LV_Modify(0, "Select0 Focus0")
                    EditMP3sTags.Na_ListView.LV_Modify(A_EventInfo, "Select1 Focus1")
                    EditMP3sTags.Ti_ListView.LV_Modify(A_EventInfo, "Select1 Focus1")
                    EditMP3sTags.Ar_ListView.LV_Modify(A_EventInfo, "Select1 Focus1")
                    EditMP3sTags.Al_ListView.LV_Modify(A_EventInfo, "Select1 Focus1")
                    EditMP3sTags.current_selected_row := A_EventInfo
                }else if (A_GuiEvent == "e" and A_GuiControl == "AGuiControlVar_Na_ListView"){
                    Name := EditMP3sTags.Na_ListView.LV_GetText(A_EventInfo, 1)
                    EditMP3sTags.Ti_ListView.LV_Modify(A_EventInfo, , RegExReplace(Name, "\.mp3$", ""))
                    EditMP3sTags.Editing := False
                }else if (A_GuiEvent == "E"){
                    EditMP3sTags.Editing := True
                    send, {Right}
                }
            }
#IfWinActive EditMP3sTags
            ^Tab::
                if (EditMP3sTags.Editing){
                    send, {Enter}{Tab}{F2}
                }else{
                    send, {Ctrl Tab}
                }
                return
            ^+Tab::
                if (EditMP3sTags.Editing){
                    send, {Enter}{Shift Tab}{F2}
                }else{
                    send, {Ctrl Shift Tab}
                }
                return
#IfWinActive
		register_launcher:
            configFD.read()
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
            RegisterLauncher := new AGui(, "RegisterLauncher")
            RegisterLauncher.read_font("registerlauncher")
            RegisterLauncher.Margin("10", "10")
            RegisterLauncher.add_agc("Text", "NameLabel", , "&Name")
			SplitPath, FilePath, FileName, FileDir
            RegisterLauncher.add_agc("Edit", "EName", "w800", FileName)
            RegisterLauncher.add_agc("Text", "CommandLabel", , "&Command")
            RegisterLauncher.add_agc("Edit", "ECommand", "w800", FilePath)
            RegisterLauncher.add_agc("Text", "WDLabel", , "&Working Directory")
            RegisterLauncher.add_agc("Edit", "EWD", "w800", FileDir)
            RegisterLauncher.add_agc("Text", "TypeLabel", , "Type")
			RegisterLauncher.add_agc("Radio", "RApp", RCApp, "&Application")
			RegisterLauncher.add_agc("Radio", "RLoc", RCLoc, "&LocalPath")
			RegisterLauncher.add_agc("Radio", "RURL", , "&URL")
			RegisterLauncher.add_agc("Radio", "RLab", , "&Label")
			RegisterLauncher.add_agc("Text", "ComputerLabel", , "Computer")
			RegisterLauncher.add_agc("Radio", "RThi", "Checked", "&ThisComputer")
			RegisterLauncher.add_agc("Radio", "RAll", , "&AllComputer")
			RegisterLauncher.add_agc("Button", "OK", "Default", "&OK")
            RegisterLauncher.OK.method := "RegisterLauncherOK"
			RegisterLauncher.remove_option("Resize")
			RegisterLauncher.show("Autosize", "RegisterLauncher")
			return
			RegisterLauncherOK:
                RegisterLauncher.Submit()
				B_ComputerName := ""
				if (RegisterLauncher.RThi.value = 1)
					B_ComputerName := A_ComputerName
				else if (RegisterLauncher.RAll.value = 1)
					B_ComputerName := "default"
                EName := RegisterLauncher.EName.value
				launcherFD.fdict[EName, B_ComputerName, "command"] := RegisterLauncher.ECommand.value
                launcherFD.fdict[EName, B_ComputerName, "working_dir"] := RegisterLauncher.EWD.value
				if (RegisterLauncher.RApp.value = 1)
					EType := "Application"
				else if (RegisterLauncher.RLoc.value = 1)
					EType := "LocalPath"
				else if (RegisterLauncher.RURL.value = 1)
					EType := "URL"
                else if (RegisterLauncher.RLab.value = 1)
                    EType := "Label"
				launcherFD.fdict[EName, B_ComputerName, "type"] := EType
				launcherFD.write()
                RegisterLauncher.Destroy()
				return
			open_with:
				msgjoin("未実装")
				return
		editmp3tags:
            configFD.read()
            EditMP3Tags := new AGui(, "EditMp3Tags")
            EditMP3Tags.read_font("editmp3tags")
            EditMP3Tags.Margin("10", "10")
			EditMP3Tags.remove_option("Border")
			EditMP3Tags.add_agc("Text", "NewNameLabel", , "&NewName")
			SplitPath, FilePath, FileName, FileDir
			Tags := GetMP3TagsFunc(FilePath)
            EditMP3Tags.add_agc("Edit", "ENewName", "w800", FileName)
            EditMP3Tags.ENewName.method := "NewNameChanged"
            EditMP3Tags.add_agc("Text", "TitleLabel", , "&Title")
			EditMP3Tags.add_agc("Edit", "ETitle", "w800", Tags[1])
			EditMP3Tags.add_agc("Text", "ArtistLabel", , "&Artist")
			EditMP3Tags.add_agc("Edit", "EArtist", "w800", Tags[2])
			EditMP3Tags.add_agc("Text", "AlbumLabel", , "&Album")
			EditMP3Tags.add_agc("Edit", "EAlbum", "w800", Tags[3])
			EditMP3Tags.add_agc("Button", "OK", "Default", "&OK")
            EditMP3Tags.OK.method := "EditMP3TagsOK"
            EditMP3Tags.remove_option("Resize")
			EditMP3Tags.show("Autosize", "EditMP3Tags")
			return
			NewNameChanged:
                EditMP3Tags.submit("NoHide")
                NewName := EditMP3Tags.ENewName.value
				SplitPath, NewName, , , , PureName
                EditMP3Tags.ETitle.value := PureName
				return
			EditMP3TagsOK:
                EditMP3Tags.submit()
                EditMP3Tags.destroy()
                dict := Object()
                dict["title"] := EditMP3Tags.ETitle.value
                dict["artist"] := EditMP3Tags.EArtist.value
                dict["album"] := EditMP3Tags.EAlbum.value
				EditMP3TagsFunc(FilePath, dict, EditMP3Tags.ENewName.value)
                ATooltip.display("Done", , , 1000)
				return
        copy_after_seven_days:
            solved_path := solvepath(FilePath)
            path := solved_path.path
            msgjoin(path . "\" . name)
            if (InStr(FileExist(FilePath), "D") != 0){
                FileCopyDir, %FilePath%, %path%%name%
            }else{
                FileCopy, %FilePath%, %path%%name%
            }
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
