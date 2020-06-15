procedure TForm1.SaveKSV (filename: string);
var
  i : integer;
  tfOut: TextFile;

  procedure Save1PN;
  var
    k: integer;
  begin

      // write basic data
      write (tfOut, 1+ PN[i].Gi
                    ,','
                    ,PN[i].s);

      // if this is PN[0], there is more data
      if (i = 0) then
        writeln (tfOut
                 ,',' , PN[i].PlaceCount
                 ,',' , PN[i].TransCount)
      else
        writeln (tfOut, '');

      // Now, list the elements.
      for k := 0 to PN[i].Gi do begin

        write (tfOut, k);
        write (tfOut, ',');

        case PN[i].El[k].tipo of
           KPlace : begin

             if (KPlace = PN[i].El[k].ptipo) then
                write (tfOut, 'P,')
             else
                write (tfOut, 'PC,');

             write (tfOut, PN[i].El[k].s    , ','
                         , PN[i].El[k].count, ','
                         , PN[i].El[k].x    , ','
                         , PN[i].El[k].y);

             if (KPlace = PN[i].El[k].ptipo) then
                writeln (tfOut, '')
             else
                writeln (tfOut, ',', PN[_].El[k].idx_real_p);

           end;

           KTransition : begin

             if (KTransition = PN[i].El[k].ttipo) then
                write (tfOut, 'T,')
             else
                write (tfOut, 'TC,');

             write (tfOut, PN[i].El[k].s, ','
                         , PN[i].El[k].x, ','
                         , PN[i].El[k].y);

             if     (KTransitionC = PN[i].El[k].ttipo)
                 or (k = 0)
                 or (k = 1)
             then
                writeln (tfOut, ',', PN[i].El[k].idx_subpn_t)
             else
                writeln (tfOut, '')

           end;
           KArc: begin
             write (tfOut, 'A,');

             write (tfOut, 'arc');
             //write (tfOut, PN[_].El[k].s);

             writeln (tfOut, ',', PN[i].El[k].atipo
                           , ',', PN[i].El[k].uidth
                           , ',', PN[i].El[k].id1
                           , ',', PN[i].El[k].id2);
           end;


        end;

      end;

  end;

begin

  AssignFile(tfOut, filename);

  try

    // Create the file.
    rewrite(tfOut);

    for i := 0 to length (PN)-1 do
       Save1PN;

    CloseFile(tfOut);

  except
    // If there was an error the reason can be found here
    on E: EInOutError do
      ;
  end;

end;

//-----------------------------------------------------------------------

procedure TForm1.LoadKSV (filename: string);
label
   badfile;
var
  tfIn: TextFile;
  sx: string;
  sl: tstringarray;
  i,k,n : integer;

  function ProcesseLinha : boolean;
  label
     badexit;
  var
    sl: tstringarray;
    j : integer;
  begin

    // prepare list
    //sl := tstringlist.create;
    //sl.delimiter := ',';
    //sl.text      := sx;
    sl := sx.split (',');

    // process arc
    if 'A' = sl[1] then begin

       if length (sl) < 6 then goto badexit;

       PN[i].El[k].tipo  := KArc;
       PN[i].El[k].s     := sl[2];
       PN[i].El[k].atipo := StrToInt(sl[3]);
       PN[i].El[k].uidth := StrToInt(sl[4]);
       PN[i].El[k].id1   := StrToInt (sl[5]);
       PN[i].El[k].id2   := StrToInt (sl[6]);

    end else
    // possibilities left = place or transition.
    if ('P' = sl[1]) or  ('PC' = sl[1]) then begin

         PN[i].El[k].tipo  := KPlace;

         if  ('P' = sl[1]) then
            PN[i].El[k].ptipo := KPlace
         else
            PN[i].El[k].ptipo := KPlaceC;

         PN[i].El[k].s     := sl[2];
         PN[i].El[k].count := StrToInt (sl[3]);
         PN[i].El[k].x     := StrToInt (sl[4]);
         PN[i].El[k].y     := StrToInt (sl[5]);

         if PN[i].El[k].ptipo = KPlaceC then
            if length (sl) < 7 then goto badexit
            else PN[i].El[k].idx_real_p := StrToInt (sl[6]);
    end
    else if ('T' = sl[1]) or ('TC' = sl[1]) then begin

         PN[i].El[k].tipo  := KTransition;

         if ('T' = sl[1]) then
            PN[i].El[k].ttipo := KTransition
         else
            PN[i].El[k].ttipo := KTransitionC;

         PN[i].El[k].s     := sl[2];
         PN[i].El[k].x     := StrToInt (sl[3]);
         PN[i].El[k].y     := StrToInt (sl[4]);


         if PN[i].El[k].ttipo = KTransitionC then
            if length (sl) < 6 then goto badexit
            else PN[i].El[k].idx_subpn_t := StrToInt (sl[5]);

      end; //transition

     // release memory.

     ProcesseLinha := true;
     exit;

    badexit:
     ProcesseLinha := false;

   end; //procedure


begin

  // Set the name of the file that will be read
  AssignFile(tfIn, filename);

  // Embed the file handling in a try/except block to handle errors gracefully
  try
    // Open the file for reading
    reset(tfIn);

    // Read PetriNet Length and name
    readln(tfIn, sx);

    i := 0; // PN number
    while not eof(tfIn) do begin

      // Each iteration loads a new PN, needs more space.
      SetLength (PN, 1+ i);

      sl := sx.split (',');

      // set Petri net length, use the
      //   standard representation throughout the code.
      // Gi points to the last element of the PN,
      //   index begins at zero.
      n := -1+ StrToInt (sl[0]);

      // petri net name
      if (length(sl) < 1) then raise Exception.Create ('badfile');
      PN[i].s  := sl[1];

      // petri net number of elements
      PN[i].Gi := n;
      SetLength (PN[i].El, 1+ n);

      // if this is PN[0], there is more data
      if (i = 0) then begin
         if length(sl) < 4 then raise Exception.Create ('badfile');

         PN[0].PlaceCount := StrToInt(sl[2]);
         PN[0].TransCount := StrToInt(sl[3]);
      end;

      for k := 0 to n do
        if not eof(tfIn) then begin
          readln(tfIn, sx);
          if not ProcesseLinha then raise Exception.Create ('badfile');
        end;

      // Read PetriNet Length and name
      readln(tfIn, sx);

      inc(i);

    end; // while

    // Done. Close the file
    CloseFile(tfIn);

  except

   // Eliminate sub-nets
   for k := 0 to i do
      SetLength (PN[k].El, 0);

   // There's only one net
   SetLength (PN, 1);

   // Standard initial values.
   PN[_].Gi := -1;
   PN[_].PlaceCount := -1;
   PN[_].TransCount := -1;
   //PN[_]._Count     := 0;
  end;

  _ := 0;


end;


