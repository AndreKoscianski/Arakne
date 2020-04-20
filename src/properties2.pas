
var
  _id, _matrix : TMatrix;



//----------------------------------------------------------------
procedure TForm1.TransposeMatrix;
var
   i,j,aux:integer;
begin

  for i:=0 to GPlaceCount-1 do
     for j:=0 to i-1 do begin
        aux := _matrix[i][j];
        _matrix[i][j] := _matrix[j][i];
        _matrix[j][i] := aux;
     end;
end;

//------------------------------------------------------
procedure TForm1.ComputeMatrix;

var
  i,j,k,np,nt,it,ip: integer;

  aux : ^TArcs;
begin


   // Set sequential numbers to places and transitions.

   np := 0;
   nt := 0;

   for i := 1 to Gi do begin
      if (GElements[i].tipo = KPlace) then begin
         GElements[i].seqnumber := np;
         inc (np);
         Continue;
      end;
      if (GElements[i].tipo = KTransition) then begin
         GElements[i].seqnumber := nt;
         inc (nt);
         Continue;
      end;
   end;


   // Scan the network and extract topology
   //   in the form of lists.
   PrepareToPlayPetriNet;

   // Set Matrix Dimension.
   SetLength (_matrix, Gplacecount, Gtransitioncount * 2);

   // Clean Matrix.
   // It's a global variable used across calls.
   for i := 0 to GPlaceCount-1 do begin
      for j := 0 to GTransitionCount-1 do begin
         _matrix[i][j] := 0;
         _matrix[i][j+GTransitionCount] := 0;
      end;         
     _matrix[i][i+GTransitionCount] := 1;
  end;         


   //-------------------------------------

   // for each transition
   for i := 0 to GTransitionCount-1 do begin

      it  := GElements[_trInfo[i].id].seqnumber;

      //----------------------------------------

      aux := _trInfo[i].input;

      // scan input arcs
      while (aux <> nil) do begin

         // Get index of the place in the matrix 
         ip := GElements[aux^.id].seqnumber;

         // If there's a double arc, 
         //    it'll be nullified by the 'output step' below.
         _matrix[ip][it] := _matrix[ip][it] -(aux^.uidth);

         aux := aux^.prox;
      end; // while

      //----------------------------------------

      aux := _trInfo[i].output;

      // scan input arcs
      while (aux <> nil) do begin

         // Get index of the place in the matrix 
         ip := GElements[aux^.id].seqnumber;

         // If there's a double arc, it'll be nullified.
         _matrix[ip][it] := _matrix[ip][it] + (aux^.uidth);

         aux := aux^.prox;
      end; // while

   end; // for


end;



//----------------------------------------------------

procedure TForm1.ComputeInvariants;
var
   i, j, l, nx, ny: integer ;

   //-------------------------------
   function FindRowWithCol1 : integer;
   var t,t2: integer;
   begin

      t2 := -1;

      for t:= i to ny do begin
         if abs(_matrix[t][i]) = 1 then begin
            FindRowWithCol1 := t;
            Exit;
         end;
         if (_matrix[t][i] <> 0) then
            t2 := t;
      end;// for
      FindRowWithCol1 := t2;
   end;

   //-------------------------------
   procedure SwapLines;
   var t,aux: integer;
   begin
      for t:= 0 to nx do begin
         aux := _matrix[i][t];
         _matrix[i][t] := _matrix[l][t];
         _matrix[l][t] := aux;
      end;
   end;

   //-------------------------------
   procedure SubtractLines;
   var t, alpha: integer;
   begin

      if (_matrix[j][i] = 0) then Exit;

      alpha := _matrix[j][i] div _matrix[i][i];

      //  Unlikely, because [i][i] should be 1
      if alpha = 0 then
         alpha := 1;

      for t:=i to nx do begin
         _matrix[j][t] := _matrix[j][t] - alpha * _matrix[i][t];
      end;
   end;

   procedure DebugConsole;
   var
      i2,j2: integer;
   begin
      writeln('----------------------');
      for i2:= 0 to GPlaceCount-1 do begin
         for j2:=0 to GTransitionCount-1 do begin
            write (_matrix[i2][j2]);
            write (' ');
         end;

         write (' | ');

         for j2:=0 to GTransitionCount-1 do begin
            write (_matrix[i2][j2+GTransitionCount]);
            write (' ');
         end;

         writeln (' ');
      end;
   end;

begin

   ComputeMatrix;

   ny := GPlaceCount - 1;
   nx := GTransitionCount * 2 - 1;

 //  TransposeMatrix;

   for i:= 0 to GPlaceCount-1 do begin

      l := FindRowWithCol1;

      if (l < 0) then Continue;

      if (l <> i) then
         SwapLines;

      for j:= i+1 to ny do
         SubtractLines;

   end;

   DebugConsole;

end;


