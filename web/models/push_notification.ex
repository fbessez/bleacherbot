defmodule Bleacherbot.PushNotification do
  use Bleacherbot.Web, :model
  @moduledoc """
  """

  schema "pushnotifications" do

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

defmodule BleacherBot.LastPush do
  @moduledoc """
  # This module will get the last push notification for
  # the unique_name that it was given
  # This is used when last push notification button is pressed
  """

  @spec get_N_pushes(String_JSON, Integer, List) :: List 
  def get_N_pushes(body, _, _) when body == [], do: "Invalid permalink"
  def get_N_pushes(_, n, _) when n > 25, do: "Max push notifications is 25"
  def get_N_pushes(body, n, list_of_pushes) when n <= 1 do
    list_of_pushes ++ [parse_response(body)]
  end
  def get_N_pushes(body, n, list_of_pushes) do
    list_of_pushes = list_of_pushes ++ [parse_response(body)]
    get_N_pushes(tl(body), n - 1, list_of_pushes)
  end

  @spec fetch_pushes(String, Integer) :: Poison.decode!
  def fetch_pushes(unique_name, n \\ 1) do
    unique_name
    |> fetch_response
    |> get_body(n)
  end

  @spec fetch_response(String) :: HTTPoison.response!
  def fetch_response(unique_name) do
    url = url(unique_name)
    {:ok, response} = HTTPoison.get(url, [timeout: 15_000])
    response
  end

  @spec get_body(HTTPoison.response!, Integer) :: String_JSON
  def get_body(response, n) do
    response
    |> Map.from_struct
    |> Map.fetch!(:body)
    |> Poison.decode! # body is made here
    |> get_N_pushes(n, [])
  end

  @spec parse_response(String_JSON) :: String_JSON
  def parse_response(body), do: hd(body)

  @spec url(String) :: String
  def url(unique_name) do
    "#{System.get_env "PUSHAPI"}/api/v1/push_notifications?tags=#{unique_name}"
  end
end






