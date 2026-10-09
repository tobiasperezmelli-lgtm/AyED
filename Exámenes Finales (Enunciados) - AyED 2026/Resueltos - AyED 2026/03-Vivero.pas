program ej_arch_03;
//examen final del 02/12/2015 - Vivero
uses crt;
TYPE
   mayorista = RECORD
                   codPlanta: integer;
                   detalle: string[30];
                   precio: real;
                   estacion: char;   // P-V-O-I
                   stock: integer;
                   pendientes: integer;
               END;
   minorista = RECORD
                 codMinorista: integer;
                 nombre: string[40];
               END;
   pendiente = RECORD
                 codPlanta: integer;
                 codMinorista: integer;
                 cantidad: integer;
               END;
VAR
   aMayoristas: file of mayorista;   //ordenado por codPlanta
   aMinoristas: file of minorista;   //desordenado
   aPendientes: file of pendiente;
   rMayorista: mayorista;
   rMinorista: minorista;
   rPendiente: pendiente;
   opc:char;


procedure CARGAARCHIVOS(); //procedimiento para cargar algunos registros ficticios
VAR A: mayorista;          //en viveromayorista.dat y viverominorista.dat
    B: minorista;
begin
     reset(aMayoristas);
     if eof(aMayoristas) then
     begin
          A.codPlanta := 1;  A.detalle := 'potus';  A.precio := 10.50;
          A.estacion := 'P';  A.stock := 5;   A.pendientes := 0;
          write(aMayoristas,A);
          A.codPlanta := 2;  A.detalle := 'orquidea';  A.precio := 100.10;
          A.estacion := 'V';  A.stock := 10;   A.pendientes := 0;
          write(aMayoristas,A);
          A.codPlanta := 3;  A.detalle := 'rosa';  A.precio := 50.25;
          A.estacion := 'O';  A.stock := 1;   A.pendientes := 0;
          write(aMayoristas,A);
          A.codPlanta := 4;  A.detalle := 'margarita';  A.precio := 8.50;
          A.estacion := 'I';  A.stock := 5;   A.pendientes := 0;
          write(aMayoristas,A);
     end;
     reset(aMinoristas);
     if eof(aMinoristas) then
     begin
          B.codMinorista := 7; B.nombre := 'TuVivero';
          write(aMinoristas,B);
          B.codMinorista := 3; B.nombre := 'MiVivero';
          write(aMinoristas,B);
          B.codMinorista := 5; B.nombre := 'NuestroVivero';
          write(aMinoristas,B);
     end;
end;



procedure menu;
begin
     writeln('Menu');
     writeln('----');
     writeln();
     writeln('a- Venta a minoristas');
     writeln('b- Inversion a futuro');
     writeln('c- Compromiso con cada minorista');
     writeln('d- Salir');
     writeln();
     write('Ingrese la opcion: ');
end;


function DICO(cod: integer):boolean; //Busqueda dicotomica
VAR min, max, medio:integer;
begin
  reset(aMayoristas);
  min:=0;
  max:=filesize(aMayoristas)-1;
  repeat
       medio:=(min+max) div 2;
       seek(aMayoristas,medio);
       read(aMayoristas,rMayorista);
       if cod < rMayorista.codPlanta then max:=medio-1
       else min:=medio+1;
  until (rMayorista.codPlanta=cod) or (min>max);
  if cod=rMayorista.codPlanta then DICO:=true
  else DICO:=false;
end;


procedure VENTA();
CONST
    cant=20;
TYPE
    renglon = RECORD
                  codigo: integer;
                  detalle: string[30];
                  cant: integer;
                  precio: real;
              END;
    venta = array[1 .. cant] of renglon;
VAR codViv: integer;
    fin: boolean;
    est: char;
    codPla: integer;
    cantPla: integer;
    total: real;
    i,j, dif: integer;
    factura: venta;
begin
    fin:=false;
    i:=0;
    repeat
          reset(aMinoristas);
          clrscr();
          write('Ingrese el codigo del vivero <0 para volver>: ');
          readln(codViv);
          if codViv=0 then fin:=true
          else
          begin
               repeat
                     read(aMinoristas,rMinorista);
               until (rMinorista.codMinorista=codViv) or eof(aMinoristas);
               if rMinorista.codMinorista=codViv then fin:=true
               else
               begin
                   writeln('Vivero no encontrado');
                   readkey;
               end;
          end;
    until fin;
    if codViv<>0 then
    begin
    repeat
          write('Ingrese la estacion <P V O I>: ');
          readln(est);
    until (est='P') or (est='V') or (est='O') or (est='I');
    repeat
          clrscr();
          writeln('Carga de Factura');
          writeln('----------------');
          writeln(); writeln();
          write('Codigo de planta <0 para terminar>: ');
          readln(codPla);
          if codPla<>0 then
          begin
             if DICO(codPla) then
             begin
                  if rMayorista.stock>0 then
                  begin
                  i:=i+1;
                  factura[i].codigo := codPla;
                  factura[i].detalle := rMayorista.detalle;
                  factura[i].precio := rMayorista.precio * 1.2;
                  write('Cantidad: ');
                  readln(cantPla);
                  if cantPla <= rMayorista.stock then
                     begin
                     factura[i].cant := cantPla;
                     rMayorista.stock := rMayorista.stock - cantPla;
                     end
                  else
                  begin
                     factura[i].cant := rMayorista.stock;
                     dif := cantPla - rMayorista.stock;
                     rMayorista.stock := 0;
                     if est <> rMayorista.estacion then
                        begin
                             writeln('No es planta de estacion');
                             readkey;
                        end
                     else
                     begin
                        rMayorista.pendientes := rMayorista.pendientes + dif;
                        rPendiente.codPlanta := codPla;
                        rPendiente.codMinorista := codViv;
                        rPendiente.cantidad := dif;
                        seek(aPendientes,filesize(aPendientes));
                        write(aPendientes,rPendiente);
                     end;
                  end;
                  seek(aMayoristas,filepos(aMayoristas)-1);
                  write(aMayoristas,rMayorista);
                  end
                  else
                  begin
                       writeln('Planta sin Stock');
                       readkey;
                  end
             end
             else
                 begin
                      writeln('Planta no encontrada');
                      readkey;
                 end
          end;
    until codPla=0;
    clrscr();
    writeln('                   Factura de Venta');
    writeln();writeln();
    writeln('Cod.   Detalle Planta    Cantidad    Precio Unit    Subtotal');
    writeln('-------------------------------------------------------------');
    total:=0;
    for j:=1 to i do
    begin
             writeln(factura[j].codigo:2,'     ',factura[j].detalle,' ':20-length(factura[j].detalle),factura[j].cant:2,'          ',factura[j].precio:5:2,'         ',factura[j].cant*factura[j].precio:6:2);
             total := total + (factura[j].cant*factura[j].precio);
    end;
    writeln('------------------------------------------------------------');
    writeln('Total                                                ',total:6:2);
    readkey;
    end;

end;


procedure INVERSION();
VAR i:integer;
    inversi:real;
begin
     clrscr();
     inversi := 0;
     reset(aMayoristas);
     for i:= 0 to filesize(aMayoristas)-1 do
     begin
          read(aMayoristas,rMayorista);
          inversi := inversi + (rMayorista.pendientes * rMayorista.precio)
     end;
     writeln('LA INVERSION A FUTURO EN PESOS ES: ',inversi:6:2);
     readkey;
end;


procedure COMPROMISO();
VAR i,j:integer;
    vacio:boolean;
begin
     reset(aMinoristas);
     for i:= 0 to filesize(aMinoristas)-1 do
     begin
         read(aMinoristas,rMinorista);
         vacio:=true;
         clrscr();
         writeln();
         writeln('             Vivero Minorista: ',rMinorista.codMinorista,' - ',rMinorista.nombre);
         writeln();
         reset(aPendientes);
         writeln('Codigo de Planta   Detalle de la planta   Cantidad');
         writeln('--------------------------------------------------');
         for j:=0 to filesize(aPendientes)-1 do
         begin
          read(aPendientes,rPendiente);
          if rPendiente.codMinorista = rMinorista.codMinorista then
          begin
               DICO(rPendiente.codPlanta);
               writeln(rPendiente.codPlanta:2,'                      ',rMayorista.detalle,' ':20-length(rMayorista.detalle),rPendiente.cantidad:2);
               vacio:=false;
          end;
         end;
         if vacio then writeln('No hay pendientes ...');
         readkey;
     end;
end;


begin
assign(aMayoristas,'c:\pascal\viveromayorista.dat');
assign(aMinoristas,'c:\pascal\viverominorista.dat');
assign(aPendientes,'c:\pascal\pendientes.dat');
CARGAARCHIVOS();  // carga inicial de archivos
repeat
      clrscr;
      MENU;
      repeat
         readln(opc);
      until (opc>='a') and (opc<='d');
      case opc of
         'a': VENTA;
         'b': INVERSION;
         'c': COMPROMISO;
      end;
until opc='d';
close(aMayoristas);
close(aMinoristas);
close(aPendientes);
end.

