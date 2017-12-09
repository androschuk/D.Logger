unit Logger.Test.Manager;

interface
uses
  DUnitX.TestFramework;

type

  [TestFixture]
  TLogManagerTest = class(TObject)
  public
    [Test]
    procedure TestGetSingletonInDifThread;
  end;

implementation

uses
  System.SysUtils, System.Threading, System.Classes, Logger.Manager;

procedure TLogManagerTest.TestGetSingletonInDifThread;
var
  Proc: TProc;
  Tasks: TArray<ITask>;
  I: Integer;
  List: IInterfaceList;
begin
  List := TInterfaceList.Create;

  Proc :=  procedure
    begin
      List.Add(LogManager)
    end;

  SetLength(Tasks, 10);

  for I := 0 to Length(Tasks) - 1 do
    Tasks[I] := TTask.Create(Proc);

  for I := 0 to Length(Tasks) - 1 do
    Tasks[I].Start;

  TTask.WaitForAll(Tasks);

  // The same interface pointer
  for I := 1 to List.Count-1 do
    Assert.AreEqual(List[0], List[I], 'LogManager not thread-safe. Returns different instances in different threads');
end;

initialization
  TDUnitX.RegisterTestFixture(TLogManagerTest);
end.
