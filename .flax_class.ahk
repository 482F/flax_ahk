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
        Str := ""
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
        global
        configFD.read()
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
        if (DriveLetter == ""){
            FilePath := this.SolveRelativePath(FilePath)
            SplitPath, FilePath, FileName, Dir, Extension, NameNoExt, DriveLetter
        }
		this.FilePath := FilePath
		this.FileName := FileName
		this.Dir := Dir
		this.Extension := Extension
		this.NameNoExt := NameNoExt
		this.DriveLetter := DriveLetter
		this.Encoding := Encoding
		this.Read()
	}
    SolveRelativePath(RelativePath){
        AbsolutePath := A_WorkingDir . "\" . Relativepath
        return AbsolutePath
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
        Object := 
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
	do(sub_command="", param=""){
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
    LV_Default(){
        this.gui.do("ListView", this.name)
    }
    LV_Add(options="", Col*){
        this.LV_Default()
        return LV_Add(options, Col*)
    }
    LV_Insert(RowNumber, Options="", Col*){
        this.LV_Default()
        return LV_Insert(RowNumber, Options, Col*)
    }
    LV_Modify(RowNumber, Options="", Col*){
        this.LV_Default()
        return LV_Modify(RowNumber, Options, Col*)
    }
    LV_Delete(RowNumber=""){
        this.LV_Default()
        return LV_Delete(RowNumber)
    }
    LV_GetCount(Type=""){
        this.LV_Default()
        return LV_GetCount(Type)
    }
    LV_GetNext(StartingRowNumber, Type=""){
        this.LV_Default()
        return LV_GetNext(StartingRowNumber, Type)
    }
    LV_GetText(RowNumber, ColumnNumber=""){
        this.LV_Default()
        LV_GetText(tmp, RowNumber, ColumnNumber)
        return tmp
    }
}
class AGuiControlText extends AGuiControl{
	__New(target_gui){
		base.__New(target_gui, "Text")
	}
}
class AInput{
    __New(){
        this.str := ""
        this.ErrorLevel := ""
    }
    input(){
        this.input_mode("off")
        Input, pressed_key, L1, {Enter} {Esc} {BackSpace}
        if (ErrorLevel == "EndKey:Backspace"){
            str := this.str
            StringTrimRight, str, str, 1
            this.str := str
        }else{
            this.str .= pressed_key
        }
        this.ErrorLevel := ErrorLevel
        this.input_mode("on")
        return ErrorLevel
    }
    input_mode(mode){
        BlockInput, %mode%
    }
}

ExecuteTimer:
	timerFD.execute_next()
	return


