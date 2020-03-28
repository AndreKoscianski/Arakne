unit frm1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Buttons, Clipbrd, LCLIntf, LCLType, StdCtrls, Spin, Menus,
  DOM, XMLRead, XMLWrite;
//,GraphUtil;

type

  { TForm1 }

  TArray4 = array[1..4] of TPoint;

  TForm1 = class(TForm)
    btnOpen: TBitBtn;
    btnNew: TBitBtn;
    btnCopy: TBitBtn;
    btnSave: TBitBtn;
    Edit1: TEdit;
    Label1: TLabel;
    MICount: TMenuItem;
    MIRename: TMenuItem;
    MIDelete: TMenuItem;
    MyCanvas: TPaintBox;
    OpenDialog1: TOpenDialog;
    PopupMenu1: TPopupMenu;
    SaveDialog1: TSaveDialog;
    CanvasScroller: TScrollBox;
    SpinEdit1: TSpinEdit;
    ToolErase: TSpeedButton;
    ToolRect: TSpeedButton;
    ToolPointer: TSpeedButton;
    ToolLine: TSpeedButton;
    ToolOval: TSpeedButton;
    procedure btnCopyClick(Sender: TObject);
    procedure btnNewClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnPasteClick(Sender: TObject);
    procedure btnResizeClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit1EditingDone(Sender: TObject);
    procedure Edit1Exit(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure MICountClick(Sender: TObject);
    procedure MIDeleteClick(Sender: TObject);
    procedure MIRenameClick(Sender: TObject);
    procedure MyCanvasClick(Sender: TObject);
    procedure MyCanvasDblClick(Sender: TObject);
    procedure MyCanvasMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; pX, pY: Integer);
    procedure MyCanvasMouseMove(Sender: TObject; Shift: TShiftState; pX,
      pY: Integer);
    procedure MyCanvasMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; pX, pY: Integer);
    procedure MyCanvasPaint(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit1Exit(Sender: TObject);
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
       (no: TDOMNode; var sid, sname: string; var id1, id2: integer);
    procedure RemoverElemento;
  public
    { public declarations }
  end;

var
  Form1: TForm1;

  paintbmp: TBitmap;

  MouseIsDown: Boolean;
  PrevX, PrevY: Integer;

implementation

{$R *.lfm}

const
  KPlace = 1;
  KTransition = 2;
  KArc = 3;
  KEditName = 4;
  KCriandoLinha = 5;
  KNothing = 6;
  KPopupMenu = 7;
  KLengthName = 15;
  KNumElements = 1000;


type TElement = record
   x, y, id1, id2, tipo, count : integer;
   s: String[KLengthName];
end;


var GElements : array[1..KNumElements] of TElement;
    Gi  // current element being created
   ,Gs, Gss // current element selected
   ,Gs1, Gs2 // while creating an arrow
   ,Gsize , Gmidsize   // current size to draw element
   ,GsizeToken
   ,Gstate
   ,Gplacecounter
   ,Gtransitioncounter
      : integer;

   Gstr: array[1..KNumElements] of string;

{ TForm1 }
procedure TForm1.ExtraiaDadosPlaceXML
   (no: TDOMNode; var sid, sname: string; var x, y, count: integer);
var
   aux,aux2 : TDOMNode;
   i,k : integer;
   lista: TDOMNodeList;
   saux : string;
begin

  sid := no.Attributes.Item[0].Nodevalue;

  lista := no.ChildNodes;

  for k := 0 to (lista.Count - 1) do with lista.Item[k] do begin
  if (NodeName = 'graphics') then begin

     aux := lista.Item[k].FindNode('position');

     if (nil <> aux) then begin
         for i:= 0 to 1 do
           if ('x' = aux.Attributes.Item[i].NodeName) then
            x := StrToInt (aux.Attributes.Item[i].NodeValue)
           else if ('y' = aux.Attributes.Item[i].NodeName) then
            y := StrToInt (aux.Attributes.Item[i].NodeValue);
      end
  end else if (NodeName = 'name') then begin

     aux := lista.Item[k].FindNode('text');

     if (nil = aux) then sname := sid
     else                sname := aux.TextContent;

  end else if (NodeName = 'initialMarking') then begin

     aux := lista.Item[k].FindNode('text');

     if (nil = aux) then continue;

     saux := aux.TextContent;

     if (saux <> '') then count := StrToInt (saux);
  end

end;

end;

procedure TForm1.ExtraiaDadosTransitionXML
   (no: TDOMNode; var sid, sname: string; var x, y: integer);
var
   aux,aux2 : TDOMNode;
   i,k : integer;
   lista: TDOMNodeList;
   saux : string;
begin

  sid := no.Attributes.Item[0].Nodevalue;

  lista := no.ChildNodes;

  for k := 0 to (lista.Count - 1) do with lista.Item[k] do begin
  if (NodeName = 'graphics') then begin

     aux := lista.Item[k].FindNode('position');

     if (nil <> aux) then begin
         for i:= 0 to 1 do
           if ('x' = aux.Attributes.Item[i].NodeName) then
            x := StrToInt (aux.Attributes.Item[i].NodeValue)
           else if ('y' = aux.Attributes.Item[i].NodeName) then
            y := StrToInt (aux.Attributes.Item[i].NodeValue);
      end
  end else if (NodeName = 'name') then begin

     aux := lista.Item[k].FindNode('text');

     if (nil = aux) then sname := sid
     else                sname := aux.TextContent;

  end
end;

end;

procedure TForm1.ExtraiaDadosArcXML
   (no: TDOMNode; var sid, sname: string; var id1, id2: integer);
var
   aux,aux2 : TDOMNode;
   i,k,n : integer;
   lista: TDOMNodeList;
   saux : string;
begin

  n := no.Attributes.Length;

  id1 := 0;
  id2 := 0;

  for i:=0 to n-1 do begin

     if ('id' = no.Attributes.Item[i].NodeName) then
        sid := no.Attributes.Item[i].NodeValue

     else if ('source' = no.Attributes.Item[i].NodeName) then begin

        saux := no.Attributes.Item[i].NodeValue;

        for k:=1 to Gi do begin
           if (Gstr[k] = saux) then begin
              id1 := k;
              Break
           end
        end

     end else if ('target' = no.Attributes.Item[i].NodeName) then begin

        saux := no.Attributes.Item[i].NodeValue;

        for k:=1 to Gi do begin
           if (Gstr[k] = saux) then begin
              id2 := k;
              Break
           end
        end

     end


  end
end;

procedure TForm1.CarregueXML (s: string);
var
  Doc: TXMLDocument;
  node, Child: TDOMNode;
  Members: TDOMNodeList;
  i, x, y, count: integer;
  sid, sname : string;
  begin

    try
      ReadXMLFile(Doc, s);
      // using FirstChild and NextSibling properties
      Child := Doc.DocumentElement.FirstChild;

      // ===Places===
      Members := Doc.GetElementsByTagName('place');

      for i:= 0 to Members.Count - 1 do begin

         node := Members[i];

         ExtraiaDadosPlaceXML (Members[i], sid, sname, x, y, count);

         inc (Gi);
         Gstr[Gi] := sid;
         GElements[Gi].x := x;
         GElements[Gi].y := y;
         GElements[Gi].tipo := KPlace;
         GElements[Gi].s := sname;
         GElements[Gi].count := count;
      end;

      // ===Transitions===
      Members := Doc.GetElementsByTagName('transition');

      for i:= 0 to Members.Count - 1 do begin

         node := Members[i];

         ExtraiaDadosTransitionXML (Members[i], sid, sname, x, y);

         inc (Gi);
         Gstr[Gi] := sid;
         GElements[Gi].x := x;
         GElements[Gi].y := y;
         GElements[Gi].tipo := KTransition;
         GElements[Gi].s := sname;
      end;

       // ===Arcs===
      Members := Doc.GetElementsByTagName('arc');

      for i:= 0 to Members.Count - 1 do begin

         node := Members[i];

         ExtraiaDadosArcXML (Members[i], sid, sname, x, y);

         if ((x < 1) or (y < 1)) then Halt;

         inc (Gi);
         Gstr[Gi] := sid;
         GElements[Gi].id1 := x;
         GElements[Gi].id2 := y;
         GElements[Gi].tipo := KArc;

         // marque na linha coordenadas do centro dela
         GElements[Gi].x :=
           (GElements[GElements[Gi].id1].x +
            GElements[GElements[Gi].id2].x) div 2;
         GElements[Gi].y :=
           (GElements[GElements[Gi].id1].y +
            GElements[GElements[Gi].id2].y) div 2;
      end;

    finally
      Doc.Free;
    end;
  end;
procedure TForm1.GereXML (s: string);
var
  Doc: TXMLDocument;                                  // variable to document
  RootNode,
  node,
  node2,
  node3,
  node4: TDOMNode;

  i: integer;

begin

  try
    // Create a document
    Doc := TXMLDocument.Create;

    Doc.TextContent:= 'abc';

   // Doc.SetAttribute ('xmlns', 'http://www.pnml.org/version-2009/grammar/pnml');

    // Create a root node
    RootNode := Doc.CreateElement('net');
    Doc.AppendChild (RootNode);
    TDOMElement(RootNode).SetAttribute ('id', 'myself');
    TDOMElement(RootNode).SetAttribute ('type', 'http://www.pnml.org/version-2009/grammar/ptnet');

     // Create a parent node
    RootNode:= Doc.DocumentElement;

    node := Doc.CreateElement('page');
    TDOMElement(node).SetAttribute('id', '0');
    RootNode.Appendchild(node);

    // tudo ficará dentro desta página.
    RootNode := node;

    for i:=1 to Gi do with GElements[i] do begin

    if tipo = KPlace then begin
    //==Place==
    node := Doc.CreateElement ('place');
    TDOMElement(node).SetAttribute ('id',IntToStr(i));
    RootNode.AppendChild(node);

    node2 := Doc.CreateElement ('name');
      node.AppendChild (node2);
      node3 := Doc.CreateElement ('text');
      node2.AppendChild (node3);
      node4 := Doc.CreateTextNode (s);
      node3.AppendChild (node4);
    node2 := Doc.CreateElement ('graphics');
      node.AppendChild (node2);
      node3 := Doc.CreateElement ('position');
      TDOMElement(node3).SetAttribute ('x', IntToStr(x));
      TDOMElement(node3).SetAttribute ('y', IntToStr(y));
      node2.AppendChild (node3);
    node2 := Doc.CreateElement ('initialMarking');
      node.AppendChild (node2);
      node3 := Doc.CreateElement ('text');
      node2.AppendChild (node3);
      node4 := Doc.CreateTextNode (IntToStr(count));
      node3.AppendChild (node4);
    end;

    if tipo = KTransition then begin
    //==Transition==
    node := Doc.CreateElement ('transition');
    TDOMElement(node).SetAttribute ('id',IntToStr(i));
    RootNode.AppendChild(node);

    node2 := Doc.CreateElement ('name');
      node.AppendChild (node2);
      node3 := Doc.CreateElement ('text');
      node2.AppendChild (node3);
      node4 := Doc.CreateTextNode (s);
      node3.AppendChild (node4);
    node2 := Doc.CreateElement ('graphics');
      node.AppendChild (node2);
      node3 := Doc.CreateElement ('position');
      TDOMElement(node3).SetAttribute ('x', IntToStr(x));
      TDOMElement(node3).SetAttribute ('y', IntToStr(y));
      node2.AppendChild (node3);
    end;

    if tipo = KArc then begin
     //==Arc==
    node := Doc.CreateElement ('arc');
    TDOMElement(node).SetAttribute ('id',IntToStr(i));
    TDOMElement(node).SetAttribute ('source',IntToStr(id1));
    TDOMElement(node).SetAttribute ('target',IntToStr(id2));
    RootNode.AppendChild(node);
    end

    end; // for LOOP


    writeXMLFile(Doc, s);

  finally
    Doc.Free;
  end;
end;
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
      MyCanvasPaint(Sender);

    end else begin
      ShowMessage('File is not found. You will have to open an existing file.');

    end;

  end;
end;

procedure TForm1.btnNewClick(Sender: TObject);
begin
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

    MyCanvasPaint(Sender);
end;

procedure TForm1.btnCopyClick(Sender: TObject);
begin

  Clipboard.Assign(paintbmp);

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
    MyCanvasPaint(Sender);

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
  MyCanvasPaint(Sender);

end;

procedure TForm1.btnSaveClick(Sender: TObject);
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

procedure TForm1.Edit1Change(Sender: TObject);
begin

end;


procedure TForm1.Edit1EditingDone(Sender: TObject);
begin

  Gstate := 0;

  GElements[Gss].s := Edit1.Text;

  Gs := 0;
  Gss := 0;

  Invalidate;
  MyCanvasPaint (Sender);

end;

procedure TForm1.Edit1Exit(Sender: TObject);
begin
  Edit1.Text := '';
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
  // We create a new file/canvas/document when
  // it starts up
  btnNewClick(Sender);
end;

procedure TForm1.MICountClick(Sender: TObject);
begin
  Gss := Gs;

  Gstate := KEditName;

  SpinEdit1.Value := GElements[Gs].count;
  SpinEdit1.SetFocus;
end;

procedure TForm1.MIDeleteClick(Sender: TObject);
begin
  Gstate := 0;

  if (Gs > 0) then begin
     RemoverElemento;
     Invalidate;
     MyCanvasPaint (Sender);
  end;

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



procedure TForm1.MyCanvasClick(Sender: TObject);
begin

  if (Gstate = KEditName) then begin
    Edit1.Text := '';
    Gs := 0;
    Gss := 0;

    Gstate := 0;
    BtnSave.SetFocus;
    Exit;

  end;

  if ((not ToolPointer.Down) and (not ToolErase.Down)) then Exit;

  Gss := 0;

  if (Gs < 1) then
     Exit;

  if (ToolErase.Down) then begin
     RemoverElemento;
     Invalidate;
     MyCanvasPaint(Sender);
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

     MICount.Enabled := (GElements[Gs].tipo = KPlace);


     PopupMenu1.PopUp(Form1.Left + CanvasScroller.Left + pX,
                      Form1.Top + CanvasScroller.Left + pY + 50);
    // Gstate := KPopupMenu;
     Exit;
  end;

  if Gstate = KPopupMenu then
     Exit;

  if ToolRect.Down = true then begin
    inc(Gi);
    inc(Gtransitioncounter);
    with GElements[Gi] do begin
        x := pX;
        y := pY;
        tipo := KTransition;
        s := 'T' + IntToStr (Gtransitioncounter);
    end;
  end else if ToolOval.Down then begin
    inc(Gi);
    inc(Gplacecounter);
    with GElements[Gi] do begin
        x := pX;
        y := pY;
        tipo := KPlace;
        s := 'P' + IntToStr (Gplacecounter);
    end;
  end else if (ToolLine.Down and (Gs > 0)) then begin

    inc(Gi);
    GElements[Gi].x := GElements[Gs].x;
    GElements[Gi].y := GElements[Gs].y;
    GElements[Gi].tipo := KArc;
    GElements[Gi].id1 := Gs;
    GElements[Gi].id2 := -1;

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
    MyCanvasPaint(Sender);

  end;

  // placing a new element
  if (MouseIsDown and (Gi > 0) and
      (ToolRect.Down or ToolOval.Down)) then begin

     GElements[Gi].x := pX;
     GElements[Gi].y := pY;

     Invalidate;
     MyCanvasPaint(Sender);

  end;

  // only get coordinates.
  if ((ToolLine.Down) or (ToolErase.Down)) then begin

     PrevX := pX;
     PrevY := pY;

     MouseSelectedElement (pX, pY);
     Invalidate;
     MyCanvasPaint (Sender);
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
  MyCanvasPaint (Sender);

end;

procedure TForm1.MyCanvasPaint(Sender: TObject);
var i, ax, ay: integer;
    d, dx, dy: real;
    atp : array[1..4] of TPoint;
    cor : TColor;

begin

  MyCanvas.Canvas.Brush.Color := clWhite;
  MyCanvas.Canvas.Pen  .Color := clBlack;


  for i:=1 to Gi do begin


      if GElements[i].tipo = KNothing then Continue;


      // Se elemento selecionado, cor = amarelo
      if (Gss = i) then
         MyCanvas.Canvas.Brush.Color := clYellow
      else if (Gs = i) then
         MyCanvas.Canvas.Brush.Color := clOlive
      else
         MyCanvas.Canvas.Brush.Color := clWhite;

       with GElements[i] do begin

          // vamos plotar linha
          if tipo = KArc then begin

             // a linha ainda não tem elemento final.
             // então plote reta até posição atual do mouse.
             if GElements[i].id2 = -1 then begin
                MyCanvas.Canvas.Line (
                   GElements[GElements[i].id1].x,
                   GElements[GElements[i].id1].y,
                   prevX, prevY);
                Continue;
             end ;

             // Se chegou aqui, reta tem ponto final.

             if (Gs = i) then begin
                MyCanvas.Canvas.Pen.Color := clOlive;
                MyCanvas.Canvas.Pen.Width := 4;
             end;

             // marque na linha coordenadas do centro dela
             GElements[i].x :=
               (GElements[GElements[i].id1].x +
                GElements[GElements[i].id2].x) div 2;
             GElements[i].y :=
               (GElements[GElements[i].id1].y +
                GElements[GElements[i].id2].y) div 2;

             atp[1].x := GElements[i].x;
             atp[1].y := GElements[i].y;
             atp[2].x := GElements[GElements[i].id2].x;
             atp[2].y := GElements[GElements[i].id2].y;


             // Termine com uma flecha.
             dx := (atp[2].x - atp[1].x);
             dy := (atp[2].y - atp[1].y);

             d := sqrt (dx*dx + dy* dy);

             dx := Gsize * (dx / d);
             dy := Gsize * (dy / d);

             // arrow base
             atp[3].x := atp[2].x - trunc(dx); atp[3].y := atp[2].y - trunc(dy);


            // Draw arc
            MyCanvas.Canvas.Line (
                   GElements[GElements[i].id1].x,
                   GElements[GElements[i].id1].y,
                   atp[3].x,
                   atp[3].y
                   );

            MyCanvas.Canvas.Pen.Color := clBlack;
            MyCanvas.Canvas.Pen.Width := 1;

            // Draw Arrows

            // arrow line1
            atp[4].x := atp[3].x - trunc(dx * 0.866 + dy * -0.500);
            atp[4].y := atp[3].y - trunc(dx * 0.500 + dy *  0.866);

             MyCanvas.Canvas.Line (
                atp[3].x, atp[3].y,
                atp[4].x, atp[4].y
                );

             // arrow line2
             atp[4].x := atp[3].x - trunc(dx *  0.866 + dy * 0.500);
             atp[4].y := atp[3].y - trunc(dx * -0.500 + dy * 0.866);

             MyCanvas.Canvas.Line (
                atp[3].x, atp[3].y,
                atp[4].x, atp[4].y
                );



            (* if (atp[1].x < atp[2].x) then atp[2].x := atp[2].x - Gsize;
             if (atp[2].x < atp[1].x) then atp[2].x := atp[2].x + Gsize;
             if (atp[1].y < atp[2].y) then atp[2].y := atp[2].y - Gsize;
             if (atp[1].y < atp[2].y) then atp[2].x := atp[2].y + Gsize;

             DrawArrow(MyCanvas.Canvas,atp[1],atp[2],atArrows); //atSolid
            *)

            // Calcule Bezier e plote.
(*            InterpolateBezier (GElements[i].id1,
                               GElements[i].id2,
                               atp);

            MyCanvas.Canvas.PolyBezier(atp);
 *)
             Continue;
          end

          else if tipo = KPlace then begin

             MyCanvas.Canvas.Ellipse (x-Gsize, y-Gsize, x+Gsize, y+Gsize);

             if (count > 0) then begin

                cor := MyCanvas.Canvas.Brush.Color;

                MyCanvas.Canvas.Brush.Color := clBlack;

                if (count = 1) or (count = 3) then
                 MyCanvas.Canvas.Ellipse (x-GsizeToken, y-GsizeToken, x+GsizeToken, y+GsizeToken);

                if (count = 2) or (count = 3) then begin
                  ax := x - 2*GsizeToken;
                  ay := y + 2*GsizeToken;
                  MyCanvas.Canvas.Ellipse (ax-GsizeToken, ay-GsizeToken, ax+GsizeToken, ay+GsizeToken);

                  ax := x + 2*GsizeToken;
                  ay := y - 2*GsizeToken;
                  MyCanvas.Canvas.Ellipse (ax-GsizeToken, ay-GsizeToken, ax+GsizeToken, ay+GsizeToken);
                end;

                if (count > 3) then   begin
                   MyCanvas.Canvas.Brush.Color := cor;
                   MyCanvas.Canvas.TextOut(x - GsizeToken, y- GsizeToken, IntToStr(count));
                end ;

                MyCanvas.Canvas.Brush.Color := cor;
             end
          end

          else if tipo = KTransition then
             MyCanvas.Canvas.Rectangle (x-Gsize, y-Gmidsize, x+Gsize, y+Gmidsize);


          MyCanvas.Canvas.TextOut(x + Gsize + 5, y, s);

       end;
  end;


end;

procedure TForm1.SpinEdit1Change(Sender: TObject);

begin

  if (Gss < 1) then Exit;

  GElements[Gss].count := SpinEdit1.Value;

  Invalidate;
  MyCanvasPaint (sender);

end;

procedure TForm1.SpinEdit1Exit(Sender: TObject);
begin
  Gs := 0;
  Gss := 0;
  Gstate := 0;

  SpinEdit1.Value := 0;
end;

procedure TForm1.InterpolateBezier (id1, id2 : integer;
           var atp: TArray4);//array[1..4] of TPoint);
var  x1, y1
    ,x4, y4
    ,xc, yc: integer;
begin

  atp[1].x := GElements[id1].x;
  atp[1].y := GElements[id1].y;
  atp[4].x := GElements[id2].x;
  atp[4].y := GElements[id2].y;

  xc := abs(atp[4].x-atp[1].x);
  yc := abs(atp[4].y-atp[1].x);

  if (xc > yc) then begin
     atp[2].x := atp[1].x + ((atp[4].x - atp[1].x) div 2);
     atp[3].x := atp[2].x;
     atp[2].y := atp[1].y;
     atp[3].y := atp[4].y;
  end else begin
     atp[2].y := atp[1].y + ((atp[4].y - atp[1].y) div 2);
     atp[3].y := atp[2].y;
     atp[2].x := atp[1].x;
     atp[3].x := atp[4].x;
  end

end;



begin
   Gi := 0;
   Gs := 0;
   Gss := 0;
   Gsize := 20;
   Gplacecounter := 0;
   Gtransitioncounter := 0;
   Gmidsize := Gsize div 2;
   GsizeToken := Gsize div 4;

end.

