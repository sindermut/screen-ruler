#SingleInstance force
Initialize()
{
	global Fuckers := {}
	static _ := !Initialize()
	IfEqual, _, 1, return 1
	
	;~ GuiColor := 0x3399FF
	Random, GuiColor, 0, 0xFFFFFF
	TextColor := 0xFFFFFF
	Transparency := 255
	
	try Gui New, -0x04CA0000 0x10000000 E0x080800A8 hwnd_
	Fuckers.sizebox := _
	try Gui New, -0x04CA0000 0x10000000 E0x080C0028 hwnd_ Owner%_%
	Fuckers.maingui := _

	DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", Fuckers.sizebox, "Int", 12, "Int*", 1, "Int", 4)
	DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", Fuckers.maingui, "Int", 12, "Int*", 1, "Int", 4)
	
	_ := DllCall("LoadCursor", "Int", 0, "Int", 32515, "Ptr") ; IDC_CROSS
	Loop, Parse, % "32512|32513|32514|32515|32516|32631|32640|32641|32642|32643|32644|32645|32646|32648|32649|32650|32651", |
		DllCall("SetSystemCursor", "Ptr", DllCall("CopyImage", "Ptr", _, "Int", 2, "Int", 0, "Int", 0, "Int", 0, "Ptr"), "Int", A_LoopField)
	DllCall("DestroyCursor", "Ptr", _)
	
	NumPut(0x200001, NumPut(A_ScreenHeight, NumPut(A_ScreenWidth, NumPut(VarSetCapacity(_, 40, 0), _, "Int"), "Int"), "Int"), "Int")
	Fuckers.hdc := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
	Fuckers.hbm := DllCall("CreateDIBSection", "Ptr", 0, "Ptr", &_, "Int", 0, "Ptr", 0, "Ptr", 0, "Int", 0, "Ptr")
	Fuckers.obm := DllCall("SelectObject", "Ptr", Fuckers.hdc, "Ptr", Fuckers.hbm, "Ptr")
	
	Fuckers.color := Transparency << 24 | GuiColor & 0xFFFFFF
	VarSetCapacity(_, 24, 0), NumPut(1, _)
	Fuckers.hModule := DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")
	DllCall("gdiplus\GdiplusStartup", "Ptr*", _, "Ptr", &_, "Ptr", 0)
	Fuckers.pToken := _
	
	DllCall("gdiplus\GdipCreateFromHDC", "Ptr", Fuckers.hdc, "Ptr*", _)
	DllCall("gdiplus\GdipSetCompositingMode", "Ptr", _, "Int", 0)
	DllCall("gdiplus\GdipSetCompositingQuality", "Ptr", _, "Int", 1)
	DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", _, "Int", 1)
	DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", _, "Int", 1)
	DllCall("gdiplus\GdipSetInterpolationMode", "Ptr", _, "Int", 2)
	DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", _, "Int", 5)
	Fuckers.graphic := _
	
	DllCall("gdiplus\GdipCreateSolidFill", "Int", 0xFF<<24|TextColor, "Ptr*", _)
	Fuckers.pBrush := _
	DllCall("gdiplus\GdipCreatePen1", "Int", 0xFF<<24|GuiColor, "Float", 1, "Int", 2, "Ptr*", _)
	Fuckers.pPen := _
	DllCall("gdiplus\GdipCreateFontFamilyFromName", "Str", "MS Shell Dlg", "Int", 0, "Ptr*", h)
	DllCall("gdiplus\GdipCreateFont", "Ptr", h, "Float", 11, "Int", 0, "Int", 0, "Ptr*", _)
	DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", h)
	Fuckers.pFont := _
	DllCall("gdiplus\GdipCreateStringFormat", "Int", 0x4000, "Int", 0, "Ptr*", _)
	DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", _, "Int", 1)
	DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", _, "Int", 1)
	Fuckers.strFormat := _
	
	CoordMode, Mouse
	MouseGetPos, h, _
	DrawGUI(h, _, 0, 0, 0)
	
	Menu, context, Add, Screenshot, PrepareScreenshot
	Menu, context, Add, Reload, Reload
	Menu, context, Add, Edit Script, Setting
	Menu, context, Add
	Menu, context, Add, Exit, GuiClose
	
	OnExit("Finalize")
	OnMessage(0x201, "Message")
	OnMessage(0x204, "Message")
	OnMessage(0x216, "Message")
	DllCall("SystemParametersInfo", "Int", 0x70, "Int", 0, "Int*", _, "Int", 0) ; SPI_GETMOUSESPEED
	Fuckers.MouseSpeed := _
	Fuckers.hMouseHook := DllCall("SetWindowsHookEx", "Int", 14, "Ptr", RegisterCallback("MouseHook", "Fast"), "Ptr", 0, "Int", 0, "Ptr")
	try return ErrorLevel for this Func while on class break
}

DrawGUI(posX1, posY1, posX2, posY2, mode)
{
	posX1 := posX1 < 0 ? 0 : posX1 > A_ScreenWidth ? A_ScreenWidth-1 : posX1
	posY1 := posY1 < 0 ? 0 : posY1 > A_ScreenHeight ? A_ScreenHeight-1 : posY1
	
	guiX := posX1 > A_ScreenWidth-95 ? A_ScreenWidth-95 : posX1 < 5 ? 5 : posX1
	guiY := posY1 > A_ScreenHeight-30 ? A_ScreenHeight-30 : posY1 < 5 ? 5 : posY1
	
	if (mode = 1)
	{
		DrawBox(posX1, posY1, posX2, posY2)
		DrawText(Abs(posX1 - posX2) + 1 " × " Abs(posY1 - posY2) + 1, guiX, guiY)
	}
	else DrawText("X " posX1 " Y " posY1, guiX, guiY)
}

DrawText(text, x, y)
{
	global Fuckers
	VarSetCapacity(RC, 16, 0) NumPut(12, NumPut(45, RC, "Float"), "Float")
	DllCall("gdiplus\GdipGraphicsClear", "Ptr", Fuckers.graphic, "Int", 0xFF<<24|Fuckers.color)
	DllCall("gdiplus\GdipDrawString", "Ptr", Fuckers.graphic, "Str", text, "Int", -1, "Ptr", Fuckers.pFont, "Ptr", &RC, "Ptr", Fuckers.strFormat, "Ptr", Fuckers.pBrush)
	DllCall("UpdateLayeredWindow", "Ptr", Fuckers.maingui, "Ptr", 0, "Int64*", x|y<<32, "Int64*", 90|25<<32, "Ptr", Fuckers.hdc, "Int64*", 0, "Int", 0, "Ptr", 0, "Int", 4)
}

DrawBox(X1, Y1, X2, Y2)
{
	global Fuckers
	x := X1 < X2 ? X1 : X2, y := Y1 < Y2 ? Y1 : Y2, w := Abs(X1 - X2) + 1, h := Abs(Y1 - Y2) + 1
	DllCall("gdiplus\GdipGraphicsClear", "Ptr", Fuckers.graphic, "Int", Fuckers.color)
	DllCall("gdiplus\GdipDrawRectangle", "Ptr", Fuckers.graphic, "Ptr", Fuckers.pPen, "Float", 0, "Float", 0, "Float", w-1, "Float", h-1)
	DllCall("UpdateLayeredWindow", "Ptr", Fuckers.sizebox, "Ptr", 0, "Int64*", x|y<<32, "Int64*", w|h<<32, "Ptr", Fuckers.hdc, "Int64*", 0, "Int", 0, "Int*", 0x1FF0000, "Int", 2)
}

Finish(text, x, y)
{
	global Fuckers
	try Gui, % Fuckers.maingui ":-E32"
	x := x > A_ScreenWidth-95 ? A_ScreenWidth-95 : x < 5 ? 5 : x
	y := y > A_ScreenHeight-65 ? A_ScreenHeight-65 : y < 5 ? 5 : y
	VarSetCapacity(RC, 16, 0) NumPut(6, NumPut(6, RC, "Float"), "Float")
	DllCall("gdiplus\GdipDrawString", "Ptr", Fuckers.graphic, "Str", "×", "Int", -1, "Ptr", Fuckers.pFont, "Ptr", &RC, "Ptr", Fuckers.strFormat, "Ptr", Fuckers.pBrush)
	VarSetCapacity(RC, 16, 0) NumPut(40, NumPut(45, RC, "Float"), "Float")
	DllCall("gdiplus\GdipDrawString", "Ptr", Fuckers.graphic, "Str", text, "Int", -1, "Ptr", Fuckers.pFont, "Ptr", &RC, "Ptr", Fuckers.strFormat, "Ptr", Fuckers.pBrush)
	DllCall("UpdateLayeredWindow", "Ptr", Fuckers.maingui, "Ptr", 0, "Int64*", x|y<<32, "Int64*", 90|60<<32, "Ptr", Fuckers.hdc, "Int64*", 0, "Int", 0, "Ptr", 0, "Int", 4)
}

Finalize()
{
	global Fuckers
	static _ := 1
	IfNotEqual, _, 1, return
	else VarSetCapacity(_,_,_)
	DllCall("UnhookWindowsHookEx", "Ptr", Fuckers.hMouseHook)
	DllCall("SystemParametersInfo", "Int", 0x57, "Int", 0,"Int", 0, "Int", 0)
	DllCall("SystemParametersInfo", "Int", 0x71, "Int", 0, "Ptr", Fuckers.MouseSpeed, "Int", 0)
	DllCall("gdiplus\GdipDeleteFont", "Ptr", Fuckers.pFont)
	DllCall("gdiplus\GdipDeletePen", "Ptr", Fuckers.pPen)
	DllCall("gdiplus\GdipDeleteBrush", "Ptr", Fuckers.pBrush)
	DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", Fuckers.strFormat)
	DllCall("gdiplus\GdipDeleteGraphics", "Ptr", Fuckers.graphic)
	DllCall("gdiplus\GdiplusShutdown", "Ptr", Fuckers.pToken)
	DllCall("FreeLibrary", "Ptr", Fuckers.hModule)
	DllCall("SelectObject", "Ptr", Fuckers.hdc, "Ptr", Fuckers.obm)
	DllCall("DeleteObject", "Ptr", Fuckers.hbm)
	DllCall("DeleteDC", "Ptr", Fuckers.hdc)
	DllCall("SetProcessWorkingSetSize", "Int", -1, "Int", -1, "Int", -1)
}

Screenshot(x, y, w, h)
{
	sdc := DllCall("GetDC", "Ptr", 0, "Ptr")
	ddc := DllCall("CreateCompatibleDC", "Ptr", sdc, "Ptr")
	hbm := DllCall("CreateCompatibleBitmap", "Ptr", sdc, "Int", w, "Int", h, "Ptr")
	obm := DllCall("SelectObject", "Ptr", ddc, "Ptr", hbm, "Ptr")
	DllCall("BitBlt", "Ptr", ddc, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", sdc, "Int", x, "Int", y, "Int", 0x40CC0020)
	FileSelectFile, file, 16, %A_Now%.bmp, Save As, Image files (*.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.jpe;*.jfif;*.gif;*.tif;*.tiff;*.png)
	if (file)
	{
		VarSetCapacity(_, 24, 0), NumPut(1, _)
		hModule := DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")
		DllCall("gdiplus\GdiplusStartup", "Ptr*", _, "Ptr", &_, "Ptr", 0)
		DllCall("gdiplus\GdipGetImageEncodersSize", "Int*", nCount, "Int*", nSize)
		VarSetCapacity(ci, nSize)
		DllCall("gdiplus\GdipGetImageEncoders", "Int", nCount, "Int", nSize, "Ptr", &ci)
		SplitPath, file,,, ext
		Loop % nCount
		{
			if InStr(StrGet(NumGet((clsid:=&ci+(A_Index-1)*(7*A_PtrSize+48))+3*A_PtrSize+32), "UTF-16"), ext)
			{
				DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hbm, "Ptr", 0, "Ptr*", pBitmap)
				DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "Str", file, "Ptr", clsid, "Ptr", 0)
				DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
			}
		}
		DllCall("gdiplus\GdiplusShutdown", "Ptr", _)
		DllCall("FreeLibrary", "Ptr", hModule)
	}
	DllCall("SelectObject", "Ptr", ddc, "Ptr", obm)
	DllCall("DeleteObject", "Ptr", hbm)
	DllCall("DeleteDC", "Ptr", ddc)
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", sdc)
	return pBitmap ? "Success" : file ? "Failed" : "Canceled"
}

MouseHook(nCode, wParam, lParam)
{
	Critical
	static mf := 0, oriX, oriY
	
	if (nCode = 0)
	{
		if (wParam = 0x200)
		{
			DrawGUI(NumGet(lParam+0, "Int"), NumGet(lParam+4, "Int"), oriX, oriY, mf)
		}
		else if (wParam = 0x201)
		{
			if (++mf = 1)
			{
				oriX := NumGet(lParam+0, "Int"), oriY := NumGet(lParam+4, "Int")
				DrawGUI(oriX, oriY, oriX, oriY, mf)
			}
			else if (mf = 2)
			{
				Finish("Start on`nX" oriX " Y" oriY, NumGet(lParam+0, "Int"), NumGet(lParam+4, "Int"))
				Hotkey, Shift Up,, Off
				Hotkey, Shift,, Off
				Finalize()
			}
		}
	}
	return DllCall("CallNextHookEx", "Int", 0, "Int", nCode, "Int", wParam, "Int", lParam)
}

Message(wParam, lParam, msg, hwnd)
{
	global Fuckers
	
	if (hwnd != Fuckers.maingui)
		return
	
	else if (msg = 0x216)
		Gui, Show, % "X" NumGet(lParam+0, "Int") "Y" NumGet(lParam+4, "Int") "W" NumGet(lParam+8, "Int") "H" NumGet(lParam+12, "Int") "NA"
	
	else if (msg = 0x204)
		Menu, context, Show
	
	else if (msg = 0x201)
	{
		PostMessage, 0xA1, 2
		X := lParam & 0xFFFF, Y := lParam >> 16
		if (X >= 2) && (X <= 11) && (Y >= 2) && (Y <= 11)
			ExitApp
	}
}

Enter::
PrepareScreenshot()
{
	global Fuckers
	Finalize()
	VarSetCapacity(RC, 16, 0)
	Gui, % Fuckers.sizebox ":Hide"
	Gui, % Fuckers.maingui ":+OwnDialogs"
	DllCall("GetWindowRect", "Ptr", Fuckers.sizebox, "Ptr", &RC)
	NumPut(NumGet(RC, 8, "Int64") - NumGet(RC, 0, "Int64"), RC, 8, "Int64")
	Screenshot(NumGet(RC, 0, "Int"), NumGet(RC, 4, "Int"), NumGet(RC, 8, "Int"), NumGet(RC, 12, "Int"))
	ExitApp
}

; set to slowest mouse speed while shift is pressed down
Shift::
Hotkey, Shift,, Off
DllCall("SystemParametersInfo", "Int", 0x71, "Int", 0, "Int", 1, "Int", 0) ; SPI_SETMOUSESPEED
return

Shift Up::
DllCall("SystemParametersInfo", "Int", 0x71, "Int", 0, "Ptr", Fuckers.MouseSpeed, "Int", 0)
Hotkey, Shift,, On
return

Reload:
Reload
return

Setting:
try Run, notepad.exe %A_ScriptFullPath%
return

!F4::
Esc::
GuiClose:
ExitApp
