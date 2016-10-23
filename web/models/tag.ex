defmodule Bleacherbot.Tag do
  use Bleacherbot.Web, :model
  @moduledoc """
  """

  schema "tags" do

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


defmodule BleacherBot.TagWorth do
  @moduledoc """
  This Module will be called from the BleacherBot.GetTags module.
  It will receive the list of all tags that match the user input
  Then, it will check the Djay URL for each of those tag options
  If, the Djay URL does not have more than 7 stories -> it will
  return only the streams with enough content to present
  """

  @spec check_worth(String) :: Map.fetch!(String_JSON)
  def check_worth(unique_name) do
    unique_name
    |> fetch_response
    |> get_body
  end

  @spec fetch_response(String) :: HTTPoison.response!
  def fetch_response(unique_name) do
    url = url(unique_name)
    {:ok, response} = HTTPoison.get(url, [])
    response
  end

  @spec url(String) :: String
  def url(playlist) do
    "#{System.get_env "DJAY_URL"}/api/playlists/#{playlist}_ts/tracks?limit=10&offset=0"
  end

  @spec get_body(HTTPoison.response!) :: String_JSON
  def get_body(response) do
    response
    |> Map.from_struct
    |> Map.fetch!(:body)
    |> decode_body(response.status_code)
  end

  @spec decode_body(String_JSON, Integer) :: String
  def decode_body(body, status_code) do
    case status_code do
      200 ->
        Poison.decode!(body)["tracks"]
        |> parse_response
        _   ->
          "not good enough"
    end
  end

  @spec parse_response(String_JSON) :: String
  def parse_response(tracklist) when length(tracklist) <= 8, do: "not good enough"
  def parse_response(_), do: "good enough"

end



defmodule BleacherBot.GetTags do
  alias BleacherBot.TagWorth
  @moduledoc """
  his module will get the tagdata for all players, teams, leagues
  that have the user input in the "name" key:value pair.
  This is used when trying to figure out which stream user is interested in
  test this
  """

  def convert_back(input) do
    input
    |> fetch_tags
    |> Poison.encode!
  end

  @spec fetch_tags(String, String) :: [List]
  def fetch_tags(input \\ nil, url \\ nil) do
    input
    |> fetch_response(url)
    |> get_body
  end

  @spec fetch_response(String, String) :: HTTPoison.response
  def fetch_response(input, url) do
    case url do
      nil -> url = url(input)
      _ -> url
    end
    {:ok, response} = HTTPoison.get(url, [])
    response
  end

  @spec get_body(HTTPoison.response) :: Poison.decode!
  def get_body(response) do
    response
    |> Map.from_struct
    |> Map.fetch!(:body)
    |> Poison.decode!
    |> parse_response
  end

  @spec url(String) :: String
  def url(input) do
    "#{System.get_env "TAGS"}/tags.json?q=#{input}"
  end

  @spec parse_response(String_JSON) :: String
  def parse_response(body) when body == %{"tags" => []}, do: "invalid input"
  def parse_response(body) do
    get_all_options(body["tags"], (length body["tags"]), [])
  end


  @spec get_fields(String_JSON) :: JSON
  def get_fields(tag) do
    %{"permalink": get_permalink(tag),
    "name": get_name(tag),
    "id": get_id(tag),
    "logo_filename": get_team_logo(tag),
    "type": get_type(tag),
    "links":
      %{
      "parent": get_parent_url(tag),
      "tag_parent": get_parent_links(tag)}
    }
  end

  @spec get_team_logo(String_JSON) :: String
  def get_team_logo(tag) do
    if get_type(tag) === "Person" do
      get_parent_permalink(tag)
    else
      get_logo_filename(tag)
    end
  end

  @spec get_parent_permalink(String_JSON) :: String
  def get_parent_permalink(tag) do
    parent_url = get_parent_links(tag)
    parent_tag = BleacherBot.GetTags.fetch_tags(nil, parent_url)
    case parent_tag do
      [] -> "http://static1.squarespace.com/static/50e4b513e4b0837383d619f3/t/5277c2dbe4b0a89c83bd522b/1383580380356/Bleacher-Report-Logo.jpg"
      _ -> hd(parent_tag).logo_filename
    end
  end

  @spec get_type(String_JSON) :: String
  def get_type(tag) do
    tag["type"]
  end

  @spec get_permalink(String_JSON) :: String
  def get_permalink(tag) do
    tag["permalink"]
  end

  @spec get_name(String_JSON) :: String
  def get_name(tag) do
    tag["name"]
  end

  @spec get_parent_url(String_JSON) :: String
  def get_parent_url(tag) do
    permalink = get_permalink(tag)
    parent_url = get_parent_links(tag)
    case parent_url do
      nil -> nil
      _ ->
        "#{System.get_env "BLEACHERBOT"}/tags?tags=#{permalink}&r=parent"
    end
  end

  @spec get_parent_links(String_JSON) :: String
  def get_parent_links(tag) do
    tag["links"]["parent"]
  end

  @spec get_id(String_JSON) :: Integer
  def get_id(tag) do
    tag["id"]
  end

  @spec get_logo_filename(String_JSON) :: String
  def get_logo_filename(tag) do
    cdn_route = "http://cdn.bleacherreport.net/images/team_logos/164x164/"
    image = cdn_route <> tag["logo_filename"]
    {:ok, response} = HTTPoison.get(image, [timeout: 15_000])
    case response.status_code do
      200 ->
        cdn_route <> tag["logo_filename"]
      _ -> "http://www.iamjasonso.com/img/teamstream-thumbnail.jpg"
    end
  end


  @spec get_all_options(list, integer, list) :: List
  def get_all_options(list_of_tags, amount_of_options, result) when amount_of_options <= 1 do
    result = result ++ [hd(list_of_tags)]
    result
    |> filter_options([])
  end
  def get_all_options(list_of_tags, amount_of_options, result) do
    result = result ++ [hd(list_of_tags)]
    get_all_options(tl(list_of_tags), amount_of_options - 1, result)
  end


  @spec filter_options(list, list) :: List
  def filter_options(list_of_lists, filtered_options) when tl(list_of_lists) == [] do
    result = TagWorth.check_worth((hd(list_of_lists))["permalink"])
    case result do
      "not good enough" -> filtered_options
      _ -> filtered_options ++ [get_fields(hd(list_of_lists))]
    end
  end
  def filter_options(list_of_lists, filtered_options) do
    result = TagWorth.check_worth((hd(list_of_lists))["permalink"])
    case result do
      "not good enough" -> filtered_options = filtered_options ++ []
      _ -> filtered_options = filtered_options ++ [get_fields(hd(list_of_lists))]
    end
    filter_options(tl(list_of_lists), filtered_options)
  end

end
