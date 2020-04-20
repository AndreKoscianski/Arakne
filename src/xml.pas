procedure TForm1.ExtraiaDadosPlaceXML
   (no: TDOMNode; var sid, sname: string; var x, y, count: integer);
var
   aux,aux2 : TDOMNode;
   i,k : integer;
   lista: TDOMNodeList;
   saux : string;
begin

  sid := no.Attributes.Item[0].Nodevalue;

  lista := no.ChildNodes;

  for k := 0 to (lista.Count - 1) do with lista.Item[k] do begin
  if (NodeName = 'graphics') then begin

     aux := lista.Item[k].FindNode('position');

     if (nil <> aux) then begin
         for i:= 0 to 1 do
           if ('x' = aux.Attributes.Item[i].NodeName) then
            x := StrToInt (aux.Attributes.Item[i].NodeValue)
           else if ('y' = aux.Attributes.Item[i].NodeName) then
            y := StrToInt (aux.Attributes.Item[i].NodeValue);
      end
  end else if (NodeName = 'name') then begin

     aux := lista.Item[k].FindNode('text');

     if (nil = aux) then sname := sid
     else                sname := aux.TextContent;

  end else if (NodeName = 'initialMarking') then begin

     aux := lista.Item[k].FindNode('text');

     if (nil = aux) then continue;

     saux := aux.TextContent;

     if (saux <> '') then count := StrToInt (saux);
  end
  end; //for

end;

procedure TForm1.ExtraiaDadosTransitionXML
   (no: TDOMNode; var sid, sname: string; var x, y: integer);
var
   aux,aux2 : TDOMNode;
   i,k : integer;
   lista: TDOMNodeList;
   saux : string;
begin

  sid := no.Attributes.Item[0].Nodevalue;

  lista := no.ChildNodes;

  for k := 0 to (lista.Count - 1) do with lista.Item[k] do begin
  if (NodeName = 'graphics') then begin

     aux := lista.Item[k].FindNode('position');

     if (nil <> aux) then begin
         for i:= 0 to 1 do
           if ('x' = aux.Attributes.Item[i].NodeName) then
            x := StrToInt (aux.Attributes.Item[i].NodeValue)
           else if ('y' = aux.Attributes.Item[i].NodeName) then
            y := StrToInt (aux.Attributes.Item[i].NodeValue);
      end
  end else if (NodeName = 'name') then begin

     aux := lista.Item[k].FindNode('text');

     if (nil = aux) then sname := sid
     else                sname := aux.TextContent;

  end
end;

end;

procedure TForm1.ExtraiaDadosArcXML
   (no: TDOMNode; var sid, sname: string; var id1, id2, uidth: integer);
var
   aux,aux2 : TDOMNode;
   i,k,n : integer;
   lista: TDOMNodeList;
   saux : string;
begin

  n := no.Attributes.Length;

  id1 := 0;
  id2 := 0;


  // Attention!
  // The actual links will be solved only after
  //   all the XML file has been read.
  // That's because we need to know the names of all objects,
  //   before translating them into indices in GElements[]

  for i:=0 to n-1 do begin

     if ('id' = no.Attributes.Item[i].NodeName) then
        sid := no.Attributes.Item[i].NodeValue

     else if ('source' = no.Attributes.Item[i].NodeName) then begin

        saux := no.Attributes.Item[i].NodeValue;

        for k:=1 to Gi do begin
           if (Gstr[k] = saux) then begin
              id1 := k;
              Break
           end
        end

     end else if ('target' = no.Attributes.Item[i].NodeName) then begin

        saux := no.Attributes.Item[i].NodeValue;

        for k:=1 to Gi do begin
           if (Gstr[k] = saux) then begin
              id2 := k;
              Break
           end
        end

     end


  end; // for

  lista := no.ChildNodes;

  uidth := -1;

  for k := 0 to (lista.Count - 1) do with lista.Item[k] do begin
  if (NodeName = 'inscription') then begin

     aux := lista.Item[k].FindNode('text');

     if (nil = aux) then continue;

     saux := aux.TextContent;

     if (saux <> '') then uidth := StrToInt (saux);
  end
  end; //for

end;

procedure TForm1.CarregueXML (s: string);
var
  Doc: TXMLDocument;
  node, Child: TDOMNode;
  Members: TDOMNodeList;
  i, x, y, count, uidth: integer;
  sid, sname : string;
begin

    Gi := 0;

    try
      ReadXMLFile(Doc, s);
      // using FirstChild and NextSibling properties
      Child := Doc.DocumentElement.FirstChild;

      // ===Places===
      Members := Doc.GetElementsByTagName('place');

      Gplacecount := Members.Count;

      for i:= 0 to Members.Count - 1 do begin

         node := Members[i];

         ExtraiaDadosPlaceXML (Members[i], sid, sname, x, y, count);

         inc (Gi);
         Gstr[Gi] := sid;
         GElements[Gi].x := x;
         GElements[Gi].y := y;
         GElements[Gi].tipo := KPlace;
         GElements[Gi].s := sname;
         GElements[Gi].count := count;
      end;

      // ===Transitions===
      Members := Doc.GetElementsByTagName('transition');

      Gtransitioncount := Members.Count;

      for i:= 0 to Members.Count - 1 do begin

         node := Members[i];

         ExtraiaDadosTransitionXML (Members[i], sid, sname, x, y);

         inc (Gi);
         Gstr[Gi] := sid;
         GElements[Gi].x := x;
         GElements[Gi].y := y;
         GElements[Gi].tipo := KTransition;
         GElements[Gi].s := sname;
      end;

       // ===Arcs===
      Members := Doc.GetElementsByTagName('arc');

      for i:= 0 to Members.Count - 1 do begin

         node := Members[i];

         ExtraiaDadosArcXML (Members[i], sid, sname, x, y, uidth);

         // avoid invalid coordinates, with a radical solution...
         if ((x < 1) or (y < 1)) then Halt;

         inc (Gi);
         Gstr[Gi] := sid;
         GElements[Gi].id1 := x;
         GElements[Gi].id2 := y;
         GElements[Gi].tipo := KArc;

         if (uidth > 0) then
            GElements[Gi].uidth := uidth
         else
            GElements[Gi].uidth := 1;


         // marque na linha coordenadas do centro dela
         GElements[Gi].x :=
           (GElements[GElements[Gi].id1].x +
            GElements[GElements[Gi].id2].x) div 2;
         GElements[Gi].y :=
           (GElements[GElements[Gi].id1].y +
            GElements[GElements[Gi].id2].y) div 2;
      end;

    finally
      Doc.Free;
    end;
  end;
procedure TForm1.GereXML (s: string);
var
  Doc: TXMLDocument;                                  // variable to document
  RootNode,
  node,
  node2,
  node3,
  node4: TDOMNode;

  i: integer;

begin

  try
    // Create a document
    Doc := TXMLDocument.Create;

    Doc.TextContent:= 'abc';

   // Doc.SetAttribute ('xmlns', 'http://www.pnml.org/version-2009/grammar/pnml');

    // Create a root node
    RootNode := Doc.CreateElement('net');
    Doc.AppendChild (RootNode);
    TDOMElement(RootNode).SetAttribute ('id', 'myself');
    TDOMElement(RootNode).SetAttribute ('type', 'http://www.pnml.org/version-2009/grammar/ptnet');

     // Create a parent node
    RootNode:= Doc.DocumentElement;

    node := Doc.CreateElement('page');
    TDOMElement(node).SetAttribute('id', '0');
    RootNode.Appendchild(node);

    // tudo ficará dentro desta página.
    RootNode := node;

    for i:=1 to Gi do with GElements[i] do begin

    if tipo = KPlace then begin
    //==Place==
    node := Doc.CreateElement ('place');
    TDOMElement(node).SetAttribute ('id',IntToStr(i));
    RootNode.AppendChild(node);

    node2 := Doc.CreateElement ('name');
      node.AppendChild (node2);
      node3 := Doc.CreateElement ('text');
      node2.AppendChild (node3);
      node4 := Doc.CreateTextNode (s);
      node3.AppendChild (node4);
    node2 := Doc.CreateElement ('graphics');
      node.AppendChild (node2);
      node3 := Doc.CreateElement ('position');
      TDOMElement(node3).SetAttribute ('x', IntToStr(x));
      TDOMElement(node3).SetAttribute ('y', IntToStr(y));
      node2.AppendChild (node3);
    node2 := Doc.CreateElement ('initialMarking');
      node.AppendChild (node2);
      node3 := Doc.CreateElement ('text');
      node2.AppendChild (node3);
      node4 := Doc.CreateTextNode (IntToStr(count));
      node3.AppendChild (node4);
    end;

    if tipo = KTransition then begin
    //==Transition==
    node := Doc.CreateElement ('transition');
    TDOMElement(node).SetAttribute ('id',IntToStr(i));
    RootNode.AppendChild(node);

    node2 := Doc.CreateElement ('name');
      node.AppendChild (node2);
      node3 := Doc.CreateElement ('text');
      node2.AppendChild (node3);
      node4 := Doc.CreateTextNode (s);
      node3.AppendChild (node4);
    node2 := Doc.CreateElement ('graphics');
      node.AppendChild (node2);
      node3 := Doc.CreateElement ('position');
      TDOMElement(node3).SetAttribute ('x', IntToStr(x));
      TDOMElement(node3).SetAttribute ('y', IntToStr(y));
      node2.AppendChild (node3);
    end;

    if tipo = KArc then begin
     //==Arc==
    node := Doc.CreateElement ('arc');
    TDOMElement(node).SetAttribute ('id',IntToStr(i));
    TDOMElement(node).SetAttribute ('source',IntToStr(id1));
    TDOMElement(node).SetAttribute ('target',IntToStr(id2));
    TDOMElement(node).SetAttribute ('type'  ,'normal');
    RootNode.AppendChild(node);

    if (uidth > 1) then begin
      node2 := Doc.CreateElement ('inscription');
      node.AppendChild (node2);
      node3 := Doc.CreateElement ('text');
      node2.AppendChild (node3);
      node4 := Doc.CreateTextNode (IntToStr(uidth));
      node3.AppendChild (node4);
    end

    end

    end; // for LOOP


    writeXMLFile(Doc, s);

  finally
    Doc.Free;
  end;
end;

