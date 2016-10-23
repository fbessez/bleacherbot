defmodule Bleacherbot.Track do
  use Bleacherbot.Web, :model
  @moduledoc """
  cookies and cream
  """

  schema "tracks" do

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

defmodule BleacherBot.Djay do
  @moduledoc """
  This module will fetch the title, subtitle, image_url, and item_url
  for a given N number of tracks of the desired team, player, or league.
  It gets all of the information from Djay.
  """

  @spec convert_back(String) :: Poison.encode!
  def convert_back(unique_name) do
    unique_name
    |> fetch_tracks
    |> Poison.encode!
  end

  @spec fetch_tracks(String, Integer, Integer) :: String_JSON
  def fetch_tracks(unique_name, offset \\ 0, n \\ 10) do
    unique_name
    |> fetch(offset)
    |> get_body(n)
  end

  @spec fetch_tracks(String, Integer) :: HTTPoison.response!
  def fetch(unique_name, offset) do
    url = url(unique_name, offset)
    {:ok, response} = HTTPoison.get(url, [timeout: 15_000])
    response
  end

  @spec url(String, Integer) :: String
  def url(playlist, offset) do
    "#{System.get_env "DJAY_URL"}/api/playlists/#{playlist}_ts/tracks?limit=10&offset=#{offset}"
  end

  @spec get_body(HTTPoison.response!, Integer) :: String_JSON
  def get_body(response, n) do
    response
    |> Map.from_struct
    |> Map.fetch!(:body)
    |> decode_body(n, response.status_code)
  end

  @spec decode_body(String_JSON, Integer, Integer) :: String
  def decode_body(body, n, status_code) do
    case status_code do
      200 ->
        body = Poison.decode!(body)
        body["tracks"]
        |> parse_response(n)
      _ ->
        "not good enough"
    end
  end

  @spec parse_response(String_JSON, Integer) :: String
  def parse_response(tracklist, _) when length(tracklist) < 8, do: "not good enough"
  def parse_response(tracklist, n), do: get_N_tracks(tracklist, n, [])

  @spec fetch_track_info(String_JSON, String) :: String_JSON
  def fetch_track_info(track, track_content_type) do
    %{"title": fetch_title(track, track_content_type),
     "subtitle": fetch_subtitle(track, track_content_type),
     "item_url": fetch_item_url(track, track_content_type),
     "image_url": fetch_image_url(track, track_content_type),
     "permalink": fetch_permalink(track),
     "playlist_id": fetch_playlist_id(track),
     "tag_id": fetch_tag_id(track),
     "content_type": track_content_type,
     "display_name": fetch_display_name(track)}
  end

  @spec get_N_tracks(String_JSON, Integer, List) :: List
  def get_N_tracks(tracklist, n, n_tracks) when n <= 1 do
    n_tracks ++ [fetch_track_info(hd(tracklist), fetch_content_type(hd(tracklist)))]
  end
  
  def get_N_tracks(tracklist, n, n_tracks) do
    n_tracks = n_tracks ++ [fetch_track_info(hd(tracklist),
                 fetch_content_type(hd(tracklist)))]
    get_N_tracks(tl(tracklist), n - 1, n_tracks)
  end

  @spec fetch_display_name(String_JSON) :: String
  def fetch_display_name(track) do
    track["tag"]["display_name"]
  end

  @spec fetch_tag_id(String_JSON) :: Integer
  def fetch_tag_id(track) do
    track["tag"]["tag_id"]
  end

  @spec fetch_provider(String_JSON) :: String
  def fetch_provider(track) do
    track["content"]["metadata"]["provider_url"]
  end

  @spec fetch_playlist_id(String_JSON) :: String
  def fetch_playlist_id(track) do
    track["playlist_id"]
  end

  @spec fetch_permalink(String_JSON) :: String
  def fetch_permalink(track) do
    track["permalink"]
  end

  @spec fetch_content_type(String_JSON) :: String
  def fetch_content_type(track) do
    track["content_type"]
  end

  @spec fetch_title(String_JSON, String) :: String
  def fetch_title(track, content_type) do
    # add to photo:  facebook_image_post, facebook_post, facebook_video_post, gif, podcast
    cond do
      content_type == "tweet" || content_type == "instagram_image" ||
      content_type == "instagram_video" ->
        track["content"]["metadata"]["caption"]
      content_type == "photo" ->
        track["content"]["commentary"]["title"]
      content_type == "youtube" ->
        track["content"]["metadata"]["title"]
      content_type == "scoreboard" ->
        "Score: " <> to_string(track["content"]["metadata"]["legacy_game_widget"]["homeTeamScore"]) <>
        " - " <> to_string(track["content"]["metadata"]["legacy_game_widget"]["awayTeamScore"])
      true ->
        track["content"]["title"]
    end
  end

  @spec fetch_subtitle(String_JSON, String) :: String
  def fetch_subtitle(track, content_type) do
    cond do
      content_type == "text" ->
        track["content"]["description"]
      content_type == "scoreboard" ->
        track["content"]["metadata"]["native_widget"]["homeTeamInfo"]["shortName"] <>
        " vs. " <> track["content"]["metadata"]["native_widget"]["awayTeamInfo"]["shortName"]
      true ->
        "Check this out!"
    end
  end

  @spec fetch_item_url(String_JSON, String) :: String
  def fetch_item_url(track, content_type) do
    cond do
      content_type == "gif" -> track["content"]["metadata"]["media_url"]
      content_type == "text" ->
        "http://bleacherreport.com/" <> track["tag"]["unique_name"]
      content_type == "deeplink" ->
        "http://bleacherreport.com" <> track["permalink"]
      content_type == "scoreboard" ->
        track["content"]["metadata"]["box_score_url"]
      content_type == "internal_article" || content_type == "external_article" ||
      content_type == "youtube" ->
       # fetch_provider(track) <> track["permalink"]
       "http://bleacherreport.com" <> track["permalink"]
      true ->
        track["url"]
    end
  end

  @spec fetch_image_url(String_JSON, String) :: String
  def fetch_image_url(track, content_type) do
    first_seven = ["text", "facebook_post", "tweet", "youtube", "facebook_image_post", "facebook_video_post", "podcast"]
    next_four = ["instagram_image", "instagram_video", "photo", "scoreboard"]
    image = 
      cond do
        Enum.member?(first_seven, content_type) ->
          fetch_image_url_7(track, content_type)
        Enum.member?(next_four, content_type) ->
          fetch_image_url_4(track, content_type)
        true ->
          track["content"]["thumbnail_url"]
      end
    case image do
      nil -> "http://cdn1.thecomeback.com/wp-content/uploads/sites/94/2015/01/bleacherreport2-583x356.png"
      _ -> image
    end
  end

  @spec fetch_image_url_7(String_JSON, String) :: String
  def fetch_image_url_7(track, content_type) do
    cond do
      content_type == "text" || content_type == "facebook_post" ->
        image = "http://www.sportsnexus.in/wp-content/uploads/2016/02/team-stream.jpg"
      content_type == "tweet" || content_type == "youtube" ||
      content_type == "facebook_image_post" || content_type == "facebook_video_post" ||
      content_type == "podcast" ->
        image = track["content"]["metadata"]["thumbnail_url"]
      true -> image = nil
    end
  end

  @spec fetch_image_url_4(String_JSON, String) :: String
  def fetch_image_url_4(track, content_type) do
    cond do
      content_type == "instagram_image" || content_type == "instagram_video" ->
        image = track["content"]["metadata"]["thumbnails"]["standard_resolution"]["url"]
      content_type == "photo" ->
        image = track["url"]
      content_type == "scoreboard" ->
        image = "http://www.iamjasonso.com/img/teamstream-thumbnail.jpg"
    end
  end

end
