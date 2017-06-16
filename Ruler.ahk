GuiColor     = 3399FF
TextColor    = FFFFFF
Transparency = 100
FontName     = MS Shell Dlg
FontSize     = 11

Width   = 90
Height  = 25
Height2 = 37

; file path for screenshot, enclose it in quote, use "Clipboard" to copy it to clipboard
ScreenshotDir := "Clipboard"

;============================================================================================================================;
;============================================================================================================================;
;============================================================================================================================;
#SingleInstance force
#KeyHistory, 0
ListLines, Off
SetWinDelay, -1
SetBatchLines, -1
OnExit("Finalize")
global gRuler := {}

try
{
	gRuler.Drawing := {}
	NumPut(VarSetCapacity(_, 40, 0), _), NumPut(A_ScreenWidth, _, 4), NumPut(A_ScreenHeight, _, 8), NumPut(0x200001, _, 12)
	gRuler.Drawing.DC := DllCall("CreateCompatibleDC", "Ptr", 0, "Ptr")
	gRuler.Drawing.Bitmap := DllCall("CreateDIBSection", "Ptr", 0, "Ptr", &_, "Int", 0, "Ptr", 0, "Ptr", 0, "Int", 0, "Ptr")
	gRuler.Drawing.defBitmap := DllCall("SelectObject", "Ptr", gRuler.Drawing.DC, "Ptr", gRuler.Drawing.Bitmap, "Ptr")
	if !(gRuler.Drawing.DC)
		throw Exception("Failed to create device context")
	
	VarSetCapacity(_, 24, 0), NumPut(1, _)
	gRuler.gdipModule := DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")
	DllCall("gdiplus\GdiplusStartup", "Ptr*", _, "Ptr", &_, "Ptr", 0)
	if !(gRuler.gdipModule && gRuler.gdipToken := _)
		throw Exception("Failed to initialize GDI+")
	
	DllCall("gdiplus\GdipCreateFromHDC", "Ptr", gRuler.Drawing.DC, "Ptr*", _)
	DllCall("gdiplus\GdipSetCompositingMode", "Ptr", _, "Int", 0)    ; CompositingMode::CompositingModeSourceOver
	DllCall("gdiplus\GdipSetCompositingQuality", "Ptr", _, "Int", 1) ; CompositingQuality::CompositingQualityHighSpeed
	DllCall("gdiplus\GdipSetPixelOffsetMode", "Ptr", _, "Int", 1)    ; PixelOffsetMode::PixelOffsetModeHighSpeed
	DllCall("gdiplus\GdipSetSmoothingMode", "Ptr", _, "Int", 1)      ; SmoothingMode::SmoothingModeHighSpeed
	DllCall("gdiplus\GdipSetInterpolationMode", "Ptr", _, "Int", 2)  ; InterpolationMode::InterpolationModeHighQuality
	DllCall("gdiplus\GdipSetTextRenderingHint", "Ptr", _, "Int", 5)  ; TextRenderingHint::TextRenderingHintClearTypeGridFit
	DllCall("gdiplus\GdipGraphicsClear", "Ptr", _, "Int", -1)        ; fill with solid white
	gRuler.Drawing.Graphics := _
	
	   DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", fontName, "Int", 0, "Ptr*", _) ; load the specified font to memory
	&& DllCall("gdiplus\GdipCreateFontFamilyFromName", "WStr", "MS Shell Dlg", "Int", 0, "Ptr*", _) ; invalid font, use default instead
	gRuler.Drawing.FontFamily := _
	DllCall("gdiplus\GdipCreateFont", "Ptr", gRuler.Drawing.FontFamily, "Float", fontSize+0 > 0 ? fontsize : 11, "Int", 0, "Int", 2, "Ptr*", _) ; style normal, size in pixels
	gRuler.Drawing.FontDefault := _
	DllCall("gdiplus\GdipCreateStringFormat", "Int", 0x4000, "Int", 0, "Ptr*", _) ; StringFormatFlags::StringFormatFlagsNoClip
	DllCall("gdiplus\GdipSetStringFormatLineAlign", "Ptr", _, "Int", 1) ; StringAlignment::StringAlignmentCenter
	DllCall("gdiplus\GdipSetStringFormatAlign", "Ptr", _, "Int", 1) ; StringAlignment::StringAlignmentCenter
	gRuler.Drawing.StrFormat := _
	
	width := width+0 > 0 ? width : 90, height := height+0 > 0 ? height : 25, height2 := height2+0 > 0 ? height2 : 37
	GuiColor  := GuiColor  ~= "i)^(?:0x)?[A-F\d]{6}$" ? InStr(GuiColor, "0x") ? GuiColor  : "0x"GuiColor  : 0x3399FF
	TextColor := TextColor ~= "i)^(?:0x)?[A-F\d]{6}$" ? InStr(TextColor, "0x") ? TextColor : "0x"TextColor : 0xFFFFFF
	gRuler.color := GuiColor & 0xFFFFFF | (Transparency+0 != "" ? Transparency & 0xFF : 100) << 24
	DllCall("gdiplus\GdipCreatePen1", "Int", 0xFF<<24|GuiColor, "Float", 1, "Int", 2, "Ptr*", _) ; pen width 1 pixel
	gRuler.Drawing.Pen := _
	DllCall("gdiplus\GdipCreateSolidFill", "Int", 0xFF<<24|TextColor, "Ptr*", _)
	gRuler.Drawing.Brush := _
	
	gRuler.Hwnd := {}
	; -0x00CA0000 = ~(WS_CAPTION | WS_SYSMENU | WS_MINIMIZEBOX)
	Gui New, -0x00CA0000 0x10000000 E0x08080008 hwnd_          ; WS_VISIBLE | WS_EX_NOACTIVATE | WS_EX_LAYERED | WS_EX_TOPMOST
	DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", _, "Int", 12, "Int*", 1, "Int", 4)
	gRuler.Hwnd.layer := _
	Gui New, -0x00CA0000 0x50000000 E0x00080020 hwnd_ Owner%_% ; WS_CHILD | WS_VISIBLE | WS_EX_LAYERED | WS_EX_TRANSPARENT
	DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", _, "Int", 12, "Int*", 1, "Int", 4)
	gRuler.Hwnd.sizebox := _
	Gui New, -0x00CA0000 0x50000000 E0x080C0020 hwnd_ Owner%_% ; WS_CHILD | WS_VISIBLE | WS_EX_NOACTIVATE | WS_EX_LAYERED | WS_EX_APPWINDOW | WS_EX_TRANSPARENT
	DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", _, "Int", 12, "Int*", 1, "Int", 4)
	gRuler.Hwnd.main := _
	if !(gRuler.Hwnd.layer && gRuler.Hwnd.sizebox && gRuler.Hwnd.main)
		throw Exception("Failed to create window")
	
	; create screen wide transparent layer to catch mouse move and clicks
	_ := (A_ScreenWidth & 0xFFFF) | (A_ScreenHeight & 0xFFFF) << 32
	DllCall("UpdateLayeredWindow", "Ptr", gRuler.Hwnd.layer, "Ptr", 0, "Ptr", 0, "Int64*", _, "Ptr", gRuler.Drawing.DC, "Int64*", 0, "Int", 0, "Int*", 0x10000, "Int", 2)
	gRuler.hCursor := DllCall("SetClassLong"(A_PtrSize=8?"Ptr":""), "Ptr", gRuler.Hwnd.layer, "Int", -12, "Ptr", DllCall("LoadCursor", "Int", 0, "Int", 32515), "Ptr") ; GCL_HCURSOR
	DllCall("SystemParametersInfo", "Int", 0x70, "Int", 0, "Int*", _, "Int", 0) ; SPI_GETMOUSESPEED
	gRuler.MouseSpeed := _
	
	OnMessage(0x200, "Message")
	OnMessage(0x201, "Message")
}
catch _
{
	MsgBox % _.Message
	ExitApp
}

; mode 0 = show current screen coordinate (X1, Y1)
; mode 1 = draw a box ( (X1, Y1) to (X2, Y2) ) and show its size ( |X1-X2|, |Y1-Y2| )
; mode 2 = show the box size ( |X1-X2|, |Y1-Y2| ) and its point of origin (X2, Y2)
DrawGUI(X1, Y1, X2, Y2, mode)
{
	global width, height, height2
	
	text := (mode = 0) ? "X " X1 " Y " Y1 : (Abs(X1 - X2) + 1) " × " (Abs(Y1 - Y2) + 1)
	, maxX := A_ScreenWidth-width-5, maxY := A_ScreenHeight-height-5
	, x := X1 > maxX ? maxX : X1 < 5 ? 5 : X1, y := Y1 > maxY ? maxY : Y1 < 5 ? 5 : Y1
	, VarSetCapacity(RC, 16, 0), NumPut(height/2, NumPut(width/2, RC, "Float"), "Float")
	
	, DllCall("gdiplus\GdipGraphicsClear", "Ptr", gRuler.Drawing.Graphics, "Int", 0xFF<<24|gRuler.color)
	, DllCall("gdiplus\GdipDrawString", "Ptr", gRuler.Drawing.Graphics, "WStr", text, "Int", -1, "Ptr", gRuler.Drawing.FontDefault, "Ptr", &RC, "Ptr", gRuler.Drawing.StrFormat, "Ptr", gRuler.Drawing.Brush)
	, DllCall("UpdateLayeredWindow", "Ptr", gRuler.Hwnd.main, "Ptr", 0, "Int64*", x|y<<32, "Int64*", width|height<<32, "Ptr", gRuler.Drawing.DC, "Int64*", 0, "Int", 0, "Ptr", 0, "Int", 4)
	
	if (mode = 1)
	{
		x := X1 < X2 ? X1 : X2, y := Y1 < Y2 ? Y1 : Y2, w := Abs(X1 - X2) + 1, h := Abs(Y1 - Y2) + 1
		, DllCall("gdiplus\GdipGraphicsClear", "Ptr", gRuler.Drawing.Graphics, "Int", gRuler.color)
		, DllCall("gdiplus\GdipDrawRectangle", "Ptr", gRuler.Drawing.Graphics, "Ptr", gRuler.Drawing.Pen, "Float", 0, "Float", 0, "Float", w-1, "Float", h-1)
		, DllCall("UpdateLayeredWindow", "Ptr", gRuler.Hwnd.sizebox, "Ptr", 0, "Int64*", x|y<<32, "Int64*", w|h<<32, "Ptr", gRuler.Drawing.DC, "Int64*", 0, "Int", 0, "Int*", 0x1FF0000, "Int", 2)
	}
	else if (mode = 2)
	{
		text := "Start on`nX" X2 " Y" Y2, maxY2 := maxY - height2, y := y > maxY2 ? maxY2 : y
		
		, NumPut(6, NumPut(width-6, RC, "Float"), "Float")
		, DllCall("gdiplus\GdipCreateFont", "Ptr", gRuler.Drawing.FontFamily, "Float", 13, "Int", 1, "Int", 2, "Ptr*", font)
		, DllCall("gdiplus\GdipDrawString", "Ptr", gRuler.Drawing.Graphics, "WStr", "×", "Int", 1, "Ptr", font, "Ptr", &RC, "Ptr", gRuler.Drawing.StrFormat, "Ptr", gRuler.Drawing.Brush)
		, DllCall("gdiplus\GdipDeleteFont", "Ptr", font)
		
		, NumPut(height+height2/2, NumPut(width/2, RC, "Float"), "Float")
		, DllCall("gdiplus\GdipDrawString", "Ptr", gRuler.Drawing.Graphics, "WStr", text, "Int", -1, "Ptr", gRuler.Drawing.FontDefault, "Ptr", &RC, "Ptr", gRuler.Drawing.StrFormat, "Ptr", gRuler.Drawing.Brush)
		, DllCall("UpdateLayeredWindow", "Ptr", gRuler.Hwnd.main, "Ptr", 0, "Int64*", x|y<<32, "Int64*", width|height+height2<<32, "Ptr", gRuler.Drawing.DC, "Int64*", 0, "Int", 0, "Ptr", 0, "Int", 4)
	}
}

Reset()
{
	DllCall("SystemParametersInfo", "Int", 0x71, "Int", 0, "Ptr", gRuler.MouseSpeed, "Int", 0)
	DllCall("SetClassLong"(A_PtrSize=8?"Ptr":""), "Ptr", gRuler.Hwnd.layer, "Int", -12, "Ptr", gRuler.hCursor)
	try Gui, % gRuler.Hwnd.main ":-E0x20" ; remove transparency
	try Gui, % gRuler.Hwnd.layer ":Hide"
	DllCall("psapi\EmptyWorkingSet", "Ptr", -1)
}

Finalize()
{
	Reset()
	DllCall("gdiplus\GdipDeletePen", "Ptr", gRuler.Drawing.Pen)
	DllCall("gdiplus\GdipDeleteBrush", "Ptr", gRuler.Drawing.Brush)
	DllCall("gdiplus\GdipDeleteFont", "Ptr", gRuler.Drawing.FontDefault)
	DllCall("gdiplus\GdipDeleteFontFamily", "Ptr", gRuler.Drawing.FontFamily)
	DllCall("gdiplus\GdipDeleteStringFormat", "Ptr", gRuler.Drawing.StrFormat)
	DllCall("gdiplus\GdipDeleteGraphics", "Ptr", gRuler.Drawing.Graphics)
	DllCall("gdiplus\GdiplusShutdown", "Ptr", gRuler.gdipToken)
	DllCall("FreeLibrary", "Ptr", gRuler.gdipModule)
	DllCall("SelectObject", "Ptr", gRuler.Drawing.DC, "Ptr", gRuler.Drawing.defBitmap)
	DllCall("DeleteObject", "Ptr", gRuler.Drawing.Bitmap)
	DllCall("DeleteDC", "Ptr", gRuler.Drawing.DC)
}

Message(wParam, lParam, msg, hwnd)
{
	if (hwnd = gRuler.Hwnd.layer)
	{
		static oriX := 0, oriY := 0, mode := 0, lastX, lastY
		X := lParam & 0xFFFF, Y := lParam >> 16
		
		if (msg = 0x200) ; WM_MOUSEMOVE
		{
			if (X != lastX || Y != lastY)
			{
				DrawGUI(lastX := X, lastY := Y, oriX, oriY, mode)
				Sleep, -1
			}
			return 0
		}
		else if (msg = 0x201) ; WM_LBUTTONDOWN
		{
			if (++mode = 1)
				DrawGUI(X, Y, oriX := X, oriY := Y, mode)
			
			else if (mode = 2)
			{
				OnMessage(0x200, "")
				OnMessage(0x216, "Message")
				DrawGUI(X, Y, oriX, oriY, mode)
				Reset()
			}
		}
	}
	else if (hwnd = gRuler.Hwnd.main)
	{
		if (msg = 0x216) ; WM_MOVING
		{		
			if GetKeyState("Control")
			{
				WinGetPos, x2, y2
				WinGetPos, x, y,,, % "ahk_id" gRuler.Hwnd.sizebox
				WinMove, % "ahk_id" gRuler.Hwnd.sizebox,, % NumGet(lParam+0, "Int") - x2 + x, % NumGet(lParam+4, "Int") - y2 + y
			}
			WinMove, % NumGet(lParam+0, "Int"), % NumGet(lParam+4, "Int")
		}
		else if (msg = 0x201) ; WM_LBUTTONDOWN
		{
			WinGetPos,,, w
			if ((x := lParam & 0xFFFF) >= w-12) && ((y := lParam >> 16) <= 12)
				ExitApp
			PostMessage, 0x112, 0xF012
		}
	}
}

GuiContextMenu(h)
{
	if (h != gRuler.Hwnd.main)
		return
	Menu, context, Add
	Menu, context, DeleteAll
	Menu, context, Add, Screenshot, PrepareScreenshot
	Menu, context, Add, Reload, Reload
	Menu, context, Add, Edit Script, Setting
	Menu, context, Add
	Menu, context, Add, Exit, GuiClose
	Menu, context, Show
	WinSet, Topmost, On
}
	
Enter::
PrepareScreenshot()
{
	global ScreenshotDir
	try
	{
		Reset()
		Hotkey, *Shift, Off
		Hotkey, *Shift Up, Off
		Gui, % gRuler.Hwnd.sizebox ":Hide"
		Gui, % gRuler.Hwnd.main ":Hide"
		Gui, % gRuler.Hwnd.main ":+OwnDialogs"
		DetectHiddenWindows, On
		WinGetPos, x, y, w, h, % "ahk_id" gRuler.Hwnd.sizebox
		Screenshot(x, y, w, h, ScreenshotDir)
	}
	finally ExitApp
}

Screenshot(x, y, w, h, file := "")
{
	sdc := DllCall("GetDC", "Ptr", 0, "Ptr")
	hbm := DllCall("CreateCompatibleBitmap", "Ptr", sdc, "Int", w, "Int", h, "Ptr")
	obm := DllCall("SelectObject", "Ptr", gRuler.Drawing.DC, "Ptr", hbm, "Ptr")
	
	DllCall("BitBlt", "Ptr", gRuler.Drawing.DC, "Int", 0, "Int", 0, "Int", w, "Int", h, "Ptr", sdc, "Int", x, "Int", y, "Int", 0x40CC0020) ; CAPTUREBLT | SRCCOPY
	DllCall("SelectObject", "Ptr", gRuler.Drawing.DC, "Ptr", obm)
	DllCall("ReleaseDC", "Ptr", 0, "Ptr", sdc)
	
	if (file = "Clipboard")
	{
		DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
		DllCall("EmptyClipboard")
		DllCall("SetClipboardData", "Int", 2, "Ptr", hbm) ; CF_BITMAP
		DllCall("CloseClipboard")
	}
	else while (!ErrorLevel)
	{
		if RegExMatch(file, "i)^[A-Z]\:[\\/](?:[^\\/]+[\\/])*[^\Q\/:*?<>""|\E]+\.(?P<ext>bmp|dib|rle|jpg|jpeg|jpe|jfif|gif|tif|tiff|png)[\\/]?$", file)
		{
			DllCall("gdiplus\GdipGetImageEncodersSize", "Int*", nCount, "Int*", nSize)
			DllCall("gdiplus\GdipGetImageEncoders", "Int", nCount, "Int", VarSetCapacity(ci, nSize), "Ptr", &ci)
			while (nCount-- && !InStr(StrGet(NumGet(32+(id:=&ci+(48+7*A_PtrSize)*nCount)+3*A_PtrSize), "UTF-16"), fileExt))
				continue
			DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hbm, "Ptr", 0, "Ptr*", pBitmap)
			DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "Str", file, "Ptr", id, "Ptr", 0)
			DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
			break
		}
		SplitPath, % file "\\", name, dir
		FileSelectFile, file, 16, % dir (name ? name : A_Now ".bmp"), Save As, Image files (*.bmp;*.dib;*.rle;*.jpg;*.jpeg;*.jpe;*.jfif;*.gif;*.tif;*.tiff;*.png)
	}
	DllCall("DeleteObject", "Ptr", hbm)
}

; set to slowest mouse speed while shift is pressed down
*Shift::
Hotkey, *Shift, Off
DllCall("SystemParametersInfo", "Int", 0x71, "Int", 0, "Int", 1, "Int", 0) ; SPI_SETMOUSESPEED
return

*Shift Up::
DllCall("SystemParametersInfo", "Int", 0x71, "Int", 0, "Ptr", gRuler.MouseSpeed, "Int", 0)
Hotkey, *Shift, On
return

Setting:
Edit
return

Reload:
Reload

!F4::
Esc::
GuiClose:
ExitApp
