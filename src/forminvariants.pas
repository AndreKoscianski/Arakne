unit forminvariants;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    ButtonClose: TButton;
    Memo1: TMemo;
    RadioGroupScope: TRadioGroup;
    RadioGroupType: TRadioGroup;
    RadioGroupFormat: TRadioGroup;
    procedure Button1Click(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  Form3: TForm3;

implementation

uses frm1;

{$R *.lfm}

{ TForm3 }

procedure TForm3.Button1Click(Sender: TObject);
var
  r,c,nr,nc : integer;
  s : string;


  function NomeDoCabra (idx:integer; flagP : boolean) : string;
  begin

       if (flagP) then
         NomeDoCabra :=
            PN[_].El[Form1.GPlaceName[idx]].s
       else
         NomeDoCabra :=
            PN[_].El[Form1.GTransName[idx]].s;
  end;

begin

  // clear old results and re-calculate.
  Memo1.Lines.Clear;

  // parameter true = T-invariants.
  Form1.ComputeInvariants (RadioGroupScope.ItemIndex = 1
                          ,RadioGroupType .ItemIndex = 1);

  // obtain size of matrix
  nr := length (Form1._matrix);

  if (nr < 1) then begin

     if (RadioGroupType.ItemIndex = 0) then
        Memo1.Lines.Add ('No Place Invariants')
     else
       Memo1.Lines.Add ('No Transition Invariants');

     Exit;
  end;
  nc := length (Form1._matrix[0]);

  if (nc < 1) then exit;


  // print matrix to memo
  for  r := 0 to nr-1 do begin

     s := '';
     for c := 0 to nc-1 do begin

        // matrix format
        if RadioGroupFormat.ItemIndex = 1 then
           s := s + IntToStr (Form1._matrix[r][c]) + ' ,'

        // list format
        else  begin

           // null element, skip it
           if 0 = Form1._matrix[r][c] then continue;

           // get name
           s := s + NomeDoCabra (c, (0 = RadioGroupType.ItemIndex))
                  + ' ';

        end //else


     end;  // for c

     Memo1.Lines.Add (s);

  end; // for r
end;

procedure TForm3.ButtonCloseClick(Sender: TObject);
begin
   Close;
end;

procedure TForm3.FormShow(Sender: TObject);
begin
  RadioGroupScope.Enabled := (length(PN) > 1);
end;

end.

