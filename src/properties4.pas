


//----------------------------------------------------------------
procedure TForm1.TransposeMatrix;
var
   i,j,ni,nj,aux:integer;
begin

  ni := length(_matrix);
  nj := length (_matrix[0]);

  // enlarge matrix to become square
  setlength (_matrix,ni+nj,ni+nj);

  // transpose
  for i:=0 to ni+nj-1 do
     for j:=0 to i-1 do begin
        aux := _matrix[i][j];
        _matrix[i][j] := _matrix[j][i];
        _matrix[j][i] := aux;
     end;

  // shrink matrix to rectangle, 90 degrees rotated.
  setlength (_matrix,nj,ni);
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

   for i := 0 to PN[_].Gi do begin
      if (PN[_].El[i].tipo = KPlace) then begin
         PN[_].El[i].seqnumber := np;
         inc (np);
         Continue;
      end;
      if (PN[_].El[i].tipo = KTransition) then begin
         PN[_].El[i].seqnumber := nt;
         inc (nt);
         Continue;
      end;
   end;

   _PlaceCount := np;
   _TransCount := nt;

   // Scan the network and extract topology
   //   in the form of lists.
   PrepareToPlayPetriNet;

   // Set Matrix Dimension.
   SetLength (_matrix, _PlaceCount, _TransCount);//+_PlaceCount);

   // Clean Matrix.
   // It's a global variable used across calls.
   for i := 0 to _PlaceCount-1 do
      for j := 0 to _TransCount-1 do
         _matrix[i][j] := 0;


   //-------------------------------------

   // for each transition
   for i := 0 to _TransCount-1 do begin

      it  := PN[_].El[_trInfo[i].id].seqnumber;

      //----------------------------------------

      aux := _trInfo[i].input;

      // scan input arcs
      while (aux <> nil) do begin

         // Attention!
         // inhibitor arcs are removed to compute invariants.
         // This is an option of this tool.
         if (not aux^.finhibitor) then begin

           // Get index of the place in the matrix
           ip := PN[_].El[aux^.id].seqnumber;

           // If there's a double arc,
           //    it'll be nullified by the 'output step' below.
           _matrix[ip][it] := _matrix[ip][it] -(aux^.uidth);

         end;

         aux := aux^.prox;
      end; // while

      //----------------------------------------

      aux := _trInfo[i].output;

      // scan input arcs
      while (aux <> nil) do begin

         // Get index of the place in the matrix 
         ip := PN[_].El[aux^.id].seqnumber;

         // If there's a double arc, it'll be nullified.
         // XXX this is a problem, as it ruins
         //  the calculation of invariants.
         // solution: add an artificial second place.
         // to be done.
         _matrix[ip][it] := _matrix[ip][it] + (aux^.uidth);

         aux := aux^.prox;
      end; // while

   end; // for


end;



//----------------------------------------------------

procedure TForm1.ComputeInvariants (flag_Unfold, flag_T : boolean);
var
   i, j, l, nx, ny: integer ;


   //-------------------------------------------------------
   // all networks can be copied together into
   //   a single network, in order to perform
   //   analysis or execution.
   // This is an auxiliary procedure that
   //   copies a single sub-pn and adjusts arc indices.
   procedure CopiarRede (tgt, src: integer);
   var
     i,n,offset : integer;
   begin;

     n := length (PN[tgt].El);


     // Gi points to last element of a PN.
     // It is -1 if network is empty.
     // n := total number of elements
     n := 2+ (PN[tgt].Gi) + (PN[src].Gi);
     SetLength (PN[tgt].El, n);

     // Start position where sub-net will be copied.
     offset := 1+ PN[tgt].Gi;

     // Index of last element of target PN.
     PN[tgt].Gi := 1+ PN[tgt].Gi
                    + PN[src].Gi;

     // loop, copy elements
     for i:=0 to PN[src].Gi do begin

        // copy
        PN[tgt].El[i+offset] := PN[src].El[i];

        // arc sources and destiny moved.
        if (Karc = PN[tgt].El[i+offset].tipo) then begin

           // be careful. only shift position of arcs to normal objects.
           // arcs from/to  input/output transitions of sub-net
           // must be left untouched,
           // they will be adjusted in a second pass.
           //if (PN[tgt].El[i+offset].id1 > 1) then
              PN[tgt].El[i+offset].id1 :=
                 offset + PN[tgt].El[i+offset].id1;

           //if (PN[tgt].El[i+offset].id2 > 1) then
              PN[tgt].El[i+offset].id2 :=
                 offset + PN[tgt].El[i+offset].id2;
        end;

     end; //for

   end; // procedure

   //----------------------------------------------------------
   // A transition that represents a sub-net must be
   //   unfolded. That's relatively easy to do.
   // First, copy the sub-net to the same array where the
   //   the super-net is.
   // Second, scan the array; any arcs targeting the super-transition
   //   must be mapped to input/output transitions of the sub-net.
   procedure AjustarTransicao (tgt, idt, idtin,idtout: integer);
   var
     i : integer;
   begin

      // start scanning one position after the super-transition,
      //   because sub-nets are copied after the super-net.
      i := idt + 1;

      repeat

        // Search for arcs.
        if (PN[tgt].El[i].tipo = KArc) then begin

           // Does the arc targets the input/output transitions
           //   of sub-net? Remap them to super-transition.
           if PN[tgt].El[i].id1 = idt then
              PN[tgt].El[i].id1 := idtout;

           if PN[tgt].El[i].id2 = idt then
              PN[tgt].El[i].id2 := idtin;
        end;

        inc(i);

      until (i = PN[tgt].Gi);

   end;
   //-------------------------------------------------------
   // Combine all sub-nets into a single PN.
   procedure Unfold_Sub_PN;
   var
     k,idt,idtin,idtout,tgt,isub: integer;
   begin

     // a single PN will contain all PN's combined.
     // It will be located at the last position of PN[].
     // Indices in PN[] begin at zero,
     //   so this is the index of the new PN:
     tgt := length (PN);

     // Nothing to do,
     //   there are no sub-pn.
     if (tgt < 2) then
        exit;

     // make room for result (=target, = tgt) PN.
     SetLength (PN, 1+ tgt);

     // target PN starts empty.
     PN[tgt].Gi := -1;

     // copy the first network.
     CopiarRede(tgt, 0);

     // now start scanning the resulting network;
     //  every super-transition must be expanded.
     // This is not a recursive procedure (the logic isn't).
     k:=0;
     repeat

        // all right, i could have used AND and short-circuit.
        // what the hell, i did not trusted the compiler here,
        // yesterday watched several conspiracy movies.
        // stop mumbling and read the code.

        // if element is 'super-transition', handle it.
        if (PN[tgt].El[k].tipo  = KTransition) then
        if (PN[tgt].El[k].ttipo = KTransitionC) then begin

           // remember super-transition index.
           idt := k;

           // this is the index of the sub-PN
           isub := PN[tgt].El.[idt].idx_subpn_t;

           // The sub-network has input and output transitions.
           // They are the first two elements of a sub-network.
           // They will fall into these places.
           idtin  := PN[tgt].Gi + 1;
           idtout := PN[tgt].Gi + 2;

           // Copy the subPN.
           // Super-transition has index of the sub-pn in PN[]
           CopiarRede(tgt, isub);

           // adjust arcs to/from super-transition,
           //  so they point to input/output transitions
           //  of the (now) unfolded net)
           AjustarTransicao (tgt, idt, idtin, idtout);

        end; // if

        inc(k);

     // Gi points to the last element of a network
     until (k > PN[tgt].Gi);

   end; // procedure

   //-------------------------------
   // this is part of Gaussian Elimination
   // search for a row that is not all zeroes
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
   // this is part of Gaussian Elimination
   procedure SwapLines (la,lb : integer);
   var t,aux: integer;
   begin
      for t:= 0 to nx do begin
         aux := _matrix[la][t];
         _matrix[la][t] := _matrix[lb][t];
         _matrix[lb][t] := aux;
      end;
   end;

   //-------------------------------
   // This is part of Gaussian Elimination
   procedure SubtractLines (a,b : integer);
   var t, alpha: integer;
   begin

      if (_matrix[b][a] = 0) then Exit;

      alpha := _matrix[b][a] div _matrix[a][a];

      //  Unlikely, because [i][i] should be 1
      if alpha = 0 then
         alpha := 1;

      for t:=i to nx do begin
         _matrix[b][t] := _matrix[b][t] - alpha * _matrix[a][t];
      end;
   end;

   //--------------------------------
   procedure DebugConsole;
   var
      i,j,ni,nj: integer;
   begin

      ni := length (_matrix);

      if (ni < 1) then exit;

      nj := length (_matrix[0]);

      writeln('----------------------');
      for i := 0 to ni-1 do begin
         for j:=0 to nj-1 do begin
            write (_matrix[i][j]);
            write (' ');
         end;
         writeln (' ');
      end;
   end;

   //--------------------------------
   // should be as triangular as possible
   procedure SortMatrix;
   var
     a,b,c,g: integer;
   begin

     for a:=0 to ny-1 do begin

        g  := _matrix[a][a];  // greatest so far
        c  := a; // greatest index so far

        b  := a + 1;

        while (b <= ny) do begin
           if (g < abs(_matrix[a][b])) then begin
              g := _matrix[a][b];
              c := b;
           end;

           inc(b);
        end;

        if (a <> c) then
           SwapLines (a,c);

     end; // for
   end;


   //-----------------------------------------------------
   // Once Gaussian Elimination is complete,
   //   get rid of non-zero lines
   //   and get rid of left matrix.
   // What is left, is the matrix of invariants.
   procedure ShrinkMatrix;
   var
      r,c,nx,nr,nc,ir,ic,sizer,sizec: integer;
      f : boolean;
   begin

      // size of left matrix.
      nr := length (_matrix);

      // There are no invariants.
      if (nr < 1) then exit;

      nc := length (_matrix[0]) - nr;
      nx := length (_matrix[0]) - nc;

      // Search for first line, where all columns are zero.
      // Remember, there are two matrices concatenated,
      //   we examine the left one.
      ir := -1;
      for r := 0 to nr-1 do begin
         f := true;
         for c := 0 to nc-1 do begin
            f := f and (_matrix[r][c] = 0);
         end;
         if f then begin
            inc(ir);
            for ic := 0 to nx-1 do
               _matrix[ir][ic] := _matrix[r][ic+nc];
         end
      end;

      // shrink the matrix!
      SetLength (_matrix,ir+1,nx);

   end; // procedure

   //--------------------------------------------------------
   // concatenate an identity matrix
   //   to the right of the incidence matrix.
   // the result will be used with gaussian elimination.
   procedure ConcatenateIdentityMatrix;
   var
      i, j, ni, nj: integer;
   begin
      // Set Matrix Dimension.
     if (Flag_T) then begin
        SetLength (_matrix, _TransCount, _TransCount+_PlaceCount);
        ni := _TransCount;
        nj := _PlaceCount;
     end else begin
        SetLength (_matrix, _PlaceCount, _TransCount+_PlaceCount);
        ni := _PlaceCount;
        nj := _TransCount;
     end;

     // Add Matrix.
     for i := 0 to ni-1 do begin
        for j := nj to ni+nj-1 do
           _matrix[i][j] := 0;
       _matrix[i][i+nj] := 1;
    end;
  end;

  procedure farkas;

    procedure zeralinha(d,e,f: integer);
    var
       k,alpha,res:integer;
    begin
       alpha := _matrix[e][f] div _matrix[d][f];

       for k:=f to nx do begin
          res := _matrix[e][k] - (alpha * _matrix[d][k]);
          _matrix[e][k] := res;
       end;
    end;

  var
     a,b,c:integer;
  begin

     // from 1st line to the last one
     for a := 0 to ny-1 do begin

       if 0 <> _matrix[a][a] then
          for b := a+1 to ny do
             zeralinha(a,b,a)

       else begin

          for c := a+1 to nx do
             if 0 <> _matrix[a][c] then begin
                for b := a+1 to ny do
                   zeralinha(a,b,c);
                break;
             end;

       end;
     end; //for

  end;  // procedure farkas

begin


  // Create a PN joining all sub-PNs.
  if (flag_unfold) then begin

     Unfold_Sub_PN;

     // current net = complete PN
     _ := length (PN) - 1;

   end;

   // incidence matrix. lines = places
   ComputeMatrix;

   // to compute T-Invariants use the same process,
   //  just tranpose the incidence matrix.
   if Flag_T then  TransposeMatrix;

   // as the name says...
   ConcatenateIdentityMatrix;

   // adjust reference variables
   //  they are used by sub-procedures
   if Flag_T then begin
      ny := _TransCount - 1;
      nx := _TransCount+_PlaceCount - 1;
   end else begin
      ny := _PlaceCount - 1;
      nx := _TransCount+_PlaceCount - 1;
   end;

   //-----------------

   // Farkas Algorithm

   SortMatrix;

   farkas;

   for i:= 0 to ny do begin

      l := FindRowWithCol1;

      if (l < 0) then Continue;

      if (l <> i) then
         SwapLines (i,l);

      for j:= i+1 to ny do
         SubtractLines(i,j);

   end;

   DebugConsole;

   // Get Rid of Identity Matrix
   // The form will collect results and display them.
   ShrinkMatrix;

   // xxx debug (remove exit after debug)
   //exit;

   // if total PN was computed, then now get rid of it.
   if (flag_unfold) then begin

      SetLength (PN, length(PN) - 1);

      // select main PN
      _ := 0;

   end;

end;


