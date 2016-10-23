defmodule Bleacherbot.ScoreView do
  use Bleacherbot.Web, :view

  def render("index.json", %{scores: scores}) do
    %{games: scores}
   #%{games: render_many(scores, Bleacherbot.ScoreView, "score.json")}
  end

  def render("show.json", %{score: score}) do
    %{games: render_one(score, Bleacherbot.ScoreView, "score.json")}
  end

  def render("score.json", %{score: score}) do
    score
  end
end
