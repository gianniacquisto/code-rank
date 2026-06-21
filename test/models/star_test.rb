require "test_helper"

class StarTest < ActiveSupport::TestCase
  test "star should be valid with user and technology" do
    user = users(:one)
    technology = technologies(:django)
    star = Star.new(user: user, technology: technology, starred: true)
    assert star.valid?
  end

  test "star should require user" do
    technology = technologies(:django)
    star = Star.new(technology: technology, starred: true)
    assert_not star.valid?
    assert_includes star.errors[:user_id], "can't be blank"
  end

  test "star should require technology" do
    user = users(:one)
    star = Star.new(user: user, starred: true)
    assert_not star.valid?
    assert_includes star.errors[:technology_id], "can't be blank"
  end

  test "user should not be able to star the same technology twice" do
    user = users(:one)
    technology = technologies(:rails)
    # rails already has a star fixture for user :one, so this should fail
    duplicate = Star.new(user: user, technology: technology, starred: true)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "already starred"
  end
end
