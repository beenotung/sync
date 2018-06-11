-module(scan).
-export([main/1, debug/0]).

-include_lib("kernel/include/file.hrl").

main(_Args) ->
  scan(".").

scan(Dir) ->
  {ok, Files} = file:list_dir(Dir),
  lists:foreach(
    fun(File0) ->
      File = filename:join(Dir, File0),
      case get_file_type(File) of
        directory -> scan(File);
        _ -> print_file(File)
      end
    end
    , Files),
  ok.

get_file_type(File) ->
%%  io:format("read ~p~n", [File]),
  {ok, FileInfo} = file:read_file_info(File),
  FileInfo#file_info.type.

print_file(File) ->
  {ok, Content} = file:read_file(File),
  Hash = crypto:hash(md5, Content),
  Hex = bin_to_hex(Hash),
  io:format("~s ~ts~n", [Hex, File]).

hex(C) when C < 10 -> $0 + C;
hex(C) -> $a + (C - 10).

bin_to_hex(Bin) when is_binary(Bin) ->
  <<<<(hex(H)), (hex(L))>> || <<H:4, L:4>> <= Bin>>.

debug() ->
  try
    dbg:tracer() of _ -> ok
  catch
    _ -> ok
  end,
  {ok, _Res1} = dbg:p(all, c),
  {ok, _Res2} = dbg:tp(?MODULE, scan, x),
  {ok, _Res2} = dbg:tp(?MODULE, get_file_type, x),
  ok.
