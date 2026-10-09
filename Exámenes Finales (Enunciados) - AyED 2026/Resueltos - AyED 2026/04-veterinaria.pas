program ej_arch_04;
//examen final del 07/08/2013 - Veterinaria
uses crt;
TYPE
   mascota = RECORD
                   codigo: integer;
                   nombre: string[20];
                   duenio: string[35];
                   mail: string[40];
               END;
   historia = RECORD
                 codigo: integer;
                 diaVisita: string[8]; {DDMMAAAA}
                 atencion: char;  //(P: peluquería / V: veterianaria)
                 corte: char;    // (S/N)
                 banio: char;    // (S/N)
                 vacuna: string[25];
                 medicamento: string[40];
                 proximoControl: string[6]; {MMAAAA}
               END;
VAR
   aMascotas: file of mascota;
   aHistoria: file of historia;
   rMascota: mascota;
   rHistoria: historia;
   opc:integer;


procedure menu;
begin
     writeln('Menu');
     writeln('----');
     writeln();
     writeln('1- Carga Inicial');
     writeln('2- Peluqueria');
     writeln('3- Veterinaria');
     writeln('4- Avisos de Proximos Controles');
     writeln('5- Salir');
     writeln();
     write('Ingrese la opcion: ');
end;


procedure CARGA;
VAR sigue: char;
begin
     reset(aMascotas);
     if eof(aMascotas) then rMascota.codigo:=0
     else  begin
                 seek(aMascotas, filesize(aMascotas)-1);
                 read(aMascotas,rMascota);
           end;
     repeat
           clrscr();
           writeln('CARGA DE MASCOTAS');
           writeln('-----------------');
           writeln();
           rMascota.codigo := rMascota.codigo + 1;
           writeln('Codigo: ', rMascota.codigo);
           write('Nombre: ');
           readln(rMascota.nombre);
           write('Duenio: ');
           readln(rMascota.duenio);
           write('Mail: ');
           readln(rMascota.mail);
           write(aMascotas,rMascota);
           writeln();
           write('Continua (S/N): ');
           repeat
                 readln(sigue);
           until (sigue='N') or (sigue='n') or (sigue='S') or (sigue='s');
     until (sigue='N') or (sigue='n');
end;


function DICO(C: integer):boolean; //Busqueda dicotomica
VAR min, max, medio:integer;
begin
  reset(aMascotas);
  min:=0;
  max:=filesize(aMascotas)-1;
  repeat
       medio:=(min+max) div 2;
       seek(aMascotas,medio);
       read(aMascotas,rMascota);
       if C < rMascota.codigo then max:=medio-1
       else min:=medio+1;
  until (rMascota.codigo=C) or (min>max);
  if C=rMascota.codigo then DICO:=true
  else DICO:=false;
end;


procedure PELUQUERIA();
VAR cod: integer;
begin
    clrscr();
    write('Ingrese el codigo del cachorro: ');
    readln(cod);
    if DICO(cod) then
    begin
         writeln('Nombre: ', rMascota.nombre);
         rHistoria.codigo := cod;
         rHistoria.atencion := 'P';
         write('Fecha (ddmmaaa): ');
         readln(rHistoria.diaVisita);
         write('Corte (s/n): ');
         repeat
           readln(rHistoria.corte)
         until (rHistoria.corte = 's') or (rHistoria.corte = 'n');
         write('Banio (s/n): ');
         repeat
           readln(rHistoria.banio)
         until (rHistoria.banio = 's') or (rHistoria.banio = 'n');
         reset(aHistoria);
         seek(aHistoria,filesize(aHistoria));
         write(aHistoria,rHistoria);
         writeln();
         writeln('Atencion registrada!!');
         readkey;
    end
    else begin
         writeln('Codigo no encontrado');
         readkey;
         end;
end;


procedure VETERINARIA();
VAR cod, i: integer;
begin
    clrscr();
    write('Ingrese el codigo del cachorro: ');
    readln(cod);
    if DICO(cod) then
    begin
         writeln('Nombre: ', rMascota.nombre);
         writeln();
         writeln('Fecha Visita     Vacunas            Medicamentos        Proximo Control');
         writeln('-----------------------------------------------------------------------');
         reset(aHistoria);
         for i:=0 to filesize(aHistoria)-1 do
         begin
          read(aHistoria,rHistoria);
          if (rHistoria.codigo = cod) and (rHistoria.atencion = 'V') then
             writeln(rHistoria.diaVisita,'         ',rHistoria.vacuna,' ':20-length(rHistoria.vacuna),rHistoria.medicamento,' ':20-length(rHistoria.medicamento),rHistoria.proximoControl);
         end;
         readkey;
         writeln();writeln();
         rHistoria.codigo := cod;
         rHistoria.atencion := 'V';
         write('Fecha (ddmmaaa): ');
         readln(rHistoria.diaVisita);
         write('Vacunas: ');
         readln(rHistoria.vacuna);
         write('Medicamentos: ');
         readln(rHistoria.medicamento);
         write('Proximo Control (MMAAAA): ');
         readln(rHistoria.proximoControl);
         seek(aHistoria,filesize(aHistoria));
         write(aHistoria,rHistoria);
         writeln();
         writeln('Atencion registrada!!');
         readkey;
    end
    else begin
         writeln('Codigo no encontrado');
         readkey;
         end;
end;


procedure AVISOS();
VAR i: integer;
    periodo: string[6];
begin
     clrscr();
     write('Ingrese mes y anio (MMAAAA): ');
     readln(periodo);
     writeln();
     writeln('Codigo    Nombre              Duenio              Mail');
     writeln('------------------------------------------------------------------');
     reset(aHistoria);
     for i:= 0 to filesize(aHistoria)-1 do
     begin
         read(aHistoria,rHistoria);
         if rHistoria.proximoControl = periodo then
         begin
            DICO(rHistoria.codigo);
            writeln(rMascota.codigo,'         ',rMascota.nombre,' ':20-length(rMascota.nombre),rMascota.duenio,' ':20-length(rMascota.duenio),rMascota.mail,' ':20-length(rMascota.mail));
         end;
     end;
     readkey;
end;


begin
assign(aMascotas,'c:\pascal\Mascotas.dat');
assign(aHistoria,'c:\pascal\Historia.dat');
repeat
      clrscr;
      MENU;
      repeat
         readln(opc);
      until (opc>=1) and (opc<=5);
      case opc of
         1: CARGA;
         2: PELUQUERIA;
         3: VETERINARIA;
         4: AVISOS;
      end;
until opc=5;
close(aMascotas);
close(aHistoria);
end.

