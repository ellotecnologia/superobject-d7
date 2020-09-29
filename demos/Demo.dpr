program Demo;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Contnrs,
  JsonListAdapter in '..\JsonListAdapter.pas',
  OldRttiMarshal in '..\OldRttiMarshal.pas',
  OldRttiUnMarshal in '..\OldRttiUnMarshal.pas',
  RestJsonOldRTTI in '..\RestJsonOldRTTI.pas',
  RestJsonUtils in '..\RestJsonUtils.pas',
  superobject in '..\superobject.pas';

type
  {$M+}
  TBook = class;

  TAuthor = class
  private
    FName: String;
    FBooks: TObjectList;
  public
    constructor Create(const AName: String);
    destructor Destroy; override;
    procedure AddBook(Book: TBook);
  published
    property Name: String read FName write FName;
    property BookList: TObjectList read FBooks write FBooks;
  end;

  TBook = class(TPersistent)
  private
    FEdition: Cardinal;
    FYear: Integer;
    FName: String;
  public
    constructor Create(const AName: String; AYear: Integer; AEdition: Cardinal);
  published
    property Name: String read FName write FName;
    property Year: Integer read FYear write FYear;
    property Edition: Cardinal read FEdition write FEdition;
  end;
  {$M-}

{ TAuthor }

constructor TAuthor.Create(const AName: String);
begin
  FName := AName;
  FBooks := TObjectList.Create;
end;

destructor TAuthor.Destroy;
begin
  FBooks.Free;
  inherited;
end;

procedure TAuthor.AddBook(Book: TBook);
begin
   FBooks.Add(Book);
end;

{ TBook }

constructor TBook.Create(const AName: String; AYear: Integer; AEdition: Cardinal);
begin
   FName := AName;
   FYear := AYear;
   FEdition := AEdition;
end;

procedure ObjectToJson;
var
   obj: ISuperObject;
   author: TAuthor;
begin
   author := TAuthor.Create('Douglas Adams');
   author.AddBook(TBook.Create('O Guia do Mochileiro das Galáxias', 1979, 1));

   obj := TOldRttiMarshal.ToJson(author);

   WriteLn(obj.AsJson);
   writeln('');
end;

procedure JsonToObject;
var
   json: String;
   author: TAuthor;
   book: TBook;
   i: Integer;
begin
   json := '{                                                                                     ' +
           '   "Name": "Douglas Adams",                                                           ' +
           '   "BookList": [                                                                      ' +
           '      {"Name": "O Guia do Mochileiro das Gal\u00e1xias", "Year": 1979, "Edition": 1}, ' +
           '      {"Name": "O restaurante no fim do Universo", "Year": 1980, "Edition": 2},       ' +
           '      {"Name": "A Vida, o Universo e tudo mais", "Year": 1982, "Edition": 1},         ' +
           '   ]                                                                                  ' +
           '}                                                                                     ';

   author := TAuthor(TOldRttiUnMarshal.FromJson(TAuthor, json));

   WriteLn('Author: ', author.Name);
   writeln('Books:');
   for i := 0 to author.BookList.Count - 1 do begin
      book := TBook(author.BookList.Items[i]);
      writeln(Format('  Name: %s, Year: %d, Edition: %d', [book.Name, book.Year, book.Edition]));
   end;
end;

begin
  RegisterClass(TBook);

  ObjectToJson;
  JsonToObject;

  ReadLn;
end.
