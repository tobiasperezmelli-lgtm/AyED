program ej_arch_02;
//examen final del 13/03/2013 - Votacion Electronica
uses crt;
TYPE
   persona = RECORD
                   dni: real;
                   nombre: string[50];
                   apellido: string[50];
                   lugar: integer; //entre 1 y 9999
                   mesa: integer;  //entre 1 y 99
                   voto: char;
              END;
   voto = RECORD
                 lugar: integer;
                 mesa: integer;
                 partido1: integer;
                 partido2: integer;
                 partido3: integer;
           END;
VAR
   aPersonas: file of persona;
   aVotos: file of voto;
   rPersona: persona;
   dni: real;
   lugar: integer;


procedure CARGAPERSONAS(); //procedimiento para cargar algunos registros
VAR i,j,k: integer;        //ficticios en personas.dat y votos.dat
    P: persona;
    V: voto;
begin
     rewrite(aVotos);
     rewrite(aPersonas);
     for i:=1 to 2 do
     begin
         for j:= 1 to 3 do
         begin
                 V.lugar := 1000 + i;   //lugares: 1001 y 1002
                 V.mesa := (10*i) + j;  //mesas: 11,12,13 - 21,22,23
                 V.partido1 := 0;
                 V.partido2 := 0;
                 V.partido3 := 0;
                 write(aVotos,V);
             for k:= 1 to 5 do
             begin
                 P.dni := (100*i) + (10*j) + k;   //dni:111 a 115, 121 a 125, 131 a 131
                                                  //    211 a 215, 221 a 225, 231 a 235
                 P.nombre := 'Juan ' + chr(63+j+k);
                 P.apellido := 'Perez ' + chr(63+j+k);
                 P.lugar := V.lugar;
                 P.mesa := V.mesa;
                 P.voto := 'N';
                 write(aPersonas,P);
             end;
         end;
     end;
end;


function BUSCAPERSONA(D:real; VAR P:persona):boolean; //Busqueda dicotomica
VAR min, max, medio:integer;
begin
  reset(aPersonas);
  min:=0;
  max:=filesize(aPersonas)-1;
  medio:=(min+max) div 2;
  seek(aPersonas,medio);
  read(aPersonas,P);
  while (P.dni<>D) and (min<=max) do
  begin
       if D < P.dni then max:=medio-1
       else min:=medio+1;
       medio:=(min+max) div 2;
       seek(aPersonas,medio);
       read(aPersonas,P)
  end;
  if D=rPersona.dni then BUSCAPERSONA := true
  else BUSCAPERSONA := false;
end;


procedure CAMBIOESTADO (D:real);
VAR P:persona;
begin
  if BUSCAPERSONA(D,P) then
  begin
     P.voto:='S';
     seek(aPersonas,filepos(aPersonas)-1);
     write(aPersonas,P);
  end;
end;


procedure VOTACION(P:persona);
VAR opc: integer;
    V:voto ;
    continua: boolean;
begin
     reset(aVotos);
     write('Ingrese Opcion <entre 1 y 3>: ');
     repeat
      readln(opc);
     until (opc>=1) and (opc<=3);
     continua := true;
     while not eof(aVotos) and (continua) do
     begin
         read(aVotos,V);
         if (V.lugar = P.lugar) and (V.mesa = P.mesa) then
         begin
             case opc of
                1: V.partido1 := V.partido1 + 1;
                2: V.partido2 := V.partido2 + 1;
                3: V.partido3 := V.partido3 + 1;
             end;
             seek(aVotos,filepos(aVotos)-1);
             write(aVotos,V);
             continua := false;
         end;
     end;
     writeln('Votacion registrada ... ');
     CAMBIOESTADO(P.dni);
end;


procedure RECUENTOVOTOS(L: integer);
VAR i, tPartido1, tPartido2, tPartido3: integer;
    V: voto;
begin
  clrscr;
  tPartido1 := 0;
  tPartido2 := 0;
  tPartido3 := 0;
  reset(aVotos);
  writeln('Listado por lugar de votacion');
  writeln('-----------------------------');
  writeln();writeln();
  writeln('Lugar de votacion: ', L);
  writeln('Nro. de mesa    Partido 1    Partido 1    Partido 3');
  for i:=1 to filesize(aVotos) do
     begin
         read(aVotos,V);
         if V.lugar = L then
         begin
            writeln(V.mesa:2,'                ',V.partido1:2,'            ',V.partido2:2,'           ',V.partido3:2);
            tPartido1 := tPartido1 + V.partido1;
            tPartido2 := tPartido2 + V.partido2;
            tPartido3 := tPartido3 + V.partido3;
         end;
     end;
  writeln('---------------------------------------------------');
  writeln('Total              ',tPartido1,'             ',tPartido2,'            ',tPartido3);
  readkey;
end;


begin
assign(aPersonas,'c:\pascal\personas.dat');
assign(aVotos,'c:\pascal\votos.dat');
CARGAPERSONAS();  // carga inicial de archivos
reset(aPersonas);
reset(aVotos);
repeat
      clrscr;
      writeln('Registro de Votos');
      writeln('-----------------');
      writeln();writeln();
      write('Ingrese el DNI <0 para terminar>: ');
      readln(dni);
      if dni<>0 then
      begin
           if BUSCAPERSONA(dni, rPersona) then
           begin
                if rPersona.voto = 'N' then VOTACION(rPersona)
                else writeln('La persona con DNI ',trunc(dni),' YA VOTO en el lugar ',rPersona.lugar,' y en la mesa ',rPersona.mesa);
           end
           else writeln('El DNI ',trunc(dni),' NO se encuentra en el padron');
           readkey();
      end;
until dni=0;
repeat
      clrscr;
      write('Ingrese el lugar de votacion <1 y 9999> <0 para terminar>: ');
      repeat
            read(lugar);
      until (lugar>=0) and (lugar<=9999);
      if lugar<>0 then RECUENTOVOTOS(lugar);
until lugar=0;
close(aPersonas);
close(aVotos);
end.

