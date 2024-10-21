;===================
; Next Tile Machine
;===================
;
; By Bruno Vignoli
; (c) 2024 MIT
;
;===================

UsePNGImageDecoder()
UseJPEGImageDecoder()
UseGIFImageDecoder()

; declarations
Declare generate_default_palettes()
Declare ResetLayer2()
Declare DrawTileBorder(x.l, y.l, width.l, height.l)
Declare FillRightPalette()
Declare CreateTiles()
Declare RedrawTiles()
Declare UpdatePalette16()
Declare RedrawTileView()
Declare RedrawMap()
Declare RedrawScreen()

; constants
#MAX_REAL_PALETTE_COLORS512 = 512
#MAX_REAL_PALETTE_COLORS256 = 256
#MAX_PALETTE_COLORS = 256
#MAX_TILES_BY_FRAME = 64

#L2_PALETTE = 1

#PALETTE512 = 1
#PALETTE256 = 2

#MAX_MAP_WIDTH = 256
#MAX_MAP_HEIGHT = 256

#WINDOW = 0
#PANEL = 1
#CANVAS_LEFT = 2
#CANVAS_RIGHT = 5
#BUTTON1 = 6
#BUTTON2 = 7
#BUTTON3 = 8
#STRING = 9
#BUTTON_IMPORT_PALETTE = 11
#BUTTON_EXPORT_PALETTE = 12
#CANVAS_LEFT2 = 3
#CANVAS_LEFT3 = 4
#CANVAS_RIGHT2 = 13
#CANVAS_DOWN2 = 14
#SCROLLBAR1 = 15
#BUTTON4 = 16
#BUTTON5 = 17
#BUTTON_IMPORT_TILES = 18
#BUTTON_EXPORT_TILES = 19
#BUTTON6 = 20
#BUTTON7 = 21
#BUTTON8 = 22
#BUTTON9 = 23
#BUTTON10 = 24
#BUTTON11 = 25
#BUTTON12 = 26
#CANVAS_RIGHT3 = 27
#BUTTON13 = 28
#BUTTON_IMPORT_TILEMAP = 29
#BUTTON_EXPORT_TILEMAP = 30
#SPIN1 = 31
#SPIN2 = 32
#SCROLLAREA3 = 33
#LABEL = 34
#CHECKBOX = 35
#CANVAS_LEFT4 = 36
#BUTTON_IMPORT_SCREEN = 37
#BUTTON_EXPORT_SCREEN = 38
#SPIN3 = 39
#SPIN4 = 40
#OPTION1 = 41
#OPTION2 = 42
#OPTION3 = 43

; vars & arrays
Global Dim palette9.l(#MAX_REAL_PALETTE_COLORS512)
Global Dim palette8.l(#MAX_REAL_PALETTE_COLORS256)
Global Dim paletteL2.l(#MAX_PALETTE_COLORS)
Global Dim img.l(#MAX_TILES_BY_FRAME, 8, 8)
Global Dim selpal.l(#MAX_TILES_BY_FRAME)
Global Dim cb.l(8, 8)
Global Dim tilemap.l(#MAX_MAP_WIDTH, #MAX_MAP_HEIGHT)

Global selected_color.l
Global selected_palette.l
Global selectedX.l
Global selectedY.l
Global selected_new_color.l
Global palette_type.l
Global xtile.l
Global ytile.l
Global selected_palette16.l
Global selected_pen.l
Global selected_img.l
Global map_width.l
Global map_height.l

; initialize palette
generate_default_palettes()

; program version
version$ = "v0.2.0"

; open the window
If OpenWindow(#WINDOW, 0, 0, 640, 325, "Next Tile Machine " + version$, #PB_Window_ScreenCentered|#PB_Window_MinimizeGadget)
  ; add gadgets
  PanelGadget(#PANEL, 0, 0, 640, 480)
  AddGadgetItem(#PANEL, -1, "Palettes")
  CanvasGadget(#CANVAS_LEFT, 0, 0, 256, 256)
  CanvasGadget(#CANVAS_RIGHT, 272, 0, 256, 256)
  ButtonGadget(#BUTTON1, 0, 256, 128, 20, "Reset L2 (256 colors)")
  ButtonGadget(#BUTTON2, 272, 256, 64, 20, "Search...")
  ButtonGadget(#BUTTON3, 400, 256, 128, 20, "9 bits colors (512)")
  StringGadget(#STRING, 336, 256, 64, 20, "$fff", #PB_String_LowerCase)
  ButtonGadget(#BUTTON_IMPORT_PALETTE, 532, 0, 96, 20, "Import Palette")
  ButtonGadget(#BUTTON_EXPORT_PALETTE, 532, 20, 96, 20, "Export Palette")
  AddGadgetItem(#PANEL, -1, "Tiles")
  CanvasGadget(#CANVAS_LEFT2, 0, 0, 256, 256)
  CanvasGadget(#CANVAS_RIGHT2, 272, 0, 256, 256)
  CanvasGadget(#CANVAS_DOWN2, 0, 256, 256, 16)
  ButtonGadget(#BUTTON_IMPORT_TILES, 532, 0, 96, 20, "Import Tiles")
  ButtonGadget(#BUTTON_EXPORT_TILES, 532, 20, 96, 20, "Export Tiles")
  ScrollBarGadget(#SCROLLBAR1, 0, 272, 256, 16, 0, 15, 1)
  ButtonGadget(#BUTTON6, 272, 256, 40, 20, "Cut")
  ButtonGadget(#BUTTON7, 312, 256, 40, 20, "Copy")
  ButtonGadget(#BUTTON8, 352, 256, 40, 20, "Paste")
  ButtonGadget(#BUTTON9, 392, 256, 40, 20, "Delete")
  ButtonGadget(#BUTTON10, 432, 256, 100, 20, "Rotate")
  ButtonGadget(#BUTTON11, 432, 276, 50, 20, "Mirror X")
  ButtonGadget(#BUTTON12, 482, 276, 50, 20, "Mirror Y")
  AddGadgetItem(#PANEL, -1, "TileMap")
  ScrollAreaGadget(#SCROLLAREA3, 0, 0, 256, 256, 256, 256, 16, #PB_ScrollArea_Flat)
  CanvasGadget(#CANVAS_LEFT3, 0, 0, 256, 256)
  CloseGadgetList()
  CanvasGadget(#CANVAS_RIGHT3, 272, 0, 256, 256)
  ButtonGadget(#BUTTON13, 532, 0, 100, 20, "New TileMap")
  ButtonGadget(#BUTTON_IMPORT_TILEMAP, 532, 20, 100, 20, "Import TileMap")
  ButtonGadget(#BUTTON_EXPORT_TILEMAP, 532, 40, 100, 20, "Export TileMap")
  SpinGadget(#SPIN1, 532, 80, 100, 20, 1, 256, #PB_Spin_Numeric)
  SpinGadget(#SPIN2, 532, 100, 100, 20, 1, 256, #PB_Spin_Numeric)
  SpinGadget(#SPIN3, 532, 140, 100, 20, 1, 256, #PB_Spin_Numeric)
  SpinGadget(#SPIN4, 532, 160, 100, 20, 1, 256, #PB_Spin_Numeric)
  TextGadget(#LABEL, 0, 256, 128, 25, "", #PB_Text_Border)
  CheckBoxGadget(#CHECKBOX, 128, 256, 128, 20, "Export 2 bytes")
  AddGadgetItem(#PANEL, -1, "Screens")
  CanvasGadget(#CANVAS_LEFT4, 0, 0, 320, 256)
  ButtonGadget(#BUTTON_IMPORT_SCREEN, 328, 0, 100, 20, "Import Screen")
  ButtonGadget(#BUTTON_EXPORT_SCREEN, 328, 20, 100, 20, "Export Screen")
  OptionGadget(#OPTION1, 328, 60, 100, 20, "No Split")
  OptionGadget(#OPTION2, 328, 80, 100, 20, "Split 16ko")
  OptionGadget(#OPTION3, 328, 100, 100, 20, "Split 8ko")
  CloseGadgetList()
  
  ; 9 bits palette by default
  palette_type = #PALETTE512
  
  ; fill right palette
  FillRightPalette()
  
  ; reset layer2 palette
  ResetLayer2()
  
  ; initialize tiles
  xtile = 0
  ytile = 0
  selected_palette16 = 0
  selected_pen = 0
  selected_img = 0
  CreateTiles()
  RedrawTiles()
  UpdatePalette16()
  
  SetGadgetText(#SPIN1, "")
  SetGadgetText(#SPIN2, "")
  DisableGadget(#SPIN1, #True)
  DisableGadget(#SPIN2, #True)
  
  SetGadgetText(#SPIN3, "40")
  SetGadgetText(#SPIN4, "32")

  StartDrawing(CanvasOutput(#CANVAS_DOWN2))
  DrawingMode(#PB_2DDrawing_AllChannels)
  DrawTileBorder(selected_pen * 16, 0, 16, 16)
  StopDrawing()
  
  RedrawScreen()
  
  SetGadgetState(#OPTION1, 1)
  
  Repeat
    ev = WaitWindowEvent(10)
    
    Select ev
      Case #PB_Event_CloseWindow
        Break
      Case #PB_Event_Gadget
        eg = EventGadget()
        et = EventType()
        
        Select eg
          Case #CANVAS_LEFT
            If et = #PB_EventType_LeftClick
              xm.l = WindowMouseX(#WINDOW)
              ym.l = WindowMouseY(#WINDOW)
              
              If xm >= 0 And ym >= 0
                xm - GadgetX(eg, #PB_Gadget_WindowCoordinate) - GadgetX(1, #PB_Gadget_WindowCoordinate)
                ym - GadgetY(eg, #PB_Gadget_WindowCoordinate) - GadgetY(1, #PB_Gadget_WindowCoordinate)
                
                xt.l = Round(xm / 16, #PB_Round_Down)
                yt.l = Round(ym / 16, #PB_Round_Down)
                
                xm = xt * 16
                ym = yt * 16
                
                StartDrawing(CanvasOutput(#CANVAS_LEFT))
                DrawingMode(#PB_2DDrawing_AllChannels)
                Box(selectedX * 16, selectedY * 16, 16, 16, paletteL2(selected_color))
                selected_color = xt + (yt * 16)
                selectedX = xt
                selectedY = yt
                DrawTileBorder(selectedX * 16, selectedY * 16, 16, 16)
                StopDrawing()
              EndIf
            EndIf
          Case #CANVAS_RIGHT
            If et = #PB_EventType_LeftClick
              xm.l = WindowMouseX(#WINDOW)
              ym.l = WindowMouseY(#WINDOW)
              
              If xm >= 0 And ym >= 0
                xm - GadgetX(eg, #PB_Gadget_WindowCoordinate) - GadgetX(1, #PB_Gadget_WindowCoordinate)
                ym - GadgetY(eg, #PB_Gadget_WindowCoordinate) - GadgetY(1, #PB_Gadget_WindowCoordinate)
                
                xt.l = Round(xm / (8 * palette_type), #PB_Round_Down)
                yt.l = Round(ym / 16, #PB_Round_Down)
                
                ; grab future new color
                grabbed_color.l = (xt + (yt * 32 / palette_type))
                
                ; set left palette color
                If grabbed_color <> 454 And grabbed_color <> 455
                  If selected_color <> 227
                    If palette_type = #PALETTE512
                      paletteL2(selected_color) = palette9(grabbed_color)
                    Else
                      paletteL2(selected_color) = palette8(grabbed_color)
                    EndIf
                  EndIf
                EndIf
                
                yt.l = selected_new_color / (32 / palette_type)
                xt.l = selected_new_color - (yt * 32 / palette_type)
                
                ; clear the selection on old new color (right side)
                StartDrawing(CanvasOutput(#CANVAS_RIGHT))
                DrawingMode(#PB_2DDrawing_AllChannels)
                pl.l = palette9(selected_new_color)
                
                If palette_type = #PALETTE256
                  pl = palette8(selected_new_color)
                EndIf
                
                Box(xt * 8 * palette_type, yt * 16, 8 * palette_type, 16, pl)
                StopDrawing()
                
                ; update new selection
                selected_new_color = grabbed_color
                yt.l = selected_new_color / (32 / palette_type)
                xt.l = selected_new_color - (yt * 32 / palette_type)
                
                ; draw new selection (right side)
                StartDrawing(CanvasOutput(#CANVAS_RIGHT))
                DrawingMode(#PB_2DDrawing_AllChannels)
                DrawTileBorder(xt * 8 * palette_type, yt * 16, 8 * palette_type, 16)
                StopDrawing()
                
                ; update left palettes
                r.l = 0
                g.l = 0
                b.l = 0
                
                StartDrawing(CanvasOutput(#CANVAS_LEFT))
                DrawingMode(#PB_2DDrawing_AllChannels)
                Box(selectedX * 16, selectedY * 16, 16, 16, paletteL2(selected_color))
                DrawTileBorder(selectedX * 16, selectedY * 16, 16, 16)
                r = Red(paletteL2(selected_color)) >> 4
                g = Green(paletteL2(selected_color)) >> 4
                b = Blue(paletteL2(selected_color)) >> 4
                StopDrawing()
                
                ; show hexa code
                SetGadgetText(#STRING, "$" + Hex(r) + Hex(g) + Hex(b))
                
                ; update palette 16
                UpdatePalette16()
                RedrawTiles()
                RedrawMap()
              EndIf
            EndIf
          Case #BUTTON1
            generate_default_palettes()
            ResetLayer2()
            RedrawTiles()
            RedrawMap()
            UpdatePalette16()
          Case #BUTTON2
            hexa_color.s = GetGadgetText(#STRING)
            
            If Left(hexa_color, 1) = "$"
              hexa_color = Mid(hexa_color, 2)
              hexa_color_real.s = ""
              
              If Len(hexa_color) = 3
                For i = 1 To 3
                  letter.s = Mid(hexa_color, i, 1)
                  
                  If (letter >= "0" And letter <= "9") Or (letter >= "a" And letter <= "f")
                    hexa_color_real = hexa_color_real + letter
                  Else
                    MessageRequester("Error", "Wrong hexa number!", #PB_MessageRequester_Error)
                  EndIf
                Next
                
                If hexa_color_real <> ""
                  value_red.l = Val("$" + Mid(hexa_color_real, 1, 1))
                  value_green.l = Val("$" + Mid(hexa_color_real, 2, 1))
                  value_blue.l = Val("$" + Mid(hexa_color_real, 3, 1))
                  
                  ptr.l = 0
                  
                  While value_red >= 0 And value_green >= 0 And value_blue >= 0
                    For i = 0 To 511
                      vr.l = Red(palette9(i))
                      vg.l = Green(palette9(i))
                      vb.l = Blue(palette9(i))
                      
                      If palette_type = #PALETTE256
                        vr = Red(palette8(i / 2))
                        vg = Green(palette8(i / 2))
                        vb = Blue(palette8(i / 2))
                      EndIf
                        
                      If value_red = vr >> 4
                        If value_green = vg >> 4
                          If value_blue = vb >> 4
                            yt.l = selected_new_color / 32
                            xt.l = selected_new_color - (yt * 32)
                            
                            StartDrawing(CanvasOutput(#CANVAS_RIGHT))
                            DrawingMode(#PB_2DDrawing_AllChannels)
                            pl.l = palette9(selected_new_color)
                            
                            If palette_type = #PALETTE256
                              pl = palette8(selected_new_color)
                            EndIf
                            
                            Box(xt * 8, yt * 16, 8, 16, pl)
                            StopDrawing()
                            
                            selected_new_color = i
                            yt.l = selected_new_color / 32
                            xt.l = selected_new_color - (yt * 32)
                            
                            StartDrawing(CanvasOutput(#CANVAS_RIGHT))
                            DrawingMode(#PB_2DDrawing_AllChannels)
                            DrawTileBorder(xt * 8, yt * 16, 8, 16)
                            StopDrawing()
                            
                            ; update left palettes
                            StartDrawing(CanvasOutput(#CANVAS_LEFT))
                            DrawingMode(#PB_2DDrawing_AllChannels)
                            pl.l = palette9(selected_new_color)
                            
                            If palette_type = #PALETTE256
                              pl = palette8(selected_new_color)
                            EndIf
                            
                            paletteL2(selected_color) = pl
                            Box(selectedX * 16, selectedY * 16, 16, 16, paletteL2(selected_color))
                            DrawTileBorder(selectedX * 16, selectedY * 16, 16, 16)
                            StopDrawing()
                            
                            SetGadgetText(#STRING, "$" + Hex(value_red) + Hex(value_green) + Hex(value_blue))
                            
                            Break(2)
                          EndIf
                        EndIf
                      EndIf
                    Next
                    
                    Select ptr
                      Case 0
                        value_red - 1
                      Case 1
                        value_green - 1
                      Case 2
                        value_blue - 1
                    EndSelect                    
                    
                    ptr = Mod(ptr + 1, 3)
                  Wend
                EndIf
              Else
                MessageRequester("Error", "Hexa number wrong format!", #PB_MessageRequester_Error)
              EndIf
            Else
              MessageRequester("Error", "Missing $ before hexa number!", #PB_MessageRequester_Error)
            EndIf
            
            RedrawTiles()
            RedrawMap()
          Case #BUTTON3
            generate_default_palettes()
            ResetLayer2()

            If palette_type = #PALETTE512
              palette_type = #PALETTE256
              SetGadgetText(#BUTTON3, "8 bits colors (256)")
            Else
              palette_type = #PALETTE512
              SetGadgetText(#BUTTON3, "9 bits colors (512)")
            EndIf
            
            FillRightPalette()
            ResetLayer2()                        
            RedrawTiles()
            RedrawMap()
          Case #BUTTON_IMPORT_PALETTE
            f$ = OpenFileRequester("Import Palette...", "*.pal", "Palettes|*.pal", 0)
            
            If f$ <> ""
              If GetExtensionPart(f$) = ""
                f$ = f$ + ".pal"
              EndIf
              
              If ReadFile(1, f$, #PB_Ascii)
                If Lof(1) = 512
                  For i = 0 To 255
                    col8.a = ReadAsciiCharacter(1)
                    col1.a = ReadAsciiCharacter(1)
                    col9.w = (col8 << 1) | col1
                    paletteL2(i) = palette9(col9)
                  Next
                  
                  palette_type = #PALETTE512
                ElseIf Lof(1) = 256
                  For i = 0 To 255
                    col8.a = ReadAsciiCharacter(1)
                    j.l = col8
                    paletteL2(i) = palette8(j)
                  Next
                  
                  palette_type = #PALETTE256
                Else
                  MessageRequester("Error", "Not a recognised palette!", #PB_MessageRequester_Error)
                EndIf
                
                CloseFile(1)
                
                If palette_type = #PALETTE512
                  SetGadgetText(#BUTTON3, "9 bits colors (512)")
                Else
                  SetGadgetText(#BUTTON3, "8 bits colors (256)")
                EndIf
                
                FillRightPalette()
                ResetLayer2()                
                                
                selected_img = 0
                selected_pen = 0
                RedrawTiles()
                RedrawMap()
                UpdatePalette16()
              EndIf
            EndIf
            
            ResetLayer2()
          Case #BUTTON_EXPORT_PALETTE
            f$ = SaveFileRequester("Export Palette...", "*.pal", "Palettes|*.pal", 0)
            
            If f$ <> ""
              If GetExtensionPart(f$) = ""
                f$ = f$ + ".pal"
              EndIf
              
              If CreateFile(1, f$, #PB_Ascii)
                If palette_type = #PALETTE512
                  For i = 0 To 255
                    For j = 0 To 511
                      If paletteL2(i) = palette9(j)
                        WriteAsciiCharacter(1, (j & %111111110) >> 1)
                        WriteAsciiCharacter(1, j & %00000001)
                        Break
                      EndIf
                    Next
                  Next
                Else
                  For i = 0 To 255
                    For j = 0 To 255
                      If paletteL2(i) = palette8(j)
                        k.a = j
                        WriteAsciiCharacter(1, k)
                        Break
                      EndIf
                    Next
                  Next
                EndIf
                
                CloseFile(1)
              EndIf
            EndIf
          Case #SCROLLBAR1
            selected_palette16 = GetGadgetState(#SCROLLBAR1)
            selpal(selected_img) = selected_palette16
            UpdatePalette16()
            RedrawTiles()
                            
            StartDrawing(CanvasOutput(#CANVAS_DOWN2))
            DrawingMode(#PB_2DDrawing_AllChannels)
            DrawTileBorder(selected_pen * 16, 0, 16, 16)
            StopDrawing()            
          Case #CANVAS_DOWN2
            If et = #PB_EventType_LeftClick
              xm.l = WindowMouseX(#WINDOW)
              ym.l = WindowMouseY(#WINDOW)
              
              If xm >= 0 And ym >= 0
                xm - GadgetX(eg, #PB_Gadget_WindowCoordinate) - GadgetX(1, #PB_Gadget_WindowCoordinate)
                xt.l = Round(xm / 16, #PB_Round_Down)
                
                selected_pen = xt
                UpdatePalette16()
                
                StartDrawing(CanvasOutput(#CANVAS_DOWN2))
                DrawingMode(#PB_2DDrawing_AllChannels)
                DrawTileBorder(selected_pen * 16, 0, 16, 16)
                StopDrawing()
              EndIf
            EndIf
          Case #CANVAS_LEFT2
            If GetGadgetAttribute(eg, #PB_Canvas_Buttons) = #PB_Canvas_LeftButton
              xm.l = WindowMouseX(#WINDOW)
              ym.l = WindowMouseY(#WINDOW)
              
              If xm >= 0 And ym >= 0
                xm - GadgetX(eg, #PB_Gadget_WindowCoordinate) - GadgetX(1, #PB_Gadget_WindowCoordinate)
                ym - GadgetY(eg, #PB_Gadget_WindowCoordinate) - GadgetY(1, #PB_Gadget_WindowCoordinate)
                
                xt.l = xm / 32
                yt.l = ym / 32
                
                img(selected_img, xt, yt) = selected_pen
                RedrawTiles()
              EndIf
            EndIf
          Case #CANVAS_RIGHT2, #CANVAS_RIGHT3
            If et = #PB_EventType_LeftClick
              xm.l = WindowMouseX(#WINDOW)
              ym.l = WindowMouseY(#WINDOW)
              
              If xm >= 0 And ym >= 0
                xm - GadgetX(eg, #PB_Gadget_WindowCoordinate) - GadgetX(1, #PB_Gadget_WindowCoordinate)
                ym - GadgetY(eg, #PB_Gadget_WindowCoordinate) - GadgetY(1, #PB_Gadget_WindowCoordinate)
                
                xt.l = xm / 32
                yt.l = ym / 32
                
                selected_img = xt + (yt * 8)
                RedrawTiles()
              EndIf
            EndIf
          Case #BUTTON_IMPORT_TILES
            f$ = OpenFileRequester("Import Tiles...", "*.til", "Sprites|*.til", 0)
            
            If f$ <> ""
              If GetExtensionPart(f$) = ""
                f$ = f$ + ".spr"
              EndIf
              
              If ReadFile(1, f$, #PB_Ascii)
                If Lof(1) = 64 * (8 * 8) / 2
                  For i = 0 To 63
                    For y = 0 To 7
                      For x = 0 To 7 Step 2
                        byte.a = ReadAsciiCharacter(1)
                        img(i, x, y) = (byte & %11110000) >> 4
                        img(i, x + 1, y) = byte & %00001111
                      Next
                    Next
                  Next
                Else
                  MessageRequester("Error", "Not a recognised set of tiles!", #PB_MessageRequester_Error)
                EndIf
                
                CloseFile(1)
              EndIf
            EndIf
            
            ResetLayer2()
          Case #BUTTON_EXPORT_TILES
            f$ = SaveFileRequester("Export Tiles...", "*.til", "Sprites|*.til", 0)
            
            If f$ <> ""
              If GetExtensionPart(f$) = ""
                f$ = f$ + ".spr"
              EndIf
              
              If CreateFile(1, f$, #PB_Ascii)
                For i = 0 To 63
                  For y = 0 To 7
                    For x = 0 To 7 Step 2
                      byte.a = (img(i, x, y) << 4) | img(i, x + 1, y)
                      WriteAsciiCharacter(1, byte)
                    Next
                  Next
                Next
                
                CloseFile(1)
              EndIf
            EndIf
          Case #BUTTON6
            For y = 0 To 7
              For x = 0 To 7
                cb(x, y) = img(selected_img, x, y)
                img(selected_img, x, y) = 0
              Next
            Next
            
            RedrawTiles()
          Case #BUTTON7
            ClearClipboard()
            
            For y = 0 To 7
              For x = 0 To 7
                cb(x, y) = img(selected_img, x, y)
              Next
            Next
          Case #BUTTON8
            For y = 0 To 7
              For x = 0 To 7
                img(selected_img, x, y) = cb(x, y)
              Next
            Next
            
            RedrawTiles()
          Case #BUTTON9
            For y = 0 To 7
              For x = 0 To 7
                img(selected_img, x, y) = 0
              Next
            Next
            
            RedrawTiles()
          Case #BUTTON10
            For y = 0 To 7
              For x = 0 To 7
                cb(7 - y, x) = img(selected_img, x, y)
              Next
            Next
            
            For y = 0 To 7
              For x = 0 To 7
                img(selected_img, x, y) = cb(x, y)
              Next
            Next
            
            RedrawTiles()
          Case #BUTTON11
            For y = 0 To 7
              For x = 0 To 3
                vleft.l = img(selected_img, x, y)
                vright.l = img(selected_img, 7 - x, y)
                img(selected_img, x, y) = vright
                img(selected_img, 7 - x, y) = vleft
              Next
            Next
            
            RedrawTiles()
          Case #BUTTON12
            For x = 0 To 7
              For y = 0 To 3
                vup.l = img(selected_img, x, y)
                vdown.l = img(selected_img, x, 7 - y)
                img(selected_img, x, y) = vdown
                img(selected_img, x, 7 - y) = vup
              Next
            Next
            
            RedrawTiles()
          Case #BUTTON13
            w$ = InputRequester("TileMap Width", "Please input the TileMap Width...", "64", #WINDOW)
            h$ = InputRequester("TileMap Height", "Please input the TileMap Height...", "64", #WINDOW)
            
            map_width = Val(w$)
            map_height = Val(h$)
            
            If map_width > 0 And map_width <= #MAX_MAP_WIDTH
              If map_height > 0 And map_height <= #MAX_MAP_HEIGHT
                SetGadgetText(#SPIN1, w$)
                SetGadgetText(#SPIN2, h$)
              EndIf
            EndIf
            
            For y = 0 To map_height - 1
              For x = 0 To map_width - 1
                tilemap(x, y) = 0
              Next
            Next
            
            SetGadgetAttribute(#SCROLLAREA3, #PB_ScrollArea_InnerWidth, 16 * map_width)
            SetGadgetAttribute(#SCROLLAREA3, #PB_ScrollArea_InnerHeight, 16 * map_height)
            SetGadgetAttribute(#SCROLLAREA3, #PB_ScrollArea_ScrollStep, 16)
            ResizeGadget(#CANVAS_LEFT3, 0, 0, 16 * map_width, 16 * map_height)
            RedrawMap()
          Case #BUTTON_IMPORT_TILEMAP
            f$ = OpenFileRequester("Import TileMap...", "*.map", "TileMaps|*.map", 0)
            
            If f$ <> ""
              If GetExtensionPart(f$) = ""
                f$ = f$ + ".map"
              EndIf
              
              w$ = InputRequester("TileMap Width", "Please input the TileMap Width...", "64", #WINDOW)
              h$ = InputRequester("TileMap Height", "Please input the TileMap Height...", "64", #WINDOW)
              
              map_width = Val(w$)
              map_height = Val(h$)
              
              If map_width > 0 And map_width <= #MAX_MAP_WIDTH
                If map_height > 0 And map_height <= #MAX_MAP_HEIGHT
                  SetGadgetText(#SPIN1, w$)
                  SetGadgetText(#SPIN2, h$)
                EndIf
              EndIf

              If ReadFile(1, f$, #PB_Ascii)
                If Lof(1) = map_width * map_height * 2
                  SetGadgetState(#CHECKBOX, #PB_Checkbox_Checked)
                  For y = 0 To map_height - 1
                    For x = 0 To map_width - 1
                      byte.a = ReadAsciiCharacter(1)
                      tilemap(x, y) = ReadAsciiCharacter(1)                   
                    Next
                  Next
                ElseIf  Lof(1) = map_width * map_height
                  SetGadgetState(#CHECKBOX, #PB_Checkbox_Unchecked)
                  For y = 0 To map_height - 1
                    For x = 0 To map_width - 1
                      tilemap(x, y) = ReadAsciiCharacter(1)
                    Next
                  Next
                Else
                  MessageRequester("Error", "Wrong TileMap!", #PB_MessageRequester_Error)
                EndIf
                
                CloseFile(1)
              EndIf
            EndIf
            
            SetGadgetAttribute(#SCROLLAREA3, #PB_ScrollArea_InnerWidth, 16 * map_width)
            SetGadgetAttribute(#SCROLLAREA3, #PB_ScrollArea_InnerHeight, 16 * map_height)
            SetGadgetAttribute(#SCROLLAREA3, #PB_ScrollArea_ScrollStep, 16)
            ResizeGadget(#CANVAS_LEFT3, 0, 0, 16 * map_width, 16 * map_height)
            RedrawMap()
          Case #BUTTON_EXPORT_TILEMAP
            f$ = SaveFileRequester("Export TileMap...", "*.map", "TileMaps|*.map", 0)
            
            If f$ <> ""
              If GetExtensionPart(f$) = ""
                f$ = f$ + ".map"
              EndIf
              
              If CreateFile(1, f$, #PB_Ascii)
                For y = 0 To map_height - 1
                  For x = 0 To map_width - 1
                    byte.a = tilemap(x, y) %00111111
                    If GetGadgetState(#CHECKBOX) = #PB_Checkbox_Checked
                      
                      WriteAsciiCharacter(1, selpal(tilemap(x, y)) << 4)
                    EndIf
                    WriteAsciiCharacter(1, byte)
                  Next
                Next
                
                CloseFile(1)
              EndIf
            EndIf
          Case #CANVAS_LEFT3
            xm.l = WindowMouseX(#WINDOW)
            ym.l = WindowMouseY(#WINDOW)
            
            If GetGadgetAttribute(eg, #PB_Canvas_Buttons) = #PB_Canvas_LeftButton            
              If xm >= 0 And ym >= 0
                xm - GadgetX(eg, #PB_Gadget_WindowCoordinate) - GadgetX(1, #PB_Gadget_WindowCoordinate)
                ym - GadgetY(eg, #PB_Gadget_WindowCoordinate) - GadgetY(1, #PB_Gadget_WindowCoordinate)
                
                xt.l = (xm / 16)
                yt.l = (ym / 16)
                
                tilemap(xt, yt) = selected_img
                RedrawMap()
              EndIf
            EndIf
          Case #BUTTON_IMPORT_SCREEN
            f$ = OpenFileRequester("Import Picture...", "*.png", "Pictures|*.png|*.bmp|*.gif|*.jpg", 0)
            
            If f$ <> ""
              LoadImage(1, f$)
              
              If ImageWidth(1) > 320 Or ImageHeight(1) > 256
                MessageRequester("Error", "Maximum size for 256 colors screens: 320x256", #PB_MessageRequester_Error)
              Else
                RedrawScreen()
              EndIf
            EndIf
          Case #BUTTON_EXPORT_SCREEN
            If IsImage(1)
              f$ = SaveFileRequester("Export Screen...", "*.scn", "Screens|*.scn", 0)
              
              If f$ <> ""
                e$ = ".scn"
                p$ = GetPathPart(f$)
                f$ = GetFilePart(f$, #PB_FileSystem_NoExtension)
                n$ = ""
                
                ; convert to 256 colors
                err = #False
                
                cpt.l = 0
                cpt2.l = 0
                
                mx.l = 0
                tot.l = ImageWidth(1) * ImageHeight(1)
                
                If GetGadgetState(#OPTION1) = 1
                  mx = ImageWidth(1) * ImageHeight(1)
                ElseIf GetGadgetState(#OPTION2) = 1
                  mx = 16384
                  n$ = "1"
                ElseIf GetGadgetState(#OPTION3) = 1
                  mx = 8192
                  n$ = "1"
                EndIf
                
                StartDrawing(ImageOutput(1))
                DrawingMode(#PB_2DDrawing_AllChannels)
                If CreateFile(1, p$ + f$ + n$ + e$, #PB_Ascii)
                  For y = 0 To ImageHeight(1) - 1
                    For x = 0 To ImageWidth(1) - 1 
                      For d = 0 To 15
                        For c = 0 To 255
                          ev = WindowEvent()
                          
                          cl2.l = RGB(Red(palette8(c)), Green(palette8(c)), Blue(palette8(c))) & $ffffff
                          r2.l = Red(cl2) >> 4
                          g2.l = Green(cl2) >> 4
                          b2.l = Blue(cl2) >> 4
                          
                          dr.l = Abs(r2 - r1)
                          dg.l = Abs(g2 - g1)
                          db.l = Abs(b2 - b1)
                        
                          If dr >= 0 And dg >= 0 And db >= 0 And dr <= d And dg <= d And db <= d
                            WriteAsciiCharacter(1, c)
                          
                            cpt + 1
                            cpt2 + 1
                          
                            If cpt2 = tot
                              CloseFile(1)
                              Break(2)
                            ElseIf cpt = mx
                              cpt = 0
                              
                              If n$ <> ""
                                n$ = Str(Val(n$) + 1)
                                CreateFile(1, p$ + f$ + n$ + e$, #PB_Ascii)
                              EndIf 
                            EndIf
                          
                            Break(2)
                          EndIf
                        Next
                      Next
                    Next
                  Next
                  
                  If err = #True
                    MessageRequester("Error", "Can't find approximative colors!", #PB_MessageRequester_Error)
                  EndIf
                Else
                  MessageRequester("Error", "Can't create file for write!", #PB_MessageRequester_Error)
                EndIf
                StopDrawing()
              EndIf
            Else
              MessageRequester("Error", "Import a screen image first!", #PB_MessageRequester_Error)
            EndIf
          Case #SPIN3
            RedrawMap()
          Case #SPIN4
            RedrawMap()
        EndSelect
    EndSelect
    
    xm.l = WindowMouseX(#WINDOW)
    ym.l = WindowMouseY(#WINDOW)
    
    xm - GadgetX(#SCROLLAREA3, #PB_Gadget_WindowCoordinate) - GadgetX(1, #PB_Gadget_WindowCoordinate)
    ym - GadgetY(#SCROLLAREA3, #PB_Gadget_WindowCoordinate) - GadgetY(1, #PB_Gadget_WindowCoordinate)
    
    If xm >= 0 And ym >= 0 And xm < GadgetWidth(#SCROLLAREA3) And ym < GadgetHeight(#SCROLLAREA3)
      xt.l = (xm / 16) + GetGadgetAttribute(#SCROLLAREA3, #PB_ScrollArea_X)
      yt.l = (ym / 16) + GetGadgetAttribute(#SCROLLAREA3, #PB_ScrollArea_Y)
      
      SetGadgetText(#LABEL, Str(xt) + ", " + Str(yt))
    Else
      SetGadgetText(#LABEL, "")
    EndIf

    Delay(1)
  ForEver
  
  CloseWindow(0) 
EndIf

End

;============
; procedures
;============
Procedure generate_default_palettes()
  stp.d = 255.0/7.0
  
  r.d = 0
  g.d = 0
  b.d = 0
  i.l = 0
  
  While Round(r, #PB_Round_Nearest) < 256
    While Round(g, #PB_Round_Nearest) < 256
      While Round(b, #PB_Round_Nearest) < 256
        palette9(i) = RGBA(Round(r, #PB_Round_Nearest), Round(g, #PB_Round_Nearest), Round(b, #PB_Round_Nearest), 255)
        palette8(i/2) = palette9(i)
        i + 1
        b + stp
      Wend
      b = 0
      g + stp
    Wend
    g = 0
    r + stp
  Wend
  
  palette9(454) = RGBA(0, 0, 0, 0)
  palette9(455) = RGBA(0, 0, 0, 0)
  
  For i = 0 To 255
    paletteL2(i) = palette8(i)
  Next  
EndProcedure

Procedure ResetLayer2()
  StartDrawing(CanvasOutput(#CANVAS_LEFT))
  DrawingMode(#PB_2DDrawing_AllChannels)
  i = 0
  For y = 0 To 255 Step 16
    For x = 0 To 255 Step 16
      Box(x, y, 16, 16, paletteL2(i))
      i + 1
    Next
  Next  
  selected_color = 0
  selected_new_color = 0
  selectedX = 0
  selectedY = 0  
  selected_palette = #L2_PALETTE
  DrawTileBorder(0, 0, 16, 16)
  StopDrawing()
  
  StartDrawing(CanvasOutput(#CANVAS_RIGHT))
  DrawingMode(#PB_2DDrawing_AllChannels)
  DrawTileBorder(0, 0, 8 * palette_type, 16)
  StopDrawing()
  
  SetGadgetText(#STRING, "$000")
EndProcedure

Procedure DrawTileBorder(x.l, y.l, width.l, height.l)
  For i = x + 1 To x + width - 2 Step 3
    Line(i, y + 1, 2, 1, RGB(255, 255, 0))
    Line(i, y + height - 2, 2, 1, RGB(255, 255, 0))
  Next
  
  For i = y + 1 To y + height - 2 Step 3
    Line(x + 1, i, 1, 2, RGB(255, 255, 0))
    Line(x + width - 2, i, 1, 2, RGB(255, 255, 0))
  Next
EndProcedure

Procedure FillRightPalette()
  StartDrawing(CanvasOutput(#CANVAS_RIGHT))
  DrawingMode(#PB_2DDrawing_AllChannels)
  
  i = 0  
  If palette_type = #PALETTE512
    For y = 0 To 255 Step 16
      For x = 0 To 255 Step 8
        Box(x, y, 8, 16, palette9(i))
        i + 1
      Next
    Next
  Else
    For y = 0 To 255 Step 16
      For x = 0 To 255 Step 16
        Box(x, y, 16, 16, palette8(i))
        i + 1
      Next
    Next
  EndIf
  StopDrawing()
EndProcedure

Procedure CreateTiles()
  For i = 0 To 63
    selpal(i) = 0
    
    For y = 0 To 7
      For x = 0 To 7
        img(i, x, y) = 0
      Next
    Next
  Next
EndProcedure

Procedure RedrawTileView()
  StartDrawing(CanvasOutput(#CANVAS_LEFT2))
  Dim c(1)
  c(0) = RGBA(255, 255, 255, 255)
  c(1) = RGBA(128, 128, 128, 255)
  i = 0
  For y = 0 To 255 Step 32
    For x = 0 To 255 Step 32
      DrawingMode(#PB_2DDrawing_AllChannels)
      Box(x, y, 32, 32, c(i))
      xt.l = img(selected_img, x / 32, y / 32)
      sp.l = selpal(selected_img)
      v.l = xt + (sp * 16)
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      Box(x, y, 32, 32, paletteL2(v))
      i = Mod(i + 1, 2)
    Next
    i = Mod(i + 1, 2)
  Next
  StopDrawing()
EndProcedure

Procedure RedrawTiles()
  RedrawTileView()
  
  StartDrawing(CanvasOutput(#CANVAS_RIGHT2))
  Dim c(1)
  c(0) = RGBA(255, 255, 255, 255)
  c(1) = RGBA(128, 128, 128, 255)
  i = 0
  j = 0
  For y = 0 To 255 Step 32
    For x = 0 To 255 Step 32
      DrawingMode(#PB_2DDrawing_AllChannels)
      Box(x, y, 32, 32, c(i))
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      For y2 = 0 To 7
        For x2 = 0 To 7
          xt.l = img(j, x2, y2)
          sp.l = selpal(selected_img)
          v.l = xt + (sp * 16)
          Box(x + (x2 * 4), y + (y2 * 4), 4, 4, paletteL2(v))
        Next
      Next
      i = Mod(i + 1, 2)
      j + 1
    Next
    i = Mod(i + 1, 2)
  Next
  yt.l = selected_img / 8
  xt.l = selected_img - (yt * 8)
  DrawingMode(#PB_2DDrawing_AllChannels)
  DrawTileBorder(xt * 32, yt * 32, 32, 32)
  StopDrawing()
  
  StartDrawing(CanvasOutput(#CANVAS_RIGHT3))
  Dim c(1)
  c(0) = RGBA(255, 255, 255, 255)
  c(1) = RGBA(128, 128, 128, 255)
  i = 0
  j = 0
  For y = 0 To 255 Step 32
    For x = 0 To 255 Step 32
      DrawingMode(#PB_2DDrawing_AllChannels)
      Box(x, y, 32, 32, c(i))
      DrawingMode(#PB_2DDrawing_AlphaBlend)
      For y2 = 0 To 7
        For x2 = 0 To 7
          xt.l = img(j, x2, y2)
          sp.l = selpal(selected_img)
          v.l = xt + (sp * 16)
          Box(x + (x2 * 4), y + (y2 * 4), 4, 4, paletteL2(v))
        Next
      Next
      i = Mod(i + 1, 2)
      j + 1
    Next
    i = Mod(i + 1, 2)
  Next
  yt.l = selected_img / 8
  xt.l = selected_img - (yt * 8)
  DrawingMode(#PB_2DDrawing_AllChannels)
  DrawTileBorder(xt * 32, yt * 32, 32, 32)
  StopDrawing()
EndProcedure

Procedure UpdatePalette16()
  StartDrawing(CanvasOutput(#CANVAS_DOWN2))
  DrawingMode(#PB_2DDrawing_AllChannels)
  For x = 0 To 15
    xt.l = x + (selected_palette16 * 16)
    Box(x * 16, 0, 16, 16, paletteL2(xt))
  Next
  StopDrawing()  
EndProcedure

Procedure RedrawMap()
  StartDrawing(CanvasOutput(#CANVAS_LEFT3))
  DrawingMode(#PB_2DDrawing_AllChannels)
  For y = 0 To map_height - 1
    For x = 0 To map_width - 1
      t.l = tilemap(x, y)
      For y2 = 0 To 7
        For x2 = 0 To 7
          xt.l = img(t, x2, y2)
          sp.l = selpal(t)
          v.l = xt + (sp * 16)
          Box((x * 16) + (x2 * 2), (y * 16) + (y2 * 2), 2, 2, paletteL2(v))
        Next
      Next
    Next
  Next
  
  sw.l = map_width * 16
  sh.l = map_height * 16
  stpw.l = Val(GetGadgetText(#SPIN3)) * 16
  stph.l = Val(GetGadgetText(#SPIN4)) * 16
  
  x = 0
  y = 0
  
  If stpw > 0 And stph > 0
    While y < sh
      While x < sw
        Line(x, y, stpw, 1, RGB(0, 255, 0))
        Line(x + stpw - 1, y, 1, stph, RGB(0, 255, 0))
        Line(x + stpw - 1, y + stph - 1, stpw, 1, RGB(0, 255, 0))
        Line(x, y + stph - 1, 1, stph, RGB(0, 255, 0))
        
        x + stpw
      Wend
      x = 0
      y + stph
    Wend
  EndIf
  StopDrawing()
EndProcedure

Procedure RedrawScreen()
  If IsImage(1) = #False : ProcedureReturn : EndIf
  
  StartDrawing(CanvasOutput(#CANVAS_LEFT4))
  DrawingMode(#PB_2DDrawing_AllChannels)
  Box(0, 0, 320, 256, RGB(0, 0, 0))
  StopDrawing()

  For y = 0 To ImageHeight(1) - 1
    For x = 0 To ImageWidth(1) - 1
      StartDrawing(ImageOutput(1))
      ; read real color
      DrawingMode(#PB_2DDrawing_AllChannels)
      cl1.l = Point(x, y)
      StopDrawing()
      
      r1.a = Red(cl1) >> 4
      g1.a = Green(cl1) >> 4
      b1.a = Blue(cl1) >> 4
                    
      d.l = 0
      
      ; scan colors
      For d = 0 To 15
        For c = 0 To 255
          ev = WindowEvent()
          
          cl2.l = RGB(Red(palette8(c)), Green(palette8(c)), Blue(palette8(c)))
          r2.a = Red(cl2) >> 4
          g2.a = Green(cl2) >> 4
          b2.a = Blue(cl2) >> 4
          
          dr.l = Abs(r2 - r1)
          dg.l = Abs(g2 - g1)
          db.l = Abs(b2 - b1)
          
          If dr >= 0 And dg >=0 And db >= 0 And dr <= d And dg <= d And db <= d
            StartDrawing(ImageOutput(1))
            DrawingMode(#PB_2DDrawing_AllChannels)
            Plot(x, y, palette8(c) & $ffffffff)
            StopDrawing()
            
            StartDrawing(CanvasOutput(#CANVAS_LEFT4))
            DrawingMode(#PB_2DDrawing_AllChannels)
            Plot(x, y, palette8(c))
            StopDrawing()
            
            Break(2)
          EndIf
        Next                
      Next
    Next
  Next
  StopDrawing()
EndProcedure

; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 862
; FirstLine = 850
; Folding = --
; EnableXP
; DPIAware
; UseIcon = icon.ico
; Executable = Next Tile Machine.exe