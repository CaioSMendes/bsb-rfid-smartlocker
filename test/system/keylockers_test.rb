require "application_system_test_case"

class KeylockersTest < ApplicationSystemTestCase
  setup do
    @keylocker = keylockers(:one)
  end

  test "visiting the index" do
    visit keylockers_url
    assert_selector "h1", text: "Keylockers"
  end

  test "should create keylocker" do
    visit keylockers_url
    click_on "New keylocker"

    fill_in "Ipaddress", with: @keylocker.ipAddress
    fill_in "Namedevice", with: @keylocker.nameDevice
    fill_in "Owner", with: @keylocker.owner
    fill_in "Status", with: @keylocker.status
    click_on "Create Keylocker"

    assert_text "Keylocker was successfully created"
    click_on "Back"
  end

  test "should update Keylocker" do
    visit keylocker_url(@keylocker)
    click_on "Edit this keylocker", match: :first

    fill_in "Ipaddress", with: @keylocker.ipAddress
    fill_in "Namedevice", with: @keylocker.nameDevice
    fill_in "Owner", with: @keylocker.owner
    fill_in "Status", with: @keylocker.status
    click_on "Update Keylocker"

    assert_text "Keylocker was successfully updated"
    click_on "Back"
  end

  test "should destroy Keylocker" do
    visit keylocker_url(@keylocker)
    click_on "Destroy this keylocker", match: :first

    assert_text "Keylocker was successfully destroyed"
  end
end
