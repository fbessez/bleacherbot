defmodule Bleacherbot.TagView do
  use Bleacherbot.Web, :view

  def render("index.json", %{tags: tags}) do
    %{tags: tags}
    #render_many(tags, Bleacherbot.TagView, "tag.json")
  end

  def render("show.json", params) do
    %{"tags": params.tag}
    #%{data: render_one(tag, Bleacherbot.TagView, "tag.json")}
  end

  def render("tag.json", %{tag: tag}) do
    %{id: tag}
  end
end
