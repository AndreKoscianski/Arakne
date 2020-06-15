procedure TForm1.InterpolateBezier (id1, id2 : integer;
           var atp: TArray4);//array[1..4] of TPoint);
var  x1, y1
    ,x4, y4
    ,xc, yc: integer;
begin

  atp[1].x := PN[_].El[id1].x;
  atp[1].y := PN[_].El[id1].y;
  atp[4].x := PN[_].El[id2].x;
  atp[4].y := PN[_].El[id2].y;

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









procedure TForm1.RenderPetriNet(Sender: TObject);
var i, ax, ay, aux: integer;
    d, dx, dy: real;
    atp : array[1..4] of TPoint;
    cor : TColor;
    k , ntokens : integer;
begin

  MyCanvas.Canvas.Brush.Color := clWhite;
  MyCanvas.Canvas.Pen  .Color := clBlack;

  k := High(GSelectedElements);

  // let's draw a petri net
  for i:=0 to PN[_].Gi do begin


      if PN[_].El[i].tipo = KNothing then Continue;

      // Se elemento selecionado, cor = amarelo
      //if (Gss = i) then
      //   MyCanvas.Canvas.Brush.Color := clYellow
      //else
      if (Gs = i) or PN[_].El[i].selected then
         MyCanvas.Canvas.Brush.Color := clOlive
      else
         MyCanvas.Canvas.Brush.Color := clWhite;


      //-------------------------------------
      // FOR EACH element
      with PN[_].El[i] do begin

          // vamos plotar linha
          if tipo = KArc then begin

             // a linha ainda não tem elemento final,
             //  arco está sendo traçado!
             // então plote reta até posição atual do mouse.
             if PN[_].El[i].id2 = -1 then begin
                MyCanvas.Canvas.Line (
                   PN[_].El[PN[_].El[i].id1].x,
                   PN[_].El[PN[_].El[i].id1].y,
                   GNewX, GNewY);
                Continue;
             end ;

             // Se chegou aqui, reta tem ponto final.

             if (Gs = i) then begin
                MyCanvas.Canvas.Pen.Color := clOlive;
                MyCanvas.Canvas.Pen.Width := 4;
             end;

             // marque na linha coordenadas do centro dela
             PN[_].El[i].x :=
               (PN[_].El[PN[_].El[i].id1].x +
                PN[_].El[PN[_].El[i].id2].x) div 2;
             PN[_].El[i].y :=
               (PN[_].El[PN[_].El[i].id1].y +
                PN[_].El[PN[_].El[i].id2].y) div 2;

             // centro da linha e posição id2
             atp[1].x := PN[_].El[PN[_].El[i].id1].x;
             atp[1].y := PN[_].El[PN[_].El[i].id1].y;

             atp[2].x := PN[_].El[PN[_].El[i].id2].x;
             atp[2].y := PN[_].El[PN[_].El[i].id2].y;

             // If arc width greater than 1, write that.
             if (uidth > 1) then begin
                aux := MyCanvas.Canvas.Font.Size;
                MyCanvas.Canvas.Font.Size := aux - 2;
                MyCanvas.Canvas.TextOut(PN[_].El[i].x + 5,
                                        PN[_].El[i].y,
                                         IntToStr(uidth));
                MyCanvas.Canvas.Font.Size := aux;
             end;


             // Calculate a line segment, along of arc,
             //    with length = Gsize.
             dx := (atp[2].x - atp[1].x);
             dy := (atp[2].y - atp[1].y);

             d := sqrt (dx*dx + dy* dy);

             dx := Gsize * (dx / d);
             dy := Gsize * (dy / d);


             // Extreme points of arc
             atp[1].x := atp[1].x + trunc(dx); atp[1].y := atp[1].y + trunc(dy);
             atp[3].x := atp[2].x - trunc(dx); atp[3].y := atp[2].y - trunc(dy);


            // Draw arc
            MyCanvas.Canvas.Line (
                   PN[_].El[PN[_].El[i].id1].x + trunc(dx),
                   PN[_].El[PN[_].El[i].id1].y + trunc(dy),
                   atp[3].x,
                   atp[3].y
                   );


            // Reuse variable, size of arrow
            dx := dx / 2;
            dy := dy / 2;


            MyCanvas.Canvas.Pen.Color := clBlack;
            MyCanvas.Canvas.Pen.Width := 1;

            // Draw Arrows
             if (PN[_].El[i].atipo <> KArcInhibit) then begin

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

               // another arrow (it's a double arc)
               if (PN[_].El[i].atipo = KArcDouble) then begin

                  // arrow line1
                  atp[4].x := atp[1].x + trunc(dx * 0.866 + dy * -0.500);
                  atp[4].y := atp[1].y + trunc(dx * 0.500 + dy *  0.866);

                   MyCanvas.Canvas.Line (
                      atp[1].x, atp[1].y,
                      atp[4].x, atp[4].y
                      );

                   // arrow line2
                   atp[4].x := atp[1].x + trunc(dx *  0.866 + dy * 0.500);
                   atp[4].y := atp[1].y + trunc(dx * -0.500 + dy * 0.866);

                   MyCanvas.Canvas.Line (
                      atp[1].x, atp[1].y,
                      atp[4].x, atp[4].y
                      );

               end;   // if double arc

             // this is an inhibitor arc
             end else
                 MyCanvas.Canvas.Ellipse (atp[3].x - GsizeToken, atp[3].y - GsizeToken,
                                          atp[3].x + GsizeToken, atp[3].y + GsizeToken);

            (* if (atp[1].x < atp[2].x) then atp[2].x := atp[2].x - Gsize;
             if (atp[2].x < atp[1].x) then atp[2].x := atp[2].x + Gsize;
             if (atp[1].y < atp[2].y) then atp[2].y := atp[2].y - Gsize;
             if (atp[1].y < atp[2].y) then atp[2].x := atp[2].y + Gsize;

             DrawArrow(MyCanvas.Canvas,atp[1],atp[2],atArrows); //atSolid
            *)

            // Calcule Bezier e plote.
(*            InterpolateBezier (PN[_].El[i].id1,
                               PN[_].El[i].id2,
                               atp);

            MyCanvas.Canvas.PolyBezier(atp);
 *)


             Continue;

          end  // Arc

          else if (tipo = KPlace) then begin

             cor := MyCanvas.Canvas.Brush.Color;

             // if place composed and not selected,
             //   use special color
             if (PN[_].El[i].ptipo = KPlaceC) and (not PN[_].El[i].selected) then
                MyCanvas.Canvas.Brush.Color := clAqua;

             MyCanvas.Canvas.Ellipse (x-Gsize, y-Gsize, x+Gsize, y+Gsize);

             // back to normal color
             MyCanvas.Canvas.Brush.Color := cor;

             // now draw tokens
             if (PN[_].El[i].ptipo = KPlace) then
                ntokens := count
             else
                ntokens := PN[_].El[PN[_].El[i].idx_real_p].count;

             if (ntokens > 0) then begin

                cor := MyCanvas.Canvas.Brush.Color;

                MyCanvas.Canvas.Brush.Color := clBlack;

                if (ntokens = 1) or (ntokens = 3) then
                 MyCanvas.Canvas.Ellipse (x-GsizeToken, y-GsizeToken, x+GsizeToken, y+GsizeToken);

                if (ntokens = 2) or (ntokens = 3) then begin
                  ax := x - 2*GsizeToken;
                  ay := y + 2*GsizeToken;
                  MyCanvas.Canvas.Ellipse (ax-GsizeToken, ay-GsizeToken, ax+GsizeToken, ay+GsizeToken);

                  ax := x + 2*GsizeToken;
                  ay := y - 2*GsizeToken;
                  MyCanvas.Canvas.Ellipse (ax-GsizeToken, ay-GsizeToken, ax+GsizeToken, ay+GsizeToken);
                end;

                if (ntokens > 3) then   begin
                   MyCanvas.Canvas.Brush.Color := cor;
                   MyCanvas.Canvas.TextOut(x - GsizeToken, y- GsizeToken, IntToStr(count));
                end ;

                MyCanvas.Canvas.Brush.Color := cor;
             end;

             MyCanvas.Canvas.TextOut(x + Gsize + 5, y, s);

          end // Place

          // Draw Transitions;
          else if (tipo = KTransition) then begin

             // remember original color.
             cor := MyCanvas.Canvas.Brush.Color;

             // if this is a TransitionC and it is not selected,
             //   paint it blue.
             if (ttipo = KTransitionC) and (not PN[_].El[i].selected) then
                MyCanvas.Canvas.Brush.Color := clBlue;

//             if (cor = clWhite) then
//                   MyCanvas.Canvas.Brush.Color := clBlack;

             MyCanvas.Canvas.Rectangle (x-Gsize, y-Gsizetoken, x+Gsize, y+Gsizetoken);

             // reset color
             MyCanvas.Canvas.Brush.Color := cor;

             MyCanvas.Canvas.TextOut(x + Gsize + 5, y, s);

          end // Transition
       end; // With
  end; // for

  // User is selecting area.
  // Draw a rectangle.

  if ((GPrevX > -1) and (GNewX > -1)) then begin

     MyCanvas.Canvas.Pen.Color := clOlive;
     MyCanvas.Canvas.Brush.Style := bsClear;

     MyCanvas.Canvas.Rectangle (GPrevX, GPrevY, GNewX, GNewY);

     MyCanvas.Canvas.Brush.Style := bsSolid;


  end;

end; 
