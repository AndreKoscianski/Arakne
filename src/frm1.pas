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
    Button1: TButton;
    ComboBox1: TComboBox;
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
    MITEditSubPN: TMenuItem;
    MITDelete: TMenuItem;
    MITRename: TMenuItem;
    MITTransitionC: TMenuItem;
    MIPDelete: TMenuItem;
    MIPlaceC: TMenuItem;
    MIPRename: TMenuItem;
    MIPTokens: TMenuItem;
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
    PopupMenuTransition: TPopupMenu;
    PopupMenuArc: TPopupMenu;
    PopupMenuPlace: TPopupMenu;
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
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
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
    procedure MITEditSubPNClick(Sender: TObject);
    procedure MITTransitionCClick(Sender: TObject);
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
    procedure ToolLineClick(Sender: TObject);
    procedure ToolOvalClick(Sender: TObject);
    procedure ToolPointerClick(Sender: TObject);
    procedure ToolRectClick(Sender: TObject);
  private
    { private declarations }
    function MouseSelectedElement (pX, pY: integer) : boolean;
    procedure InterpolateBezier (id1, id2 : integer;
           var atp: TArray4);//array[1..4] of TPoint);

    // Arquivos XML
    procedure CarregueXML (s: string);
    procedure GereXML (s: string);
    procedure ExtraiaDadosPlaceXML
       (no: TDOMNode; var sid, sname: string; var x, y, count: integer);
    procedure ExtraiaDadosTransitionXML
       (no: TDOMNode; var sid, sname: string; var x, y: integer);
    procedure ExtraiaDadosArcXML
       (no: TDOMNode; var sid, sname: string; var id1, id2, uidth: integer);

    // Arquivos KSV
    procedure SaveKSV (filename: string);
    procedure LoadKSV (filename: string);


    procedure RemoverElemento;
    procedure RemoverVazios;
    procedure PrepareToPlayPetriNet;
    procedure ArmTransitions;
    function PlayPetriNet : integer;

    procedure LoadConfiguration;
    procedure SaveConfiguration;
    procedure ComputeMatrix;
    procedure ComputeInvariants;
    procedure TransposeMatrix;
    function GatherSelectedObjects:boolean;
    procedure MovaOsCabra;

    procedure AtualizeComBoBox;



  public
    { public declarations }
    //function GetFont:TFont;

    var GFont : TFont;

  end;

var
  Form1: TForm1;

  paintbmp: TBitmap;

  MouseIsDown: Boolean;
  GPrevX, GPrevY, GNewX, GNewY,
  GDragX, GDragY,
  GNewDragX, GNewDragY: Integer;



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
  KSelectingRectangle = 10;
  KSelectedObjects = 11;

  KPlaceC      = 12;
  KTransitionC = 13;

  KSHovering = 0;
  KSStartRectangle = 101;
  KSDefiningRectangle = 102;
  KSDraggingObject = 103;
  KSHoveringWithRectangle = 104;
  KSStartDraggingSeveral = 105;
  KSDraggingSeveral = 106;
  KSAddObject = 107;
  KSPlaying = 108;


  KLengthName = 15;
  KNumTransitions = 500;
  KNumElements = 1000;
  KNumBranches = 10;


type TElement = record
   selected: boolean;
   x, y, seqnumber: integer;
   s: String[KLengthName];

   case tipo : integer of
   KPlace: (count,ptipo,idx_subpn_p : integer);
   KTransition: (ttipo,idx_subpn_t : integer);
   KArc:    (id1, id2, uidth, atipo: integer;);
end;


type TPetriNet = record
   s: string[KLengthName];
   Gi : integer;
   El : array of TElement;
   PlaceCount
   ,TransCount
   ,_Count
   : integer;
end;


var
   PN : array of TPetriNet;
   _  : integer;

    Gs  // current element selected
   ,Gs1, Gs2 // while creating an arrow
   ,Gsize , Gmidsize   // current size to draw element
   ,GsizeToken
   ,GAnimInterval
   ,GMagnetGrid
   ,Gstate
  // ,Gplacecount
  // ,Gtransitioncount
   : integer;

   GElements       : array[1..KNumElements] of TElement;
   Gstr            : array[1..KNumElements] of string;

   GFont : TFont;


   GSelectedElements : array of integer;

implementation

{$R *.lfm}



{ TForm1 }

{$I xml.pas}

{$I ksv.pas}

{$I playpetri2.pas}

{$I render.pas}

{$I config.pas}

{$I properties4.pas}

//=======================================================

procedure TForm1.AtualizeComBoBox;
var
   i : integer;
begin
  ComboBox1.Clear;

  For i := 0 to length (PN) - 1 do
     ComboBox1.Items.Add (PN[i].s);

  ComboBox1.ItemIndex := _;

  ComboBox1.Enabled := (1 < length (PN));
end;

procedure TForm1.RemoverElemento;
var i, thing: integer;

   procedure RemoverSubPN (idx : integer);
   var
      j,k,n,inet,it : integer;
   begin

     // recursively remove sub-nets
     for k :=0 to PN[idx].Gi do
        if (KTransition = PN[idx].El[k].tipo)
           and
           (KTransitionC = PN[idx].El[k].ttipo)
        then RemoverSubPN (PN[idx].El[k].idx_subpn_t);

     // now, remove this sub-net.
     // first, get it length
     n := length (PN) - 1;

     // copy last sub-net to current (=idx) position
     if (idx < n) then begin

       //SetLength (PN[idx].El, length(PN[n].El));
       //PN[idx].El := PN[n].El;
       PN[idx] := PN[n];

       // After copying, adjust links between sub-net and super-net.

       // Follow backward link, which did not change.
       inet := PN[idx].El[0].idx_subpn_t ; // net
       it   := PN[idx].El[1].idx_subpn_t ; // element

       // Now adjust forward link, because it changed.
       PN[inet].El[it].idx_subpn_t := idx;

     end; // if

     // we must delete last sub-net.

     // remove elements
     SetLength (PN[n].El, 0);

     // remove net
     SetLength (PN, n);

   end; // procedure

begin

   // If this is a sub-net, the two first
   //   elements cannot be deleted.
   // They are transitions linked to the super-net.
   if (_ > 0) and (Gs < 2) then begin
     MessageDlg('Attention',
                'This Transition cannot be Deleted.'
                + LineEnding
                + 'It links this net to its higher-level net.'
                ,  mtInformation,
                [mbOk],0);

      Exit;
   end;

   // Remember who is being deleted
   thing := PN[_].El[Gs].tipo;

   if (thing = KTransition) and
      (PN[_].El[Gs].ttipo = KTransitionC) then
      RemoverSubPN (PN[_].El[Gs].idx_subpn_t);

   // Delete.
   PN[_].El[Gs].tipo := KNothing;

   // It wasn't an arc: we have to handle arcs
   //  pointing to the thing that has been removed.
   if (thing <> KArc) then
   for i:=1 to PN[_].Gi do begin

      if ((i = Gs) or (PN[_].El[i].tipo <> KArc)) then Continue;

      // Delete arcs pointing to deleted element.
      if ((PN[_].El[i].id1 = Gs) or
          (PN[_].El[i].id2 = Gs)) then
          PN[_].El[i].tipo := KNothing;
   end;

   // If last positions of PetriNet had arcs that were removed,
   //   then shrink the PetriNet.
   while (PN[_].Gi > 0) and (PN[_].El[PN[_].Gi].tipo = KNothing) do
      dec (PN[_].Gi);


   // Compact Empty Spaces
   RemoverVazios;

   AtualizeComBoBox;

end;

procedure TForm1.RemoverVazios;

var oldref, newref: integer;

   procedure AjustarReferencias ;
   var k: integer;
   begin
      // Scan the PetriNet searching for arcs
      //  that we're affected by the movement
      //  of an element.
      for k := 1 to PN[_].Gi do

         // We're interested on arcs only.
         if (PN[_].El[k].tipo = KArc) then begin

            // arc points to old position, here's the new one
            if PN[_].El[k].id1 = oldref then
               PN[_].El[k].id1 := newref;

            // arc points to old position, here's the new one
            if PN[_].El[k].id2 = oldref then
               PN[_].El[k].id2 := newref;
         end // if
   end; // procedure
begin

   // Begin at the beginning;
   newref := 0;

   // Let's search for every empty space
   while (newref < PN[_].Gi) do begin

     // find empty space
     repeat
        inc(newref)
     until (newref = PN[_].Gi) or (PN[_].El[newref].tipo = KNothing);

     // if this happens, we're done.
     if (newref = PN[_].Gi) then
        Exit;

     // we will shrink the PetriNet.
     oldref := PN[_].Gi;
(*
     // So: find first element AFTER the empty space
     newref := oldref + 1;
     while (newref < PN[_].Gi) and (PN[_].El[newref].tipo = KNothing) do
        inc(newref);
 *)
     // replace empty space with element.
     PN[_].El[newref] := PN[_].El[oldref];

     // if we moved a place or transition,
     //  then adjust any references to it.
     if (PN[_].El[oldref].tipo <> KArc) then
        AjustarReferencias;

     // PetriNet shrunk.
     dec (PN[_].Gi);

   end;

   // Release memory.
   // Always remember, Gi points to last element
   //   and the array index begins with 0 (zero),
   //   so an empty PN has Gi = -1.
   SetLength (PN[_].El, 1+ PN[_].Gi);

end;

function TForm1.GatherSelectedObjects: boolean;
var x1,y1,x2,y2,i,k: integer;
begin
   // Prepare coordinates of rectangle
   if GPrevX < GNewX then begin
      x1 := GPrevx; x2 := GNewx;
   end else begin
      x2 := GPrevx; x1 := GNewx;
   end;
   if GPrevY < GNewY then begin
      y1 := GPrevy; y2 := GNewy;
   end else begin
      y2 := GPrevy; y1 := GNewy;
   end;

   // empty selection
   SetLength (GSelectedElements, 0);
   k := 0;

   // test each element
   for i := 0 to PN[_].Gi do
      if    (PN[_].El[i].x >= x1)
        and (PN[_].El[i].x <= x2)
        and (PN[_].El[i].y >= y1)
        and (PN[_].El[i].y <= y2)
      then begin
         inc (k);
         // SetLength (GSelectedElements, k);
         // GSelectedElements[k] := i;
          PN[_].El[i].selected := true;
      end;

   GatherSelectedObjects := (k > 0);

   // if there's no selected object,
   //    clear selection rectangle.
   if (k < 1) then
       GPrevX := -1;

end;

procedure TForm1.MovaOsCabra;
var
   i, dx, dy: integer;
begin
   dx := GNewDragX - GDragX;
   dy := GNewDragY - GDragY;

   GPrevX := GPrevX + dx;
   GPrevY := GPrevY + dy;

   GNewX  := GNewX  + dx;
   GNewY  := GNewY  + dy;

   for i := 1 to PN[_].Gi do
      if PN[_].El[i].selected then begin
         PN[_].El[i].x := PN[_].El[i].x + dx;
         PN[_].El[i].y := PN[_].El[i].y + dy;
      end
end;


procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  paintbmp.Free;
end;

function TForm1.MouseSelectedElement (pX, pY: integer) : boolean;
var
 i : integer;
begin
      Gs := -1;

     for i:=0 to PN[_].Gi do begin
        with PN[_].El[i] do begin
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

  GState := KSPlaying;
end;

procedure TForm1.btnPauseClick(Sender: TObject);
begin
  Timer1.Enabled := False;
  GState := KSHovering;
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

procedure TForm1.Button1Click(Sender: TObject);

var k: integer;

begin
  // debug code

     writeln (' ');
     writeln (' ');

     for k := 1 to PN[_].Gi do begin
       write (k);
       write (' , ');

       if (PN[_].El[k].tipo <> KArc) then
          write (PN[_].El[k].s)
       else begin
          write (' arc ,');
          write (PN[_].El[k].id1);
          write (' ,');
          write (PN[_].El[k].id2);
       end;

       writeln (' ');

     end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  _ := ComboBox1.ItemIndex;

  Invalidate;
  RenderPetriNet (Sender);
end;



procedure TForm1.Edit1EditingDone(Sender: TObject);
begin
  ;
end;

procedure TForm1.Edit1Exit(Sender: TObject);
var
    i : integer;
begin

    Gstate := 0;

    PN[_].El[Gs].s := Edit1.Text;


    if (PN[_].El[Gs].tipo = KTransition) and
       (PN[_].El[Gs].ttipo = KTransitionC) then begin

       PN[PN[_].El[Gs].idx_subpn_t].s := Edit1.Text;

       AtualizeComBoBox;
    end;


    Edit1.Text := '';
    Edit1.Enabled := false;

    Gs := -1;

    Invalidate;
    RenderPetriNet (Sender);

end;

procedure TForm1.FileMenuNewClick(Sender: TObject);
begin
  PN[_].Gi := 0;

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

      LoadKSV     (OpenDialog1.FileName);
      //CarregueXML (OpenDialog1.FileName);

      Invalidate;
      RenderPetriNet(Sender);

    end else begin
      ShowMessage('File is not found. You will have to open an existing file.');

    end;

  end;

  AtualizeComBoBox;

end;

procedure TForm1.MenuFileSaveAsClick(Sender: TObject);
begin
  SaveDialog1.Execute;

  if SaveDialog1.Files.Count > 0 then begin
    // if the user enters a file name without a .bmp
    // extension, we will add it
    if RightStr(SaveDialog1.FileName, 5) <> '.ksv' then
      SaveDialog1.FileName:=SaveDialog1.FileName+'.ksv';

    SaveKSV(SaveDialog1.FileName);
    GereXML(SaveDialog1.FileName+'.pnml');
  end;
end;

procedure TForm1.MenuFileSaveClick(Sender: TObject);
begin

  if SaveDialog1.Files.Count < 1 then
     SaveDialog1.Execute;

  if SaveDialog1.Files.Count > 0 then begin
    // if the user enters a file name without a .bmp
    // extension, we will add it
    if RightStr(SaveDialog1.FileName, 5) <> '.ksv' then
      SaveDialog1.FileName:=SaveDialog1.FileName+'.ksv';

    SaveKSV (SaveDialog1.FileName);
    GereXML(SaveDialog1.FileName+'.pnml');
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

  Gstate := KEditName;

  SpinEdit1.Enabled := true;

  if (PN[_].El[Gs].tipo = KPlace) then
     SpinEdit1.Value := PN[_].El[Gs].count
  else
     SpinEdit1.Value := PN[_].El[Gs].uidth;

  SpinEdit1.SetFocus;
end;

procedure TForm1.MIDeleteClick(Sender: TObject);
begin

  if (KTransitionC = PN[_].El[Gs].ttipo) then
  if mrNo = MessageDlg('Attention',
                       'This action is Irreversible!'
                       +LineEnding
                       +'Delete transition <'
                       +PN[_].El[Gs].s
                       +'> ?'
                       , mtConfirmation,
                       [mbYes, mbNo],0)
  then exit;


  Gstate := 0;

  if (Gs > -1) then begin
     RemoverElemento;
     Invalidate;
     RenderPetriNet (Sender);
  end;

end;


procedure TForm1.MIDoubleArcClick(Sender: TObject);
begin
  if (Gs < 0) then Exit;

  if (PN[_].El[Gs].atipo = KArcDouble) then
     PN[_].El[Gs].atipo := KArcNormal
  else
     PN[_].El[Gs].atipo := KArcDouble;

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
   if (Gs < 0) then Exit;

   aux := PN[_].El[Gs].id1;
   PN[_].El[Gs].id1 := PN[_].El[Gs].id2;
   PN[_].El[Gs].id2 := aux;

   Invalidate;
   RenderPetriNet(Sender);
end;

procedure TForm1.MIRenameClick(Sender: TObject);
begin

  Edit1.Enabled := true;
  Edit1.Text := PN[_].El[Gs].s;
  SpinEdit1.Value := PN[_].El[Gs].count;

  Gstate := KEditName;

  Edit1.MaxLength := KLengthName;
  Edit1.SetFocus;

end;

procedure TForm1.MISettingsClick(Sender: TObject);
begin
  Form2.Show;
end;

procedure TForm1.MITEditSubPNClick(Sender: TObject);
begin

  // "jump" to sub-PN
  _ := PN[_].El[Gs].idx_subpn_t;

  Invalidate;
  RenderPetriNet(Sender);
end;

procedure TForm1.MITTransitionCClick(Sender: TObject);
var
  i : integer;
begin
  if mrNo = MessageDlg('Attention',
                       'Are you sure?'
                       , mtConfirmation,
                       [mbYes, mbNo],0)
  then exit;

  // change type of transition.
  PN[_].El[Gs].ttipo := KTransitionC;

  // increment number of petri nets
  //inc(PN[0]._Count);

  i := length(PN); //PN[0]._Count;

  // Create New net
  SetLength(PN, 1+ i);

  // link current transition to new net
  PN[_].El[Gs].idx_subpn_t := i;


  PN[i].Gi := 1;
  PN[i].s  := PN[_].El[Gs].s;

  // New PN, create 2 transitions
  SetLength(PN[i].El, 2);

  PN[i].El[0].tipo  := KTransition;
  PN[i].El[0].ttipo := KTransition;
  PN[i].El[0].s     := 'Input';
  PN[i].El[0].x     := 50;
  PN[i].El[0].y     := 50;
  PN[i].El[0].idx_subpn_t := _; // link back (net id)

  PN[i].El[1].tipo  := KTransition;
  PN[i].El[1].ttipo := KTransition;
  PN[i].El[1].s     := 'Output';
  PN[i].El[1].x     := 150;
  PN[i].El[1].y     := 50;
  PN[i].El[1].idx_subpn_t := Gs; // link back (el id)

  AtualizeComBoBox;

end;



procedure TForm1.MyCanvasClick(Sender: TObject);
begin

  // if playing petri net, always exit.
  if (Gstate = KSPlaying) then Exit;

  if (Gstate = KEditName) then begin
    Edit1.Text := '';

    Gs := -1;

    Gstate := 0;
    Exit;

  end;

  if (not ToolPointer.Down) then Exit;

  if (Gs < 0) then
     Exit;

(* old code
  if (ToolErase.Down) then begin
     RemoverElemento;
     Invalidate;
     RenderPetriNet(Sender);
  end;
*)

end;

procedure TForm1.MyCanvasDblClick(Sender: TObject);
begin

  Exit;
(*
  Gss := Gs;
  Edit1.Text := PN[_].El[Gs].s;
  SpinEdit1.Value := PN[_].El[Gs].count;

  Gstate := KEditName;

  Edit1.SetFocus;
*)
end;

procedure TForm1.MyCanvasMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; pX, pY: Integer);
var
   i : integer;
begin

  // if playing petri net, ignore mouse.
  if (Gstate = KSPlaying) then exit;

  MouseIsDown := True;

  // process menu from Right-Click
  if Button = mbRight then begin

     if (Gs < 0) then Exit;

     // menu = place
     if (PN[_].El[Gs].tipo = KPlace) then begin
        PopupMenuPlace.PopUp(Form1.Left + CanvasScroller.Left + pX,
                         Form1.Top + CanvasScroller.Top + pY + 50);
        exit
     end else
     // menu = arc
     if (PN[_].El[Gs].tipo = KArc) then begin

        MiDoubleArc.Checked := PN[_].El[Gs].atipo = (KArcDouble);

        PopupMenuArc.PopUp(Form1.Left + CanvasScroller.Left + pX,
                           Form1.Top + CanvasScroller.Top + pY + 50);
        Exit;
     // menu = transition
     end else begin

     //MITTransitionC.Enabled := (PN[_].El[Gs].ttipo = KTransition);
       MITEditSubPn.Enabled := PN[_].El[Gs].ttipo = KTransitionC;

       PopupMenuTransition.PopUp(Form1.Left + CanvasScroller.Left + pX,
                                 Form1.Top + CanvasScroller.Top + pY + 50);
       Exit;
     end;
  end;

  // still menu...
  if Gstate = KPopupMenu then
     Exit;

  // user wandering around, clicked mouse
  //  over empty space.
  // maybe he'll begin to trace a rectangle.
  if (Gstate = KSHovering) and (Gs < 0) then begin
      GState := KSDefiningRectangle;
      GPrevX := pX;
      GPrevY := pY;
      GNewX  := -1;

      // mark all objects as non-selected.
       for i:=1 to PN[_].Gi do
          PN[_].El[i].selected := false;

      Exit;
  end;

  // User clicked mouse over an object, probably to drag it.
  if (GState = KSHovering) and (Gs > -1) then begin

     GState := KSDraggingObject;
     Exit;
  end;

  // a selection rectangle exists, user clicked:
  if (GState = KSHoveringWithRectangle) then begin

     // user clicked outside rectangle.
     // abandomn selection.
     if ((pX < GPrevX) or (pX > GNewX) or
         (pY < GPrevY) or (pY > GNewY)) then begin

        GState := KSHovering;

        // mark all objects as non-selected.
        for i:=1 to PN[_].Gi do
          PN[_].El[i].selected := false;

        // undo rectangle
        GPrevX := -1;

        Exit;

     // user clicked inside rectangle.
     // begin dragging objects
     end else begin
        GState := KSStartDraggingSeveral;

        GDragX := pX;
        GDragY := pY;

        Exit;
     end
  end;


  // drawing a transition
  if ToolRect.Down = true then begin

    // one more element
    inc(PN[_].Gi);
    SetLength (PN[_].El, 1+ PN[_].Gi);

    inc(PN[0].TransCount);
    with PN[_].El[PN[_].Gi] do begin
        x := pX;
        y := pY;
        tipo  := KTransition;
        ttipo := KTransition;

        s := 'T' + IntToStr (PN[0].TransCount);
        //source[1] := -1;
        //target[1] := -1;
    end;

  // drawing a place
  end else if ToolOval.Down then begin

    // one more element
    inc(PN[_].Gi);
    SetLength (PN[_].El, 1+ PN[_].Gi);

    // one more place
    inc(PN[0].PlaceCount);

    with PN[_].El[PN[_].Gi] do begin
        x := pX;
        y := pY;
        tipo  := KPlace;
        ptipo := KPlace;
        s := 'P' + IntToStr (PN[0].PlaceCount);
    end;

  // drawing an arc
  end else if (ToolLine.Down and (Gs > -1)) then begin

    // one more element
    inc(PN[_].Gi);
    SetLength (PN[_].El, 1+ PN[_].Gi);

    PN[_].El[PN[_].Gi].x := PN[_].El[Gs].x;
    PN[_].El[PN[_].Gi].y := PN[_].El[Gs].y;
    PN[_].El[PN[_].Gi].tipo := KArc;
    PN[_].El[PN[_].Gi].id1 := Gs;
    PN[_].El[PN[_].Gi].id2 := -1;
    PN[_].El[PN[_].Gi].uidth := 1;

    Gs1 := Gs;

    Gstate := KCriandoLinha;

  end

end;

procedure TForm1.MyCanvasMouseMove(Sender: TObject; Shift: TShiftState; pX,
  pY: Integer);
label saidaMouseMove;
var i:integer;
    n, min: real;
    ax, ay: integer;
begin

  // These actions do not require mouse tracking.
  if ((Gstate = KEditName) or
      (Gstate = KPopupMenu)) then
      Exit;

  // If user selected several objects and is just
  //    moving mose around, just exit.
  // Otherwise we got objects selected with a rectangle,
  //    plus auto-selection with mouse movement = bizarre.
  if (not MouseIsDown and (Gstate = KSelectedObjects)) then
     Exit;

  // user is drawing rectangle
  if (GState = KSDefiningRectangle) then begin
    GNewX := pX;
    GNewY := pY;

    goto saidaMouseMove;
  end;


  // user is about to move several objects
  if (GState = KSStartDraggingSeveral) then begin
    GState := KSDraggingSeveral;
    GDragX := pX;
    GDragY := pY;
    exit;
  end;

  // user IS moving several objects...
  if (GState = KSDraggingSeveral) then begin
    GNewDragX := pX;
    GNewDragY := pY;

    MovaOsCabra;

    GDragX := GNewDragX;
    GDragY := GNewDragY;

    goto saidaMouseMove;
  end;


  // user is just wandering around.
  // highlight object under the mouse cursor.
  if (GState = KSHovering) or (GState = KSAddObject) then begin
    MouseSelectedElement (pX, pY);

    goto saidaMouseMove;
  end;

    // user is dragging one object around:
    //  move it!
    // object follows mouse.
  if (GState = KSDraggingObject) then begin
     PN[_].El[Gs].x := pX;
     PN[_].El[Gs].y := pY;

     goto saidaMouseMove;
  end;

  // placing a new element
  if (MouseIsDown and (PN[_].Gi > 0) and
      (ToolRect.Down or ToolOval.Down)) then begin

     PN[_].El[PN[_].Gi].x := pX; //(pX div GMagnetGrid) * GMagnetGrid;
     PN[_].El[PN[_].Gi].y := pY;

     Invalidate;
     RenderPetriNet(Sender);

  end;

  // only get coordinates.
  if (ToolLine.Down)  then begin

     // we need these coordinates,
     //   to register the end point of a line being drawn.
     GNewX := pX;
     GNewY := pY;

     // and we need these coordinates,
     //   to highlight and select the object
     //   being pointed by the cursor.
     // This applies to both endpoints of an arc.
     MouseSelectedElement (pX, pY);

  end;

 saidaMouseMove:
  Invalidate;
  RenderPetriNet (Sender);
end;

procedure TForm1.MyCanvasMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; pX, pY: Integer);
label saidaMouseUp;
var
   i : integer;
begin

  MouseIsDown := False;


  // release mouse during popup menu choice, just exit
  if (Gstate = KPopupMenu) then Exit;

  // release mouse while dragging to create line,
  //   this is the endpoint.
  if (Gstate = KCriandoLinha) then begin

     // Soltar mouse sobre objeto - verifique qual
     MouseSelectedElement (pX, pY);

     // não criar linha para si mesmo,
     //   ou para lugar vazio
     if ((Gs = Gs1) or (Gs < 0)) then begin
        dec (PN[_].Gi);
        Exit;
     end;

     // também não crie linha entre objetos de mesmo tipo.
     if (PN[_].El[PN[_].El[PN[_].Gi].id1].tipo = PN[_].El[Gs].tipo) then begin
        dec (PN[_].Gi);
        Exit;
     end;

     // marque na linha objeto final
     PN[_].El[PN[_].Gi].id2 := Gs;

     // marque na linha coordenadas do centro dela
     PN[_].El[PN[_].Gi].x :=
       (PN[_].El[PN[_].El[PN[_].Gi].id1].x +
        PN[_].El[PN[_].El[PN[_].Gi].id2].x) div 2;
     PN[_].El[PN[_].Gi].y :=
       (PN[_].El[PN[_].El[PN[_].Gi].id1].y +
        PN[_].El[PN[_].El[PN[_].Gi].id2].y) div 2;


     // interface volta ao estado zero
     Gstate := KSAddObject;
     Gs := -1;

  end; //KCriandoLinha

  // User stopped moving a single object.
  if  (GState = KSDraggingObject) then begin
    PN[_].El[Gs].x := (pX div GMagnetGrid) * GMagnetGrid;
    PN[_].El[Gs].y := (pY div GMagnetGrid) * GMagnetGrid;

    GState := KSHovering;
    goto saidaMouseUp;
  end;

    // User drawed rectangle, released mouse.
  if  (GState = KSDefiningRectangle) then begin

    // final coordinates of rectangle
    GNewX := pX;
    GNewY := pY;

    // re-order if necessary
    if (GNewX < GPrevX) then begin
      i := GNewX; GNewX := GPrevX; GPrevX := i;
    end;
    if (GNewY < GPrevY) then begin
      i := GNewY; GNewY := GPrevY; GPrevY := i;
    end;

    // no objects selected: forget rectangle
    if not GatherSelectedObjects then begin
        GPrevX := -1;
        GState := 0;

        goto saidaMouseUp;
    end;

    // Arrived here, there are objects selected.
    GState := KSHoveringWithRectangle;

    goto saidaMouseUp;

   end; //KSDefiningRectangle


  // There's still a rectangle selecting several objects.
  // User just released mouse.
  if (GState = KSDraggingSeveral) then begin

     GState := KSHoveringWithRectangle;

     // adjust with magnetic grid
     for i := 1 to PN[_].Gi do
        if (PN[_].El[i].selected) then begin
          PN[_].El[i].x := (PN[_].El[i].x div GMagnetGrid) * GMagnetGrid;
          PN[_].El[i].y := (PN[_].El[i].y div GMagnetGrid) * GMagnetGrid;
        end;

     GPrevX := (GPrevX div GMagnetGrid) * GMagnetGrid;
     GPrevY := (GPrevY div GMagnetGrid) * GMagnetGrid;
     GNewX  := (GNewX  div GMagnetGrid) * GMagnetGrid;
     GNewY  := (GNewY  div GMagnetGrid) * GMagnetGrid;

     goto saidaMouseUp;
  end;

(*
  if (Gstate = KSelectingRectangle) then begin

     GState := 0;

     GNewX := pX;
     GNewY := pY;

     // Verify if there's something inside
     //  the rectangle;

     //  AFTER doing that, set GPrevX

     if not GatherSelectedObjects then begin
        GPrevX := -1;
        goto saidaMouseUp;
     end;

     // End of Selection Operation,
     //   something was selected.
     GPrevX := -1;
     GState := KSelectedObjects;

  end;
 *)

 saidaMouseUp:

  Invalidate;
  RenderPetriNet (Sender);

end;



procedure TForm1.SpinEdit1Change(Sender: TObject);

begin

  if (Gs < 0) then Exit;

  if (PN[_].El[Gs].tipo = KPlace) then
     PN[_].El[Gs].count := SpinEdit1.Value

  else // arcs are always non-zero
     if (SpinEdit1.Value > 0) then
        PN[_].El[Gs].uidth := SpinEdit1.Value;

  Invalidate;
  RenderPetriNet (sender);

end;

procedure TForm1.SpinEdit1Exit(Sender: TObject);
begin

  Gs     := -1;

  Gstate := 0;

  SpinEdit1.Value := 0;

  SpinEdit1.Enabled := false;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
    ArmTransitions;
    PlayPetriNet;
    Invalidate;
    RenderPetriNet(Sender);
end;

procedure TForm1.ToolLineClick(Sender: TObject);
begin
  GState := KSAddObject;
end;

procedure TForm1.ToolOvalClick(Sender: TObject);
begin
  GState := KSAddObject;
end;

procedure TForm1.ToolPointerClick(Sender: TObject);
begin
  GState := KSHovering;
end;

procedure TForm1.ToolRectClick(Sender: TObject);
begin
  Gstate := KSAddObject
end;





begin
   _ := 0;

   SetLength (PN, 1);

   // field Gi points to the last elements of a petrinet,
   //   so (-1) means the net is empty.
   PN[_].s          := 'Root';
   PN[_].Gi         := -1;
   PN[_].PlaceCount := -1;
   PN[_].TransCount := -1;
//   PN[_]._Count     := 0;


   // no element selected yet
   Gs := -1;

  // Gss := 0;
   Gsize := 20;
   //Gplacecount := 0;
   //Gtransitioncount := 0;
   Gmidsize := Gsize div 2;
   GsizeToken := Gsize div 4;

   GAnimInterval := 500;

   GMagnetGrid := 1;

   // no selection rectangle being drawn.
   GPrevX := -1;

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


select tool

mouse down out of shape
drag with Gs = -1
mouse up with Gs = -1 -> rectangle
  select all objects
  Gstate = KSelectedMany

mouse down and
over shape and
KSelectedMany
   KMoveMany

mouse move and
KMoveMany
    movemany







hovering

hovering-over-object

clicked-over-object

clicked-over-empty-space

clicked-over-selected-object








*)
