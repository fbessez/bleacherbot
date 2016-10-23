
defmodule Bleacherbot.TrackController do
  use Bleacherbot.Web, :controller

  alias Bleacherbot.Track

  def index(conn, %{"permalinks" => params}) do
    tracks = BleacherBot.Djay.fetch_tracks(params)
    render(conn, "index.json", tracks: tracks)
  end

  def index(conn, _) do
    conn
    |> send_resp(422, "A permalink is required!")
  end

  def create(conn, %{"track" => track_params}) do
    changeset = Track.changeset(%Track{}, track_params)

    case Repo.insert(changeset) do
      {:ok, track} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", track_path(conn, :show, track))
        |> render("show.json", track: track)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Bleacherbot.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => unique_name}) do
    track = BleacherBot.Djay.fetch_tracks(unique_name)
    render(conn, "show.json", track: track)
  end

  # def update(conn, %{"id" => unique_name, "track" => track_params}) do
  #   track = BleacherBot.Djay.fetch_tracks(unique_name)
  #   changeset = Track.changeset(track, track_params)

  #   case Repo.update(changeset) do
  #     {:ok, track} ->
  #       render(conn, "show.json", track: track)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Bleacherbot.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => unique_name}) do
  #   track = BleacherBot.Djay.fetch_tracks(unique_name)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(track)

  #   send_resp(conn, :no_content, "")
  # end
end
