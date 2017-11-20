unit ThreadWorker;

interface

uses
  System.Classes, System.SyncObjs;

procedure ExecuteTasks(ATaskCount, ALogRecordCount : Integer; OnStatusChange: TGetStrProc);

implementation

uses
   System.Threading, Logger.Manager, Logger.Intf, System.SysUtils;

function NewGuid: TGuid;
var
  CreateResult: HResult;
  Uid: TGuid;
begin
  if CreateGuid(Uid) <> S_OK then
    raise Exception.Create('Can not generate GUID');
  Result := Uid;
end;

procedure ExecuteTasks(ATaskCount, ALogRecordCount : Integer; OnStatusChange: TGetStrProc);
var
  Tasks : TArray<ITask>;
  Task: ITask;
  Proc : TProc;
  I: Integer;
begin
  Proc :=  procedure
    var
     Logger : ILogger;
     I: Integer;
     processed: integer; // shared counter
     total    : integer; // total number of items to be processed
    begin

      processed := 0;
      total := ALogRecordCount;

       Logger := LogManager.GetLogger('Task_' + NewGuid.ToString);

       TThread.Synchronize(TThread.CurrentThread,
        procedure
        begin

          if Assigned(OnStatusChange) then
            OnStatusChange(Format('%s Started...', [Logger.SourceName]));
        end);

       TParallel.For(1, ALogRecordCount,
         procedure (i: integer)
         var
           new: integer;
         begin
           Logger.Info(I.ToString);

           new := TInterlocked.Increment(processed);

           if (new mod 100) = 0 then // update the progress bar every 10 processed items
              TThread.Queue(nil,
                procedure
                var
                  newValue: Integer;
                begin
                  //update the progress bar in the main thread
                  newValue := Round(new / total * 100);
                  OnStatusChange(Format('%s : [%d]; processsed: %d; total: %d', [Logger.SourceName, newValue, new, total]));
                end
              ); //TThread.Queue
         end);

         // Update the UI
         TThread.Queue(nil,
         procedure
         begin
            if Assigned(OnStatusChange) then
              OnStatusChange(Format('%s Completed', [Logger.SourceName]));
         end);
    end;

  SetLength(Tasks, ATaskCount);

  for I := 0 to ATaskCount - 1 do
  begin
    Tasks[I] := TTask.Create(Proc);
    Tasks[I].Start;
  end;

//  TTask.WaitForAll(Tasks);
end;

end.
