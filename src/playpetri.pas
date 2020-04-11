// As the name indicates,
//  this procedure finds which transitions are ready to fire
//  and takes note of that.
procedure TForm1.ArmTransitions;
var i,j,k,n: integer;
begin

   for n := 1 to GTransitionCount do begin

       i := GTransitionList[n];

       GElements[i].active := true;

       j := 1;
       while (GElements[i].active
              and
              (GElements[i].source[j] > 0)) do begin

          // this a place,
          // pointed by an incoming arc
          k := GElements[i].source[j];

          GElements[i].active := (GElements[k].count > 0);
          inc (j);
       end;
    end;
end;



procedure TForm1.PrepareToPlayPetriNet;

   // auxiliary proc, do as the name says
   procedure LinkPlaceTransition (t1, t2: integer);
      var j : integer;
   begin
      j := 1;
      while ((j <= KNumBranches) and (GElements[t2].source[j] > 0)) do
         inc(j);

      if (j <= KNumBranches) then
          GElements[t2].source[j] := t1;
   end;

   // auxiliary proc, do as the name says
   procedure LinkTransitionPlace (t1, t2: integer);
      var j : integer;
   begin
      j := 1;
      while ((j <= KNumBranches) and (GElements[t1].target[j] > 0)) do
         inc(j);

      if (j <= KNumBranches) then
          GElements[t1].target[j] := t2;
   end;

var i, j, k, t1, t2: integer;
begin


  // First step, clean links.
  GTransitionCount := 0;
  for i := 1 to Gi do
     if GElements[i].tipo = KTransition then begin

        inc(GTransitionCount);
        GTransitionList[GTransitionCount] := i;

        for j := 1 to KNumBranches do begin
           GElements[i].source[j] := -1;
           GElements[i].target[j] := -1;
        end
     end;

  // Second step, (re)create links.
  for i := 1 to Gi do begin

     if (GElements[i].tipo <> KArc) then Continue;

     t1 := GElements[i].id1;
     t2 := GElements[i].id2;

     if (GElements[t1].tipo = KPlace) then
        LinkPlaceTransition (t1, t2)
     else
        LinkTransitionPlace (t1, t2);
  end;

  // Third step, arm transitions.
  ArmTransitions;

end;
function TForm1.PlayPetriNet : integer;

   function SelectTransition : integer;
   var i, k: integer;
   begin;
      k := trunc(random * GTransitionCount);
      i := k;

      repeat
         i := 1 + (i mod GTransitionCount);
         if GElements[GTransitionList[i]].active then begin
            SelectTransition := GTransitionList[i];
            Exit;
         end;
      until i=k;

      SelectTransition := -1;
   end;

var i, t: integer;
begin;
   t := SelectTransition;

   if (t < 1) then begin
      PlayPetriNet := -1;
      Exit;
   end;

   i := 1;
   while (GElements[t].source[i] > 0) do begin
      dec (GElements[GElements[t].source[i]].count);
      inc (i);
   end;

    i := 1;
   while (GElements[t].target[i] > 0) do begin
      inc (GElements[GElements[t].target[i]].count);
      inc (i);
   end;

   PlayPetriNet := t;
end;   
