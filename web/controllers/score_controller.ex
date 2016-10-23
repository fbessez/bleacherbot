defmodule Bleacherbot.ScoreController do
  use Bleacherbot.Web, :controller

  alias Bleacherbot.Score



  def index(conn, %{"team" => team}) do
    scores = BleacherBot.NewScoresInfo.fetch_scores(nil, team)
    #Repo.all(Score)
    render(conn, "index.json", scores: scores)
  end

  def index(conn, %{"league" => league}) do
    scores = BleacherBot.NewScoresInfo.fetch_scores(league, nil)
    #Repo.all(Score)
    render(conn, "index.json", scores: scores)
  end

  def index(conn, _) do
    conn
    |> send_resp(422, "desired league or team is required")
  end

  def create(conn, %{"score" => score_params}) do
    changeset = Score.changeset(%Score{}, score_params)

    case Repo.insert(changeset) do
      {:ok, score} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", score_path(conn, :show, score))
        |> render("show.json", score: score)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Bleacherbot.ChangesetView, "error.json", changeset: changeset)
    end
  end


  def show(conn, %{"id" => league}) do
    # this is only becuase the current leagues I know are MLB, NFL, NHL, NBA...
    if ((String.length league) <= 3) do
      league = String.upcase(league)
      score = BleacherBot.NewScoresInfo.fetch_scores(league, nil)
    else
      team = String.downcase(league)
      score = BleacherBot.NewScoresInfo.fetch_scores(nil, team)
    end
    render(conn, "show.json", score: score)
  end

  # def update(conn, %{"id" => id, "score" => score_params}) do
  #   score = Repo.get!(Score, id)
  #   changeset = Score.changeset(score, score_params)

  #   case Repo.update(changeset) do
  #     {:ok, score} ->
  #       render(conn, "show.json", score: score)
  #     {:error, changeset} ->
  #       conn
  #       |> put_status(:unprocessable_entity)
  #       |> render(Bleacherbot.ChangesetView, "error.json", changeset: changeset)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   score = Repo.get!(Score, id)

  #   # Here we use delete! (with a bang) because we expect
  #   # it to always work (and if it does not, it will raise).
  #   Repo.delete!(score)

  #   send_resp(conn, :no_content, "")
  # end
end
