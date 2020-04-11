
procedure TForm1.LoadConfiguration;

const
  C_SECTION = 'Arakne-config';

var
  INI: TINIFile;
  str : string;
  aux : integer;

begin
  // Create the object, specifying the the ini file that contains the settings
  INI := TINIFile.Create('Arakne.ini');

  // Put reading the INI file inside a try/finally block to prevent memory leaks
  try

    //----------------------------------------
    str := INI.ReadString (C_SECTION,'PlaceSize','0');

    aux := StrToInt (str);

    if ((aux > 0) and (aux < 200)) then
       Gsize := aux
    else
       Gsize := 20;

    //----------------------------------------
    str := INI.ReadString (C_SECTION,'AnimInterval','0');

    aux := StrToInt (str);

    if ((aux > 50) and (aux < 2000)) then
       GAnimInterval := aux
    else
       GAnimInterval := 500;




  finally
    INI.Free;
  end;

  Gmidsize := Gsize div 2;
  GsizeToken := Gsize div 4;

end;




//-------------------------------------------------



procedure TForm1.SaveConfiguration;

const
  C_SECTION = 'Arakne-config';

var
  INI: TINIFile;
  str : string;
  aux : integer;
 
begin

  // Create the object, specifying the the ini file that contains the settings
  INI := TINIFile.Create('Arakne.ini');

  // Put reading the INI file inside a try/finally block to prevent memory leaks
  try
    INI.WriteString (C_SECTION,'PlaceSize', IntToStr (Gsize));
    INI.WriteString (C_SECTION,'AnimInterval', IntToStr (GAnimInterval));

  finally
    INI.Free;
  end;
end;
