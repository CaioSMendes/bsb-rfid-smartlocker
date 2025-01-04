require "application_system_test_case"

class EmployeesTest < ApplicationSystemTestCase
  setup do
    @employee = employees(:one)
  end

  test "visiting the index" do
    visit employees_url
    assert_selector "h1", text: "Employees"
  end

  test "should create employee" do
    visit employees_url
    click_on "New employee"

    fill_in "Pin", with: @employee.PIN
    fill_in "Cardrfid", with: @employee.cardRFID
    fill_in "Companyid", with: @employee.companyID
    fill_in "Function", with: @employee.function
    fill_in "Lastname", with: @employee.lastname
    fill_in "Name", with: @employee.name
    fill_in "Phone", with: @employee.phone
    fill_in "Pswdsmartlocker", with: @employee.pswdSmartlocker
    fill_in "Status", with: @employee.status
    click_on "Create Employee"

    assert_text "Employee was successfully created"
    click_on "Back"
  end

  test "should update Employee" do
    visit employee_url(@employee)
    click_on "Edit this employee", match: :first

    fill_in "Pin", with: @employee.PIN
    fill_in "Cardrfid", with: @employee.cardRFID
    fill_in "Companyid", with: @employee.companyID
    fill_in "Function", with: @employee.function
    fill_in "Lastname", with: @employee.lastname
    fill_in "Name", with: @employee.name
    fill_in "Phone", with: @employee.phone
    fill_in "Pswdsmartlocker", with: @employee.pswdSmartlocker
    fill_in "Status", with: @employee.status
    click_on "Update Employee"

    assert_text "Employee was successfully updated"
    click_on "Back"
  end

  test "should destroy Employee" do
    visit employee_url(@employee)
    click_on "Destroy this employee", match: :first

    assert_text "Employee was successfully destroyed"
  end
end
