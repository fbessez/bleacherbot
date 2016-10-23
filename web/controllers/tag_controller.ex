defmodule Bleacherbot.TagController do
  use Bleacherbot.Web, :controller

  #alias Bleacherbot.Tag

  def index(conn, %{"tags" => params, "r" => "parent"}) do
    origin = BleacherBot.GetTags.fetch_tags(params)
    parent_url = hd(origin).links.tag_parent
    tags = BleacherBot.GetTags.fetch_tags(nil, parent_url)
    render(conn, "index.json", tags: tags)
  end

  def index(conn, %{"tags" => params}) do
    tags = BleacherBot.GetTags.fetch_tags(params)
    render(conn, "index.json", tags: tags)
  end

  def index(conn, _) do
    conn
    |> send_resp(422, "tag input is required")
  end


  # def create(conn, %{"tag" => tag_params}) do
  #   changeset = Tag.changeset(%Tag{}, tag_params)

  #   case Repo.insert(changeset) do
  #     {:ok, tag} ->
  #       conn
  #       |> put_status(:created)
  #       |> put_resp_header("location", tag_path(conn, :show, tag))
  #       |> render("show.json", tag: tag)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Bleacherbot.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  def show(conn, %{"id" => input}) do
    tag = BleacherBot.GetTags.fetch_tags(input)
    render(conn, "show.json", tag: tag)
  end

  # def update(conn, %{"id" => input, "tag" => tag_params}) do
  #   tag = BleacherBot.GetTags.fetch_tags(input)
  #   changeset = Tag.changeset(tag, tag_params)

  #   case Repo.update(changeset) do
  #     {:ok, tag} ->
  #       render(conn, "show.json", tag: tag)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Bleacherbot.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => input}) do
  #   tag = BleacherBot.GetTags.fetch_tags(input)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(tag)

  #   send_resp(conn, :no_content, "")
  # end
end
