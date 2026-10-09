program ej_arch_01(input, output);
//parcial de arreglos 2016 resuelto con registros y archivos
uses crt;
TYPE
   deportista = RECORD
                      nombre: string[50];
                      pais: string[50];
                      oro: integer;
                      plata: integer;
                      bronce: integer;
                END;
VAR
   medallero: file of deportista;
   opc: integer;


procedure menu;
begin
     writeln('Menu');
     writeln('----');
     writeln();
     writeln('1-Alta de Deportistas');
     writeln('2-Listado de Medallas');
     writeln('3-Listado de Deportistas');
     writeln('4-Salir');
     writeln();
     write('Ingrese la opcion: ');
end;


procedure carga();
VAR rdep: deportista;
begin
     clrscr;
     seek(medallero,filesize(medallero));
     write('Ingrese los datos de los deportistas <* en nombre para terminar>');
     writeln();writeln();
     write('Nombre: ');
     readln(rdep.nombre);
     while rdep.nombre <> '*' do
     begin
          write('Pais: ');
          readln(rdep.pais);
          write('Cant. de oro: ');
          readln(rdep.oro);
          write('Cant. de plata: ');
          readln(rdep.plata);
          write('Cant. de bronce: ');
          readln(rdep.bronce);
          write(medallero,rdep);
          writeln();writeln();
          write('Nombre: ');
          readln(rdep.nombre);
     end;
end;


procedure listaMedallas();
VAR i, oro, plata, bronce: integer;
    pais: string[50];
    rdep: deportista;
begin
     clrscr;
     reset(medallero);
     if eof(medallero) then
        writeln('No hay deportistas inscriptos!!')
     else
         begin
         write('Ingrese el pais: ');
         readln(pais);
         oro:=0; plata:=0; bronce:=0;
         for i:=1 to filesize(medallero) do
         begin
           read(medallero,rdep);
           if rdep.pais = pais then
           begin
                oro := oro + rdep.oro;
                plata := plata + rdep.plata;
                bronce := bronce + rdep.bronce;
           end;
         end;
         writeln();
         writeln('                   ORO  PLATA  BRONCE  TOTAL');
         writeln(pais,' ':20-length(pais),oro:2,'    ',plata:2,'     ',bronce:2,'     ',oro+plata+bronce:2);
      end;
      readkey();
end;


procedure listaDeportistas();
VAR i,j: integer;
    rdepi, rdepj: deportista;
begin
  clrscr;
  reset(medallero);
  if eof(medallero) then
     writeln('No hay deportistas inscriptos!!')
  else
      begin
     //ordeno el archivo
     for i:=0 to filesize(medallero)-2 do
     begin
         for j:=i+1 to filesize(medallero)-1 do
         begin
              seek(medallero,i);
              read(medallero,rdepi);
              seek(medallero,j);
              read(medallero,rdepj);
              if rdepi.nombre > rdepj.nombre then
              begin
                   seek(medallero,i);
                   write(medallero,rdepj);
                   seek(medallero,j);
                   write(medallero,rdepi);
              end;
         end;
      end;
     //muestro el listado
     reset(medallero);
     writeln('Deportistas de los JJOO RIO 2016 <ordenado por Nombre>');
     writeln();
     writeln('Nombre                 Pais            Oro  Plata  Bronce');
     writeln('---------------------------------------------------------');
     for i:=1 to filesize(medallero) do
     begin
         read(medallero,rdepi);
         writeln(rdepi.nombre,' ':20-length(rdepi.nombre),rdepi.pais,' ':20-length(rdepi.pais),rdepi.oro:2,'     ',rdepi.plata:2,'      ',rdepi.bronce:2);
     end;
   end;
   readkey;
end;


begin
assign(medallero,'c:\pascal\medallero.dat');
reset(medallero);
repeat
      clrscr;
      menu;
      repeat
         readln(opc);
      until (opc>=1) and (opc<=4);
      case opc of
         1: carga();
         2: listaMedallas();
         3: listaDeportistas();
         4: close(medallero)
      end;
until opc=4;
end.

