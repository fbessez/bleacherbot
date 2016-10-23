defmodule Bleacherbot.TagTest do
  use Bleacherbot.ModelCase

  alias Bleacherbot.Tag

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Tag.changeset(%Tag{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Tag.changeset(%Tag{}, @invalid_attrs)
    refute changeset.valid?
  end
end


defmodule BleacherBot.TagWorthTest do
  use Bleacherbot.ModelCase

  alias BleacherBot.TagWorth

  test "fetch_response/1 with valid unique name" do
    response = TagWorth.fetch_response("lebron-james")
    assert response.status_code === 200
  end

  test "fetch_response/1 with invalid unique name" do
    response = TagWorth.fetch_response("fabien-bessez")
    assert response.status_code === 503
  end

  test "fetch_response/1 with empty string unique name" do
    response = TagWorth.fetch_response("")
    content_length = hd(tl(tl(tl(tl(tl(tl(tl(tl(response.headers))))))))) # {"Content-Length", "239"}
    {str, int} = content_length
    assert int < 250
  end
  
  test "check_worth/1 with valid unique name and a tracklist length > 8" do
    verified? = TagWorth.check_worth("lebron-james")
    assert verified? === "good enough"
  end

  test "check_worth/1 with invalid unique name or valid unique name with tracklist length <= 8" do
    verified1 = TagWorth.check_worth("larry-bird")
    verified2 = TagWorth.check_worth("fabien-bessez")
    verified3 = TagWorth.check_worth("")
    assert verified1 === "not good enough"
    assert verified2 === "not good enough"
    assert verified3 === "not good enough"
  end

end


defmodule BleacherBot.GetTagsTest do
  use Bleacherbot.ModelCase

  alias BleacherBot.GetTags

  test "fetch_response/2 when url is nil" do
    response = BleacherBot.GetTags.fetch_response("lebron-james", nil)
    assert response.status_code === 200
  end

  test "fetch_response/2 when url is not nil but invalid" do
    response = BleacherBot.GetTags.fetch_response("lebron-james", "http://google.com")
    assert response.status_code === 301
  end

  test "fetch_response/2 when url is not nil but valid" do
    response = BleacherBot.GetTags.fetch_response("lebron-james", "http://tags.bleacherreport.com/tags.json?q=kyrie")
    assert response.status_code === 200
  end

  test "parse_response/1 when body is empty" do
    response = GetTags.fetch_response("fabien-bessez", nil)
    response = GetTags.get_body(response)
    assert response === "invalid input"
  end

  test "fetch_tags/2 when input is valid and url is nil" do
    data = GetTags.fetch_tags("kyrie-irvin")
    assert (length data) >= 1
  end

  test "fetch_tags/2 when input is invalid (no options) and url is nil" do
    data = GetTags.fetch_tags("fabien-bessez")
    assert data === "invalid input"
  end

end


