unit FormConfig;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ComCtrls;

type

  { TForm2 }

  TForm2 = class(TForm)
    ButtonDone: TButton;
    ButtonFont: TButton;
    EditMagnet: TEdit;
    EditAnim: TEdit;
    EditSize: TEdit;
    FontDialog1: TFontDialog;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    procedure ButtonDoneClick(Sender: TObject);
    procedure ButtonFontClick(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private

  public

  end;

var
  Form2: TForm2;

implementation

uses frm1;

{$R *.lfm}

{ TForm2 }

procedure TForm2.ButtonFontClick(Sender: TObject);
begin

  if (nil = GFont) then
     GFont := Form1.MyCanvas.Font;

  FontDialog1.Font := GFont;

  if not FontDialog1.Execute then
     FontDialog1.Font := GFont;
end;

procedure TForm2.ButtonDoneClick(Sender: TObject);
var
  aux : integer;
begin

   GFont := FontDialog1.Font;

   //-----------------------------------------------
   aux := StrToInt (EditSize.text);

   if (aux > 5) and (aux < 200) then begin
      GSize := aux;
      Gmidsize := Gsize div 2;
      GsizeToken := Gsize div 4;
   end;


   //-----------------------------------------------
   aux := StrToInt (EditAnim.text);

   if (aux > 49) and (aux < 2001) then begin
      GAnimInterval := aux;
   end;


   //-----------------------------------------------
   aux := StrToInt (EditMagnet.text);

   if (aux > 0) and (aux < 101) then begin
      GMagnetGrid := aux;
   end;

   Close;

end;

procedure TForm2.FormActivate(Sender: TObject);
begin
  EditSize  .Text := IntToStr (Gsize);
  EditAnim  .Text := IntToStr (GAnimInterval);
  EditMagnet.Text := IntToStr (GMagnetGrid);
end;

end.

