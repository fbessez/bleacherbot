defmodule Bleacherbot.Score do
  use Bleacherbot.Web, :model
  @moduledoc """
  """

  schema "scores" do

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [])
    |> validate_required([])
  end
end

defmodule BleacherBot.NewScoresInfo do
  @moduledoc """
  This module will fetch from the Scores service all of the
  information that I think is necessary to send in a message
  about a particular game
    tvListing, startTime, period, pbpURL, LeagueDisplayName,
    id, homeTeamShortName, homeTeamScore, homeTeamRecord,
    logo, abbrev, awayTeamShortName, awayTeamScore, awayTeamRecord,
    logo, abbrev,
  """
  @spec by_league_url(String, String) :: String
  def by_league_url(league, team) do
    leagues = %{
  "NBA" => "basketball",
  "MLB" => "baseball",
  "NHL" => "hockey",
  "NFL" => "football"
  }
    "#{System.get_env "SCORES"}/api/scores/league/#{league}/#{leagues[league]}"
  end

  def by_date_url(league, date) do
      leagues = %{
        "NBA" => "basketball",
        "MLB" => "baseball",
        "NHL" => "hockey",
        "NFL" => "football"
      }
      "#{System.get_env "SCORES"}/api/scores/league/#{league}/#{leagues[league]}/?date=#{date}"
    #"http://scores.sbleacherreport.com/api/scores/league/MLB/Baseball/?date=2016-07-15"
  end

  @spec my_teams_url(String, String) :: String
  def my_teams_url(league, teams) do
    "#{System.get_env "SCORES"}/api/scores/my_teams/?teams=#{teams}"
  end

  @spec fetch_scores(String, String) :: Poison.decode!
  def fetch_scores(league \\ nil, teams \\ nil) do
    league
    |> fetch_game_info(teams)
    |> get_body
  end

  @spec fetch_game_info(String, String) :: HTTPoison.response!
  def fetch_game_info(league, teams) do
    url = 
      case {league, teams} do
        {league, nil} ->
          by_league_url(league, teams)
        {nil, teams} ->
          my_teams_url(league, teams)
      end
    # url = by_league_url(league, teams)
    {:ok, response} = HTTPoison.get(url, [timeout: 15_000])
    response
  end

  @spec get_body(HTTPoison.response!) :: String_JSON
  def get_body(response) do
    response
    |> Map.from_struct
    |> Map.fetch!(:body)
    |> Poison.decode!
    #|> IO.inspect
    |> get_games
  end

  @spec get_all_games(String_JSON, List) :: List
  def get_all_games(games, result) when tl(games) == [] do
    result ++ [fetch_game_details(hd(games))]
  end
  def get_all_games(games, result) do
    result = result ++ [fetch_game_details(hd(games))]
    get_all_games(tl(games), result)
  end

  @spec get_games(String_JSON) :: String_JSON
  def get_games(body) do
    body = body["games"]
    case body do
      [] -> "No Games!"
      _ -> get_all_games(body, [])
    end
  end

  @spec fetch_game_details(String_JSON) :: String_JSON
  def fetch_game_details(game) do
    %{
      "eventInfo":  get_event_info(game),
      "homeTeamInfo": get_home_team_info(game),
      "awayTeamInfo": get_away_team_info(game),
      "valuables":  get_proper_sentences(game)
    }
  end

  @spec get_event_info(String_JSON) :: String_JSON
  def get_event_info(game) do
    %{
      "tvListing":    get_tv_listing(game),
      "startTime":    get_start_time(game),
      "currentPeriod":  get_period(game),
      "playByPlay":     get_play_by_play(game)}
  end

  @spec get_tv_listing(String_JSON) :: String
  def get_tv_listing(game) do
    game["tvListing"]
  end

  @spec get_start_time(String_JSON) :: String
  def get_start_time(game) do
    game["startTime"]
  end

  @spec get_period(String_JSON) :: String
  def get_period(game) do
    game["period"]
  end

  @spec get_play_by_play(String_JSON) :: String
  def get_play_by_play(game) do
    game["pbpUrl"]
  end

  @spec get_home_team_info(String_JSON) :: String_JSON
  def get_home_team_info(game) do
    %{
      "homeTeamId":   get_home_team_id(game),
      "homeAbbrev":   get_home_abbrev(game),
      "homeLogo":   get_home_logo(game),
      "homeRecord":   get_home_record(game),
      "homeScore":  get_home_score(game),
      "homeName":   get_home_short_name(game)}
  end

  @spec get_home_team_id(String_JSON) :: Integer
  def get_home_team_id(game) do
    game["homeTeamId"]
  end

  @spec get_home_abbrev(String_JSON) :: String
  def get_home_abbrev(game) do
    game["homeTeamInfo"]["abbrev"]
  end

  @spec get_home_logo(String_JSON) :: String
  def get_home_logo(game) do
    game["homeTeamInfo"]["logo"]
  end

  @spec get_home_record(String_JSON) :: Integer
  def get_home_record(game) do
    game["homeTeamRecord"]
  end

  @spec get_home_score(String_JSON) :: Integer
  def get_home_score(game) do
    game["homeTeamScore"]
  end

  @spec get_home_short_name(String_JSON) :: String
  def get_home_short_name(game) do
    game["homeTeamShortName"]
  end

  @spec get_away_team_info(String_JSON) :: String_JSON
  def get_away_team_info(game) do
    %{
      "awayTeamId":   get_away_team_id(game),
      "awayAbbrev":   get_away_abbrev(game),
      "awayLogo":   get_away_logo(game),
      "awayRecord":   get_away_record(game),
      "awayScore":  get_away_score(game),
      "awayName":   get_away_short_name(game)}
  end

  @spec get_away_team_id(String_JSON) :: Integer
  def get_away_team_id(game) do
    game["awayTeamId"]
  end

  @spec get_away_abbrev(String_JSON) :: String
  def get_away_abbrev(game) do
    game["awayTeamInfo"]["abbrev"]
  end

  @spec get_away_logo(String_JSON) :: String
  def get_away_logo(game) do
    game["awayTeamInfo"]["logo"]
  end

  @spec get_away_record(String_JSON) :: Integer
  def get_away_record(game) do
    game["awayTeamRecord"]
  end

  @spec get_away_score(String_JSON) :: Integer
  def get_away_score(game) do
    game["awayTeamScore"]
  end

  @spec get_away_short_name(String_JSON) :: String
  def get_away_short_name(game) do
    game["awayTeamShortName"]
  end

  @spec get_real_time(String_JSON) :: String
  def get_real_time(game) do
    x = get_start_time(game)
    hour = String.to_integer(String.slice(x, 11..12)) - 7
    minute = String.slice(x, 14..15)
    time_zone = "PST"
    to_string(hour) <> ":" <> minute <> " " <> time_zone
  end


  @spec get_proper_sentences(String_JSON) :: String_JSON
  def get_proper_sentences(game) do
    %{
      "current_score": get_home_abbrev(game) <> " " <>
              to_string(get_home_score(game)) <> " - " <>
              to_string(get_away_score(game)) <> " " <>
              get_away_abbrev(game),
      "teams":    get_home_short_name(game) <> " (" <> get_home_record(game) <> ")"
              <> " vs. " <>
              get_away_short_name(game) <> " (" <> get_away_record(game) <> ")",
      "time":     get_real_time(game)
      }
  end



end
