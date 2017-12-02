unit ThreadWorker;

interface

uses
  System.Classes, System.SyncObjs, System.Threading;

function ExecuteTasks(ATaskCount, ALogRecordCount : Integer; OnStatusChange: TGetStrProc): TArray<ITask>;

implementation

uses
   Logger.Manager, Logger.Intf, System.SysUtils;

function NewGuid: TGuid;
var
  Uid: TGuid;
begin
  if CreateGuid(Uid) <> S_OK then
    raise Exception.Create('Can not generate GUID');
  Result := Uid;
end;

function ExecuteTasks(ATaskCount, ALogRecordCount : Integer; OnStatusChange: TGetStrProc): TArray<ITask>;
var
  Proc : TProc;
  I: Integer;
begin
  Proc :=  procedure
    var
     Logger : ILogger;
     processed: integer; // shared counter
     total    : integer; // total number of items to be processed
    begin

      processed := 0;
      total := ALogRecordCount;

       Logger := LogManager.GetLogger('Task_' + NewGuid.ToString);

       TThread.Queue(Nil,
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
           Logger.Error(I.ToString);

           new := TInterlocked.Increment(processed);

           if (new mod 100) = 0 then // update the progress bar every 10 processed items
              TThread.Queue(nil,
                procedure
                var
                  Percent: Integer;
                begin
                  //update the progress bar in the main thread
                  Percent := Round(new / total * 100);
                  OnStatusChange(Format('%s : [complete: %d]; processsed: %d; total: %d', [Logger.SourceName, Percent, new, total]));
                end
              ); //TThread.Queue
         end);

         // Update the UI
         TThread.Queue(Nil,
         procedure
         begin
            if Assigned(OnStatusChange) then
              OnStatusChange(Format('%s Completed', [Logger.SourceName]));
         end);
    end;

  SetLength(Result, ATaskCount);

  for I := 0 to ATaskCount - 1 do
  begin
    Result[I] := TTask.Create(Proc);
    Result[I].Start;
  end;

//  TTask.WaitForAll(Tasks);
end;

end.
