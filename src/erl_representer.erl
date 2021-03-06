-module(erl_representer).

%% API exports
-export([main/1]).

-define(APP, ?MODULE).

-include_lib("kernel/include/logger.hrl").

%%====================================================================
%% API functions
%%====================================================================

%% escript Entry point
main([Slug, InPath, OutPath]) ->
    ok = application:load(?APP), %% We need to load the application to its keys
                                 %% available later on.
    set_up_logger(filename:join(OutPath, "representation.out"), 2),
    ?LOG_INFO("Representer Version: ~s", [version()]),
    ?LOG_INFO(
       "OTP-Version: ~s (compiled with ~p)",
       [erlang:system_info(otp_release), ?OTP_RELEASE]),
    timer:sleep(500),
    erlang:halt(0).

%%====================================================================
%% Internal functions
%%====================================================================

version() ->
    {ok, Version0} = application:get_key(?APP, vsn),
    Version1 = string:split(Version0, "-"),
    case Version1 of
        [Date, "dirty"] ->
            format_date(Date) ++ "-dirty-commit";
        [Date, Commit] ->
            format_date(Date) ++ "-" ++ Commit;
        ["dev"] ->
            "inofficial-dev-build"
    end.

format_date(Date0) ->
    {Year, Date1} = lists:split(4, Date0),
    {Month, Date2} = lists:split(2, Date1),
    {Day, Time0} = lists:split(2, Date2),
    {Hour, Time1} = lists:split(2, Time0),
    {Minute, Seconds} = lists:split(2, Time1),
    lists:flatten(
      io_lib:format(
        "~s-~s-~sT~s:~s:~sZ",
        [Year, Month, Day, Hour, Minute, Seconds])).

set_up_logger(LogFile, Verbosity) ->
    Level = case Verbosity of
                0 -> notice;
                1 -> info;
                X when is_integer(X), X >= 2 -> debug
            end,
    logger:add_handler(
      file_logger,
      logger_std_h,
      #{config => #{file => LogFile}}),
    logger:update_primary_config(#{level => Level}),
    ?LOG_NOTICE("Logger initialized, writing to file '~s'", [LogFile]).
