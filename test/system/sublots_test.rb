require "application_system_test_case"

class SublotsTest < ApplicationSystemTestCase
  setup do
    @sublot = sublots(:one)
  end

  test "visiting the index" do
    visit sublots_url
    assert_selector "h1", text: "Sublots"
  end

  test "should create sublot" do
    visit sublots_url
    click_on "New sublot"

    fill_in "Lot", with: @sublot.lot_id
    fill_in "Name", with: @sublot.name
    fill_in "Position", with: @sublot.position
    click_on "Create Sublot"

    assert_text "Sublot was successfully created"
    click_on "Back"
  end

  test "should update Sublot" do
    visit sublot_url(@sublot)
    click_on "Edit this sublot", match: :first

    fill_in "Lot", with: @sublot.lot_id
    fill_in "Name", with: @sublot.name
    fill_in "Position", with: @sublot.position
    click_on "Update Sublot"

    assert_text "Sublot was successfully updated"
    click_on "Back"
  end

  test "should destroy Sublot" do
    visit sublot_url(@sublot)
    click_on "Destroy this sublot", match: :first

    assert_text "Sublot was successfully destroyed"
  end
end
