
defmodule Bleacherbot.TrackView do
  use Bleacherbot.Web, :view

  def render("index.json", %{tracks: tracks}) do
    %{"tracks": tracks}
    #render_many(tracks, Bleacherbot.TrackView, "track.json")
  end

  def render("show.json", params) do
    %{"tracks": params.track}
    #%{data: render_one(track, Bleacherbot.TrackView, "track.json")}
  end

  def render("track.json", %{track: track}) do
    %{id: track}
  end
end
