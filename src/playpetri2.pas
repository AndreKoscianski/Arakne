type

  TArcs = record
    id, uidth : integer;
    prox : ^TArcs;
  end;

  TTransitionInfo = record
    id: integer;
    enabled : boolean;

    input,
    output : ^TArcs
  end;

  TTheTransitions = array of TTransitionInfo;

var
  _trInfo : TTheTransitions;

  _trEnabled : array of integer;

  _TransitionCount : integer;



//----------------------------------------------------------------

procedure TForm1.PrepareToPlayPetriNet;

   // Erases input and output lists.
   procedure EraseLists;
   var
     i : integer;
     aux, aux2: ^TArcs;
   begin

      // First time this procedure is called,
      //   array is empty.
      for i := 0 to High(_trInfo)-1 do begin

         // free input list
         aux := _trInfo[i].input;
         while (aux <> nil) do begin
            aux2 := aux^.prox;
            dispose (aux);
            aux := aux2;
         end;

         // free output list
         aux := _trInfo[i].output;
         while (aux <> nil) do begin
            aux2 := aux^.prox;
            dispose (aux);
            aux := aux2;
         end;

      end; // for



   end;

var
  i,j,k,nt,idp,idt: integer;

  aux : ^TArcs;
begin

   EraseLists;

   // This is the only moment we need to know
   //  how many transitions are there.
   _TransitionCount := 0;
   for i := 0 to PN[_].Gi do
      if PN[_].El[i].tipo = KTransition then
         inc(_TransitionCount);


   SetLength (_trInfo,_TransitionCount);

   // reserve  position [0] of array to
   //   record number of enabled transitions
   SetLength (_trEnabled, _TransitionCount+1);

   // first pass, scan the net,
   //   record all transitions
   nt := 0;
   for i := 0 to PN[_].Gi do begin

      if  PN[_].El[i].tipo = KTransition then begin

        _trInfo[nt].id := i;

        // mark the list as empty
        _trInfo[nt].input  := nil;
        _trInfo[nt].output := nil;

        inc(nt);

      end;
   end; // for  - first pass


   // second pass, scan the petri net,
   //   link arcs.
   for i := 0 to PN[_].Gi do begin

     // find an arc
     if (PN[_].El[i].tipo = KArc) then begin

        // distinguish endpoints
       if (PN[_].El[PN[_].El[i].id1].tipo = KPlace) then begin
         idp := PN[_].El[i].id1;
         idt := PN[_].El[i].id2;
       end else begin
          idp := PN[_].El[i].id2;
          idt := PN[_].El[i].id1;
       end;

       // find record of the transition
       j := 0;
       while (_trInfo[j].id <> idt) do
          inc(j);

       //------------------------------------------------
       // deal with input conection
       if (PN[_].El[i].atipo = KArcDouble) or
          (idp = PN[_].El[i].id1) then begin

         new (aux);
         aux^.id := idp;
         aux^.uidth := PN[_].El[i].uidth;
         aux^.prox := _trInfo[j].input;
         _trInfo[j].input := aux;
       end;

     //------------------------------------------------
     // deal with output conection
     if (PN[_].El[i].atipo = KArcDouble) or
        (idt = PN[_].El[i].id1) then begin

          new (aux);
          aux^.id := idp;
          aux^.uidth := PN[_].El[i].uidth;
          aux^.prox := _trInfo[j].output;
          _trInfo[j].output := aux;
        end;

    end // find an arc

 end; // for - second pass

end;  // procedure PrepareToPlayPetriNet



//-------------------------------------------------------

procedure TForm1.ArmTransitions;
var i,j,k,n: integer;
    aux : ^TArcs;
begin

   // there are no enabled transitions.
   _trEnabled[0] := 0;


   // for each transition
   for i := 0 to _TransitionCount-1 do begin

      aux := _trInfo[i].input;

      _trInfo[i].enabled := true;

      // scan input arcs
      while ((aux <> nil) and (_trInfo[i].enabled)) do begin

         _trInfo[i].enabled :=
           (PN[_].El[aux^.id].count >= aux^.uidth);

         aux := aux^.prox;
      end; // while

      if _trInfo[i].enabled then begin
         k := _trEnabled[0];
         inc(k);
         _trEnabled[0] := k;
         _trEnabled[k] := i;
      end

   end; // for
end;





function TForm1.PlayPetriNet : integer;

var
   i, t: integer;
   aux : ^TArcs;
begin;

   // no enabled transition
   if (_trEnabled[0] < 1) then begin
      PlayPetriNet := -1;
      Exit;
   end;

   // number of enabled transitions
   t := _trEnabled[0];

   // draw a number between 1 and t
   t := 1 + random (t);


   // obtain number of transition;
   // 1st position of this array is count of elements.
   t := _trEnabled[t];

   // handle inputs
   aux := _trInfo[t].input;
   while (aux <> nil) do begin
      PN[_].El[aux^.id].count :=
         PN[_].El[aux^.id].count -
         aux^.uidth;

      aux := aux^.prox;
   end;

   // handle outputs
   aux := _trInfo[t].output;
   while (aux <> nil) do begin
      PN[_].El[aux^.id].count :=
         PN[_].El[aux^.id].count +
         aux^.uidth;

      aux := aux^.prox;
   end;

   PlayPetriNet := t;
end;

(*

varrer a rede

para cada transição, conhecer:
  arco de entrada e largura
  arco de saída e largura

anotar a marcação, (poderia ser um array)

play =
   verificar transição ok
   selecionar transição
   executar

*)
