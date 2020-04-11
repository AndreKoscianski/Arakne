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









procedure TForm1.RenderPetriNet(Sender: TObject);
var i, ax, ay, aux: integer;
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

             // a linha ainda não tem elemento final,
             //  arco está sendo traçado!
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

             // centro da linha e posição id2
             atp[1].x := GElements[GElements[i].id1].x;
             atp[1].y := GElements[GElements[i].id1].y;

             atp[2].x := GElements[GElements[i].id2].x;
             atp[2].y := GElements[GElements[i].id2].y;

             // If arc width greater than 1, write that.
             if (uidth > 1) then begin
                aux := MyCanvas.Canvas.Font.Size;
                MyCanvas.Canvas.Font.Size := aux - 2;
                MyCanvas.Canvas.TextOut(GElements[i].x + 5,
                                        GElements[i].y,
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
                   GElements[GElements[i].id1].x + trunc(dx),
                   GElements[GElements[i].id1].y + trunc(dy),
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

             // another arrow (it's a double arc)
             if (GElements[i].atipo = KArcDouble) then begin

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

          end  // Arc

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
             end;

             MyCanvas.Canvas.TextOut(x + Gsize + 5, y, s);

          end // Place

          else if tipo = KTransition then begin

             MyCanvas.Canvas.Rectangle (x-Gsize, y-Gmidsize, x+Gsize, y+Gmidsize);

             MyCanvas.Canvas.TextOut(x + Gsize + 5, y, s);
          end // Transition
       end;
  end;


end; 
