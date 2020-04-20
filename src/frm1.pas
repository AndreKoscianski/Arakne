unit frm1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, uPSComponent, Forms, Controls, Graphics, Dialogs
  ,ExtCtrls, Buttons, Clipbrd, LCLIntf, LCLType, StdCtrls, Spin, Menus, DOM
  ,XMLRead, XMLWrite
  ,INIFiles
  ,FormConfig
  ;
//,GraphUtil;

type
  { TForm1 }

  // type used in a form procedure
  TArray4 = array[1..4] of TPoint;
  TMatrix = array of array of integer;

  TForm1 = class(TForm)
    btnPause: TBitBtn;
    btnPlay: TBitBtn;
    btnStep: TBitBtn;
    Edit1: TEdit;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuFileOpen: TMenuItem;
    MenuFileSave: TMenuItem;
    MenuFileSaveAs: TMenuItem;
    MenuItem2: TMenuItem;
    FileMenuQuit: TMenuItem;
    FileMenuNew: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MIImage: TMenuItem;
    MIInvariants: TMenuItem;
    MISettings: TMenuItem;
    MIDoubleArc: TMenuItem;
    MIInvert: TMenuItem;
    MICount: TMenuItem;
    MIRename: TMenuItem;
    MIDelete: TMenuItem;
    MyCanvas: TPaintBox;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    PSScript1: TPSScript;
    SaveDialog1: TSaveDialog;
    CanvasScroller: TScrollBox;
    SaveDialogBMP: TSaveDialog;
    SpinEdit1: TSpinEdit;
    Timer1: TTimer;
    ToolErase: TSpeedButton;
    ToolRect: TSpeedButton;
    ToolPointer: TSpeedButton;
    ToolLine: TSpeedButton;
    ToolOval: TSpeedButton;
    procedure btnPauseClick(Sender: TObject);
    procedure btnPlayClick(Sender: TObject);
    procedure btnStepClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
    procedure btnResizeClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure Edit1EditingDone(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure FileMenuNewClick(Sender: TObject);
    procedure FileMenuQuitClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MenuFileOpenClick(Sender: TObject);
    procedure MenuFileSaveAsClick(Sender: TObject);
    procedure MenuFileSaveClick(Sender: TObject);
    procedure MIImageClick(Sender: TObject);
    procedure MICountClick(Sender: TObject);
    procedure MIDeleteClick(Sender: TObject);
    procedure MIDoubleArcClick(Sender: TObject);
    procedure MIInvariantsClick(Sender: TObject);
    procedure MIInvertClick(Sender: TObject);
    procedure MIRenameClick(Sender: TObject);
    procedure MISettingsClick(Sender: TObject);
    procedure MyCanvasClick(Sender: TObject);
    procedure MyCanvasDblClick(Sender: TObject);
    procedure MyCanvasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; pX, pY: Integer);
    procedure MyCanvasMouseMove(Sender: TObject; Shift: TShiftState; pX,
      pY: Integer);
    procedure MyCanvasMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; pX, pY: Integer);
    procedure RenderPetriNet(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit1Exit(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
    function MouseSelectedElement (pX, pY: integer) : boolean;
    procedure InterpolateBezier (id1, id2 : integer;
           var atp: TArray4);//array[1..4] of TPoint);
    procedure CarregueXML (s: string);
    procedure GereXML (s: string);
    procedure ExtraiaDadosPlaceXML
       (no: TDOMNode; var sid, sname: string; var x, y, count: integer);
    procedure ExtraiaDadosTransitionXML
       (no: TDOMNode; var sid, sname: string; var x, y: integer);
    procedure ExtraiaDadosArcXML
       (no: TDOMNode; var sid, sname: string; var id1, id2, uidth: integer);
    procedure RemoverElemento;
    procedure PrepareToPlayPetriNet;
    procedure ArmTransitions;
    function PlayPetriNet : integer;

    procedure LoadConfiguration;
    procedure SaveConfiguration;
    procedure ComputeMatrix;
    procedure ComputeInvariants;
    procedure TransposeMatrix;



  public
    { public declarations }
    //function GetFont:TFont;

    var GFont : TFont;

  end;

var
  Form1: TForm1;

  paintbmp: TBitmap;

  MouseIsDown: Boolean;
  PrevX, PrevY: Integer;



const
  KPlace = 1;
  KTransition = 2;
  KArc = 3;
  KEditName = 4;
  KCriandoLinha = 5;
  KNothing = 6;
  KPopupMenu = 7;
  KArcNormal = 8;
  KArcDouble = 9;
  KLengthName = 15;
  KNumTransitions = 500;
  KNumElements = 1000;
  KNumBranches = 10;


type TElement = record
   x, y, seqnumber: integer;
   s: String[KLengthName];
   active: boolean;
   case tipo : integer of
   KPlace: (count : integer);
   KTransition: (source: array[1..KNumBranches] of integer;
                 target: array[1..KNumBranches] of integer);
   KArc:    (id1, id2, uidth, atipo: integer;)

end;


var
    Gi  // current element being created
   ,Gs, Gss // current element selected
   ,Gs1, Gs2 // while creating an arrow
   ,Gsize , Gmidsize   // current size to draw element
   ,GsizeToken
   ,GAnimInterval
   ,Gstate
   ,Gplacecount
   ,Gtransitioncount
   : integer;

   GElements       : array[1..KNumElements] of TElement;
   Gstr            : array[1..KNumElements] of string;

   GFont : TFont;

implementation

{$R *.lfm}



{ TForm1 }

{$I xml.pas}

{$I playpetri2.pas}

{$I render.pas}

{$I config.pas}

{$I properties2.pas}


procedure TForm1.RemoverElemento;
var i: integer;
begin

   GElements[Gs].tipo := KNothing;

   // if arc, simply get rid of it and exit
   if (GElements[Gs]. tipo = KArc) then
      Exit;

   // It wasn't an arc: we have to handle arcs
   //  pointing to the thing tha has been removed.
   for i:=1 to Gi do begin

      if ((i = Gs) or (GElements[i].tipo <> KArc)) then Continue;

      if ((GElements[i].id1 = Gs) or
          (GElements[i].id2 = Gs)) then
          GElements[i].tipo := KNothing;
   end;
end;


procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  paintbmp.Free;
end;

function TForm1.MouseSelectedElement (pX, pY: integer) : boolean;
var
 i : integer;
begin
      Gs := 0;

     for i:=1 to Gi do begin
        with GElements[i] do begin
            if (pX - x) > Gmidsize then Continue;
            if (pY - y) > Gmidsize then Continue;
            if (x - pX) > Gmidsize then Continue;
            if (y - pY) > Gmidsize then Continue;
        end;

        Gs := i;

        MouseSelectedElement := true;

        Exit;

     end;

     MouseSelectedElement := false;
end;

procedure TForm1.btnOpenClick(Sender: TObject);
begin
  OpenDialog1.Execute;

  if (OpenDialog1.Files.Count > 0) then begin

    if (FileExists(OpenDialog1.FileName)) then begin
      CarregueXML (OpenDialog1.FileName);

      Invalidate;
      RenderPetriNet(Sender);

    end else begin
      ShowMessage('File is not found. You will have to open an existing file.');

    end;

  end;
end;

procedure TForm1.btnNewClick(Sender: TObject);
begin
  exit;
    // if our bitmap is already Create-ed (TBitmap.Create)
    // then start fresh
    if paintbmp <> nil then
      paintbmp.Destroy;

    paintbmp := TBitmap.Create;

    paintbmp.SetSize(Screen.Width, Screen.Height);
    paintbmp.Canvas.FillRect(0,0,paintbmp.Width,paintbmp.Height);

    paintbmp.Canvas.Brush.Style:=bsClear;
    MyCanvas.Canvas.Brush.Style:=bsClear;

    paintbmp.Canvas.Pen.Color := clBlack;
    paintbmp.Canvas.Pen.Width := 1;

    RenderPetriNet(Sender);
end;

procedure TForm1.btnStepClick(Sender: TObject);
var
    k: integer;
begin

(*  PsScript1.Script.Add('function double(num) ; begin');
  PsScript1.Script.Add(' Result := num*2;');
  PsScript1.Script.Add('end;');

  PsScript1.Compile;

  k := 111;

  //k := PsScript1.
  PsScript1.ExecuteFunction ([k], 'Double');

  write (k);

  Exit;
*)

  PrepareToPlayPetriNet;
  ArmTransitions;
  PlayPetriNet;
  Invalidate;
  RenderPetriNet(Sender);
  //Clipboard.Assign(paintbmp);

end;

procedure TForm1.btnPlayClick(Sender: TObject);
begin
  Timer1.Interval := GAnimInterval;

  PrepareToPlayPetriNet;
  ArmTransitions;

  Timer1.Enabled := true;

end;

procedure TForm1.btnPauseClick(Sender: TObject);
begin
  Timer1.Enabled := False;
end;

procedure TForm1.btnPasteClick(Sender: TObject);
var
  tempBitmap: TBitmap;
  PictureAvailable: boolean = False;
begin

  // we determine if any image is on clipboard
  if (Clipboard.HasFormat(PredefinedClipboardFormat(pcfDelphiBitmap))) or
    (Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap))) then
    PictureAvailable := True;


  if PictureAvailable then
  begin

    tempBitmap := TBitmap.Create;

    if Clipboard.HasFormat(PredefinedClipboardFormat(pcfDelphiBitmap)) then
      tempBitmap.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfDelphiBitmap));
    if Clipboard.HasFormat(PredefinedClipboardFormat(pcfBitmap)) then
      tempBitmap.LoadFromClipboardFormat(PredefinedClipboardFormat(pcfBitmap));

    // so we use assign, it works perfectly
    paintbmp.Assign(tempBitmap);
    RenderPetriNet(Sender);

    tempBitmap.Free;

  end else begin

    ShowMessage('No image is found on clipboard!');

  end;

end;

procedure TForm1.btnResizeClick(Sender: TObject);
var
  ww, hh: string;
  ww2, hh2: Integer;
  Code: Integer;
begin

  ww:=InputBox('Resize Canvas', 'Please enter the desired new width:', IntToStr(paintbmp.Width));
  Val(ww, ww2, Code);
  if Code <> 0 then begin
    ShowMessage('Error! Try again with an integer value of maximum '+inttostr(High(Integer)));
    Exit; // skip the rest of the code
  end;

  hh:=InputBox('Resize Canvas', 'Please enter the desired new height:', IntToStr(paintbmp.Height));
  Val(hh, hh2, Code);
  if Code <> 0 then begin
    ShowMessage('Error! Try again with an integer value of maximum '+inttostr(High(Integer)));
    Exit; // skip the rest of the code
  end;

  paintbmp.SetSize(ww2, hh2);
  RenderPetriNet(Sender);

end;

procedure TForm1.btnSaveClick(Sender: TObject);
begin


  if (SaveDialog1.Files.Count < 1) then begin
     if (OpenDialog1.Files.Count > 0) then
        SaveDialog1.Filename := OpenDialog1.Filename
     else
       SaveDialog1.Execute;
  end;

  if SaveDialog1.Files.Count > 0 then begin
    // if the user enters a file name without a .bmp
    // extension, we will add it
    if RightStr(SaveDialog1.FileName, 5) <> '.pnml' then
      SaveDialog1.FileName:=SaveDialog1.FileName+'.pnml';

    GereXML(SaveDialog1.FileName);
  end;
end;



procedure TForm1.Edit1EditingDone(Sender: TObject);
begin

  Gstate := 0;

  GElements[Gss].s := Edit1.Text;

  Gs := 0;
  Gss := 0;

  Invalidate;
  RenderPetriNet (Sender);

end;

procedure TForm1.Edit1Exit(Sender: TObject);
begin
  Edit1.Text := '';
end;

procedure TForm1.FileMenuNewClick(Sender: TObject);
begin
  Gi := 0;

  Invalidate;

  RenderPetriNet(Sender);
end;

procedure TForm1.FileMenuQuitClick(Sender: TObject);
begin
  SaveConfiguration;
  Application.Terminate;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin

  GFont := MyCanvas.Font;

  LoadConfiguration;

  // We create a new file/canvas/document when
  // it starts up
  btnNewClick(Sender);
end;

procedure TForm1.MenuFileOpenClick(Sender: TObject);
begin
  OpenDialog1.Execute;

  if (OpenDialog1.Files.Count > 0) then begin

    if (FileExists(OpenDialog1.FileName)) then begin
      CarregueXML (OpenDialog1.FileName);

      Invalidate;
      RenderPetriNet(Sender);

    end else begin
      ShowMessage('File is not found. You will have to open an existing file.');

    end;

  end;
end;

procedure TForm1.MenuFileSaveAsClick(Sender: TObject);
begin
  SaveDialog1.Execute;

  if SaveDialog1.Files.Count > 0 then begin
    // if the user enters a file name without a .bmp
    // extension, we will add it
    if RightStr(SaveDialog1.FileName, 5) <> '.pnml' then
      SaveDialog1.FileName:=SaveDialog1.FileName+'.pnml';

    GereXML(SaveDialog1.FileName);
  end;
end;

procedure TForm1.MenuFileSaveClick(Sender: TObject);
begin
  if SaveDialog1.Files.Count > 0 then begin
    // if the user enters a file name without a .bmp
    // extension, we will add it
    if RightStr(SaveDialog1.FileName, 5) <> '.pnml' then
      SaveDialog1.FileName:=SaveDialog1.FileName+'.pnml';

    GereXML(SaveDialog1.FileName);
  end;
end;

procedure TForm1.MIImageClick(Sender: TObject);
var
   r1, r2: TRect;
   bmp: TBitmap;

begin

  SaveDialogBMP.Execute;

  if SaveDialogBMP.Files.Count > 0 then begin
    // if the user enters a file name without a .bmp
    // extension, we will add it
    if RightStr(SaveDialogBMP.FileName, 4) <> '.bmp' then
      SaveDialogBMP.FileName:=SaveDialog1.FileName+'.bmp';
  end else
     Exit;

  if bmp <> nil then
    bmp.Destroy;

  bmp := TBitmap.Create;

  bmp.PixelFormat := pf32bit;
  r1 := Mycanvas.clientrect;

  bmp.SetSize(r1.Width, r1.Height);

  bmp.Canvas.CopyRect (r1, Mycanvas.Canvas, r1);

  bmp.SaveToFile (SaveDialogBMP.FileName);

  bmp.free;
end;






procedure TForm1.MICountClick(Sender: TObject);
begin
  Gss := Gs;

  Gstate := KEditName;

  if (GElements[Gs].tipo = KPlace) then
     SpinEdit1.Value := GElements[Gs].count
  else
     SpinEdit1.Value := GElements[Gs].uidth;

  SpinEdit1.SetFocus;
end;

procedure TForm1.MIDeleteClick(Sender: TObject);
begin
  Gstate := 0;

  if (Gs > 0) then begin
     RemoverElemento;
     Invalidate;
     RenderPetriNet (Sender);
  end;

end;


procedure TForm1.MIDoubleArcClick(Sender: TObject);
begin
  if (Gs < 1) then Exit;

  if (GElements[Gs].atipo = KArcDouble) then
     GElements[Gs].atipo := KArcNormal
  else
     GElements[Gs].atipo := KArcDouble;

  Invalidate;
  RenderPetriNet(Sender);
end;

procedure TForm1.MIInvariantsClick(Sender: TObject);
begin
   ComputeInvariants;
end;

procedure TForm1.MIInvertClick(Sender: TObject);
var aux: integer;
begin
   if (Gs < 1) then Exit;

   aux := GElements[Gs].id1;
   GElements[Gs].id1 := GElements[Gs].id2;
   GElements[Gs].id2 := aux;

   Invalidate;
   RenderPetriNet(Sender);
end;

procedure TForm1.MIRenameClick(Sender: TObject);
begin
  Gss := Gs;
  Edit1.Text := GElements[Gs].s;
  SpinEdit1.Value := GElements[Gs].count;

  Gstate := KEditName;

  Edit1.MaxLength := KLengthName;
  Edit1.SetFocus;

end;

procedure TForm1.MISettingsClick(Sender: TObject);
begin
  Form2.Show;
end;



procedure TForm1.MyCanvasClick(Sender: TObject);
begin

  if (Gstate = KEditName) then begin
    Edit1.Text := '';
    Gs := 0;
    Gss := 0;

    Gstate := 0;
    Exit;

  end;

  if ((not ToolPointer.Down) and (not ToolErase.Down)) then Exit;

  Gss := 0;

  if (Gs < 1) then
     Exit;

  if (ToolErase.Down) then begin
     RemoverElemento;
     Invalidate;
     RenderPetriNet(Sender);
  end;


end;

procedure TForm1.MyCanvasDblClick(Sender: TObject);
begin

  Exit;
(*
  Gss := Gs;
  Edit1.Text := GElements[Gs].s;
  SpinEdit1.Value := GElements[Gs].count;

  Gstate := KEditName;

  Edit1.SetFocus;
*)
end;

procedure TForm1.MyCanvasMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; pX, pY: Integer);
begin
  MouseIsDown := True;


  if Button = mbRight then begin

     if (Gs < 1) then Exit;

     MICount.Visible  := (GElements[Gs].tipo = KPlace)
                         or
                         (GElements[Gs].tipo = KArc);

     if (GElements[Gs].tipo = KArc) then begin
        MIInvert.Visible    := true; //(GElements[Gs].tipo = KArc);
        MIDoubleArc.Visible := true; //(GElements[Gs].tipo = KArc);

        MiDoubleArc.Checked := GElements[Gs].atipo = (KArcDouble);
     end else begin
        MIInvert.Visible    := false;
        MIDoubleArc.Visible := false;
        MIRename.Visible    := true; //(GElements[Gs].tipo <> KArc);
     end;

     PopupMenu1.PopUp(Form1.Left + CanvasScroller.Left + pX,
                      Form1.Top + CanvasScroller.Left + pY + 50);
    // Gstate := KPopupMenu;
     Exit;
  end;

  if Gstate = KPopupMenu then
     Exit;

  if ToolRect.Down = true then begin
    inc(Gi);
    inc(Gtransitioncount);
    with GElements[Gi] do begin
        x := pX;
        y := pY;
        tipo := KTransition;
        s := 'T' + IntToStr (Gtransitioncount);
        source[1] := -1;
        target[1] := -1;
    end;
  end else if ToolOval.Down then begin
    inc(Gi);
    inc(Gplacecount);
    with GElements[Gi] do begin
        x := pX;
        y := pY;
        tipo := KPlace;
        s := 'P' + IntToStr (Gplacecount);
    end;
  end else if (ToolLine.Down and (Gs > 0)) then begin

    inc(Gi);
    GElements[Gi].x := GElements[Gs].x;
    GElements[Gi].y := GElements[Gs].y;
    GElements[Gi].tipo := KArc;
    GElements[Gi].id1 := Gs;
    GElements[Gi].id2 := -1;
    GElements[Gi].uidth := 1;

    Gs1 := Gs;

    Gstate := KCriandoLinha;
  end
end;

procedure TForm1.MyCanvasMouseMove(Sender: TObject; Shift: TShiftState; pX,
  pY: Integer);
var i:integer;
    n, min: real;
begin

  if ((Gstate = KEditName) or (Gstate = KPopupMenu)) then Exit;

  // selecting things
  if ToolPointer.Down then begin

    // moving an element
    if (MouseIsDown) then

       // place or transition selected?
       if ((Gs > 0) and (GElements[Gs].tipo <> KArc)) then begin

           // move it!
           GElements[Gs].x := pX;
           GElements[Gs].y := pY;

       end else
          Exit
    else

    MouseSelectedElement (pX, pY);

    Invalidate;
    RenderPetriNet(Sender);

  end;

  // placing a new element
  if (MouseIsDown and (Gi > 0) and
      (ToolRect.Down or ToolOval.Down)) then begin

     GElements[Gi].x := pX;
     GElements[Gi].y := pY;

     Invalidate;
     RenderPetriNet(Sender);

  end;

  // only get coordinates.
  if ((ToolLine.Down) or (ToolErase.Down)) then begin

     PrevX := pX;
     PrevY := pY;

     MouseSelectedElement (pX, pY);
     Invalidate;
     RenderPetriNet (Sender);
  end;

end;

procedure TForm1.MyCanvasMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; pX, pY: Integer);
begin

  MouseIsDown:=False;

  if (Gstate = KPopupMenu) then Exit;

  if (Gstate = KCriandoLinha) then begin

     // Soltar mouse sobre objeto - verifique qual
     MouseSelectedElement (pX, pY);

     // não criar linha para si mesmo,
     //   ou para lugar vazio
     if ((Gs = Gs1) or (Gs < 1)) then begin
        dec (Gi);
        Exit;
     end;

     // também não crie linha entre objetos de mesmo tipo.
     if (GElements[GElements[Gi].id1].tipo = GElements[Gs].tipo) then begin
        dec (Gi);
        Exit;
     end;

     // marque na linha objeto final
     GElements[Gi].id2 := Gs;

     // marque na linha coordenadas do centro dela
     GElements[Gi].x :=
       (GElements[GElements[Gi].id1].x +
        GElements[GElements[Gi].id2].x) div 2;
     GElements[Gi].y :=
       (GElements[GElements[Gi].id1].y +
        GElements[GElements[Gi].id2].y) div 2;



     // interface volta ao estado zero
     Gstate := 0;
     Gs := 0;

  end;

  Invalidate;
  RenderPetriNet (Sender);

end;



procedure TForm1.SpinEdit1Change(Sender: TObject);

begin

  if (Gss < 1) then Exit;

  if (GElements[Gss].tipo = KPlace) then
     GElements[Gss].count := SpinEdit1.Value

  else // arcs are always non-zero
     if (SpinEdit1.Value > 0) then
        GElements[Gss].uidth := SpinEdit1.Value;

  Invalidate;
  RenderPetriNet (sender);

end;

procedure TForm1.SpinEdit1Exit(Sender: TObject);
begin
  Gs := 0;
  Gss := 0;
  Gstate := 0;

  SpinEdit1.Value := 0;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    ArmTransitions;
    PlayPetriNet;
    Invalidate;
    RenderPetriNet(Sender);
end;





begin
   Gi := 0;
   Gs := 0;
   Gss := 0;
   Gsize := 20;
   Gplacecount := 0;
   Gtransitioncount := 0;
   Gmidsize := Gsize div 2;
   GsizeToken := Gsize div 4;

   GAnimInterval := 500;

end.

(*

procedure TForm1.Button2Click(Sender: TObject);
var
  bmp: TBitmap;
  R: TRect;
  png : TPortableNetworkGraphic;
begin
  // bmp, png
  bmp := TBitmap.Create;
  png := TPortableNetworkGraphic.Create;

  try
    // bmp
    R := Rect(0, 0, BarcodeQR1.Width, BarcodeQR1.Height);
    bmp.SetSize(BarcodeQR1.Width, BarcodeQR1.Height);
    bmp.Canvas.Brush.Color := clWhite;
    bmp.Canvas.FillRect(R);
    BarcodeQR1.PaintOnCanvas(bmp.Canvas, R);
    bmp.SaveToFile('barcode.bmp');
    // png
    png.Assign(bmp);
    png.SaveToFile('barcode.png');

  finally
    bmp.Free;
    png.Free;
  end;
end;

*)

(*
Software Implementation of Petri nets and compilation of rule-based
systems.
Conference Paper · June 1990
DOI: 10.1007/BFb0019980 · Source: DBLP
CITATIONS READS
27 77
2 authors, including:
Robert Valette
French National C


Performance Evaluation of Petri Nets Execution Algorithms
Ramón Piedrafita Moreno, José Luis Villarroel Salcedo





play/pause
play N times
log results




*)
