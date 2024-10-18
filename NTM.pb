;===================
; Next Tile Machine
;===================
;
; By Bruno Vignoli
; (c) 2024 MIT
;
;===================

; declarations
Declare generate_default_palettes()
Declare ResetLayer2()
Declare DrawTileBorder(x.l, y.l, width.l, height.l)
Declare FillRightPalette()


; constants
#MAX_REAL_PALETTE_COLORS = 512
#MAX_PALETTE_COLORS = 256

#L2_PALETTE = 1

#PALETTE512 = 1
#PALETTE256 = 2

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


; vars & arrays
Global Dim palette.l(#MAX_REAL_PALETTE_COLORS)
Global Dim paletteL2.l(#MAX_PALETTE_COLORS)

Global selected_color.l
Global selected_palette.l
Global selectedX.l
Global selectedY.l
Global selected_new_color.l
Global palette_type.l

; initialize palette
generate_default_palettes()

; program version
version$ = "v0.1.0"

; open the window
If OpenWindow(#WINDOW, 0, 0, 640, 480, "Next Tile Machine " + version$, #PB_Window_ScreenCentered|#PB_Window_MinimizeGadget)
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
  CanvasGadget(#CANVAS_LEFT2, 0, 0, 256, 256, #PB_Canvas_Border)
  AddGadgetItem(#PANEL, -1, "TileMap")
  CanvasGadget(#CANVAS_LEFT3, 0, 0, 320, 256, #PB_Canvas_Border)
  CloseGadgetList()
  
  ; 9 bits palette by default
  palette_type = #PALETTE512
  
  ; fill right palette
  FillRightPalette()
  
  ; reset layer2 palette
  ResetLayer2()
  
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
                xm - GadgetX(#CANVAS_LEFT, #PB_Gadget_WindowCoordinate) - GadgetX(1, #PB_Gadget_WindowCoordinate)
                ym - GadgetY(#CANVAS_LEFT, #PB_Gadget_WindowCoordinate) - GadgetY(1, #PB_Gadget_WindowCoordinate)
                
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
                xm - GadgetX(#CANVAS_RIGHT, #PB_Gadget_WindowCoordinate) - GadgetX(1, #PB_Gadget_WindowCoordinate)
                ym - GadgetY(#CANVAS_RIGHT, #PB_Gadget_WindowCoordinate) - GadgetY(1, #PB_Gadget_WindowCoordinate)
                
                xt.l = Round(xm / (8 * palette_type), #PB_Round_Down)
                yt.l = Round(ym / 16, #PB_Round_Down)
                
                ; grab future new color
                grabbed_color.l = (xt + (yt * 32 / palette_type))
                
                ; set left palette color
                If grabbed_color <> 454 And grabbed_color <> 455
                  If selected_color <> 227
                    paletteL2(selected_color) = palette(grabbed_color * palette_type)
                  EndIf
                EndIf
                
                yt.l = selected_new_color / (32 / palette_type)
                xt.l = selected_new_color - (yt * 32 / palette_type)
                
                ; clear the selection on old new color (right side)
                StartDrawing(CanvasOutput(#CANVAS_RIGHT))
                DrawingMode(#PB_2DDrawing_AllChannels)
                Box(xt * 8 * palette_type, yt * 16, 8 * palette_type, 16, palette(selected_new_color *  palette_type))
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
              EndIf
            EndIf
          Case #BUTTON1
            generate_default_palettes()
            ResetLayer2()
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
                  
                  For i = 0 To 511
                    If value_red = Red(palette(i)) >> 4
                      If value_green = Green(palette(i)) >> 4
                        If value_blue = Blue(palette(i)) >> 4
                          yt.l = selected_new_color / 32
                          xt.l = selected_new_color - (yt * 32)
                          
                          StartDrawing(CanvasOutput(#CANVAS_RIGHT))
                          DrawingMode(#PB_2DDrawing_AllChannels)
                          Box(xt * 8, yt * 16, 8, 16, palette(selected_new_color))
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
                          paletteL2(selected_color) = palette(selected_new_color)
                          Box(selectedX * 16, selectedY * 16, 16, 16, paletteL2(selected_color))
                          DrawTileBorder(selectedX * 16, selectedY * 16, 16, 16)
                          StopDrawing()
                          
                          Break
                        EndIf
                      EndIf
                    EndIf
                  Next
                EndIf
              Else
                MessageRequester("Error", "Hexa number wrong format!", #PB_MessageRequester_Error)
              EndIf
            Else
              MessageRequester("Error", "Missing $ before hexa number!", #PB_MessageRequester_Error)
            EndIf
          Case #BUTTON3
            If palette_type = #PALETTE512
              palette_type = #PALETTE256              
              SetGadgetText(#BUTTON3, "8 bits colors (512)")
            Else
              palette_type = #PALETTE512
              SetGadgetText(#BUTTON3, "9 bits colors (256)")
            EndIf
            
            FillRightPalette()
            ResetLayer2()
          Case #BUTTON_IMPORT_PALETTE
            f$ = OpenFileRequester("Import Palette...", "", "*.pal", 0)
            
            If f$ <> ""
              If ReadFile(1, f$, #PB_Ascii)
                If palette_type = #PALETTE512
                  If Lof(1) = 512
                    For i = 0 To 255
                      col_rrrgggbb.a = ReadAsciiCharacter(1)
                      col_b.a = ReadAsciiCharacter(1)
                      col_rrrgggbbb.w = (col_rrrgggbb << 1) | col_b
                      paletteL2(i) = palette(col_rrrgggbbb)
                    Next
                  Else
                    MessageRequester("Error", "Not a recognised palette!", #PB_MessageRequester_Error)
                  EndIf
                Else
                  If Lof(1) = 256
                    For i = 0 To 255
                      j.a = ReadAsciiCharacter(1)
                      m.l = j
                      m * 2
                      paletteL2(i) = palette(m)
                    Next
                  EndIf                  
                EndIf
                
                CloseFile(1)
              EndIf
            EndIf
            
            ResetLayer2()
          Case #BUTTON_EXPORT_PALETTE
            f$ = SaveFileRequester("Export Palette...", "", "*.pal", 0)
            
            
            If f$ <> ""
              If CreateFile(1, f$, #PB_Ascii)
                If palette_type = #PALETTE512
                  For i = 0 To 255
                    For j = 0 To 511
                      If paletteL2(i) = palette(j)
                        WriteAsciiCharacter(1, (j & %111111110) >> 1)
                        WriteAsciiCharacter(1, j & %00000001)
                        Break
                      EndIf
                    Next
                  Next
                Else
                  For i = 0 To 255
                    For j = 0 To 511 Step 2
                      If paletteL2(i) = palette(j)
                        k.a = j / 2
                        k = k % 11111111
                        WriteAsciiCharacter(1, k)
                        Break
                      EndIf
                    Next
                  Next
                EndIf
                
                CloseFile(1)
              EndIf
            EndIf
        EndSelect
    EndSelect
    
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
        palette(i) = RGBA(Round(r, #PB_Round_Nearest), Round(g, #PB_Round_Nearest), Round(b, #PB_Round_Nearest), 255)
        i + 1
        b + stp
      Wend
      b = 0
      g + stp
    Wend
    g = 0
    r + stp
  Wend
  
  palette(454) = RGBA(Round(r, #PB_Round_Nearest), Round(g, #PB_Round_Nearest), Round(b, #PB_Round_Nearest), 0)
  palette(455) = RGBA(Round(r, #PB_Round_Nearest), Round(g, #PB_Round_Nearest), Round(b, #PB_Round_Nearest), 0)
  
  For i = 0 To 255
    paletteL2(i) = palette(i * 2)
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
        Box(x, y, 8, 16, palette(i))
        i + 1
      Next
    Next
  Else
    For y = 0 To 255 Step 16
      For x = 0 To 255 Step 16
        Box(x, y, 16, 16, palette(i * palette_type))
        i + 1
      Next
    Next
  EndIf
  StopDrawing()
EndProcedure

; IDE Options = PureBasic 6.12 LTS (Windows - x64)
; CursorPosition = 281
; FirstLine = 262
; Folding = -
; EnableXP
; DPIAware
; Executable = NTM.exe