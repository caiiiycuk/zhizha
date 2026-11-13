unit Textures;

interface

Uses OpenGL15;

Type Texture=Record
              ID:GLuint;
              Width,Height:GLuint;
              Data:Pointer;
             End;

     TTexCoord2F=Record
                  Coords:Array[0..3,0..1] of GLfloat;
                 End;

     TTiles=Array of TTexCoord2f;

     TGAImage = Record
                 A:GL_RGB..GL_RGBA;
                 Width,Height:Word;
                 Data:Pointer;
                End;
                
Const l_BMP=$0001;
      l_BMPA=$0002;
      l_JPG=$0003;
      l_JPGA=$0004;
      l_TGA=$0005;

Procedure BindNewTexture(var Textures:Texture; Wrap:GLuint; vFile:String; vType:Cardinal);
Procedure BindNewTextureMipMap(var Textures:Texture; MipMax,Wrap:GLuint; vFile:String; vType:Cardinal);
Function  GetTiles(Texture:Texture; TileSize:Word):TTiles;

Const DegreesOfTwo:Array[0..12] Of GLuint=(1,2,4,8,16,32,
                                           64,128,256,512,
                                           1024,2048,4096);

implementation

Uses Windows,Graphics,JPEG;

 Function  GetTiles(Texture:Texture; TileSize:Word):TTiles;
  Var Count,I,J,CoX,CoY:Word; X,Y,Xs,Ys:Real;
  Begin
   Xs:=TileSize/Texture.Width; Ys:=TileSize/Texture.Height;
   CoX:=(Texture.Width div TileSize);
   CoY:=(Texture.Height div TileSize);
   Count:=CoX*CoY;
   SetLength(Result,Count);
   For J:=0 To CoY-1 Do
    For I:=0 To CoX-1 Do
     With Result[J*CoX+I] Do
      Begin
       Coords[0,0]:=I*Xs; Coords[0,1]:=1-(J+1)*Ys;
       Coords[1,0]:=(I+1)*Xs; Coords[1,1]:=1-(J+1)*Ys;
       Coords[2,0]:=(I+1)*Xs; Coords[2,1]:=1-J*Ys;
       Coords[3,0]:=I*Xs; Coords[3,1]:=1-J*Ys;
      End
  End;

 Function  LoadBmpAFile(FFile:String):Texture; forward;
 Function  LoadJpgFile(FFile:String):Texture;  forward;
 Function  LoadBmpFile(FFile:String):Texture;  forward;
 Function  LoadTGA(vFile:String):TGAImage;     forward;

 Function LoadTGA(vFile:String):TGAImage;
  Var
   TGAHeader : packed record   // Информация(заголовок) TGA файла
     FileType     : Byte;
     ColorMapType : Byte;
     ImageType    : Byte;
     ColorMapSpec : Array[0..4] of Byte;
     OrigX  : Array [0..1] of Byte;
     OrigY  : Array [0..1] of Byte;
     Width  : Array [0..1] of Byte;
     Height : Array [0..1] of Byte;
     BPP    : Byte;
     ImageInfo : Byte;
   End;
   
   TGAFile   : File;
   bytesRead : Integer;
   ImageSize     : Integer;
   I : Integer;
   Front: ^Byte;
   Back: ^Byte;
   Temp: Byte;

  Begin
   GetMem(Result.Data, 0);

   AssignFile(TGAFile, vFile);
   Reset(TGAFile, 1);
   
   // Загрузка информации о файле
   BlockRead(TGAFile, TGAHeader, SizeOf(TGAHeader));

   // Отбраковка не подходящих TGA файлов
   IF (TGAHeader.ImageType <> 2)or(TGAHeader.ColorMapType <> 0) Then  { TGA_RGBA }
    Begin
     CloseFile(TGAFile);
     Exit;
    End;

   // Get the width, height, and color depth
   Result.Width  := TGAHeader.Width[0]  + TGAHeader.Width[1]  * 256;
   Result.Height := TGAHeader.Height[0] + TGAHeader.Height[1] * 256;
   IF TGAHeader.BPP < 32 Then
    Begin
     ImageSize:=Result.Width*Result.Height*3;
     Result.A:=GL_RGB;
    End
   Else Begin
         ImageSize  := Result.Width*Result.Height*4;
         Result.A:=GL_RGBA;
        End;

   GetMem(Result.Data, ImageSize);

   BlockRead(TGAFile, Result.Data^, ImageSize, bytesRead);
   IF bytesRead <> ImageSize then
    Begin
     CloseFile(TGAFile);
     Exit;
    End;

   IF TGAHeader.BPP=32 Then
   For I :=0 to Result.Width * Result.Height - 1 do
    Begin
      Front := Pointer(Integer(Result.Data) + I*4);
      Back  := Pointer(Integer(Result.Data) + I*4 + 2);
      Temp  := Front^;
      Front^ := Back^;
      Back^ := Temp;
    End;
   IF TGAHeader.BPP<32 Then
   For I :=0 to Result.Width * Result.Height - 1 do
    Begin
      Front := Pointer(Integer(Result.Data) + I*3);
      Back  := Pointer(Integer(Result.Data) + I*3 + 2);
      Temp  := Front^;
      Front^ := Back^;
      Back^ := Temp;
    End;
 End;
 
Function LoadBmpFile(FFile:String):Texture;
procedure SwapRGB(data : Pointer; Size : Integer);
asm
  mov ebx, eax
  mov ecx, size

@@loop :
  mov al,[ebx+0]
  mov ah,[ebx+2]
  mov [ebx+2],al
  mov [ebx+0],ah
  add ebx,3
  dec ecx
  jnz @@loop
end;
var
  FileHeader: TBITMAPFILEHEADER;
  InfoHeader: TBITMAPINFOHEADER;
  Palette: array of RGBQUAD;
  BitmapFile: THandle;
  BitmapLength: LongWord;
  PaletteLength: LongWord;
  ReadBytes: LongWord;
  Data:Pointer;
begin
  BitmapFile := CreateFile(PChar(FFile), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0);
  if (BitmapFile = INVALID_HANDLE_VALUE) then begin
    MessageBox(0, PChar('Error opening "' + FFile), PChar('BMP Unit'), MB_OK);
    Exit;
  end;

  // Get header information
  ReadFile(BitmapFile, FileHeader, SizeOf(FileHeader), ReadBytes, nil);
  ReadFile(BitmapFile, InfoHeader, SizeOf(InfoHeader), ReadBytes, nil);

  // Get palette
  PaletteLength := InfoHeader.biClrUsed;
  SetLength(Palette, PaletteLength);
  ReadFile(BitmapFile, Palette, PaletteLength, ReadBytes, nil);
  if (ReadBytes <> PaletteLength) then begin
    MessageBox(0, PChar('Error reading palette'), PChar('BMP Unit'), MB_OK);
    Exit;
  end;

  Result.Width := InfoHeader.biWidth;
  Result.Height := InfoHeader.biHeight;

  BitmapLength := InfoHeader.biSizeImage;
  if BitmapLength = 0 then
    BitmapLength := Result.Width * Result.Height * InfoHeader.biBitCount Div 8;

  // Get the actual pixel data
  GetMem(Data, BitmapLength);
  ReadFile(BitmapFile, Data^, BitmapLength, ReadBytes, nil);
  if (ReadBytes <> BitmapLength) then begin
    MessageBox(0, PChar('Error reading bitmap data'), PChar('BMP Unit'), MB_OK);
    Exit;
  end;
  CloseHandle(BitmapFile);

  // Bitmaps are stored BGR and not RGB, so swap the R and B bytes.
  SwapRGB(Data,Result.Width*Result.Height);
  Result.Data:=Data;
end;

Procedure BindNewTextureMipMap(var Textures:Texture; MipMax,Wrap:GLuint; vFile:String; vType:Cardinal);
Var Dtype:GluInt;   TexID:Cardinal;
Begin
 TexID:=Textures.ID;
 //Изменение размеров текстуры если необходимо
 Case vType of
  l_BMP:Begin Textures:=LoadBmpFile(vFile); Dtype:=GL_RGB End;
  l_BMPA:Begin Textures:=LoadBmpAFile(vFile); Dtype:=GL_RGBA End;
  l_JPG:Begin Textures:=LoadJPGFile(vFile); Dtype:=GL_RGB End;
 End;

 Textures.ID:=TexID;

 glBindTexture(GL_TEXTURE_2D, Textures.ID);

 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, Wrap);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, Wrap);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_Linear);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_Nearest_MIPMAP_Linear);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_BASE_LEVEL, 0);//>>-------------------------------------------->-
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, MipMax);//>>--------------------------------------------->-

 glTexEnvf(GL_TEXTURE_2D,GL_TEXTURE_ENV_MODE,GL_MODULATE);                                                                                                         // |
 glTexImage2D(GL_TEXTURE_2D, 0, DType, Textures.Width, Textures.Height, 0, DType, GL_UNSIGNED_BYTE, Textures.Data);                     // |
 gluBuild2DMipmaps(GL_TEXTURE_2D, DType, Textures.Width, Textures.Height, DType, GL_UNSIGNED_BYTE, Textures.Data);                  // |

 FreeMem(Textures.Data);
End;

Procedure BindNewTexture(var Textures:Texture; Wrap:GLuint; vFile:String; vType:Cardinal);
Var Dtype:GluInt;  TGA:TGAImage; TexID:Cardinal;
Begin
 TexID:=Textures.ID;
 //Изменение размеров текстуры если необходимо
 Case vType of
  l_BMP:Begin Textures:=LoadBmpFile(vFile); Dtype:=GL_RGB End;
  l_BMPA:Begin Textures:=LoadBmpAFile(vFile); Dtype:=GL_RGBA End;
  l_JPG:Begin Textures:=LoadJPGFile(vFile); Dtype:=GL_RGB End;
  l_TGA:Begin
         TGA:=LoadTGA(vFile);
         Dtype:=TGA.A;
         Textures.Width:=TGA.Width;
         Textures.Height:=TGA.Height;
         Textures.Data:=TGA.Data;
        End;
 End;

 Textures.ID:=TexID;
 
 glBindTexture(GL_TEXTURE_2D, Textures.ID);

 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, Wrap);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, Wrap);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
 glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

 glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE);                                                                                                         // |
 glTexImage2D(GL_TEXTURE_2D, 0, DType, Textures.Width, Textures.Height, 0, DType, GL_UNSIGNED_BYTE, Textures.Data);                     // |
 FreeMem(Textures.Data);
End;

Function LoadBmpAFile(FFile:String):Texture;
type
  PPixelArray = ^TPixelArray;
  TPixelArray = array [0..0] of Byte;
var
  Bitmap : TBitmap;
  Data, DataA : PPixelArray;
  BMInfo : TBitmapInfo;
  I, ImageSize : Integer;
//  Temp : Byte;
  MemDC : HDC;
begin
  Bitmap := TBitmap.Create;
  Bitmap.LoadFromFile (FFile);
  with BMinfo.bmiHeader do begin
    FillChar (BMInfo, SizeOf(BMInfo), 0);
    biSize := sizeof (TBitmapInfoHeader);
    biBitCount := 24;
    biWidth := Bitmap.Width;
    biHeight := Bitmap.Height;
    ImageSize := biWidth * biHeight;
    biPlanes := 1;
    biCompression := BI_RGB;
    MemDC := CreateCompatibleDC (0);
    GetMem (Data, ImageSize * 3);
    GetMem (DataA, ImageSize * 4);
    try
      GetDIBits (MemDC, Bitmap.Handle, 0, biHeight, Data, BMInfo, DIB_RGB_COLORS);

      //BGR-RGB+A
      For I := 0 to ImageSize - 1 do begin
          DataA[I*4]:=Data[I*3+2];
          DataA[I*4+1]:=Data[I*3+1];
          DataA[I*4+2]:=Data[I*3];
          IF (DataA[I*4]>200)   AND
             (DataA[I*4+1]>200) AND
             (DataA[I*4+2]>200)
          Then DataA [I * 4 + 3] := 0
          Else
           If (DataA [I * 4] < DataA [I * 4 + 2]) AND
              (DataA [I * 4+1] < DataA [I * 4 + 2])
           Then DataA [I * 4 + 3] := 85
           Else DataA [I * 4 + 3] := 255;
      end;

      Result.Width:=biWidth;
      Result.Height:=biHeight;
      Result.Data:=DataA;

     finally
      FreeMem (Data);
      DeleteDC (MemDC);
      Bitmap.Free;
   end;
  end;
End;

Function LoadJpgFile(FFile:String):Texture;
type
  PPixelArray = ^TPixelArray;
  TPixelArray = array [0..0] of Byte;
Var JImage:TJPEGImage;
    Bitmap:TBitmap;
    BMInfo : TBitmapInfo;
    Data, DataA : PPixelArray;
    I:Integer;
    ImageSize:Integer;
Begin
 JImage:=TJPEGImage.Create;
  Try
   JImage.LoadFromFile(FFile);
  Except
   MessageBox(0,'Не возможно открыть JPEG файл','JPEG Error',MB_ICONHAND);
   JImage.Free;
   Exit
  End;

 Bitmap:=TBitmap.Create;
 Bitmap.PixelFormat:=pf24bit;
 Bitmap.Width:=JImage.Width;
 Bitmap.Height:=JImage.Height;

 Bitmap.Assign(JImage);

 With BMInfo.bmiHeader Do
  Begin
   FillChar (BMInfo, SizeOf(BMInfo), 0);
   biSize := sizeof (TBitmapInfoHeader);
   biBitCount := 24;
   biWidth := Bitmap.Width;
   biHeight := Bitmap.Height;
   biPlanes := 1;
   biCompression := BI_RGB;
   biSizeImage := biWidth * biHeight * 4;
   ImageSize:=biWidth * biHeight;
   GetMem (Data, ImageSize * 3);
   GetMem (DataA, ImageSize * 3);
   try
    GetDIBits(Bitmap.Canvas.Handle, Bitmap.Handle, 0, biHeight, Data, BMInfo, DIB_RGB_COLORS)
   except
    MessageBox(0,'Невозможно считать информацию в память','JPEG Error',MB_ICONERROR);
    FreeMem(Data);
    FreeMem(DataA);
    Bitmap.Free;
    JImage.Free;
    Exit
   end;
   //Чтение JPEG файла завершено.

   //BGR-RGB
      For I := 0 to ImageSize - 1 do
       Begin
        DataA[I*3]:=Data[I*3+2];
        DataA[I*3+1]:=Data[I*3+1];
        DataA[I*3+2]:=Data[I*3];
       End;

     Result.Width:=biWidth;
     Result.Height:=biHeight;
     Result.Data:=DataA;

     FreeMem (Data);
  end;
 Bitmap.Free;
 JImage.Free;
End;

end.

